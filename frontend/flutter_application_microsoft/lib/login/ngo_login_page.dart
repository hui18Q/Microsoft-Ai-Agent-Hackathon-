import 'forgot_password_page.dart';
import 'ngo_signup_page.dart';
import 'package:flutter/material.dart';

class NGOLoginPage extends StatefulWidget {
  const NGOLoginPage({super.key});

  @override
  State<NGOLoginPage> createState() => _NGOLoginPageState();
}

class _NGOLoginPageState extends State<NGOLoginPage> {
  bool rememberMe = false;
  bool passwordVisible = false;

  @override
  void initState() {
    super.initState();
    passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF043258),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Welcome back —we’re here ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'whenever you need us.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 280,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Email*',
                    hintText: 'yayasan@gmail.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 8),
              // Forget Password aligned to right
              SizedBox(
                width: 280,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                      );
                    },
                    child: const Text(
                      'Forget Password?',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Remember Me centered
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
                    'Login',
                    style: TextStyle(color: Color.fromARGB(255, 241, 237, 237)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don’t have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NGOSignUpPage()),
                      );
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text('or continue with'),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Image.asset('assets/facebook.png', width: 40, height: 40),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Image.asset('assets/google.png', width: 40, height: 40),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Image.asset('assets/apple.png', width: 40, height: 40),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
