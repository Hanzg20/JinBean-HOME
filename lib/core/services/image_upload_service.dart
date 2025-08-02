import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();
  factory ImageUploadService() => _instance;
  ImageUploadService._internal();

  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  /// Upload service images to Supabase Storage
  Future<List<String>> uploadServiceImages({
    required String serviceId,
    required String providerId,
    int maxImages = 5,
    int maxSize = 1024, // Max width/height in pixels
    int quality = 85, // JPEG quality
  }) async {
    try {
      // Pick images from gallery or camera
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxSize.toDouble(),
        maxHeight: maxSize.toDouble(),
        imageQuality: quality,
      );

      if (images.isEmpty) return [];

      List<String> uploadedUrls = [];

      for (int i = 0; i < images.length && i < maxImages; i++) {
        final XFile image = images[i];

        // Compress and process image
        final File processedImage =
            await _processImage(image, maxSize, quality);

        // Generate unique filename
        final String fileName = '${_uuid.v4()}_${path.basename(image.path)}';
        final String filePath = 'services/$providerId/$serviceId/$fileName';

        // Upload to Supabase Storage
        final String url = await _uploadToStorage(processedImage, filePath);
        uploadedUrls.add(url);
      }

      return uploadedUrls;
    } catch (e) {
      print('[ImageUploadService] Error uploading images: $e');
      rethrow;
    }
  }

  /// Process and compress image
  Future<File> _processImage(XFile image, int maxSize, int quality) async {
    try {
      final Uint8List bytes = await image.readAsBytes();
      final img.Image? originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if needed
      img.Image resizedImage = originalImage;
      if (originalImage.width > maxSize || originalImage.height > maxSize) {
        resizedImage = img.copyResize(
          originalImage,
          width: maxSize,
          height: maxSize,
          interpolation: img.Interpolation.linear,
        );
      }

      // Convert to JPEG and compress
      final Uint8List compressedBytes =
          img.encodeJpg(resizedImage, quality: quality);

      // Save to temporary file
      final String tempPath = '${Directory.systemTemp.path}/${_uuid.v4()}.jpg';
      final File tempFile = File(tempPath);
      await tempFile.writeAsBytes(compressedBytes);

      return tempFile;
    } catch (e) {
      print('[ImageUploadService] Error processing image: $e');
      rethrow;
    }
  }

  /// Upload file to Supabase Storage
  Future<String> _uploadToStorage(File file, String filePath) async {
    try {
      final SupabaseClient client = Supabase.instance.client;

      // Upload file
      await client.storage.from('service-images').upload(filePath, file);

      // Get public URL
      final String publicUrl =
          client.storage.from('service-images').getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('[ImageUploadService] Error uploading to storage: $e');
      rethrow;
    }
  }

  /// Delete service images
  Future<void> deleteServiceImages(List<String> imageUrls) async {
    try {
      final SupabaseClient client = Supabase.instance.client;

      for (String url in imageUrls) {
        // Extract file path from URL
        final Uri uri = Uri.parse(url);
        final String filePath = uri.pathSegments.last;

        await client.storage.from('service-images').remove([filePath]);
      }
    } catch (e) {
      print('[ImageUploadService] Error deleting images: $e');
      rethrow;
    }
  }

  /// Get placeholder image URL for testing
  String getPlaceholderImageUrl({
    int width = 300,
    int height = 200,
    String text = 'Service Image',
  }) {
    // 使用picsum.photos替代via.placeholder.com，避免网络连接问题
    final int seed = text.hashCode;
    return 'https://picsum.photos/seed/$seed/$width/$height';
  }

  /// Get random image from Picsum for testing
  String getRandomTestImageUrl({
    int width = 300,
    int height = 200,
    int seed = 1,
  }) {
    return 'https://picsum.photos/seed/$seed/$width/$height';
  }
}
