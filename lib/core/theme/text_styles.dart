import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deepfake_ai/core/constants/app_colors.dart';

class AppTextStyles {
  static TextStyle getHeadingLarge(bool isDark) => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary(isDark),
      );

  static TextStyle getHeadingMedium(bool isDark) => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary(isDark),
      );

  static TextStyle getHeadingSmall(bool isDark) => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary(isDark),
      );

  static TextStyle getBodyLarge(bool isDark) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary(isDark),
      );

  static TextStyle getBodyMedium(bool isDark) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary(isDark),
      );

  static TextStyle getBodySmall(bool isDark) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary(isDark),
      );

  static TextStyle getLabelLarge(bool isDark) => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary(isDark),
      );

  static TextStyle getLabelMedium(bool isDark) => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary(isDark),
      );

  static TextStyle getLabelSmall(bool isDark) => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary(isDark),
      );
}
