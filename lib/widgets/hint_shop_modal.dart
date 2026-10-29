import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/game_storage.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// 3-Tier Progressive Hint Shop Modal.
/// Tier 1 (50 Coins): Reveal Starting Letter
/// Tier 2 (100 Coins): Reveal Another Letter
/// Tier 3 (250 Coins): Solve Entire Word / Title
class HintShopModal extends StatelessWidget {
  final bool isCrossword; // true: Crossword Word, false: Rebus Title
  final VoidCallback onHintTier1;
  final VoidCallback onHintTier2;
  final VoidCallback onHintTier3;

  const HintShopModal({
    super.key,
    required this.isCrossword,
    required this.onHintTier1,
    required this.onHintTier2,
    required this.onHintTier3,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isCrossword,
    required VoidCallback onHintTier1,
    required VoidCallback onHintTier2,
    required VoidCallback onHintTier3,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HintShopModal(
        isCrossword: isCrossword,
        onHintTier1: onHintTier1,
        onHintTier2: onHintTier2,
        onHintTier3: onHintTier3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = GameStorage();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: storage,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? AppColors.cellBorderDark : AppColors.cellBorderLight,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title & Balance Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text('Hint Shop', style: AppTypography.headlineMedium(isDark)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.goldCoinLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.goldCoin, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '${storage.coins}',
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
                ],
              ),
              const SizedBox(height: 20),

              // Tier 1: Reveal Starting Letter (50 Coins)
              _buildHintTier(
                context,
                isDark: isDark,
                tierNum: 1,
                title: 'Reveal Starting Letter',
                description: isCrossword
                    ? 'Fills in the first letter of the active word.'
                    : 'Unlocks the first letter of this K-Drama title.',
                cost: GameStorage.hint1Cost,
                currentCoins: storage.coins,
                onBuy: () {
                  if (storage.spendCoins(GameStorage.hint1Cost)) {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop();
                    onHintTier1();
                  }
                },
              ),
              const SizedBox(height: 12),

              // Tier 2: Reveal Another Letter (100 Coins)
              _buildHintTier(
                context,
                isDark: isDark,
                tierNum: 2,
                title: 'Reveal Another Letter',
                description: 'Uncovers a random unsolved letter tile.',
                cost: GameStorage.hint2Cost,
                currentCoins: storage.coins,
                onBuy: () {
                  if (storage.spendCoins(GameStorage.hint2Cost)) {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop();
                    onHintTier2();
                  }
                },
              ),
              const SizedBox(height: 12),

              // Tier 3: Solve Entire Word / Title (250 Coins)
              _buildHintTier(
                context,
                isDark: isDark,
                tierNum: 3,
                title: isCrossword ? 'Solve Entire Word' : 'Solve Entire Title',
                description: isCrossword
                    ? 'Instantly verifies and locks the active crossword word.'
                    : 'Solves and confirms the full K-Drama title.',
                cost: GameStorage.hint3Cost,
                currentCoins: storage.coins,
                onBuy: () {
                  if (storage.spendCoins(GameStorage.hint3Cost)) {
                    HapticFeedback.heavyImpact();
                    Navigator.of(context).pop();
                    onHintTier3();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHintTier(
    BuildContext context, {
    required bool isDark,
    required int tierNum,
    required String title,
    required String description,
    required int cost,
    required int currentCoins,
    required VoidCallback onBuy,
  }) {
    final canAfford = currentCoins >= cost;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.cellBorderDark : AppColors.cellBorderLight,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMedium(isDark)),
                const SizedBox(height: 4),
                Text(description, style: AppTypography.caption(isDark)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: canAfford ? onBuy : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canAfford ? AppColors.primaryRose : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              minimumSize: const Size(48, 48), // 48dp rule
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text('$cost', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
