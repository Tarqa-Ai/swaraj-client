import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class SwarajTypography {
  SwarajTypography._();

  // Syne - Headline Font
  static TextStyle headline({
    double fontSize = 28.0,
    FontWeight fontWeight = FontWeight.bold,
    Color color = SwarajColors.navy,
  }) {
    return GoogleFonts.syne(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // DM Sans - Body Font
  static TextStyle body({
    double fontSize = 15.0,
    FontWeight fontWeight = FontWeight.normal,
    Color color = SwarajColors.slate,
  }) {
    return GoogleFonts.dmSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.5,
    );
  }

  // Space Mono - Mono Font (Badges, Codes, Labels)
  static TextStyle mono({
    double fontSize = 11.0,
    FontWeight fontWeight = FontWeight.bold,
    Color color = SwarajColors.slateLight,
    double letterSpacing = 0.1,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
