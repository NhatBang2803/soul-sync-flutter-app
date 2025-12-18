import 'dart:io';
import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// Service để upload và quản lý media trên Cloudinary
class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  final Dio _dio = Dio();

  /// Upload file audio (MP3) lên Cloudinary
  /// Returns: Map chứa secure_url và public_id
  Future<Map<String, dynamic>> uploadAudio(File file, {String? fileName}) async {
    final cloudName = AppConfig.cloudinaryCloudName;
    final uploadPreset = AppConfig.cloudinaryUploadPreset;
    
    if (cloudName.isEmpty) {
      throw Exception('Cloudinary cloud name is not configured');
    }

    final url = 'https://api.cloudinary.com/v1_1/$cloudName/raw/upload';
    
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName ?? file.path.split('/').last,
      ),
      'upload_preset': uploadPreset,
      'resource_type': 'raw',
      'folder': 'soulsync/songs',
    });

    try {
      final response = await _dio.post(url, data: formData);
      
      if (response.statusCode == 200) {
        return {
          'secure_url': response.data['secure_url'],
          'public_id': response.data['public_id'],
          'duration': response.data['duration'],
          'format': response.data['format'],
          'bytes': response.data['bytes'],
        };
      } else {
        throw Exception('Upload failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Upload error: ${e.message}');
    }
  }

  /// Upload hình ảnh (cover art) lên Cloudinary
  Future<Map<String, dynamic>> uploadImage(File file, {String? fileName, String folder = 'covers'}) async {
    final cloudName = AppConfig.cloudinaryCloudName;
    final uploadPreset = AppConfig.cloudinaryUploadPreset;
    
    if (cloudName.isEmpty) {
      throw Exception('Cloudinary cloud name is not configured');
    }

    final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
    
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName ?? file.path.split('/').last,
      ),
      'upload_preset': uploadPreset,
      'folder': 'soulsync/$folder',
      // Auto optimize images
      'transformation': 'c_fill,w_500,h_500,q_auto',
    });

    try {
      final response = await _dio.post(url, data: formData);
      
      if (response.statusCode == 200) {
        return {
          'secure_url': response.data['secure_url'],
          'public_id': response.data['public_id'],
          'width': response.data['width'],
          'height': response.data['height'],
        };
      } else {
        throw Exception('Upload failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Upload error: ${e.message}');
    }
  }

  /// Upload từ URL (ví dụ: từ internet)
  Future<Map<String, dynamic>> uploadFromUrl(String sourceUrl, {String type = 'image'}) async {
    final cloudName = AppConfig.cloudinaryCloudName;
    final uploadPreset = AppConfig.cloudinaryUploadPreset;
    
    final resourceType = type == 'audio' ? 'raw' : 'image';
    final url = 'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload';
    
    final formData = FormData.fromMap({
      'file': sourceUrl,
      'upload_preset': uploadPreset,
      'folder': 'soulsync/${type}s',
    });

    try {
      final response = await _dio.post(url, data: formData);
      
      if (response.statusCode == 200) {
        return {
          'secure_url': response.data['secure_url'],
          'public_id': response.data['public_id'],
        };
      } else {
        throw Exception('Upload failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Upload error: ${e.message}');
    }
  }

  /// Xóa file trên Cloudinary (cần API Secret - chỉ dùng trên backend)
  /// Lưu ý: Unsigned preset không hỗ trợ xóa, cần signed request
  Future<void> deleteFile(String publicId) async {
    // This requires API Secret - should be done on backend
    throw UnimplementedError(
      'Delete requires API Secret. Implement on backend or use signed uploads.',
    );
  }

  /// Tạo URL transform cho image
  static String getTransformedImageUrl(String publicId, {
    int? width,
    int? height,
    String? crop,
    String? quality,
  }) {
    final cloudName = AppConfig.cloudinaryCloudName;
    final transforms = <String>[];
    
    if (width != null) transforms.add('w_$width');
    if (height != null) transforms.add('h_$height');
    if (crop != null) transforms.add('c_$crop');
    if (quality != null) transforms.add('q_$quality');
    
    final transformString = transforms.isNotEmpty ? '${transforms.join(',')}/' : '';
    
    return 'https://res.cloudinary.com/$cloudName/image/upload/$transformString$publicId';
  }

  /// Tạo URL thumbnail cho cover art
  static String getThumbnailUrl(String publicId, {int size = 150}) {
    return getTransformedImageUrl(
      publicId,
      width: size,
      height: size,
      crop: 'fill',
      quality: 'auto',
    );
  }

  /// Tạo URL audio streaming
  static String getAudioStreamUrl(String publicId) {
    final cloudName = AppConfig.cloudinaryCloudName;
    return 'https://res.cloudinary.com/$cloudName/raw/upload/$publicId';
  }
}
