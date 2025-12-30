# iOS Image Upload Implementation Guide

> Version: 1.0
> Date: 2025-12-28
> Purpose: Complete guide for iOS image upload functionality

## 📋 Overview

This guide covers the complete implementation of image upload functionality with iOS-specific error handling and permission management.

## ✅ What Was Fixed

### 1. **Incomplete Camera/Gallery Implementation**
**Before:**
```dart
void _pickImageFromCamera() {
  // TODO: 实现相机拍照功能
  AppLogger.info('Camera functionality to be implemented');
}

void _pickImageFromGallery() {
  // TODO: 实现相册选择功能
  AppLogger.info('Gallery functionality to be implemented');
}
```

**After:**
- ✅ Full camera implementation with error handling
- ✅ Full gallery implementation with error handling
- ✅ Automatic image upload to Supabase storage
- ✅ iOS-specific permission error messages

### 2. **No Error Handling for iOS Permissions**
**Added:**
- iOS-specific permission denial messages
- User-friendly guidance to enable permissions in Settings
- Differentiated error messages for camera vs photo library access
- Platform-specific error detection (iOS/Android)

### 3. **Missing Single Image Upload Methods**
**Added to ImageUploadService:**
- `pickSingleImage()` - Pick from camera or gallery
- `uploadSingleImage()` - Upload a single image file
- `pickMultipleImages()` - Enhanced multi-image picker with better error handling

## 🎯 New Features

### ImageUploadService Enhancements

#### 1. Pick Single Image
```dart
final imageService = ImageUploadService();

// Pick from camera
final XFile? cameraImage = await imageService.pickSingleImage(
  source: ImageSource.camera,
  maxSize: 1024,
  quality: 85,
);

// Pick from gallery
final XFile? galleryImage = await imageService.pickSingleImage(
  source: ImageSource.gallery,
  maxSize: 1024,
  quality: 85,
);
```

#### 2. Upload Single Image
```dart
if (image != null) {
  final String imageUrl = await imageService.uploadSingleImage(
    imageFile: image,
    storagePath: 'reviews',  // Or 'profiles', 'services', etc.
    maxSize: 1024,
    quality: 85,
  );
  print('Uploaded to: $imageUrl');
}
```

#### 3. Pick Multiple Images
```dart
final List<XFile> images = await imageService.pickMultipleImages(
  maxImages: 5,
  maxSize: 1024,
  quality: 85,
);
```

### ImageUploadException

New exception class for better error handling:

```dart
try {
  final image = await imageService.pickSingleImage(source: ImageSource.camera);
} on ImageUploadException catch (e) {
  // User-friendly error message
  print(e.message);
  // Technical details
  print(e.details);
}
```

## 📱 iOS-Specific Error Messages

### Camera Permission Denied
```
Camera permission denied. Please enable camera access in Settings > JinBean > Camera.
```

### Photo Library Permission Denied
```
Photo library permission denied. Please enable photo access in Settings > JinBean > Photos.
```

### Camera Not Available
```
Camera is not available on this device
```

### User Cancelled
```
Image selection cancelled
```

## 🔧 iOS Configuration (Already Set Up)

### Info.plist Permissions

Located at: `ios/Runner/Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>JinBean needs access to the camera to take photos</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>JinBean needs to access the album to select pictures for uploading reviews.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>JinBean needs to save the picture to the album</string>
```

These are **already configured** and do not need to be changed.

## 📂 Supabase Storage Buckets

The following storage buckets are used:

| Bucket Name | Purpose | Example Path |
|-------------|---------|--------------|
| `service-images` | Service provider images | `services/{providerId}/{serviceId}/{filename}` |
| `reviews` | Review photos | `reviews/{filename}` |
| `profiles` | User avatars (future) | `profiles/{userId}/{filename}` |

### Create Storage Bucket (If Needed)

If the `reviews` bucket doesn't exist in your Supabase project:

1. Go to Supabase Dashboard → Storage
2. Click "Create Bucket"
3. Name: `reviews`
4. Public: ✅ Enable
5. File size limit: 5MB (recommended)
6. Allowed MIME types: `image/jpeg`, `image/png`, `image/webp`

## 🚀 Usage Examples

### Example 1: Review Image Upload Widget

The ImageUploadWidget now fully works with camera and gallery:

```dart
ImageUploadWidget(
  images: reviewImages,
  maxImages: 5,
  onImageAdded: (String imageUrl) {
    setState(() {
      reviewImages.add(imageUrl);
    });
  },
  onImageRemoved: (String imageUrl) {
    setState(() {
      reviewImages.remove(imageUrl);
    });
  },
)
```

### Example 2: Custom Image Picker

```dart
Future<void> uploadProfilePhoto() async {
  try {
    final imageService = ImageUploadService();

    // Pick from gallery
    final XFile? image = await imageService.pickSingleImage(
      source: ImageSource.gallery,
      maxSize: 512,  // Smaller size for avatars
      quality: 90,
    );

    if (image != null) {
      // Upload to profiles bucket
      final String avatarUrl = await imageService.uploadSingleImage(
        imageFile: image,
        storagePath: 'profiles/$userId',
        maxSize: 512,
        quality: 90,
      );

      // Update user profile
      await updateUserAvatar(avatarUrl);
    }
  } on ImageUploadException catch (e) {
    // Show error to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message)),
    );
  }
}
```

