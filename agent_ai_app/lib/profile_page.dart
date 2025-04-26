import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
               SizedBox(height: 10),
               CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                child: Icon(Icons.camera_alt, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 20),
              _buildProfileItem('Name', 'Jane Tan Xiao Qi', Icons.person),
              _buildProfileItem('Age', '18', Icons.numbers),
              _buildProfileItem('Phone', '0123456789', Icons.phone),
              _buildProfileItem('Email', 'Jane123@gmail.com', Icons.email),
              _buildProfileItem('Address', '123 Maple Street, Springfield', Icons.home),
              const SizedBox(height: 30),
              SizedBox(
                width: 200,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/editprofile');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 7, 71, 123),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Edit Profile',style: TextStyle(color: Color.fromARGB(255, 241, 237, 237))),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                height: 45,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Log Out', style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String subtitle, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 30),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  )),
              const SizedBox(height: 2),
              Text(title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          )
        ],
      ),
    );
  }
}
