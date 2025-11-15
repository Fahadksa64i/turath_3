import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test2/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late String _username = '';
  late String _email = '';
  bool _isEditingUsername = false;
  bool _isUsernameAvailable = true;
  bool _isLoading = false;
  final TextEditingController _usernameController = TextEditingController();
  String? _avatarUrl;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final response = await _supabase
            .from('profiles')
            .select('username, avatar_url')
            .eq('id', user.id)
            .single();

        setState(() {
          _username = response['username'] ?? 'بدون اسم';
          _email = user.email ?? 'بدون إيميل';
          _usernameController.text = _username;
          _avatarUrl = response['avatar_url'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في تحميل البيانات: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final fileExtension = _selectedImage!.path.split('.').last;
      final fileName = 'user_${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      // 1. Upload image
      await _supabase.storage
          .from('avatars')
          .upload(fileName, _selectedImage!, fileOptions: FileOptions(
        contentType: 'image/$fileExtension',
        upsert: true,
      ));

      // 2. Get public URL
      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);

      // 3. Update profile
      await _supabase
          .from('profiles')
          .update({'avatar_url': imageUrl})
          .eq('id', user.id);

      setState(() {
        _avatarUrl = imageUrl;
        _selectedImage = null;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في رفع الصورة: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.isEmpty || username == _username) {
      setState(() => _isUsernameAvailable = true);
      return;
    }

    try {
      final exists = await _supabase
          .from('profiles')
          .select()
          .eq('username', username)
          .neq('id', _supabase.auth.currentUser!.id)
          .maybeSingle();

      setState(() => _isUsernameAvailable = exists == null);
    } catch (e) {
      setState(() => _isUsernameAvailable = false);
    }
  }

  Future<void> _updateUsername() async {
    if (!_isUsernameAvailable) return;

    setState(() => _isLoading = true);
    try {
      await _supabase
          .from('profiles')
          .update({'username': _usernameController.text.trim()})
          .eq('id', _supabase.auth.currentUser!.id);

      setState(() {
        _username = _usernameController.text;
        _isEditingUsername = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في التحديث: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEDDCF),
      appBar: AppBar(
        title: Text(
          'الملف الشخصي',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6C4422),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // صورة الملف الشخصي
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF6C4422),
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (_avatarUrl != null
                        ? NetworkImage(_avatarUrl!)
                        : null),
                    child: _selectedImage == null && _avatarUrl == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF6C4422),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Color(0xFF6C4422),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // معلومات المستخدم
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6C4422),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  // اسم المستخدم
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // الجزء الأيسر: الأيقونة والنص أو حقل النص
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Color(0xFF6C4422)),
                        SizedBox(width: 10),
                        if (_isEditingUsername)
                          Expanded(
                            child: TextField(
                              controller: _usernameController,
                              style: GoogleFonts.tajawal(fontSize: 16),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF6C4422),
                                  ),
                                ),
                                errorText: !_isUsernameAvailable ? 'اسم المستخدم غير متاح' : null,
                              ),
                              onChanged: (value) => _checkUsernameAvailability(value.trim()),
                            ),
                          )
                        else
                          Text(
                            _username,
                            style: GoogleFonts.tajawal(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // الجزء الأيمن: زر التعديل
                  IconButton(
                    icon: Icon(
                      _isEditingUsername ? Icons.check : Icons.edit,
                      color: const Color(0xFF6C4422),
                    ),
                    onPressed: () {
                      if (_isEditingUsername) {
                        _updateUsername();
                      } else {
                        setState(() {
                          _isEditingUsername = true;
                          _isUsernameAvailable = true;
                        });
                      }
                    },
                  ),
                ],
              ),
                  const SizedBox(height: 20),

                  // البريد الإلكتروني
                  Row(
                    children: [
                      const Icon(Icons.email, color: Color(0xFF6C4422)),
                      const SizedBox(width: 10),
                      Text(
                        _email,
                        style: GoogleFonts.tajawal(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C4422),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                setState(() => _isLoading = true);
                try {
                  final authService = AuthService();
                  await authService.signOut();
                  await authService.clearCredentials();

                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/auth',
                          (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('حدث خطأ أثناء تسجيل الخروج: ${e.toString()}')),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              child: Text(
                'تسجيل الخروج',
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}