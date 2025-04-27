import 'package:flutter/material.dart';
import '../welcome_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';
import 'reset_password_page.dart';
import 'profile_page.dart';
import 'edit_profile_page.dart';
import 'ngo_welcome_page.dart';
import 'ngo_profile_page.dart';
import 'ngo_edit_profile_page.dart';
import 'ngo_signup_page.dart';
import 'ngo_login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/reset-password': (context) => const ResetPasswordPage(),
        '/profile': (context) => const ProfilePage(),
        '/editprofile': (context) => const EditProfilePage(), 
        '/ngo-welcome': (context) => const NGOWelcomePage(),
        '/ngo-profile': (context) => const NGOProfilePage(), 
        '/ngo-editprofile': (context) => const NGOEditProfilePage(),
        '/ngo-signup': (context) => const NGOSignUpPage(), 
        '/ngo-login': (context) => const NGOLoginPage(),
      },
    );
  }
}
