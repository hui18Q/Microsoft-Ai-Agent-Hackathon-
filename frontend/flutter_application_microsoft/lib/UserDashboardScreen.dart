import 'package:flutter/material.dart';
import 'screens/ai_chatbot_screen.dart';
import 'screens/status_tracker_screen.dart';
import 'screens/service_finder_screen.dart';
import 'screens/notifications_screen.dart';
import 'theme_constants.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 251, 253),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, Jason Lim',
                          style: ThemeConstants.headerTextStyle.copyWith(
                            fontSize: 36,
                            color: const Color(0xFF1A237E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Application Status Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusCard(
                      'Application in Progress',
                      '2',
                    ),
                    _buildStatusCard(
                      'Upcoming Deadlines',
                      'May 39, 2024',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Recent Activity Section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Activity',
                        style: ThemeConstants.headerTextStyle.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildActivityItem(
                        'Application submitted for Education Grant',
                        'April 10, 2024',
                      ),
                      _buildActivityItem(
                        'Application submitted for Education Grant',
                        'April 3, 2024',
                      ),
                      _buildActivityItem(
                        'Application submitted for Education Grant',
                        'March 25, 2024',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Actions Section
                Text(
                  'Quick Actions',
                  style: ThemeConstants.headerTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 12),
                
                // AI Chatbot Button
                _buildQuickActionButton(
                  context,
                  'AI CHATBOT',
                  Icons.chat_bubble_outline,
                  const Color(0xFF2196F3),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AIChatbotScreen()),
                  ),
                ),
                const SizedBox(height: 12),

                // Status Tracker Button
                _buildQuickActionButton(
                  context,
                  'STATUS TRACKER',
                  Icons.track_changes,
                  const Color(0xFF9C27B0),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StatusTrackerScreen()),
                  ),
                ),
                const SizedBox(height: 12),

                // Service Finder Button
                _buildQuickActionButton(
                  context,
                  'SERVICE FINDER',
                  Icons.location_on_outlined,
                  const Color(0xFF4CAF50),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ServiceFinderScreen()),
                  ),
                ),
                const SizedBox(height: 12),

                // Notifications Button
                _buildQuickActionButton(
                  context,
                  'NOTIFICATIONS',
                  Icons.notifications_outlined,
                  const Color(0xFFFFC107),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF1A237E), width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            date,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    // Define light background colors for each button
    final Map<Color, Color> colorToLightColor = {
      const Color(0xFF2196F3): const Color(0xFFE3F2FD), // Light Blue
      const Color(0xFF9C27B0): const Color(0xFFF3E5F5), // Light Purple
      const Color(0xFF4CAF50): const Color(0xFFE8F5E9), // Light Green
      const Color(0xFFFFC107): const Color(0xFFFFF8E1), // Light Yellow
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          decoration: BoxDecoration(
            color: colorToLightColor[color],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}