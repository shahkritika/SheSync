import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SheTypography {
  /// 🖤 FONT FAMILIES (Pinterest-inspired)
  static final String displayFont = GoogleFonts.playfairDisplay().fontFamily!;
  static final String bodyFont = GoogleFonts.inter().fontFamily!;
  static final String softFont = GoogleFonts.dmSans().fontFamily!;

  /// 🌸 DISPLAY (Pinterest headers)
  static TextStyle h1 = GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: Colors.black,
    letterSpacing: -0.5,
  );

  static TextStyle h2 = GoogleFonts.playfairDisplay(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: Colors.black,
    letterSpacing: -0.3,
  );

  static TextStyle h3 = GoogleFonts.playfairDisplay(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  /// 🧠 BODY (clean readability like Notion / Apple Health)
  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
    height: 1.5,
  );

  static TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black,
    height: 1.4,
  );

  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  );

  /// 💬 LABELS (Gen Z UI text, buttons, chips)
  static TextStyle label = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static TextStyle labelSmall = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  /// 🌿 CAPTION (subtle UI text)
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: Colors.black54,
  );
}