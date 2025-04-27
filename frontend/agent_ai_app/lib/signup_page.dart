import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  bool rememberMe = false;

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

            // Email TextField
            SizedBox(
              width: 280,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Email*',
                  hintText: 'johndoe@xyz.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
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
                    Navigator.pushNamed(context, '/reset-password');
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
                    Navigator.pushNamed(context, '/ngo-login');
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
