// auth_service.dart - الإصدار المعدل
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // تم إزالة كود Supabase
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    // تم إزالة كود Supabase
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> signOut() async {
    // تم إزالة كود Supabase
  }

  Future<Map<String, dynamic>> checkUserAvailability({
    required String username,
    required String email,
  }) async {
    // تم إزالة كود Supabase
    return {
      'username_available': true,
      'email_available': true,
    };
  }

  Map<String, dynamic>? get currentUser {
    // تم إزالة كود Supabase
    return null;
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    // تم إزالة كود Supabase
    return null;
  }

  Future<void> updateProfile({
    String? username,
    String? email,
  }) async {
    // تم إزالة كود Supabase
  }

  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
  }

  String? _formatDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date.toIso8601String();
    return date.toString();
  }
}