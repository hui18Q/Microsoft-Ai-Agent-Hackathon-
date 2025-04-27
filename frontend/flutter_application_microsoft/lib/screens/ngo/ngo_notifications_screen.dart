import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class NGONotificationsScreen extends StatelessWidget {
  const NGONotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 250, 250),
      appBar: AppBar(
        backgroundColor: NGOColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'NGO Notifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
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
            'A New Bantuan Hidup application received',
            DateTime.now(),
            NotificationType.newApplication,
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            'Time to update 123456 status',
            DateTime.now().subtract(const Duration(hours: 2)),
            NotificationType.reminder,
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            'You\'ve Approved for 1M people',
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
        color: NGOColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: NGOColors.primary.withOpacity(0.1),
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
                      color: NGOColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(time),
                    style: TextStyle(
                      fontSize: 14,
                      color: NGOColors.textSecondary,
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
        color = NGOColors.secondary;
        backgroundColor = NGOColors.secondary.withOpacity(0.1);
      case NotificationType.reminder:
        icon = Icons.access_time;
        color = NGOColors.warning;
        backgroundColor = NGOColors.warning.withOpacity(0.1);
      case NotificationType.success:
        icon = Icons.check_circle_outline;
        color = NGOColors.accent;
        backgroundColor = NGOColors.accent.withOpacity(0.1);
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