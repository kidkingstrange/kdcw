import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../engine/rebus_engine.dart';
import '../services/game_storage.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/hint_shop_modal.dart';
import '../widgets/native_keyboard_wrapper.dart';
import '../widgets/trivia_card_dialog.dart';

class RebusScreen extends StatefulWidget {
  final int levelNumber;
  final String levelAssetPath;

  const RebusScreen({
    super.key,
    required this.levelNumber,
    required this.levelAssetPath,
  });

  @override
  State<RebusScreen> createState() => _RebusScreenState();
}

class _RebusScreenState extends State<RebusScreen> {
  RebusEngine? _engine;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    try {
      final jsonString = await rootBundle.loadString(widget.levelAssetPath);
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      final level = RebusLevel.fromJson(jsonMap);

      setState(() {
        _engine = RebusEngine(level);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load rebus level: $e';
        _isLoading = false;
      });
    }
  }

  void _onLetterEntered(String letter) {
    if (_engine == null) return;

    final newlySolved = _engine!.enterLetter(letter);

    if (GameStorage().hapticsEnabled) {
      if (newlySolved) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }

    setState(() {});

    if (newlySolved) {
      _handleRebusSolved();
    }
  }

  void _onBackspace() {
    if (_engine == null) return;
    setState(() {
      _engine!.backspace();
    });
  }

  void _handleRebusSolved() {
    final storage = GameStorage();
    storage.completeRebusLevel(
      widget.levelNumber,
      3, // 3 stars
      titleId: _engine!.level.titleId,
    );

    TriviaCardDialog.show(
      context,
      title: _engine!.level.originalTitle,
      triviaFact: _engine!.level.triviaFact,
      sources: _engine!.level.triviaSources,
      bonusCoins: GameStorage.rebusRewardCoins + GameStorage.levelCompleteBonusCoins,
      onContinue: () {
        Navigator.of(context).pop();
      },
    );
  }

  void _openHintShop() {
    if (_engine == null) return;

    HintShopModal.show(
      context,
      isCrossword: false,
      onHintTier1: () {
        setState(() {
          if (_engine!.hintRevealStartingLetter()) {
            if (_engine!.isSolved) _handleRebusSolved();
          }
        });
      },
      onHintTier2: () {
        setState(() {
          if (_engine!.hintRevealAnotherLetter()) {
            if (_engine!.isSolved) _handleRebusSolved();
          }
        });
      },
      onHintTier3: () {
        setState(() {
          if (_engine!.hintSolveTitle()) {
            _handleRebusSolved();
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storage = GameStorage();

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryRose)),
      );
    }

    if (_error != null || _engine == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error ?? 'Unknown error')),
      );
    }

    final level = _engine!.level;
    final isSolved = _engine!.isSolved;

    return NativeKeyboardWrapper(
      onLetterEntered: _onLetterEntered,
      onBackspace: _onBackspace,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isSolved ? level.originalTitle : level.displayTitle,
            style: AppTypography.titleLarge(isDark),
          ),
          actions: [
            // Coin Counter Badge
            AnimatedBuilder(
              animation: storage,
              builder: (ctx, _) => Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldCoinLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.goldCoin, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${storage.coins}',
                      style: const TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.goldCoinDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 1. Emoji Riddle Banner (2-6 emojis)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.cellBorderDark : AppColors.cellBorderLight,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'DECODE THE EMOJI RIDDLE',
                      style: TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: AppColors.sageGreenDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: level.emojis
                          .map((emoji) => Text(
                                emoji,
                                style: const TextStyle(fontSize: 42),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),

              // 2. Dedicated Word Rows (FittedBox auto down-scaled)
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        level.wordRows.length,
                        (rIdx) => _buildDedicatedWordRow(level.wordRows[rIdx], rIdx, isDark),
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Bottom Action Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: isDark ? AppColors.bgDark : AppColors.cardLight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Hint Shop
                    OutlinedButton.icon(
                      onPressed: isSolved ? null : _openHintShop,
                      icon: const Text('💡', style: TextStyle(fontSize: 16)),
                      label: const Text('HINT SHOP'),
                    ),

                    // Backspace button for convenience
                    IconButton(
                      onPressed: isSolved ? null : _onBackspace,
                      icon: const Icon(Icons.backspace_outlined, color: AppColors.primaryRose),
                      tooltip: 'Backspace',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dedicated Word Row with FittedBox to prevent awkward mid-word line breaking
  Widget _buildDedicatedWordRow(RebusWordRow row, int rIdx, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            row.slots.length,
            (sIdx) => _buildSlot(row.slots[sIdx], rIdx, sIdx, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildSlot(RebusSlot slot, int rIdx, int sIdx, bool isDark) {
    // Non-alphanumeric punctuation rendered as fixed separator
    if (slot.isPunctuation) {
      return Container(
        width: 24,
        height: 52,
        alignment: Alignment.center,
        child: Text(
          slot.expectedChar,
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    final isSelected = _engine!.activeRowIndex == rIdx && _engine!.activeSlotIndex == sIdx;
    final isLocked = slot.isLocked || _engine!.isSolved;

    Color bgColor;
    Color borderColor;

    if (isLocked) {
      bgColor = isDark ? const Color(0xFF1E3A2B) : AppColors.mintLockLight;
      borderColor = isDark ? AppColors.mintLock : AppColors.mintLockBorder;
    } else if (isSelected) {
      bgColor = isDark ? AppColors.cellActiveDark : AppColors.cellActiveLight;
      borderColor = AppColors.primaryRose;
    } else {
      bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
      borderColor = isDark ? AppColors.cellBorderDark : AppColors.cellBorderLight;
    }

    return GestureDetector(
      onTap: () {
        if (!_engine!.isSolved) {
          setState(() {
            _engine!.selectSlot(rIdx, sIdx);
          });
        }
      },
      child: Container(
        width: 48, // 48dp minimum touch target
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          slot.userChar,
          style: AppTypography.cellLetter(isDark, isLocked: isLocked),
        ),
      ),
    );
  }
}
