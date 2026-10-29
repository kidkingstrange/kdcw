import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/game_storage.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'crossword_screen.dart';
import 'rebus_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  final bool isCrossword; // true: Crosswords, false: Rebus

  const LevelSelectScreen({
    super.key,
    required this.isCrossword,
  });

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  List<Map<String, dynamic>> _levels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadManifest();
  }

  Future<void> _loadManifest() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/puzzles/manifest.json');
      final manifest = json.decode(jsonStr) as Map<String, dynamic>;
      final list = widget.isCrossword
          ? (manifest['crosswordLevels'] as List).cast<Map<String, dynamic>>()
          : (manifest['rebusLevels'] as List).cast<Map<String, dynamic>>();

      setState(() {
        _levels = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storage = GameStorage();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCrossword ? 'Classic Crosswords' : 'Emoji Rebus Riddles',
          style: AppTypography.titleLarge(isDark),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryRose))
          : AnimatedBuilder(
              animation: storage,
              builder: (context, _) {
                final maxUnlocked = widget.isCrossword
                    ? storage.maxUnlockedCrosswordLevel
                    : storage.maxUnlockedRebusLevel;
                final starsMap = widget.isCrossword ? storage.crosswordStars : storage.rebusStars;

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _levels.length,
                  itemBuilder: (context, idx) {
                    final levelNum = idx + 1;
                    final isUnlocked = levelNum <= maxUnlocked;
                    final stars = starsMap[levelNum] ?? 0;
                    final item = _levels[idx];
                    final filePath = item['file'] as String;

                    return _buildLevelCard(
                      levelNum: levelNum,
                      isUnlocked: isUnlocked,
                      stars: stars,
                      filePath: filePath,
                      isDark: isDark,
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildLevelCard({
    required int levelNum,
    required bool isUnlocked,
    required int stars,
    required String filePath,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => widget.isCrossword
                  ? CrosswordScreen(levelNumber: levelNum, levelAssetPath: filePath)
                  : RebusScreen(levelNumber: levelNum, levelAssetPath: filePath),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Complete Level ${levelNum - 1} to unlock this level! 🔒'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
              : (isDark ? const Color(0xFF1B1D20) : const Color(0xFFECE8E0)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? (stars > 0
                    ? AppColors.mintLock
                    : (isDark ? AppColors.cellBorderDark : AppColors.cellBorderLight))
                : (isDark ? Colors.white12 : Colors.black12),
            width: isUnlocked ? 2.0 : 1.0,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isUnlocked ? '$levelNum' : '🔒',
              style: TextStyle(
                fontFamily: AppTypography.headingFont,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isUnlocked
                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            if (isUnlocked && stars > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    size: 14,
                    color: AppColors.goldCoin,
                  ),
                ),
              )
            else if (isUnlocked)
              Text(
                'NEW',
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryRose,
                ),
              )
            else
              Text(
                'LOCKED',
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
