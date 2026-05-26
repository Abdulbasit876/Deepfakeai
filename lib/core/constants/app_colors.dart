import 'package:flutter/material.dart';

class AppColors {
  // Dark Mode Colors
  static const Color darkBgStart = Color(0xFF0A0915);
  static const Color darkBgEnd = Color(0xFF121124);
  static const Color darkCardBg = Color(0xFF181734);
  static const Color darkCardBorder = Color(0xFF25234D);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFA0A0CB);

  // Light Mode Colors
  static const Color lightBgStart = Color(0xFFF5F5FA);
  static const Color lightBgEnd = Color(0xFFFFFFFF);
  static const Color lightCardBg = Colors.white;
  static const Color lightCardBorder = Color(0xFFE2E2F0);
  static const Color lightTextPrimary = Color(0xFF0A0915);
  static const Color lightTextSecondary = Color(0xFF6B6A85);

  // High-Tech Accents (Shared / Adjusted for contrast)
  static const Color neonBlue = Color(0xFF3A86FF);
  static const Color electricViolet = Color(0xFF8338EC);
  static const Color neonPink = Color(0xFFFF006E);
  static const Color successGreen = Color(0xFF00F5A0);
  static const Color warningOrange = Color(0xFFFF9F1C);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonBlue, electricViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [electricViolet, neonPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient borderGradient = LinearGradient(
    colors: [Color(0xFF3A86FF), Color(0xFFFF006E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient bgGradient(bool isDark) {
    return LinearGradient(
      colors: isDark 
          ? [darkBgStart, darkBgEnd] 
          : [lightBgStart, lightBgEnd],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static Color cardBg(bool isDark) => isDark ? darkCardBg : lightCardBg;
  static Color cardBorder(bool isDark) => isDark ? darkCardBorder : lightCardBorder;
  static Color textPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
}