### Example 3: Batch Upload with Progress

```dart
Future<List<String>> uploadMultipleReviewImages() async {
  try {
    final imageService = ImageUploadService();

    // Pick up to 5 images
    final List<XFile> images = await imageService.pickMultipleImages(
      maxImages: 5,
      maxSize: 1024,
      quality: 85,
    );

    if (images.isEmpty) {
      return [];
    }

    List<String> uploadedUrls = [];

    for (int i = 0; i < images.length; i++) {
      final image = images[i];

      // Show progress
      print('Uploading ${i + 1}/${images.length}...');

      final String url = await imageService.uploadSingleImage(
        imageFile: image,
        storagePath: 'reviews',
        maxSize: 1024,
        quality: 85,
      );

      uploadedUrls.add(url);
    }

    return uploadedUrls;
  } on ImageUploadException catch (e) {
    print('Upload failed: ${e.message}');
    rethrow;
  }
}
```

## 🛠️ Testing on iOS

### Test Checklist

- [ ] **Camera Access**
  1. Launch app on iOS device/simulator
  2. Tap "Add Photo" → "Camera"
  3. On first use, should show permission dialog
  4. Grant permission and verify camera opens
  5. Take photo and verify it uploads successfully

- [ ] **Photo Library Access**
  1. Tap "Add Photo" → "Gallery"
  2. On first use, should show permission dialog
  3. Grant permission and verify gallery opens
  4. Select photo and verify it uploads successfully

- [ ] **Permission Denial**
  1. Go to Settings → JinBean → Photos → Select "None"
  2. Try to pick image
  3. Verify user-friendly error message appears
  4. Verify message instructs user to go to Settings

- [ ] **Camera Unavailable (Simulator)**
  1. Run on iOS Simulator (no camera)
  2. Try to use camera
  3. Verify appropriate error message

- [ ] **User Cancellation**
  1. Open camera/gallery picker
  2. Cancel without selecting
  3. Verify no error is shown (silent cancellation)

## 📊 Error Handling Flow

```
User Taps "Camera"
       ↓
pickSingleImage(source: camera)
       ↓
  iOS Permission Check
       ↓
   ┌─────┴─────┐
   │           │
Granted    Denied
   │           │
   ↓           ↓
Open     Show Error:
Camera   "Camera permission denied.
   │     Please enable camera access in
   │     Settings > JinBean > Camera."
   │
   ↓
User Takes Photo / Cancels
   │
   ├─ Photo → uploadSingleImage()
   │            ↓
   │         Success → onImageAdded(url)
   │            ↓
   │         Show: "Photo added successfully"
   │
   └─ Cancel → (silent, no error)
```

## 🎨 UI Feedback

### Success Message
```dart
Get.snackbar(
  'Success',
  'Photo added successfully',
  snackPosition: SnackPosition.BOTTOM,
  duration: const Duration(seconds: 2),
);
```

### Error Message
```dart
Get.snackbar(
  'Error',
  e.message,  // iOS-specific error message
  snackPosition: SnackPosition.BOTTOM,
  backgroundColor: Colors.red.withValues(alpha: 0.8),
  colorText: Colors.white,
  duration: const Duration(seconds: 3),
);
```

## 🔍 Debugging Tips

### Enable Detailed Logging

All image operations are logged with AppLogger:

```dart
AppLogger.info('[ImageUploadWidget] Image uploaded from camera: $imageUrl');
AppLogger.error('[ImageUploadService] Error picking image: $errorMessage');
```

### Common iOS Issues

1. **Permission Denied Even After Granting**
   - Solution: Restart the app to reload permissions

2. **Image Upload Slow on iOS**
   - Cause: Large image processing
   - Solution: Already optimized with maxSize=1024, quality=85

3. **Images Not Showing in Gallery**
   - Check Supabase bucket is public
   - Verify URL is correct in database

4. **Camera Black Screen on Simulator**
   - Expected: Simulator has no camera
   - Test on real device instead

## 📚 Related Files

| File | Purpose |
|------|---------|
| [image_upload_service.dart](../../lib/core/services/image_upload_service.dart) | Core image upload logic |
| [image_upload_widget.dart](../../lib/features/customer/reviews/presentation/widgets/image_upload_widget.dart) | Review image UI |
| [provider_registration_page.dart](../../lib/features/provider/plugins/provider_registration/provider_registration_page.dart) | Provider cert upload |
| [Info.plist](../../ios/Runner/Info.plist) | iOS permissions |

## 🚨 Known Limitations

1. **No Multi-Select from Camera**
   - Camera only supports single image capture
   - Use gallery for multi-select

2. **Image Compression**
   - All images are compressed to max 1024px
   - Quality is 85% JPEG by default
   - Reduces upload time and storage costs

3. **No Video Support**
   - Currently only supports images (JPEG, PNG)
   - Video upload can be added in future

## 📝 Future Enhancements

- [ ] Add image cropping before upload
- [ ] Support for video uploads
- [ ] Add upload progress indicator
- [ ] Implement client-side image validation (min/max dimensions)
- [ ] Add watermarking for service images
- [ ] Support for HEIC format (iOS native)

---

**Last Updated:** 2025-12-28
**Implemented By:** iOS Image Upload Fix - P0 Task
