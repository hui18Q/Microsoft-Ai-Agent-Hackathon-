import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:flutter_tts/flutter_tts.dart';
import '../models/application_details.dart';
import 'auto_fill_screen.dart';

class Message {
  final String text;
  final bool isUser;
  final List<String>? options;
  bool isBeingRead;
  
  Message({
    required this.text,
    required this.isUser,
    this.options,
    this.isBeingRead = false,
  });
}

class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  bool _isRecording = false;
  bool _isAISpeaking = false;
  String? _currentAidType;
  final Map<String, String> _userDetails = {};
  final List<String> _initialQuestions = [
    'What is your current employment status?',
    'What is your monthly household income?',
    'How many dependents do you have?',
    'What specific challenges are you facing right now?'
  ];
  int _currentQuestionIndex = -1;
  Map<String, String> _assessmentAnswers = {};
  int _currentReadingIndex = -1;
  bool _isReading = false;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
    // Start with welcome message and first question
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add(
          Message(
            text: 'Hello! I\'m here to help you find suitable aid programs. Let me ask you a few questions to better understand your situation.',
            isUser: false,
          ),
        );
      });
      _askNextQuestion();
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  void _stopReading() {
    setState(() {
      _isAISpeaking = false;
      _isReading = false;
      _currentReadingIndex = -1;
    });
    // TODO: Stop text-to-speech engine
  }

  Future<void> _readNextMessage() async {
    if (!_isAISpeaking || !_isReading) return;

    // Find next AI message to read
    int nextIndex = _currentReadingIndex + 1;
    while (nextIndex < _messages.length) {
      if (!_messages[nextIndex].isUser) {
        break;
      }
      nextIndex++;
    }

    if (nextIndex < _messages.length) {
      _currentReadingIndex = nextIndex;
      final messageToRead = _messages[nextIndex];
      
      // Show visual indicator for current message being read
      setState(() {});

      // Remove options text from reading
      String textToRead = messageToRead.text;
      if (messageToRead.options != null) {
        // Remove any text after a double newline (usually where options start)
        int optionsIndex = textToRead.indexOf('\n\n');
        if (optionsIndex != -1) {
          textToRead = textToRead.substring(0, optionsIndex);
        }
      }

      // TODO: Implement actual text-to-speech
      // For now, we'll simulate reading with a delay
      await Future.delayed(Duration(milliseconds: textToRead.length * 50));
      
      if (_isAISpeaking && _isReading) {
        _readNextMessage();
      }
    } else {
      _stopReading();
    }
  }

  void _askNextQuestion() {
    if (_currentQuestionIndex < _initialQuestions.length - 1) {
      _currentQuestionIndex++;
      setState(() {
        _messages.add(
          Message(
            text: _initialQuestions[_currentQuestionIndex],
            isUser: false,
          ),
        );
      });
    } else if (_currentQuestionIndex == _initialQuestions.length - 1) {
      // All questions answered, provide recommendations
      _provideRecommendations();
    }
  }

  void _provideRecommendations() {
    String recommendationText = 'Based on your situation:\n';
    
    // Add situation summary
    recommendationText += '\nYour current situation:\n';
    recommendationText += '• Employment: ${_assessmentAnswers['employment']}\n';
    recommendationText += '• Monthly Income: ${_assessmentAnswers['income']}\n';
    recommendationText += '• Dependents: ${_assessmentAnswers['dependents']}\n';
    recommendationText += '• Challenges: ${_assessmentAnswers['challenges']}\n\n';
    
    recommendationText += 'I recommend the following aid programs:\n\n';
    
    // Always show all available programs with their details
    recommendationText += '1. Financial Aid for Low-Income Workers\n'
        '• Monthly financial assistance of RM500-1000\n'
        '• Skills training opportunities\n'
        '• Job placement assistance\n'
        '• Career counseling services\n'
        '• Transportation allowance\n'
        '• Access to micro-financing programs\n'
        '• Free financial management workshops\n'
        '\nEligibility:\n'
        '• Malaysian citizen\n'
        '• Monthly income below RM2000\n'
        '• Age 18-60 years old\n'
        '\nProcessing Time: 5-7 working days\n\n';
    
    recommendationText += '2. Housing Assistance Program\n'
        '• Rental subsidies up to RM300/month\n'
        '• Priority for affordable housing\n'
        '• Home repair assistance up to RM5000\n'
        '• Utility bill subsidies\n'
        '• Free housing consultation\n'
        '• Legal aid for housing matters\n'
        '• Emergency shelter assistance\n'
        '\nEligibility:\n'
        '• Malaysian citizen\n'
        '• No property ownership\n'
        '• Monthly household income below RM3500\n'
        '\nProcessing Time: 10-14 working days\n\n';
    
    recommendationText += '3. Family Support Scheme\n'
        '• Education subsidies for children\n'
        '• Healthcare coverage for family\n'
        '• Childcare assistance\n'
        '• School supplies allowance (RM200/child)\n'
        '• Free health screenings for family members\n'
        '• After-school program access\n'
        '• Family counseling services\n'
        '• Parenting workshops\n'
        '\nEligibility:\n'
        '• Malaysian citizen\n'
        '• Have dependent children under 18\n'
        '• Monthly household income below RM4000\n'
        '\nProcessing Time: 7-10 working days\n\n';

    setState(() {
      _messages.add(
        Message(
          text: recommendationText,
          isUser: false,
          options: [
            'Apply for Financial Aid',
            'Apply for Housing Assistance',
            'Apply for Family Support',
          ],
        ),
      );
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(text: text, isUser: true));
      _messageController.clear();
    });

    // Handle initial assessment questions
    if (_currentQuestionIndex >= 0 && _currentQuestionIndex < _initialQuestions.length) {
      switch (_currentQuestionIndex) {
        case 0:
          _assessmentAnswers['employment'] = text;
          break;
        case 1:
          _assessmentAnswers['income'] = text;
          break;
        case 2:
          _assessmentAnswers['dependents'] = text;
          break;
        case 3:
          _assessmentAnswers['challenges'] = text;
          break;
      }
      _askNextQuestion();
      return;
    }

    // Handle auto-fill form collection
    if (_userDetails.isNotEmpty && !_userDetails.containsKey('monthlyIncome')) {
      _collectUserDetails(text);
      return;
    }
  }

  void _collectUserDetails(String text) {
    if (!_userDetails.containsKey('fullName')) {
      _userDetails['fullName'] = text;
      setState(() {
        _messages.add(
          Message(
            text: '2. Please provide your NRIC/Passport Number:',
            isUser: false,
          ),
        );
      });
    } else if (!_userDetails.containsKey('nricNumber')) {
      _userDetails['nricNumber'] = text;
      setState(() {
        _messages.add(
          Message(
            text: '3. Please provide your contact number:',
            isUser: false,
          ),
        );
      });
    } else if (!_userDetails.containsKey('contactNumber')) {
      _userDetails['contactNumber'] = text;
      setState(() {
        _messages.add(
          Message(
            text: '4. Please provide your home address:',
            isUser: false,
          ),
        );
      });
    } else if (!_userDetails.containsKey('address')) {
      _userDetails['address'] = text;
      setState(() {
        _messages.add(
          Message(
            text: '5. Please provide your monthly income:',
            isUser: false,
          ),
        );
      });
    } else if (!_userDetails.containsKey('monthlyIncome')) {
      _userDetails['monthlyIncome'] = text;
      setState(() {
        _messages.add(
          Message(
            text: 'Thank you for providing your details. Please review the information below:\n\n'
                '• Full Name: ${_userDetails['fullName']}\n'
                '• NRIC/Passport: ${_userDetails['nricNumber']}\n'
                '• Contact: ${_userDetails['contactNumber']}\n'
                '• Address: ${_userDetails['address']}\n'
                '• Monthly Income: RM${_userDetails['monthlyIncome']}\n'
                '• Aid Type: $_currentAidType\n\n'
                'Would you like me to proceed with auto-filling the application form?',
            isUser: false,
            options: [
              'Yes, proceed with auto-fill',
              'No, I need to make changes',
            ],
          ),
        );
      });
    }
  }

  void _handleOptionSelected(String option) {
    if (option.startsWith('Apply for')) {
      _currentAidType = option.substring(9);
      setState(() {
        _messages.add(
          Message(
            text: 'How would you like to proceed with the $_currentAidType application?',
            isUser: false,
            options: [
              'Auto-fill application form',
              'Guide me through the steps',
            ],
          ),
        );
      });
    } else if (option == 'Auto-fill application form' || option == 'Auto-fill for me') {
      _userDetails.clear(); // Clear any existing details
      setState(() {
        _messages.add(
          Message(
            text: 'I\'ll help you fill out the application form. Please provide your details:\n\n'
                '1. What is your full name?',
            isUser: false,
          ),
        );
      });
    } else if (option == 'Guide me through the steps') {
      setState(() {
        _messages.add(
          Message(
            text: 'Here are the steps to apply:\n\n'
                '1. Download the application form\n'
                '2. Fill in your personal details\n'
                '3. Prepare supporting documents:\n'
                '   • Identity Card\n'
                '   • Proof of income\n'
                '   • Proof of residence\n'
                '4. Submit at nearest service center\n'
                '5. Wait for processing (3-5 working days)\n\n'
                'Would you like to proceed with the application?',
            isUser: false,
            options: [
              'Fill application now',
              'Auto-fill for me',
              'I\'ll do it later',
            ],
          ),
        );
      });
    } else if (option == 'Fill application now' || option == 'Fill by myself') {
      _launchApplicationWebsite();
    } else if (option == 'Yes, proceed with auto-fill') {
      setState(() {
        _messages.add(
          Message(
            text: 'Great! I\'ll start auto-filling your application form now. Please wait a moment...',
            isUser: false,
          ),
        );
      });
      // Add a delay to show the loading message before navigation
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _navigateToAutoFillScreen();
        }
      });
    } else if (option == 'No, I need to make changes') {
      _userDetails.clear(); // Clear previous details
      setState(() {
        _messages.add(
          Message(
            text: 'No problem. Let\'s start over with your details.\n\n'
                '1. What is your full name?',
            isUser: false,
          ),
        );
      });
    } else if (option == 'I\'ll do it later') {
      setState(() {
        _messages.add(
          Message(
            text: 'No problem. You can always come back later when you\'re ready to apply. Is there anything else I can help you with?',
            isUser: false,
            options: [
              'Start over',
              'No, thank you',
            ],
          ),
        );
      });
    }
  }

  void _navigateToAutoFillScreen() {
    if (_userDetails.isEmpty || !_userDetails.containsKey('monthlyIncome')) {
      // If details are not complete, start the collection process
      setState(() {
        _messages.add(
          Message(
            text: 'I\'ll help you fill out the application form. Please provide your details:\n\n'
                '1. What is your full name?',
            isUser: false,
          ),
        );
      });
      return;
    }

    try {
      // Parse monthly income with error handling
      final double monthlyIncome = double.tryParse(_userDetails['monthlyIncome']!) ?? 0.0;
      
      final applicationDetails = ApplicationDetails(
        fullName: _userDetails['fullName']!,
        nricNumber: _userDetails['nricNumber']!,
        contactNumber: _userDetails['contactNumber']!,
        address: _userDetails['address']!,
        monthlyIncome: monthlyIncome,
        aidType: _currentAidType!,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AutoFillScreen(applicationDetails: applicationDetails),
        ),
      ).catchError((error) {
        debugPrint('Navigation error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening auto-fill form'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } catch (e) {
      debugPrint('Error creating application details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error preparing application details'),
          backgroundColor: Colors.red,
        ),
      );
      
      // Clear user details and start over
      _userDetails.clear();
      setState(() {
        _messages.add(
          Message(
            text: 'I encountered an error. Let\'s start over with your details.\n\n'
                '1. What is your full name?',
            isUser: false,
          ),
        );
      });
    }
  }

  Future<void> _launchApplicationWebsite() async {
    String url = '';
    switch (_currentAidType) {
      case 'Financial Aid':
        url = 'https://example.com/financial-aid-application';
        break;
      case 'Housing Assistance':
        url = 'https://example.com/housing-assistance-application';
        break;
      case 'Family Support':
        url = 'https://example.com/family-support-application';
        break;
      default:
        url = 'https://example.com/aid-applications';
    }

    final Uri uri = Uri.parse(url);
    if (await launcher.canLaunchUrl(uri)) {
      await launcher.launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch application website'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light Blue background
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.smart_toy_outlined,
              color: Color(0xFF1A237E),
              size: 32,
            ),
            const SizedBox(width: 8),
            const Text(
              'AI Assistant',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A237E),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home,
              color: Color(0xFF1A237E),
              size: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        elevation: 0,
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
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF2196F3) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: message.isBeingRead ? Border.all(
            color: const Color(0xFF2196F3),
            width: 2,
          ) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      message.text,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: message.isUser ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (!message.isUser) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        message.isBeingRead ? Icons.volume_up : Icons.volume_up_outlined,
                        color: const Color(0xFF2196F3),
                        size: 20,
                      ),
                      onPressed: () => _speakMessage(message),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
            ),
            if (message.options != null) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: message.options!.map((option) {
                    return TextButton(
                      onPressed: () => _handleOptionSelected(option),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _toggleRecording,
            icon: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: _isRecording ? Colors.red : const Color(0xFF1A237E),
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _sendMessage(_messageController.text),
            icon: const Icon(
              Icons.send,
              color: Color(0xFF2196F3),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      // TODO: Implement voice recognition
    });
  }

  Future<void> _speakMessage(Message message) async {
    // Stop any ongoing speech
    await _flutterTts.stop();

    // Only read the main message content, not the options
    String textToRead = message.text;
    if (message.options != null) {
      int optionsIndex = textToRead.indexOf('\n\n');
      if (optionsIndex != -1) {
        textToRead = textToRead.substring(0, optionsIndex);
      }
    }

    setState(() {
      // Reset all messages' reading state
      for (var msg in _messages) {
        msg.isBeingRead = false;
      }
      message.isBeingRead = true;
    });

    await _flutterTts.speak(textToRead);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        message.isBeingRead = false;
      });
    });
  }
}