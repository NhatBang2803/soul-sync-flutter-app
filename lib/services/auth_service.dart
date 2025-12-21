import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;

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

  /// Current user from Supabase Auth
  User? get currentAuthUser => _client.auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentAuthUser != null;

  /// Get current user ID
  String? get currentUserId => currentAuthUser?.id;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ==================== SIGN UP ====================

  /// Đăng ký tài khoản mới với username, email, password
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
      final existingUser = await _client
          .from('users')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      if (existingUser != null) {
        return AuthResult.failure('Username đã được sử dụng');
      }

      // Sign up with Supabase Auth
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username, 'display_name': username},
      );

      if (response.user == null) {
        return AuthResult.failure('Đăng ký thất bại. Vui lòng thử lại.');
      }

      // Create user profile in users table
      await _client.from('users').upsert({
        'id': response.user!.id,
        'username': username,
        'email': email,
        'display_name': username,
        'auth_method': 'local',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      return AuthResult.success(
        message:
            'Đăng ký thành công! Vui lòng kiểm tra email để xác nhận tài khoản.',
      );
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Đã xảy ra lỗi: ${e.toString()}');
    }
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

      // Password verified! Create a session using Supabase anonymous or custom token
      // For now, we'll use a workaround: sign in without session but return user profile
      final userProfile = app_user.User.fromJson(userRecord);

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
