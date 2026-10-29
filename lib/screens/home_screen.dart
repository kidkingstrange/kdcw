import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/game_storage.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/brand_icon.dart';
import 'level_select_screen.dart';
import 'trophy_dex_screen.dart';
import 'settings_screen.dart';
import 'crossword_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalLevelsInGame = 20; // 10 CW + 10 Rebus in prototype, 400+ in scale-up

  @override
  void initState() {
    super.initState();
    _loadManifestSummary();
  }

  Future<void> _loadManifestSummary() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/puzzles/manifest.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final cw = (data['crosswordLevels'] as List?)?.length ?? 10;
      final rb = (data['rebusLevels'] as List?)?.length ?? 10;
      if (mounted) {
        setState(() {
          _totalLevelsInGame = cw + rb;
        });
      }
    } catch (_) {}
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final storage = GameStorage();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: storage,
          builder: (context, _) {
            final completed = storage.totalLevelsCompleted;
            final progressFraction = _totalLevelsInGame > 0 ? (completed / _totalLevelsInGame).clamp(0.0, 1.0) : 0.0;
            final progressPercent = (progressFraction * 100).toInt();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // 1. Top Bar: Brand, Title & Coins
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const BrandIcon(size: 44),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'K-DRAMA',
                              style: TextStyle(
                                fontFamily: AppTypography.headingFont,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: AppColors.primaryRose,
                              ),
                            ),
                            Text(
                              'Crosswords',
                              style: TextStyle(
                                fontFamily: AppTypography.headingFont,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Coin Counter Badge
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
                const SizedBox(height: 24),

                // 2. Overall Game Progress Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.cellBorderDark : AppColors.cellBorderLight,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('OVERALL PROGRESS', style: AppTypography.labelSmall(isDark)),
                          Text(
                            '$progressPercent%',
                            style: TextStyle(
                              fontFamily: AppTypography.headingFont,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryRose,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progressFraction,
                          minHeight: 10,
                          backgroundColor: isDark ? Colors.white12 : const Color(0xFFECE7DE),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryRose),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Metric Counters
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('🏆 Trophies', '${storage.unlockedTrophyIds.length}/163', isDark),
                          _buildStatItem('⭐ Stars', '${storage.totalStarsEarned}', isDark),
                          _buildStatItem('🔥 Streak', '${storage.dailyStreak} Days', isDark),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Daily Challenge Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF332025), const Color(0xFF222428)]
                          : [AppColors.primaryRoseLight, AppColors.cardLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryRose.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRose.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🔥', style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DAILY CHALLENGE',
                              style: TextStyle(
                                fontFamily: AppTypography.headingFont,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: AppColors.primaryRose,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Crash Landing on You (2019)',
                              style: AppTypography.titleMedium(isDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              storage.lastDailyDate == _getTodayDateString()
                                  ? 'Completed today! Streak: ${storage.dailyStreak} 🔥'
                                  : 'Earn +300 Coins & keep your streak!',
                              style: AppTypography.caption(isDark),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => const CrosswordScreen(
                                levelNumber: 1,
                                levelAssetPath: 'assets/puzzles/crossword/level_crossword_001.json',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: const Size(48, 48),
                        ),
                        child: const Text('PLAY'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Game Modes Heading
                Text('GAME MODES', style: AppTypography.labelSmall(isDark)),
                const SizedBox(height: 12),

                // Mode 1: Classic Crosswords
                _buildModeCard(
                  context,
                  title: 'Classic Crosswords',
                  subtitle: 'Connected alphanumeric grids with word-locking',
                  iconEmoji: '📝',
                  badgeText: 'Level ${storage.maxUnlockedCrosswordLevel}',
                  accentColor: AppColors.primaryRose,
                  isDark: isDark,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const LevelSelectScreen(isCrossword: true),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Mode 2: Emoji Rebus Riddles
                _buildModeCard(
                  context,
                  title: 'Emoji Rebus Riddles',
                  subtitle: 'Dedicated word rows • Decode 2-6 emoji sequences',
                  iconEmoji: '🧩',
                  badgeText: 'Level ${storage.maxUnlockedRebusLevel}',
                  accentColor: AppColors.sageGreen,
                  isDark: isDark,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const LevelSelectScreen(isCrossword: false),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 5. Utility Hub: Trophy Dex & Settings
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => const TrophyDexScreen()),
                          );
                        },
                        icon: const Text('🏆', style: TextStyle(fontSize: 18)),
                        label: const Text('TROPHY DEX'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
                          );
                        },
                        icon: const Icon(Icons.settings_outlined, size: 20),
                        label: const Text('SETTINGS'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption(isDark),
        ),
      ],
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String iconEmoji,
    required String badgeText,
    required Color accentColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.cellBorderDark : AppColors.cellBorderLight,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(iconEmoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMedium(isDark)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTypography.caption(isDark)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
