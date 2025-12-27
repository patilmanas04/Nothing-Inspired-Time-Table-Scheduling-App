import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NothingTheme {
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color red = Color(0xFFD71921);
  static const Color grey = Color(0xFF808080);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color green = Color(0xFF00C853);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: white,
      primaryColor: black,
      colorScheme: const ColorScheme.light(
        primary: black,
        secondary: red,
        surface: white,
        onPrimary: white,
        onSecondary: white,
        onSurface: black,
      ),
      textTheme: _textTheme(black, white),
      appBarTheme: const AppBarTheme(
        backgroundColor: offWhite,
        foregroundColor: black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Ndot',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: black,
        ),
      ),
      checkboxTheme: _checkboxTheme(black, white),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: black,
      primaryColor: white,
      colorScheme: const ColorScheme.dark(
        primary: white,
        secondary: red,
        surface: black,
        onPrimary: black,
        onSecondary: black,
        onSurface: white,
      ),
      textTheme: _textTheme(white, black),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212), // Slightly lighter black for AppBar
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Ndot',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: white,
        ),
      ),
      checkboxTheme: _checkboxTheme(white, black),
    );
  }

  static TextTheme _textTheme(Color color, Color onColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Ndot',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      displayMedium: GoogleFonts.getFont(
        'Orbitron',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      displaySmall: GoogleFonts.getFont(
        'Orbitron',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      bodyLarge: GoogleFonts.getFont(
        'JetBrains Mono',
        fontSize: 16,
        color: color,
      ),
      bodyMedium: GoogleFonts.getFont(
        'JetBrains Mono',
        fontSize: 14,
        color: color,
      ),
      labelLarge: GoogleFonts.getFont(
        'Orbitron',
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: onColor,
      ),
    );
  }

  static CheckboxThemeData _checkboxTheme(Color color, Color onColor) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return red;
        }
        return onColor; // Background of checkbox when unchecked
      }),
      checkColor: WidgetStateProperty.all(onColor), // Checkmark color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
      side: BorderSide(color: color, width: 2),
    );
  }
}
