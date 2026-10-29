import 'package:flutter/material.dart';

/// Semantic Design Tokens for K-Drama Crosswords.
/// Based on the Pastel Rose & Sage Palette.
class AppColors {
  // Pastel Rose Palette
  static const Color primaryRose = Color(0xFFD9727F);
  static const Color primaryRoseLight = Color(0xFFFCECEF);
  static const Color primaryRoseDark = Color(0xFFA64B57);
  static const Color primaryRoseHover = Color(0xFFE28591);

  // Sage Green Palette
  static const Color sageGreen = Color(0xFF7E9F8E);
  static const Color sageGreenLight = Color(0xFFEBF2EE);
  static const Color sageGreenDark = Color(0xFF5A7869);

  // Mint Lock (Solved & Verified Crossword Cells)
  static const Color mintLock = Color(0xFF52B788);
  static const Color mintLockLight = Color(0xFFD8F3DC);
  static const Color mintLockBorder = Color(0xFF2D6A4F);

  // Gold Coin & Star Accents
  static const Color goldCoin = Color(0xFFE9A825);
  static const Color goldCoinLight = Color(0xFFFFF3D6);
  static const Color goldCoinDark = Color(0xFFB57D10);

  // Light Mode Surfaces & Canvas
  static const Color bgLight = Color(0xFFFBF9F6);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF7F4EE);
  static const Color cellBorderLight = Color(0xFFD8D2C8);
  static const Color cellActiveLight = Color(0xFFFFF1F3);
  static const Color cellHighlightLight = Color(0xFFF5E6E8);

  // Light Mode Typography
  static const Color textPrimaryLight = Color(0xFF2D2B2A);
  static const Color textSecondaryLight = Color(0xFF736B65);
  static const Color textMutedLight = Color(0xFFA39A92);

  // Dark Mode Canvas & Surfaces
  static const Color bgDark = Color(0xFF161719);
  static const Color surfaceDark = Color(0xFF222428);
  static const Color cardDark = Color(0xFF2B2E33);
  static const Color cellBorderDark = Color(0xFF3F444D);
  static const Color cellActiveDark = Color(0xFF4A252B);
  static const Color cellHighlightDark = Color(0xFF382327);

  // Dark Mode Typography
  static const Color textPrimaryDark = Color(0xFFF5F3EF);
  static const Color textSecondaryDark = Color(0xFFA59E97);
  static const Color textMutedDark = Color(0xFF6E6862);

  // Status Colors
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color errorRedLight = Color(0xFFFFEBEE);
  static const Color streakFlame = Color(0xFFFF5722);
}
