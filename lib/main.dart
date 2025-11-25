// main.dart - الإصدار المعدل
import 'package:flutter/material.dart';
import 'package:test2/auth_service.dart';
import 'package:test2/screen/home_screen.dart';
import 'package:test2/screen/login_screen.dart';
import 'screen/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  final credentials = await authService.getSavedCredentials();
  final isLoggedIn = false; // تم إزالة التحقق من Supabase

  runApp(MyApp(
    initialRoute: isLoggedIn || credentials != null ? '/home' : '/auth',
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/auth': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}