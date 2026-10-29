import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'brand_icon.dart';

/// Modal dialog showing the verified behind-the-scenes trivia lore card upon puzzle completion.
class TriviaCardDialog extends StatelessWidget {
  final String title;
  final String triviaFact;
  final List<String> sources;
  final int bonusCoins;
  final VoidCallback onContinue;

  const TriviaCardDialog({
    super.key,
    required this.title,
    required this.triviaFact,
    required this.sources,
    this.bonusCoins = 200,
    required this.onContinue,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String triviaFact,
    required List<String> sources,
    int bonusCoins = 200,
    required VoidCallback onContinue,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TriviaCardDialog(
        title: title,
        triviaFact: triviaFact,
        sources: sources,
        bonusCoins: bonusCoins,
        onContinue: onContinue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Brand Icon Header
            const BrandIcon(size: 56),
            const SizedBox(height: 12),

            // Title
            Text(
              'PUZZLE SOLVED! 🎉',
              style: TextStyle(
                fontFamily: AppTypography.headingFont,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: AppColors.primaryRose,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium(isDark),
            ),
            const SizedBox(height: 16),

            // Verified Lore Card Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.sageGreenLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.cellBorderDark : AppColors.sageGreen.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        'Behind-The-Scenes Lore',
                        style: TextStyle(
                          fontFamily: AppTypography.headingFont,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? AppColors.sageGreen : AppColors.sageGreenDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    triviaFact,
                    style: AppTypography.bodyMedium(isDark),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Text(
                    'Verified Citations:',
                    style: AppTypography.caption(isDark),
                  ),
                  const SizedBox(height: 4),
                  ...sources.map((s) => Text(
                        '• $s',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFont,
                          fontSize: 11,
                          color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Coin Bonus Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.goldCoinLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.goldCoin, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    '+$bonusCoins Coins Earned!',
                    style: const TextStyle(
                      fontFamily: AppTypography.headingFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.goldCoinDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 48, // 48dp rule
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onContinue();
                },
                child: const Text('CONTINUE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
