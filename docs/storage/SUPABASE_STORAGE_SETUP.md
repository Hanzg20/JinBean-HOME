# Supabase Storage 设置指南

## 步骤 1: 创建 Storage Bucket

1. 登录 Supabase Dashboard: https://app.supabase.com
2. 选择你的项目
3. 点击左侧菜单 **Storage**
4. 点击 **New bucket**
5. 创建以下 buckets:
   - `service-images` - 存放服务主图
   - `service-detail-images` - 存放服务详情图片
   - `provider-avatars` - 存放服务商头像

## 步骤 2: 设置 Bucket 权限

对于每个 bucket，设置以下策略：

### Public Read Policy (允许所有人读取)

```sql
-- Service Images Bucket - Public Read
CREATE POLICY "Public read access for service images"
ON storage.objects FOR SELECT
USING (bucket_id = 'service-images');

-- Service Detail Images Bucket - Public Read
CREATE POLICY "Public read access for service detail images"
ON storage.objects FOR SELECT
USING (bucket_id = 'service-detail-images');

-- Provider Avatars Bucket - Public Read
CREATE POLICY "Public read access for provider avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'provider-avatars');
```

### Authenticated Upload Policy (认证用户可上传)

```sql
-- Service Images - Authenticated Upload
CREATE POLICY "Authenticated users can upload service images"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'service-images'
    AND auth.role() = 'authenticated'
);

-- Service Detail Images - Authenticated Upload
CREATE POLICY "Authenticated users can upload service detail images"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'service-detail-images'
    AND auth.role() = 'authenticated'
);

-- Provider Avatars - Authenticated Upload
CREATE POLICY "Authenticated users can upload provider avatars"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'provider-avatars'
    AND auth.role() = 'authenticated'
);
```

## 步骤 3: 在 Flutter 中上传图片

### 安装依赖

```yaml
# pubspec.yaml
dependencies:
  image_picker: ^1.0.7  # 选择图片
  supabase_flutter: ^2.0.0  # 已安装
```

### 创建图片上传服务

```dart
// lib/core/services/image_upload_service.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ImageUploadService {
  static final _supabase = Supabase.instance.client;
  static final _picker = ImagePicker();

  /// 从相册选择图片
  static Future<XFile?> pickImageFromGallery() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
  }

  /// 从相机拍照
  static Future<XFile?> pickImageFromCamera() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
  }

  /// 上传图片到 Supabase Storage
  ///
  /// [file] - 要上传的图片文件
  /// [bucket] - 存储桶名称 ('service-images', 'service-detail-images', 'provider-avatars')
  /// [folder] - 可选的文件夹路径
  ///
  /// 返回: 上传后的公开URL
  static Future<String> uploadImage({
    required File file,
    required String bucket,
    String? folder,
  }) async {
    try {
      // 生成唯一文件名
      final String fileExt = path.extension(file.path);
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final String filePath = folder != null ? '$folder/$fileName' : fileName;

      // 上传文件
      await _supabase.storage.from(bucket).upload(
        filePath,
        file,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
        ),
      );

      // 获取公开URL
      final String publicUrl = _supabase.storage
          .from(bucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('图片上传失败: $e');
    }
  }

  /// 删除图片
  static Future<void> deleteImage({
    required String bucket,
    required String filePath,
  }) async {
    try {
      await _supabase.storage.from(bucket).remove([filePath]);
    } catch (e) {
      throw Exception('图片删除失败: $e');
    }
  }

  /// 批量上传图片
  static Future<List<String>> uploadMultipleImages({
    required List<File> files,
    required String bucket,
    String? folder,
  }) async {
    final List<String> urls = [];

    for (final file in files) {
      final url = await uploadImage(
        file: file,
        bucket: bucket,
        folder: folder,
      );
      urls.add(url);
    }

    return urls;
  }
}
```

## 步骤 4: 使用示例

### 上传服务图片

```dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// 选择并上传图片
Future<void> uploadServiceImage(String serviceId) async {
  // 1. 选择图片
  final XFile? image = await ImageUploadService.pickImageFromGallery();

  if (image == null) {
    print('未选择图片');
    return;
  }

  // 2. 上传到 Supabase
  try {
    final String imageUrl = await ImageUploadService.uploadImage(
      file: File(image.path),
      bucket: 'service-images',
      folder: 'services/$serviceId',
    );

    print('图片上传成功: $imageUrl');

    // 3. 更新数据库
    await Supabase.instance.client
        .from('services')
        .update({'images_url': [imageUrl]})
        .eq('id', serviceId);

  } catch (e) {
    print('上传失败: $e');
  }
}
```

### 批量上传服务详情图片

```dart
Future<void> uploadServiceDetailImages(String serviceDetailId) async {
  // 1. 选择多张图片
  final ImagePicker picker = ImagePicker();
  final List<XFile> images = await picker.pickMultiImage(
    maxWidth: 1920,
    maxHeight: 1080,
    imageQuality: 85,
  );

  if (images.isEmpty) {
    print('未选择图片');
    return;
  }

  // 2. 批量上传
  try {
    final List<String> imageUrls = await ImageUploadService.uploadMultipleImages(
      files: images.map((e) => File(e.path)).toList(),
      bucket: 'service-detail-images',
      folder: 'details/$serviceDetailId',
    );

    print('上传成功: ${imageUrls.length} 张图片');

    // 3. 更新数据库
    await Supabase.instance.client
        .from('service_details')
        .update({'images_url': imageUrls})
        .eq('id', serviceDetailId);

  } catch (e) {
    print('批量上传失败: $e');
  }
}
```

## 步骤 5: 图片URL格式

上传后的图片URL格式为：
```
https://[your-project-ref].supabase.co/storage/v1/object/public/[bucket]/[path]/[filename]
```

示例：
```
https://abcdefghijklmn.supabase.co/storage/v1/object/public/service-images/services/123/1234567890.jpg
```

## 步骤 6: 最佳实践

1. **图片压缩**: 上传前压缩图片，减少存储成本
2. **文件命名**: 使用时间戳或UUID确保唯一性
3. **文件夹组织**: 按服务ID或类别组织文件
4. **缓存控制**: 设置适当的缓存时间
5. **错误处理**: 处理网络错误和存储限制

## 存储成本

Supabase Storage 免费额度：
- **存储空间**: 1GB
- **带宽**: 2GB/月
- **请求数**: 50,000/月

超出部分收费：
- 存储: $0.021/GB/月
- 带宽: $0.09/GB

## 故障排查

### 上传失败
- 检查 bucket 是否存在
- 检查用户是否已认证
- 检查文件大小限制（默认50MB）
- 检查 Storage 策略权限

### 图片无法显示
- 确认 bucket 设置为 Public
- 检查 Public Read Policy 是否正确
- 验证 URL 格式是否正确
