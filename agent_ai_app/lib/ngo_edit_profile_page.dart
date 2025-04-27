import 'package:flutter/material.dart';

class NGOEditProfilePage extends StatelessWidget {
  const NGOEditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.camera_alt, size: 50),
            ),
            const SizedBox(height: 20),
            _buildEditableField(Icons.person, 'Name', 'Yayasan'),
            _buildEditableField(Icons.format_shapes, 'Category', 'food,housing,healthcare'),
            _buildEditableField(Icons.phone, 'Phone', '0123456789'),
            _buildEditableField(Icons.email, 'Email', 'yayasan123@gmail.com'),
            _buildEditableField(Icons.map, 'Address', '123 Maple Street, Springfield'),
            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/ngo-profile');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 7, 71, 123),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(color: Color.fromARGB(255, 241, 237, 237)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(IconData icon, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
