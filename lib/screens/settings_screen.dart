import 'package:flutter/material.dart';
import '../services/game_storage.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/brand_icon.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GameStorage();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.titleLarge(isDark)),
      ),
      body: AnimatedBuilder(
        animation: storage,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Brand Icon Header
              Center(
                child: Column(
                  children: [
                    const BrandIcon(size: 72),
                    const SizedBox(height: 12),
                    Text(
                      'K-Drama Crosswords',
                      style: AppTypography.headlineMedium(isDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 1.0.0 • Premium Offline Edition',
                      style: AppTypography.caption(isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Game Preferences Section
              Text(
                'PREFERENCES',
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppColors.primaryRose,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.cellBorderDark : AppColors.cellBorderLight,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('Dark Theme', style: AppTypography.bodyLarge(isDark)),
                      subtitle: Text('Sleek nighttime aesthetic', style: AppTypography.caption(isDark)),
                      value: storage.isDarkMode,
                      activeThumbColor: AppColors.primaryRose,
                      onChanged: (val) => storage.toggleDarkMode(val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text('Haptic Feedback', style: AppTypography.bodyLarge(isDark)),
                      subtitle: Text('Vibrations on cell entry & solves', style: AppTypography.caption(isDark)),
                      value: storage.hapticsEnabled,
                      activeThumbColor: AppColors.primaryRose,
                      onChanged: (val) => storage.toggleHaptics(val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text('Sound Effects', style: AppTypography.bodyLarge(isDark)),
                      subtitle: Text('Audio chimes on word locks', style: AppTypography.caption(isDark)),
                      value: storage.soundEnabled,
                      activeThumbColor: AppColors.primaryRose,
                      onChanged: (val) => storage.toggleSound(val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Strict Legal & IP Shield Section
              Text(
                'LEGAL & ZERO-DATA PRIVACY',
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppColors.sageGreenDark,
                ),
              ),
              const SizedBox(height: 12),

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
                        const Text('🛡️', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          '100% Offline & Private',
                          style: TextStyle(
                            fontFamily: AppTypography.headingFont,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.sageGreen : AppColors.sageGreenDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This application runs 100% offline on your device with zero internet permissions. It contains no advertisements, no tracking SDKs, no analytics, and collects zero personal data.',
                      style: AppTypography.bodyMedium(isDark),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Text(
                      'Fan Trivia Disclaimer:',
                      style: TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unofficial fan trivia game. Not affiliated with, sponsored by, or endorsed by any television network, production studio, streaming platform, or copyright holder. All drama titles, character references, and trademarks are the property of their respective owners.',
                      style: AppTypography.caption(isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Danger Zone: Reset Progress
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset All Progress?'),
                        content: const Text(
                          'This will reset your coins to 100, lock completed levels, and clear unlocked trophies. This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () {
                              storage.resetProgress();
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Game progress reset!')),
                              );
                            },
                            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
                            child: const Text('RESET'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                  label: const Text(
                    'Reset Game Progress',
                    style: TextStyle(color: AppColors.errorRed),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
