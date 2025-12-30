import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Exception for image upload errors
class ImageUploadException implements Exception {
  final String message;
  final String? details;

  ImageUploadException(this.message, [this.details]);

  @override
  String toString() => details != null ? '$message: $details' : message;
}

class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();
  factory ImageUploadService() => _instance;
  ImageUploadService._internal();

  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  /// Pick a single image from camera or gallery
  /// Returns the XFile object or throws ImageUploadException
  Future<XFile?> pickSingleImage({
    required ImageSource source,
    int maxSize = 1024,
    int quality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxSize.toDouble(),
        maxHeight: maxSize.toDouble(),
        imageQuality: quality,
      );

      return image;
    } on Exception catch (e) {
      final errorMessage = _handleImagePickerError(e, source);
      AppLogger.error('[ImageUploadService] Error picking image: $errorMessage');
      throw ImageUploadException(errorMessage, e.toString());
    }
  }

  /// Pick multiple images from gallery
  /// Returns list of XFile objects or throws ImageUploadException
  Future<List<XFile>> pickMultipleImages({
    int maxImages = 5,
    int maxSize = 1024,
    int quality = 85,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxSize.toDouble(),
        maxHeight: maxSize.toDouble(),
        imageQuality: quality,
      );

      if (images.isEmpty) return [];

      // Limit to maxImages
      return images.take(maxImages).toList();
    } on Exception catch (e) {
      final errorMessage = _handleImagePickerError(e, ImageSource.gallery);
      AppLogger.error('[ImageUploadService] Error picking images: $errorMessage');
      throw ImageUploadException(errorMessage, e.toString());
    }
  }

  /// Upload service images to Supabase Storage
  Future<List<String>> uploadServiceImages({
    required String serviceId,
    required String providerId,
    int maxImages = 5,
    int maxSize = 1024, // Max width/height in pixels
    int quality = 85, // JPEG quality
  }) async {
    try {
      // Pick images from gallery
      final List<XFile> images = await pickMultipleImages(
        maxImages: maxImages,
        maxSize: maxSize,
        quality: quality,
      );

      if (images.isEmpty) return [];

      List<String> uploadedUrls = [];

      for (int i = 0; i < images.length; i++) {
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
    } on ImageUploadException {
      rethrow;
    } catch (e) {
      AppLogger.error('[ImageUploadService] Error uploading images: $e');
      throw ImageUploadException('Failed to upload images', e.toString());
    }
  }

  /// Upload a single image file to Supabase Storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadSingleImage({
    required XFile imageFile,
    required String storagePath,
    int maxSize = 1024,
    int quality = 85,
  }) async {
    try {
      // Compress and process image
      final File processedImage =
          await _processImage(imageFile, maxSize, quality);

      // Generate unique filename
      final String fileName = '${_uuid.v4()}_${path.basename(imageFile.path)}';
      final String filePath = '$storagePath/$fileName';

      // Upload to Supabase Storage
      final String url = await _uploadToStorage(processedImage, filePath);

      return url;
    } catch (e) {
      AppLogger.error('[ImageUploadService] Error uploading single image: $e');
      throw ImageUploadException('Failed to upload image', e.toString());
    }
  }

  /// Handle image picker errors and provide user-friendly messages
  String _handleImagePickerError(Exception error, ImageSource source) {
    final errorString = error.toString().toLowerCase();

    // iOS-specific permission errors
    if (Platform.isIOS) {
      if (errorString.contains('photo') ||
          errorString.contains('camera') ||
          errorString.contains('permission') ||
          errorString.contains('access')) {
        if (source == ImageSource.camera) {
          return 'Camera permission denied. Please enable camera access in Settings > JinBean > Camera.';
        } else {
          return 'Photo library permission denied. Please enable photo access in Settings > JinBean > Photos.';
        }
      }

      if (errorString.contains('cancel')) {
        return 'Image selection cancelled';
      }

      if (source == ImageSource.camera && errorString.contains('unavailable')) {
        return 'Camera is not available on this device';
      }
    }

    // Android-specific errors
    if (Platform.isAndroid) {
      if (errorString.contains('permission')) {
        if (source == ImageSource.camera) {
          return 'Camera permission denied. Please grant camera permission in app settings.';
        } else {
          return 'Storage permission denied. Please grant storage permission in app settings.';
        }
      }
    }

    // Generic errors
    if (errorString.contains('cancel')) {
      return 'Image selection cancelled';
    }

    return 'Failed to pick image. Please try again.';
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
      AppLogger.info('[ImageUploadService] Error processing image: $e');
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
      AppLogger.info('[ImageUploadService] Error uploading to storage: $e');
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
      AppLogger.info('[ImageUploadService] Error deleting images: $e');
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
