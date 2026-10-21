import 'package:flutter/material.dart';

const kPrimary = Color(0xFF4F46E5);
const kGreen = Color(0xFF10B981);
const kRed = Color(0xFFF43F5E);
const kYellow = Color(0xFFF59E0B);
const kBg = Color(0xFFF6F7FB);
const kMuted = Color(0xFF6B7280);

final appTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: kPrimary,
  scaffoldBackgroundColor: kBg,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
  ),
);
