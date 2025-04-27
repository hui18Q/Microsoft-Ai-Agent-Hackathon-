import 'package:flutter/material.dart';

class ThemeConstants {
  // Colors
  static const Color primaryBlue = Color(0xFF1B4A95);
  static const Color linkBlue = Color(0xFF013CFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Text Styles
  static const TextStyle welcomeTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: primaryBlue,
  );

  static const TextStyle subtitleTextStyle = TextStyle(
    fontFamily: 'Inclusive Sans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: black,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: white,
  );

  static const TextStyle orTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: primaryBlue,
  );

  static const TextStyle organizationTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: linkBlue,
    decoration: TextDecoration.underline,
  );
}