import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test2/auth_service.dart';
import 'package:test2/screen/home_screen.dart';
import 'package:test2/screen/login_screen.dart';
import 'screen/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://oasznabpdabffqbxcyfw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9hc3puYWJwZGFiZmZxYnhjeWZ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1OTQ3ODgsImV4cCI6MjA3NzE3MDc4OH0.0_gj0YGv2WWZqF8_UHlCDXYXU0wOQWeDjbePk27Fsv4',
  );

  final authService = AuthService();
  final credentials = await authService.getSavedCredentials();
  final isLoggedIn = await authService.getUserProfile() != null;

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