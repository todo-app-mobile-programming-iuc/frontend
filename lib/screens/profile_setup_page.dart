import 'package:flutter/material.dart';
import 'usage_type_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileSetupPage extends StatefulWidget {
  @override
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  File? _imageFile;
  final _ageController = TextEditingController();
  final _professionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: Color(0xFFBFECFF),
        title: Text('Complete Your Profile', style: TextStyle(color: Colors.black87)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Color(0xFFCDC1FF),
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? Icon(Icons.add_a_photo, size: 40, color: Colors.black87)
                      : null,
                ),
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Age',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _professionController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Profession',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UsageTypePage()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Continue'),
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

  @override
  void dispose() {
    _ageController.dispose();
    _professionController.dispose();
    super.dispose();
  }
} 