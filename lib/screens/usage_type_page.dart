import 'package:flutter/material.dart';
import 'home_page.dart';

class UsageTypePage extends StatelessWidget {
  final List<UsageType> _usageTypes = [
    UsageType(
      title: 'Work',
      icon: Icons.work,
      description: 'Manage work tasks and projects',
    ),
    UsageType(
      title: 'School',
      icon: Icons.school,
      description: 'Track assignments and study schedules',
    ),
    UsageType(
      title: 'Home',
      icon: Icons.home,
      description: 'Organize household tasks and routines',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: Color(0xFFBFECFF),
        title: Text('How will you use Yetiştir?', 
          style: TextStyle(color: Colors.black87)),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _usageTypes.length,
        itemBuilder: (context, index) {
          final type = _usageTypes[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            color: Color(0xFFCDC1FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: Icon(type.icon, size: 32),
              title: Text(
                type.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(type.description),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class UsageType {
  final String title;
  final IconData icon;
  final String description;

  UsageType({
    required this.title,
    required this.icon,
    required this.description,
  });
} 