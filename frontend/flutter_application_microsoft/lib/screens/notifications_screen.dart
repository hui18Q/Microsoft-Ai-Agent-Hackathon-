import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 250, 250),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.notifications,
              color: Color(0xFF1A237E),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined, color: Color(0xFF1A237E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationCard(
            'You have a new Application approved',
            DateTime.now(),
            NotificationType.newApplication,
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            'Good News from NGO!',
            DateTime.now().subtract(const Duration(hours: 2)),
            NotificationType.reminder,
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            'Your yayasan scholarship Approved!',
            DateTime.now().subtract(const Duration(days: 1)),
            NotificationType.success,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    String message,
    DateTime time,
    NotificationType type,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationIcon(type),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1A237E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(time),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData icon;
    Color color;
    Color backgroundColor;

    switch (type) {
      case NotificationType.newApplication:
        icon = Icons.description_outlined;
        color = Colors.blue;
        backgroundColor = Colors.blue.withOpacity(0.1);
      case NotificationType.reminder:
        icon = Icons.access_time;
        color = Colors.orange;
        backgroundColor = Colors.orange.withOpacity(0.1);
      case NotificationType.success:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        backgroundColor = Colors.green.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

enum NotificationType {
  newApplication,
  reminder,
  success,
} 