import 'package:flutter/material.dart';
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
      home: const UserDashboardScreen(),
      routes: {
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
