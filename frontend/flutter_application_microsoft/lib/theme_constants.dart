import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConstants {
  // Colors
  static const Color primaryBlue = Color.fromARGB(255, 201, 222, 239);
  
  // Text Styles
  static final TextStyle appBarTextStyle = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static final TextStyle headerTextStyle = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static final TextStyle subtitleTextStyle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black54,
  );

  static final TextStyle dashboardValueTextStyle = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static final TextStyle dashboardTitleTextStyle = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
  );

  static final TextStyle buttonTextStyle = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // Welcome Screen Text Styles
  static final TextStyle welcomeTextStyle = GoogleFonts.poppins(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static final TextStyle orTextStyle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black54,
  );

  static final TextStyle organizationTextStyle = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: primaryBlue,
  );
} 