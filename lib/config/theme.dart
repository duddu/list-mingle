import 'package:flutter/material.dart';

const double basePadding = 16;
const double baseRadius = basePadding;
const double taskHeight = 62;

const Color paletteColor1 = Color(0xFF2B3A55);
const Color paletteColor2 = Color(0xFFCE7777);
const Color paletteColor3 = Color(0xFFE8C4C4);
const Color paletteColor4 = Color(0xFFF2E5E5);

final ThemeData appThemeData = ThemeData(
    fontFamily: 'Open Sans',
    colorScheme: ColorScheme.fromSeed(
        seedColor: paletteColor1,
        primary: paletteColor1,
        secondary: paletteColor2,
        tertiary: paletteColor3,
        inverseSurface: paletteColor4,
        secondaryContainer: paletteColor3,
        onSecondaryContainer: Colors.black87,
        background: Colors.grey.shade50,
        brightness: Brightness.light),
    textTheme: const TextTheme(
        headlineLarge: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w500,
            height: 1.35,
            letterSpacing: 0.2),
        headlineMedium: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w500,
            height: 1.25,
            letterSpacing: 0.2),
        headlineSmall: TextStyle(
            color: paletteColor1,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.2,
            letterSpacing: -0.25),
        titleMedium: TextStyle(
            color: paletteColor1,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0),
        bodyLarge: TextStyle(
          color: Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.25,
          letterSpacing: 0.1,
        ),
        bodyMedium: TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.2,
          letterSpacing: 0.1,
        ),
        bodySmall: TextStyle(
          color: Colors.black87,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.2,
          letterSpacing: 0.1,
        )));
