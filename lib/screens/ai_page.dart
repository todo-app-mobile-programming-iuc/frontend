import 'package:flutter/material.dart';

class AIPage extends StatelessWidget {
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
        child: Center(
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
                'AI Assistant Coming Soon',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 