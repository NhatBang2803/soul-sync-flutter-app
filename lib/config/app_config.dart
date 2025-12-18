import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // Cloudinary
  static String get cloudinaryCloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get cloudinaryUploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'soulsync';
  static String get cloudinaryApiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  
  // Cloudinary URLs
  static String get cloudinaryBaseUrl => 'https://res.cloudinary.com/$cloudinaryCloudName';
  static String get cloudinaryUploadUrl => 'https://api.cloudinary.com/v1_1/$cloudinaryCloudName';
}
