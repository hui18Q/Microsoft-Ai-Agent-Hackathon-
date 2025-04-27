
import 'signup_page.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
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
                'Forgot Password',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF043258),
                ),
              ),
              const SizedBox(height: 10),
              
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
              
              SizedBox(
                width: 200,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login'); // make sure '/login' route exists!
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 7, 71, 123),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      color: Color.fromARGB(255, 241, 237, 237),
                    ),
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
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
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
