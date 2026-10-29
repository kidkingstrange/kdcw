import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/game_storage.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/trivia_card_dialog.dart';

class TrophyDexScreen extends StatefulWidget {
  const TrophyDexScreen({super.key});

  @override
  State<TrophyDexScreen> createState() => _TrophyDexScreenState();
}

class _TrophyDexScreenState extends State<TrophyDexScreen> {
  List<Map<String, dynamic>> _allTitles = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;

  final List<String> _filters = [
    'All',
    'tvN',
    'JTBC',
    'Netflix',
    'SBS',
    'KBS2',
    'MBC',
    'Disney+',
  ];

  @override
  void initState() {
    super.initState();
    _loadTitles();
  }

  Future<void> _loadTitles() async {
    try {
      final jsonStr = await rootBundle.loadString('content/titles.json');
      final list = (json.decode(jsonStr) as List).cast<Map<String, dynamic>>();
      setState(() {
        _allTitles = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredTitles {
    if (_selectedFilter == 'All') return _allTitles;
    return _allTitles.where((t) {
      final studio = (t['creatorOrStudio'] as String? ?? '').toLowerCase();
      return studio.contains(_selectedFilter.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storage = GameStorage();

    return Scaffold(
      appBar: AppBar(
        title: Text('Trophy Dex', style: AppTypography.titleLarge(isDark)),
        actions: [
          AnimatedBuilder(
            animation: storage,
            builder: (ctx, _) => Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.sageGreenLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.sageGreen, width: 1.5),
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    '${storage.unlockedTrophyIds.length} / ${_allTitles.length}',
                    style: TextStyle(
                      fontFamily: AppTypography.headingFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.black87 : AppColors.sageGreenDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryRose))
          : Column(
              children: [
                // Filter Tabs Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: _filters.map((f) {
                      final isSelected = _selectedFilter == f;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(f),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedFilter = f;
                              });
                            }
                          },
                          selectedColor: AppColors.primaryRose,
                          labelStyle: TextStyle(
                            fontFamily: AppTypography.headingFont,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Grid of Titles / Trophies
                Expanded(
                  child: AnimatedBuilder(
                    animation: storage,
                    builder: (context, _) {
                      final titles = _filteredTitles;
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.88,
                        ),
                        itemCount: titles.length,
                        itemBuilder: (ctx, idx) {
                          final item = titles[idx];
                          final id = item['id'] as String;
                          final isUnlocked = storage.unlockedTrophyIds.contains(id);

                          return _buildTrophyCard(item, isUnlocked, isDark);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTrophyCard(Map<String, dynamic> item, bool isUnlocked, bool isDark) {
    final title = item['title'] as String;
    final year = item['year'] as int;
    final studio = item['creatorOrStudio'] as String;
    final emojis = (item['emojiCandidates'] as List?)?.cast<String>() ?? [];
    final fact = (item['facts'] as List?)?.isNotEmpty == true
        ? item['facts'][0]['text'] as String
        : 'Verified K-Drama Trivia Fact.';
    final sources = (item['facts'] as List?)?.isNotEmpty == true
        ? (item['facts'][0]['sources'] as List).cast<String>()
        : ['https://en.wikipedia.org', 'https://themoviedb.org'];

    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          TriviaCardDialog.show(
            context,
            title: title,
            triviaFact: fact,
            sources: sources,
            bonusCoins: 0,
            onContinue: () {},
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solve this drama\'s crossword or rebus level to unlock this lore card! 🔒'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnlocked
              ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
              : (isDark ? const Color(0xFF1C1E22) : const Color(0xFFEFECE6)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? (isDark ? AppColors.sageGreen : AppColors.sageGreen.withValues(alpha: 0.5))
                : (isDark ? AppColors.cellBorderDark : AppColors.cellBorderLight),
            width: isUnlocked ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isUnlocked ? (emojis.isNotEmpty ? emojis.first : '🫰') : '🔒',
                  style: const TextStyle(fontSize: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isUnlocked ? AppColors.sageGreenLight : Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$year',
                    style: TextStyle(
                      fontFamily: AppTypography.headingFont,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? AppColors.sageGreenDark : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              isUnlocked ? title : 'Locked Trophy',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.headingFont,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isUnlocked
                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                    : (isDark ? Colors.white38 : Colors.black38),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isUnlocked ? studio.split('/')[0].trim() : 'Complete level to unlock',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.bodyFont,
                fontSize: 11,
                color: isUnlocked
                    ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                    : (isDark ? Colors.white24 : Colors.black26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
