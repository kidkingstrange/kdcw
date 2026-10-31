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
  final FocusNode _keyboardFocusNode = FocusNode();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
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
          _engine!.hintRevealStartingLetter();
        });
      },
      onHintTier2: () {
        setState(() {
          _engine!.hintRevealAnotherLetter();
        });
      },
      onHintTier3: () {
        setState(() {
          _engine!.hintSolveTitle();
          if (_engine!.isSolved) {
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
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

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
      focusNode: _keyboardFocusNode,
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
              // 1. Emoji Riddle Banner with dynamic keyboard responsiveness
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: keyboardOpen ? 8 : 16,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: keyboardOpen ? 12 : 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16),
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
                        fontSize: keyboardOpen ? 11 : 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: AppColors.sageGreenDark,
                      ),
                    ),
                    SizedBox(height: keyboardOpen ? 6 : 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: level.emojis
                          .map((emoji) => Text(
                                emoji,
                                style: TextStyle(fontSize: keyboardOpen ? 30 : 42),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

              // 3. Bottom Action Bar (Hint Shop & Native Keyboard Summon)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: isDark ? AppColors.bgDark : AppColors.cardLight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Hint Shop Button
                    OutlinedButton.icon(
                      onPressed: _openHintShop,
                      icon: const Text('💡', style: TextStyle(fontSize: 16)),
                      label: const Text('HINT SHOP'),
                    ),

                    // Native Keyboard summon button
                    IconButton(
                      onPressed: () {
                        NativeKeyboardWrapper.requestKeyboard(_keyboardFocusNode);
                      },
                      icon: const Icon(Icons.keyboard, color: AppColors.sageGreenDark),
                      tooltip: 'Open Native Keyboard',
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

  Widget _buildDedicatedWordRow(RebusWordRow wordRow, int rowIdx, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            wordRow.slots.length,
            (sIdx) => _buildSlot(wordRow.slots[sIdx], rowIdx, sIdx, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildSlot(RebusSlot slot, int rIdx, int sIdx, bool isDark) {
    // Non-alphanumeric punctuation rendered as fixed separator
    if (slot.isPunctuation) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          slot.expectedChar,
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    final isSelected = _engine!.activeRowIndex == rIdx && _engine!.activeSlotIndex == sIdx;
    final isLocked = slot.isLocked;

    Color bg;
    Color borderColor;

    if (isLocked) {
      bg = isDark ? const Color(0xFF1E3A2B) : AppColors.mintLockLight;
      borderColor = isDark ? AppColors.mintLock : AppColors.mintLockBorder;
    } else if (isSelected) {
      bg = isDark ? AppColors.cellActiveDark : AppColors.cellActiveLight;
      borderColor = AppColors.primaryRose;
    } else {
      bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
      borderColor = isDark ? AppColors.cellBorderDark : AppColors.cellBorderLight;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _engine!.selectSlot(rIdx, sIdx);
        });
        NativeKeyboardWrapper.requestKeyboard(_keyboardFocusNode);
      },
      child: Container(
        width: 44,
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryRose.withValues(alpha: 0.35),
                    blurRadius: 6,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            slot.userChar,
            style: AppTypography.cellLetter(isDark, isLocked: isLocked),
          ),
        ),
      ),
    );
  }
}
