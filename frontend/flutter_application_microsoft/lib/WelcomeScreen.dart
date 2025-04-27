import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= 640;
    final isMediumScreen = screenSize.width <= 991 && screenSize.width > 640;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : (isMediumScreen ? 20 : 0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo placeholder
                  Container(
                    width: 118,
                    height: 115,
                    decoration: BoxDecoration(
                      color: ThemeConstants.primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Welcome text
                  Text(
                    'WELCOME',
                    style: ThemeConstants.welcomeTextStyle.copyWith(
                      fontSize: isSmallScreen ? 32 : 40,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Subtitle
                  SizedBox(
                    width: isMediumScreen || isSmallScreen ? double.infinity : 280,
                    child: Text(
                      'Your welfare journey with AI starts here.',
                      style: ThemeConstants.subtitleTextStyle.copyWith(
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Login button
                  Container(
                    width: isSmallScreen ? double.infinity : 218,
                    height: 37,
                    decoration: BoxDecoration(
                      color: ThemeConstants.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Login',
                        style: ThemeConstants.buttonTextStyle.copyWith(
                          fontSize: isSmallScreen ? 18 : 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Or text
                  Text(
                    'or',
                    style: ThemeConstants.orTextStyle,
                  ),
                  const SizedBox(height: 20),

                  // Sign Up button
                  Container(
                    width: isSmallScreen ? double.infinity : 218,
                    height: 37,
                    decoration: BoxDecoration(
                      color: ThemeConstants.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Sign Up',
                        style: ThemeConstants.buttonTextStyle.copyWith(
                          fontSize: isSmallScreen ? 18 : 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Organization link
                  Text(
                    'I\'m an Organization',
                    style: ThemeConstants.organizationTextStyle.copyWith(
                      fontSize: isSmallScreen ? 18 : 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}