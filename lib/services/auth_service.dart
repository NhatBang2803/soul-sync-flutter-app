import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;
import 'cloudinary_service.dart';

/// Authentication result wrapper
class AuthResult {
  final bool success;
  final String? message;
  final app_user.User? user;

  AuthResult({required this.success, this.message, this.user});

  factory AuthResult.success({app_user.User? user, String? message}) {
    return AuthResult(success: true, user: user, message: message);
  }

  factory AuthResult.failure(String message) {
    return AuthResult(success: false, message: message);
  }
}

/// Service để quản lý authentication
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  /// Lưu user đã đăng nhập qua custom auth (username/password hash)
  app_user.User? _customAuthUser;

  /// Current user from Supabase Auth
  User? get currentAuthUser => _client.auth.currentUser;

  /// Check if user is logged in (either Supabase Auth or custom auth)
  bool get isLoggedIn => currentAuthUser != null || _customAuthUser != null;

  /// Get current user ID (from Supabase Auth or custom auth)
  String? get currentUserId => currentAuthUser?.id ?? _customAuthUser?.id;

  /// Get current user profile (from custom auth)
  app_user.User? get currentUser => _customAuthUser;

  /// Stream controller for user updates
  final _userController = StreamController<app_user.User?>.broadcast();

  /// Stream of user profile changes
  Stream<app_user.User?> get userStream => _userController.stream;

  // ==================== SIGN UP ====================

  /// Đăng ký tài khoản mới với username, email, password (Custom Auth - không cần email confirmation)
  Future<AuthResult> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (username.isEmpty || email.isEmpty || password.isEmpty) {
        return AuthResult.failure('Vui lòng điền đầy đủ thông tin');
      }

      if (username.length < 3) {
        return AuthResult.failure('Username phải có ít nhất 3 ký tự');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.failure('Email không hợp lệ');
      }

      if (password.length < 6) {
        return AuthResult.failure('Mật khẩu phải có ít nhất 6 ký tự');
      }

      // Check if username already exists
      final existingUsername = await _client
          .from('users')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      if (existingUsername != null) {
        return AuthResult.failure('Username đã được sử dụng');
      }

      // Check if email already exists
      final existingEmail = await _client
          .from('users')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      if (existingEmail != null) {
        return AuthResult.failure('Email đã được đăng ký');
      }

      // Create password hash (same format as admin-web)
      final passwordHash = _createPasswordHash(password);

      // Create user directly in users table (Custom Auth - no Supabase Auth)
      final now = DateTime.now().toIso8601String();
      await _client.from('users').insert({
        'username': username,
        'email': email,
        'display_name': username,
        'password_hash': passwordHash,
        'auth_method': 'local',
        'created_at': now,
        'updated_at': now,
      });

      return AuthResult.success(
        message: 'Đăng ký thành công! Bạn có thể đăng nhập ngay.',
      );
    } on PostgrestException catch (e) {
      if (e.message.contains('duplicate key')) {
        if (e.message.contains('username')) {
          return AuthResult.failure('Username đã được sử dụng');
        }
        if (e.message.contains('email')) {
          return AuthResult.failure('Email đã được đăng ký');
        }
      }
      return AuthResult.failure('Đăng ký thất bại: ${e.message}');
    } catch (e) {
      return AuthResult.failure('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  /// Create password hash with random salt (same format as admin-web)
  String _createPasswordHash(String password) {
    // Generate random salt (16 hex chars)
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final saltBytes = utf8.encode(random);
    final saltDigest = sha256.convert(saltBytes);
    final salt = saltDigest.toString().substring(0, 16);

    // Hash password with salt
    final bytes = utf8.encode(salt + password);
    final digest = sha256.convert(bytes);
    final hashHex = digest.toString();

    // Return format: salt:hash
    return '$salt:$hashHex';
  }

  // ==================== SIGN IN ====================

  /// Đăng nhập với username hoặc email
  Future<AuthResult> signIn({
    required String identifier, // username or email
    required String password,
  }) async {
    try {
      print('=== DEBUG LOGIN ===');
      print('Identifier: $identifier');

      if (identifier.isEmpty || password.isEmpty) {
        return AuthResult.failure('Vui lòng điền đầy đủ thông tin');
      }

      String email = identifier;
      Map<String, dynamic>? userRecord;

      // Check if identifier is username (no @) or email (has @)
      if (!identifier.contains('@')) {
        // It's a username, look up the user
        print('Looking up username: $identifier');
        userRecord = await _client
            .from('users')
            .select('*')
            .eq('username', identifier)
            .maybeSingle();

        if (userRecord == null) {
          print('Username not found!');
          return AuthResult.failure('Username không tồn tại');
        }
        email = userRecord['email'];
        print('Found email: $email');
      } else {
        // Email lookup
        print('Looking up email: $identifier');
        userRecord = await _client
            .from('users')
            .select('*')
            .eq('email', identifier)
            .maybeSingle();

        if (userRecord == null) {
          print('Email not found!');
          return AuthResult.failure('Email không tồn tại');
        }
      }

      print('User record found: ${userRecord['id']}');
      print('Auth method: ${userRecord['auth_method']}');
      print('Password hash: ${userRecord['password_hash']}');

      // Check auth method
      final authMethod = userRecord['auth_method'] ?? 'local';

      if (authMethod == 'google') {
        return AuthResult.failure('Tài khoản này sử dụng Google để đăng nhập');
      }

      // For local auth, verify password hash
      final storedHash = userRecord['password_hash'] as String?;

      if (storedHash == null || storedHash.isEmpty) {
        print('No password_hash, falling back to Supabase Auth');
        // No password set, try Supabase Auth as fallback
        try {
          final response = await _client.auth.signInWithPassword(
            email: email,
            password: password,
          );
          if (response.user != null) {
            final userProfile = await getUserProfile(response.user!.id);
            _customAuthUser = userProfile; // Also save to custom auth
            _userController.add(_customAuthUser);
            return AuthResult.success(
              user: userProfile,
              message: 'Đăng nhập thành công!',
            );
          }
        } catch (e) {
          print('Supabase Auth failed: $e');
          return AuthResult.failure('Mật khẩu không đúng');
        }
      }

      // Verify password with custom hash
      print('Verifying custom password hash...');
      final isValidPassword = _verifyPasswordHash(password, storedHash!);
      print('Password valid: $isValidPassword');

      if (!isValidPassword) {
        return AuthResult.failure('Mật khẩu không đúng');
      }

      // Password verified! Save user to custom auth state
      final userProfile = app_user.User.fromJson(userRecord);
      _customAuthUser = userProfile;
      _userController.add(_customAuthUser);
      print('Custom auth user saved: ${_customAuthUser?.id}');

      return AuthResult.success(
        user: userProfile,
        message: 'Đăng nhập thành công!',
      );
    } on AuthException catch (e) {
      print('AuthException: ${e.message}');
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      print('Exception: $e');
      return AuthResult.failure('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  /// Verify password against stored hash (salt:hash format from admin-web)
  bool _verifyPasswordHash(String password, String storedHash) {
    final parts = storedHash.split(':');
    if (parts.length != 2) return false;

    final salt = parts[0];
    final originalHash = parts[1];

    // Hash password with salt using SHA-256 (same as admin-web)
    final bytes = utf8.encode(salt + password);
    final digest = sha256.convert(bytes);
    final hashHex = digest.toString();

    return hashHex == originalHash;
  }

  // ==================== GOOGLE SIGN IN ====================

  /// Đăng nhập với Google OAuth
  Future<AuthResult> signInWithGoogle() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.soulsync://login-callback/',
      );

      if (!response) {
        return AuthResult.failure('Đăng nhập Google thất bại');
      }

      return AuthResult.success(message: 'Đang chuyển hướng đến Google...');
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  /// Tạo hoặc cập nhật user profile sau OAuth login
  Future<void> ensureUserProfile() async {
    final authUser = currentAuthUser;
    if (authUser == null) return;

    try {
      // Check if user profile exists
      final existing = await _client
          .from('users')
          .select('id')
          .eq('id', authUser.id)
          .maybeSingle();

      if (existing == null) {
        // Create new user profile for OAuth user
        final email = authUser.email ?? '';
        final displayName =
            authUser.userMetadata?['full_name'] ??
            authUser.userMetadata?['name'] ??
            email.split('@').first;
        final avatarUrl =
            authUser.userMetadata?['avatar_url'] ??
            authUser.userMetadata?['picture'];

        await _client.from('users').insert({
          'id': authUser.id,
          'email': email,
          'display_name': displayName,
          'avatar_url': avatarUrl,
          'auth_method': 'google',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error ensuring user profile: $e');
    }
  }

  // ==================== PASSWORD RESET ====================

  /// Gửi email reset password
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      if (email.isEmpty) {
        return AuthResult.failure('Vui lòng nhập email');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.failure('Email không hợp lệ');
      }

      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.soulsync://reset-password/',
      );

      return AuthResult.success(
        message:
            'Email đặt lại mật khẩu đã được gửi. Vui lòng kiểm tra hộp thư.',
      );
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  /// Đặt lại mật khẩu mới
  Future<AuthResult> updatePassword(String newPassword) async {
    try {
      if (newPassword.length < 6) {
        return AuthResult.failure('Mật khẩu phải có ít nhất 6 ký tự');
      }

      await _client.auth.updateUser(UserAttributes(password: newPassword));

      return AuthResult.success(
        message: 'Mật khẩu đã được cập nhật thành công!',
      );
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  // ==================== SIGN OUT ====================

  /// Đăng xuất
  Future<AuthResult> signOut() async {
    try {
      // Clear custom auth user
      _customAuthUser = null;
      await _client.auth.signOut();
      return AuthResult.success(message: 'Đã đăng xuất');
    } catch (e) {
      return AuthResult.failure('Đăng xuất thất bại: ${e.toString()}');
    }
  }

  // ==================== USER PROFILE ====================

  /// Lấy thông tin user profile
  Future<app_user.User?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return app_user.User.fromJson(response);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // ==================== USER PROFILE ====================

  /// Upload avatar image to Cloudinary
  /// Returns the public URL of the uploaded image
  /// [mimeType] should be passed from XFile.mimeType for correct format detection
  Future<String?> uploadAvatar(File imageFile, {String? mimeType}) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('Chưa đăng nhập');
      }

      // Determine extension from MIME type first, then fall back to file path
      String ext;
      if (mimeType != null && mimeType.isNotEmpty) {
        // Extract extension from MIME type: 'image/jpeg' -> 'jpeg'
        ext = mimeType.split('/').last.toLowerCase();
        // Map 'jpeg' to 'jpg' for consistency
        if (ext == 'jpeg') ext = 'jpg';
      } else {
        // Fall back to file path extension
        ext = imageFile.path.split('.').last.toLowerCase();
      }

      final allowedExts = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      if (!allowedExts.contains(ext)) {
        // If extension is invalid, default to 'jpg' and let Cloudinary auto-detect
        print('Warning: Unknown extension "$ext", defaulting to jpg');
        ext = 'jpg';
      }

      // Create unique filename: userId_timestamp.ext
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_$timestamp.$ext';

      // Upload to Cloudinary
      final cloudinaryService = CloudinaryService();
      final result = await cloudinaryService.uploadImage(
        imageFile,
        fileName: fileName,
        folder: 'avatars',
      );

      // Return the secure URL from Cloudinary
      return result['secure_url'] as String?;
    } catch (e) {
      print('Error uploading avatar: $e');
      rethrow;
    }
  }

  /// Remove avatar from storage and clear from profile
  Future<AuthResult> removeAvatar() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return AuthResult.failure('Chưa đăng nhập');
      }

      // Update profile to remove avatar URL
      return await updateProfile(avatarUrl: '');
    } catch (e) {
      return AuthResult.failure('Xóa ảnh thất bại: ${e.toString()}');
    }
  }

  /// Cập nhật user profile
  Future<AuthResult> updateProfile({
    String? displayName,
    String? avatarUrl,
    String? username,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return AuthResult.failure('Chưa đăng nhập');
      }

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (displayName != null) updates['display_name'] = displayName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (username != null) {
        // Check if new username is available
        final existing = await _client
            .from('users')
            .select('id')
            .eq('username', username)
            .neq('id', userId)
            .maybeSingle();

        if (existing != null) {
          return AuthResult.failure('Username đã được sử dụng');
        }
        updates['username'] = username;
      }

      await _client.from('users').update(updates).eq('id', userId);

      final updatedUser = await getUserProfile(userId);

      // Update local state and notify listeners
      _customAuthUser = updatedUser;
      _userController.add(_customAuthUser);

      return AuthResult.success(
        user: updatedUser,
        message: 'Cập nhật thành công!',
      );
    } catch (e) {
      return AuthResult.failure('Cập nhật thất bại: ${e.toString()}');
    }
  }

  // ==================== HELPERS ====================

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _mapAuthError(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('invalid login credentials')) {
      return 'Email hoặc mật khẩu không đúng';
    }
    if (lowerMessage.contains('email not confirmed')) {
      return 'Email chưa được xác nhận. Vui lòng kiểm tra hộp thư.';
    }
    if (lowerMessage.contains('user already registered')) {
      return 'Email đã được đăng ký';
    }
    if (lowerMessage.contains('password')) {
      return 'Mật khẩu không đáp ứng yêu cầu bảo mật';
    }
    if (lowerMessage.contains('rate limit')) {
      return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
    }

    return message;
  }
}
