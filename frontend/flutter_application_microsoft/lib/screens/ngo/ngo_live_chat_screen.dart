import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class NGOLiveChatScreen extends StatefulWidget {
  const NGOLiveChatScreen({super.key});

  @override
  State<NGOLiveChatScreen> createState() => _NGOLiveChatScreenState();
}

class _NGOLiveChatScreenState extends State<NGOLiveChatScreen> {
  String _selectedFilter = 'All Chats';
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final List<ChatPreview> _allChats = [
    ChatPreview(
      name: 'John Doe',
      lastMessage: 'Hello, I need help with my application',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      isOnline: true,
    ),
    ChatPreview(
      name: 'Carmen Lai',
      lastMessage: 'When will my application be processed?',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 1,
      isOnline: true,
    ),
    ChatPreview(
      name: 'Jolyn Chong',
      lastMessage: 'Thank you for the assistance',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 0,
      isOnline: false,
    ),
    ChatPreview(
      name: 'Muhammad Danish',
      lastMessage: 'Is there any update on my application?',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      unreadCount: 0,
      isOnline: false,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatPreview> get _filteredChats {
    List<ChatPreview> chats = _allChats;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      chats = chats.where((chat) =>
        chat.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        chat.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'Unread':
        return chats.where((chat) => chat.unreadCount > 0).toList();
      case 'Active':
        return chats.where((chat) => chat.isOnline).toList();
      default:
        return chats;
    }
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search by name or message...',
        hintStyle: TextStyle(
          color: const Color(0xFF1A237E).withOpacity(0.5),
        ),
        border: InputBorder.none,
      ),
      style: const TextStyle(
        color: Color(0xFF1A237E),
        fontSize: 16,
      ),
      onChanged: (query) => setState(() {
        _searchQuery = query;
      }),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.clear, color: Color(0xFF1A237E)),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
              _searchController.clear();
            });
          },
        ),
      ];
    }

    return [
      IconButton(
        icon: const Icon(Icons.search, color: Color(0xFF1A237E)),
        onPressed: () {
          setState(() {
            _isSearching = true;
          });
        },
      ),
    ];
  }

  Widget _buildAppBarTitle() {
    if (_isSearching) {
      return _buildSearchField();
    }

    return const Text(
      'Live Chat',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A237E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 244, 244),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 237, 250, 250),
        elevation: 0,
        centerTitle: !_isSearching,
        title: _buildAppBarTitle(),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined, color: Color(0xFF1A237E)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: _buildAppBarActions(),
      ),
      body: Column(
        children: [
          if (!_isSearching) Container(
            padding: const EdgeInsets.all(16),
            color: NGOColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip('All Chats'),
                _buildFilterChip('Unread'),
                _buildFilterChip('Active'),
              ],
            ),
          ),
          Expanded(
            child: _filteredChats.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off
                              : _selectedFilter == 'Unread'
                                  ? Icons.mark_email_read
                                  : Icons.person_off,
                          size: 64,
                          color: const Color(0xFF1A237E).withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No matching chats found'
                              : _selectedFilter == 'Unread'
                                  ? 'No unread messages'
                                  : 'No active users',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF1A237E).withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredChats.length,
                    itemBuilder: (context, index) {
                      final chat = _filteredChats[index];
                      return _buildChatPreviewCard(context, chat);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color.fromARGB(255, 237, 250, 250) : const Color(0xFF1A237E),
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: NGOColors.surface,
      selectedColor: const Color(0xFF1A237E),
      checkmarkColor: NGOColors.surface,
      side: BorderSide(
        color: isSelected ? Colors.transparent : const Color(0xFF1A237E),
      ),
      onSelected: (bool selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
    );
  }

  Widget _buildChatPreviewCard(BuildContext context, ChatPreview chat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Hero(
        tag: 'chat_${chat.name}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(userName: chat.name),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: NGOColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A237E).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: NGOColors.background,
                          child: Text(
                            chat.name.split(' ').map((e) => e[0]).join(''),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A237E),
                            ),
                          ),
                        ),
                        if (chat.isOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: NGOColors.accent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: NGOColors.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                chat.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A237E),
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _formatTime(chat.timestamp),
                                style: TextStyle(
                                  color: chat.unreadCount > 0
                                      ? NGOColors.primary
                                      : NGOColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: chat.unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  chat.lastMessage,
                                  style: TextStyle(
                                    color: chat.unreadCount > 0
                                        ? const Color(0xFF1A237E)
                                        : NGOColors.textSecondary,
                                    fontSize: 14,
                                    fontWeight: chat.unreadCount > 0
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (chat.unreadCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A237E),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    chat.unreadCount.toString(),
                                    style: TextStyle(
                                      color: NGOColors.surface,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatPreview {
  final String name;
  final String lastMessage;
  final DateTime timestamp;
  final bool isOnline;
  final int unreadCount;

  ChatPreview({
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    this.isOnline = false,
    this.unreadCount = 0,
  });
}

class ChatDetailScreen extends StatefulWidget {
  final String userName;

  const ChatDetailScreen({
    super.key,
    required this.userName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // Add initial message from user
    _messages.add(
      ChatMessage(
        sender: widget.userName,
        message: 'Hello, I need help with my application',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isNGO: false,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 250, 250),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: const Icon(
                Icons.person,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.userName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      setState(() {
                        _messages.add(
                          ChatMessage(
                            sender: 'NGO Admin',
                            message: _messageController.text,
                            timestamp: DateTime.now(),
                            isNGO: true,
                          ),
                        );
                        _messageController.clear();
                      });
                    }
                  },
                  icon: const Icon(Icons.send),
                  color: const Color(0xFF2196F3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isNGO ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isNGO) ...[
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: const Icon(
                Icons.person,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isNGO
                    ? const Color(0xFF2196F3).withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: message.isNGO
                          ? const Color(0xFF2196F3)
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isNGO) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
              child: const Icon(
                Icons.support_agent,
                color: Color(0xFF2196F3),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String sender;
  final String message;
  final DateTime timestamp;
  final bool isNGO;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.isNGO,
  });
} 