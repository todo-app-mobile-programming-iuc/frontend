import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AIPage extends StatefulWidget {
  @override
  _AIPageState createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  final _secureStorage = FlutterSecureStorage();
  bool _isTyping = false;

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = Message(
      text: _messageController.text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    final response = await _sendToBackend();

    if (response != null) {
      final aiMessage = Message(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMessage);
        _isTyping = false;
      });

      _scrollToBottom();
    }
  }

  Future<String?> _sendToBackend() async {
    final token = await _getUserToken();
    if (token == null) {
      print('Failed to get user token');
      return null;
    }

    final url = Uri.parse('https://backend.ahmetcanisik5458675.workers.dev/ai');
    print('token: $token');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final messages = _messages.map((message) {
      return {
        'role': message.isUser ? 'user' : 'assistant',
        'content': message.text,
      };
    }).toList();

    // Fetch todos and alarms
    final todos = await _getTodos();
    final alarms = await _getAlarms();

    // system instruction message
    final instruction = "You are a friendly assistant that helps users with their todos and alarms. Here are the user's todos: $todos and alarms: $alarms.";

    final body = jsonEncode({
      'messages': [
        {'role': 'system', 'content': instruction},
        ...messages,
      ],
    });
    print('body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return decodedData['response'];
      } else {
        print('Failed to get response from backend');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<String?> _getUserToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<List<Map<String, dynamic>>> _getTodos() async {
    // Fetch todos from storage or API
    // Example:
    final todos = [
      {'title': 'Buy groceries', 'isCompleted': false},
      {'title': 'Walk the dog', 'isCompleted': true},
    ];
    return todos;
  }

  Future<List<Map<String, dynamic>>> _getAlarms() async {
    // Fetch alarms from storage or API
    // Example:
    final alarms = [
      {'time': '07:00 AM', 'sound': 'Default'},
      {'time': '08:00 AM', 'sound': 'Birds'},
    ];
    return alarms;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: message.isUser ? Color(0xFFFFCCEA) : Color(0xFFBFECFF),
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: Color(0xFFBFECFF),
        title: Text('AI Assistant', style: TextStyle(color: Colors.black87)),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFCDC1FF),
              Color(0xFFF6E3FF),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.psychology,
                            size: 64,
                            color: Colors.black54,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Start a conversation with AI',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(8),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessage(_messages[index]);
                      },
                    ),
            ),
            if (_isTyping)
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFBFECFF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'AI is typing...',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFBFECFF),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFCCEA),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: Icon(Icons.send),
                      color: Colors.black87,
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}