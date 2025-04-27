import 'package:flutter/material.dart';
import '../services/application_service.dart';

class StatusTrackerScreen extends StatefulWidget {
  const StatusTrackerScreen({super.key});

  @override
  State<StatusTrackerScreen> createState() => _StatusTrackerScreenState();
}

class _StatusTrackerScreenState extends State<StatusTrackerScreen> {
  final Set<String> expandedCards = {};
  final Map<String, List<ChatMessage>> _chatMessages = {};
  final TextEditingController _messageController = TextEditingController();
  final ApplicationService _applicationService = ApplicationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 250, 250),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.track_changes, size: 24, color: Color(0xFF1A237E)),
            SizedBox(width: 8),
            Text(
              'Status Tracker',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Color(0xFF1A237E)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildApplicationCard(
            id: '2025-1',
            title: 'Bantuan Sara Hidup 2025',
            status: ApplicationStatus.inProgress,
            lastUpdated: '18 April 2025',
            organization: 'Yayasan Berhad',
            phone: '+6012-3456789',
            email: 'info@yayasan.org',
            hours: 'Mon-Fri, 9AM-5PM',
            logoUrl: 'assets/yayasan_logo.png',
          ),
          const SizedBox(height: 16),
          _buildApplicationCard(
            id: '2025-2',
            title: 'Gamuda Scholarship 2025',
            status: ApplicationStatus.approved,
            lastUpdated: '15 April 2025',
            organization: 'Gamuda Foundation',
            phone: '+603-12345678',
            email: 'scholarship@gamuda.com',
            hours: 'Mon-Fri, 9AM-6PM',
            logoUrl: 'assets/gamuda_logo.png',
          ),
          const SizedBox(height: 16),
          _buildApplicationCard(
            id: '2024-1',
            title: 'Bantuan Sara Hidup 2024',
            status: ApplicationStatus.rejected,
            lastUpdated: '10 December 2024',
            organization: 'Yayasan Berhad',
            phone: '+6012-3456789',
            email: 'info@yayasan.org',
            hours: 'Mon-Fri, 9AM-5PM',
            logoUrl: 'assets/yayasan_logo.png',
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard({
    required String id,
    required String title,
    required ApplicationStatus status,
    required String lastUpdated,
    required String organization,
    required String phone,
    required String email,
    required String hours,
    required String logoUrl,
  }) {
    final isExpanded = expandedCards.contains(id);

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: status.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: status.color),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: status.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status.name,
                            style: TextStyle(
                              color: status.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: TextButton(
              onPressed: () {
                setState(() {
                  if (isExpanded) {
                    expandedCards.remove(id);
                  } else {
                    expandedCards.add(id);
                  }
                });
              },
              child: Text(
                isExpanded ? 'Hide Details' : 'Details',
                style: TextStyle(
                  color: const Color(0xFF013CFF),
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor:const Color(0xFF013CFF),
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.update, 'Last Updated', lastUpdated),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.business, 'Organization', organization),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.phone, 'Phone', phone),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.email, 'Email', email),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.access_time, 'Hours', hours),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showChatDialog(context, organization, logoUrl),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Start Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showChatDialog(BuildContext context, String organization, String logoUrl) {
    final String chatId = organization; // Using organization as chat ID for now
    if (!_chatMessages.containsKey(chatId)) {
      _chatMessages[chatId] = [];
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            height: 500,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Chat Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE3F2FD),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(logoUrl),
                        backgroundColor: const Color(0xFFE3F2FD),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              organization,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const Text(
                              'Customer Service',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Chat Messages Area
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _chatMessages[chatId]!.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 48,
                                  color: Colors.black38,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No messages yet',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Start the conversation',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _chatMessages[chatId]!.length,
                            padding: const EdgeInsets.all(8),
                            itemBuilder: (context, index) {
                              final message = _chatMessages[chatId]![index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Align(
                                  alignment: message.isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: message.isUser
                                          ? const Color(0xFF2196F3)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      message.text,
                                      style: TextStyle(
                                        color: message.isUser
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Message Input Area
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF64B5F6),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Colors.black38),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          onSubmitted: (text) => _sendMessage(text, chatId, setState),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded),
                          color: const Color(0xFF2196F3),
                          onPressed: () {
                            final messageText = _messageController.text.trim();
                            if (messageText.isNotEmpty) {
                              _sendMessage(messageText, chatId, setState);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _sendMessage(String text, String chatId, StateSetter setState) {
    if (text.isEmpty) return;

    setState(() {
      _chatMessages[chatId]!.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _messageController.clear();

    // Simulate customer service response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _chatMessages[chatId]!.add(ChatMessage(
          text: 'Thank you for your message. Our team will get back to you shortly.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    });
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

enum ApplicationStatus {
  inProgress('In Progress', Color.fromARGB(255, 252, 181, 2)),
  approved('Approved', Color(0xFF4CAF50)),
  rejected('Rejected', Color(0xFFFF0000));

  final String name;
  final Color color;

  const ApplicationStatus(this.name, this.color);
} 