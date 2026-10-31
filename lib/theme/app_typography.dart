import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography definitions using Fredoka for headings and Nunito for body/clues.
class AppTypography {
  static const String headingFont = 'Fredoka';
  static const String bodyFont = 'Nunito';
  static const String emojiFont = 'NotoColorEmoji';

  // Headings (Fredoka)
  static TextStyle displayLarge(bool isDark) => TextStyle(
        fontFamily: headingFont,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle headlineMedium(bool isDark) => TextStyle(
        fontFamily: headingFont,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle titleLarge(bool isDark) => TextStyle(
        fontFamily: headingFont,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle titleMedium(bool isDark) => TextStyle(
        fontFamily: headingFont,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  // Cell Letter (Crossword & Rebus)
  static TextStyle cellLetter(bool isDark, {bool isLocked = false}) => TextStyle(
        fontFamily: headingFont,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isLocked
            ? (isDark ? AppColors.mintLock : AppColors.mintLockBorder)
            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      );

  // Rebus Large Slot Letter (Enhanced Visibility)
  static TextStyle rebusSlotLetter(bool isDark, {bool isLocked = false}) => TextStyle(
        fontFamily: headingFont,
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: isLocked
            ? (isDark ? AppColors.mintLock : AppColors.mintLockBorder)
            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      );

  // Body & Clues (Nunito)
  static TextStyle bodyLarge(bool isDark) => TextStyle(
        fontFamily: bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle bodyMedium(bool isDark) => TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.35,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      );

  static TextStyle caption(bool isDark) => TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
      );

  static TextStyle labelSmall(bool isDark) => TextStyle(
        fontFamily: headingFont,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      );
}
