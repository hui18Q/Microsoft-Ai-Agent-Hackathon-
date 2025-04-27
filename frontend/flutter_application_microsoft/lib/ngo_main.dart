import 'package:flutter/material.dart';
import 'screens/ngo/ngo_dashboard_screen.dart';
import 'screens/ngo/application_review_screen.dart';
import 'screens/ngo/resource_management_screen.dart';
import 'screens/ngo/ngo_notifications_screen.dart';
import 'screens/ngo/ngo_live_chat_screen.dart';

// Custom color scheme for NGO app
class NGOColors {
  static const primary = Color(0xFF2C3E50);  // Deep blue-gray
  static const secondary = Color(0xFF3498DB); // Bright blue
  static const accent = Color(0xFF27AE60);    // Green
  static const warning = Color(0xFFF39C12);   // Orange
  static const error = Color(0xFFE74C3C);     // Red
  static const background = Color(0xFFF8F9FA); // Light gray
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF2C3E50);
  static const textSecondary = Color(0xFF7F8C8D);
  static const divider = Color(0xFFECF0F1);
}

void main() {
  runApp(const NGOApp());
}

class NGOApp extends StatelessWidget {
  const NGOApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NGO Welfare Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: NGOColors.primary,
        scaffoldBackgroundColor: NGOColors.background,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: NGOColors.primary,
          primary: NGOColors.primary,
          secondary: NGOColors.secondary,
          background: NGOColors.background,
          surface: NGOColors.surface,
          error: NGOColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: NGOColors.surface,
          foregroundColor: NGOColors.primary,
          elevation: 0,
          iconTheme: IconThemeData(
            color: NGOColors.primary,
          ),
          actionsIconTheme: IconThemeData(
            color: NGOColors.primary,
          ),
        ),
        cardTheme: CardTheme(
          color: NGOColors.surface,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: NGOColors.primary,
          ),
          titleMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: NGOColors.primary,
          ),
          titleSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: NGOColors.primary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: NGOColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: NGOColors.textPrimary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: NGOColors.textSecondary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: NGOColors.primary,
            foregroundColor: NGOColors.surface,
            elevation: 2,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: NGOColors.primary,
            side: const BorderSide(color: NGOColors.primary),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: NGOColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: NGOColors.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: NGOColors.divider,
          thickness: 1,
          space: 24,
        ),
      ),
      home: const NGODashboardScreen(),
      routes: {
        '/applications': (context) => const ApplicationReviewScreen(),
        '/resources': (context) => const ResourceManagementScreen(),
        '/notifications': (context) => const NGONotificationsScreen(),
        '/live-chat': (context) => const NGOLiveChatScreen(),
      },
    );
  }
} 