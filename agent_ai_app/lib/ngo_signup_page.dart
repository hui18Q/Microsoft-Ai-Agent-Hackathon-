import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class NGOSignUpPage extends StatefulWidget {
  const NGOSignUpPage({super.key});

  @override
  State<NGOSignUpPage> createState() => _NGOSignUpPageState();
}

class _NGOSignUpPageState extends State<NGOSignUpPage> {
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  bool rememberMe = false;
  String? organizationType;
  String? countryRegion;
  PlatformFile? certificateFile;
  final List<String> organizationTypes = ['NGO', 'Government', 'Corporate', 'Private'];
  final List<String> countries = ['Malaysia', 'UK', 'US', 'Canada', 'Australia', 'India'];

  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          certificateFile = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: ${e.toString()}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    passwordVisible = false;
    confirmPasswordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF043258),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Create your account to start your journey with us.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),

            // Organization Name TextField
            SizedBox(
              width: 280,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Organization Name*',
                  hintText: 'Enter your organization name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Organization Type Dropdown
            SizedBox(
              width: 280,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Organization Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                value: organizationType,
                items: organizationTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    organizationType = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Country & Region Dropdown
            SizedBox(
              width: 280,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Country & Region*',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                value: countryRegion,
                items: countries.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    countryRegion = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Registration Certificate Upload
            SizedBox(
              width: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Organization Registration Certificate*',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _pickPDF,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.upload_file),
                        const SizedBox(width: 8),
                        Text(
                          certificateFile?.name ?? 'Upload PDF Certificate',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (certificateFile != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Selected: ${certificateFile!.name}',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Password TextField
            SizedBox(
              width: 280,
              child: TextField(
                obscureText: !passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Password*',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Confirm Password TextField
            SizedBox(
              width: 280,
              child: TextField(
                obscureText: !confirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password*',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  suffixIcon: IconButton(
                    icon: Icon(
                      confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        confirmPasswordVisible = !confirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Remember me checkbox
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (value) {
                    setState(() {
                      rememberMe = value ?? false;
                    });
                  },
                ),
                const Text('Remember me'),
              ],
            ),

            // Sign Up button
            SizedBox(
              width: 200,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  // Validate form and proceed with sign up
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 7, 71, 123),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(color: Color.fromARGB(255, 241, 237, 237)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Login text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?'),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/ngo-login'); // Go back to Login
                  },
                  child: const Text('Log In'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}