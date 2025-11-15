import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Invalid email or password');
    }

    final profile = await _client
        .from('profiles')
        .select()
        .eq('id', response.user!.id)
        .maybeSingle();

    if (profile == null) {
      await _client.auth.signOut();
      throw Exception('User profile not found');
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    final availability = await checkUserAvailability(
      username: username,
      email: email,
    );

    if (!availability['username_available']!) {
      throw Exception('Username already taken');
    }

    if (!availability['email_available']!) {
      throw Exception('Email already in use');
    }

    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (authResponse.user == null) {
      throw Exception('Account creation failed');
    }

    await _client.from('profiles').upsert({
      'id': authResponse.user!.id,
      'username': username,
      'email': email,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<Map<String, dynamic>> checkUserAvailability({
    required String username,
    required String email,
  }) async {
    final usernameResponse = await _client
        .from('profiles')
        .select()
        .eq('username', username)
        .maybeSingle();

    final emailResponse = await _client
        .from('profiles')
        .select()
        .eq('email', email)
        .maybeSingle();

    return {
      'username_available': usernameResponse == null,
      'email_available': emailResponse == null,
    };
  }

  Map<String, dynamic>? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    return {
      'id': user.id,
      'email': user.email,
      'created_at': _formatDate(user.createdAt),
    };
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return response;
  }

  Future<void> updateProfile({
    String? username,
    String? email,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (email != null) updates['email'] = email;

    if (updates.isNotEmpty) {
      await _client.from('profiles').update(updates).eq('id', user.id);
    }
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