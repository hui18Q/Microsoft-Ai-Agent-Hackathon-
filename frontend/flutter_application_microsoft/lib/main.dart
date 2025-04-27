import 'package:flutter/material.dart';

// Updated imports
import 'login/welcome_page.dart';
import 'login/login_page.dart';
import 'login/signup_page.dart';
import 'login/forgot_password_page.dart';
import 'login/reset_password_page.dart';
import 'login/profile_page.dart';
import 'login/edit_profile_page.dart';
import 'login/ngo_welcome_page.dart';
import 'login/ngo_profile_page.dart';
import 'login/ngo_edit_profile_page.dart';
import 'login/ngo_signup_page.dart';
import 'login/ngo_login_page.dart';

// Other imports
import 'UserDashboardScreen.dart';
import 'screens/ai_chatbot_screen.dart';
import 'screens/status_tracker_screen.dart';
import 'screens/service_finder_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/auto_fill_screen.dart';
import 'models/application_details.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welfare AI App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFE3F2FD),
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          primary: const Color(0xFF2196F3),
          secondary: const Color(0xFF1A237E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A237E),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A237E),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
      initialRoute: '/', // Start with the WelcomePage
      routes: {
        // Login-related routes
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

        // Dashboard & app screens
        '/user-dashboard': (context) => const UserDashboardScreen(),
        '/ai-chatbot': (context) => const AIChatbotScreen(),
        '/status-tracker': (context) => const StatusTrackerScreen(),
        '/service-finder': (context) => const ServiceFinderScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/auto-fill') {
          return MaterialPageRoute(
            builder: (context) => AutoFillScreen(
              applicationDetails: ApplicationDetails(
                fullName: 'Default User',
                nricNumber: 'S1234567A',
                contactNumber: '+60123456789',
                address: '123 Main Street, City',
                monthlyIncome: 3000.0,
                aidType: 'General Assistance',
              ),
            ),
          );
        }
        return null;
      },
    );
  }
}
