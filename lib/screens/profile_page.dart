import 'package:flutter/material.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: Color(0xFFBFECFF),
        title: Text('Profile', style: TextStyle(color: Colors.black87)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFFCDC1FF),
                child: Icon(Icons.person, size: 60, color: Colors.black87),
              ),
            ),
            SizedBox(height: 24),
            _buildInfoCard('Name', '-'),
            SizedBox(height: 16),
            _buildInfoCard('Age', '-'),
            SizedBox(height: 16),
            _buildInfoCard('Profession', '-'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
              
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Logout'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFCDC1FF),
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
} 