import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../engine/crossword_engine.dart';
import '../services/game_storage.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/hint_shop_modal.dart';
import '../widgets/native_keyboard_wrapper.dart';
import '../widgets/trivia_card_dialog.dart';

class CrosswordScreen extends StatefulWidget {
  final int levelNumber;
  final String levelAssetPath;

  const CrosswordScreen({
    super.key,
    required this.levelNumber,
    required this.levelAssetPath,
  });

  @override
  State<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends State<CrosswordScreen> {
  CrosswordEngine? _engine;
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
      final level = CrosswordLevel.fromJson(jsonMap);

      setState(() {
        _engine = CrosswordEngine(level);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load level: $e';
        _isLoading = false;
      });
    }
  }

  void _onLetterEntered(String letter) {
    if (_engine == null) return;

    final newlySolved = _engine!.enterLetter(letter);

    if (newlySolved.isNotEmpty) {
      // Award +50 coins per solved word
      GameStorage().addCoins(GameStorage.wordRewardCoins * newlySolved.length);
      if (GameStorage().hapticsEnabled) {
        HapticFeedback.mediumImpact();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Word Locked! +${GameStorage.wordRewardCoins * newlySolved.length} Coins 🪙',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: AppColors.mintLock,
        ),
      );
    } else {
      if (GameStorage().hapticsEnabled) {
        HapticFeedback.lightImpact();
      }
    }

    setState(() {});

    if (_engine!.isPuzzleComplete) {
      _handlePuzzleComplete();
    }
  }

  void _onBackspace() {
    if (_engine == null) return;
    setState(() {
      _engine!.backspace();
    });
  }

  void _handlePuzzleComplete() {
    if (GameStorage().hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }

    GameStorage().completeCrosswordLevel(
      widget.levelNumber,
      3, // 3 stars
      titleId: _engine!.level.title.toLowerCase().replaceAll(' ', '-'),
    );

    TriviaCardDialog.show(
      context,
      title: _engine!.level.title,
      triviaFact: "Solved all intersecting words for '${_engine!.level.title}'. Level completed!",
      sources: const [
        "https://en.wikipedia.org",
        "https://themoviedb.org",
      ],
      bonusCoins: GameStorage.levelCompleteBonusCoins,
      onContinue: () {
        Navigator.of(context).pop();
      },
    );
  }

  void _openHintShop() {
    if (_engine == null) return;

    HintShopModal.show(
      context,
      isCrossword: true,
      onHintTier1: () {
        setState(() {
          _engine!.hintRevealStartingLetter();
        });
        if (_engine!.isPuzzleComplete) _handlePuzzleComplete();
      },
      onHintTier2: () {
        setState(() {
          _engine!.hintRevealAnotherLetter();
        });
        if (_engine!.isPuzzleComplete) _handlePuzzleComplete();
      },
      onHintTier3: () {
        setState(() {
          _engine!.hintSolveWord();
        });
        if (_engine!.isPuzzleComplete) _handlePuzzleComplete();
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

    return NativeKeyboardWrapper(
      onLetterEntered: _onLetterEntered,
      onBackspace: _onBackspace,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Level ${widget.levelNumber} • ${_engine!.level.title}',
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
              // 1. Crossword Connected Grid Area
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _buildGrid(isDark),
                    ),
                  ),
                ),
              ),

              // 2. Active Clue Ribbon above soft keyboard
              _buildClueRibbon(isDark),

              // 3. Action Toolbar (Hint Shop & Direction Toggle)
              _buildActionBar(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(bool isDark) {
    final grid = _engine!.level.grid;
    final rows = _engine!.level.rows;
    final cols = _engine!.level.cols;

    return AspectRatio(
      aspectRatio: cols / rows,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
        ),
        itemCount: rows * cols,
        itemBuilder: (context, index) {
          final r = index ~/ cols;
          final c = index % cols;
          final cell = grid[r][c];

          return _buildCell(cell, r, c, isDark);
        },
      ),
    );
  }

  Widget _buildCell(CrosswordCell cell, int r, int c, bool isDark) {
    if (cell.isBlocked) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B1D20) : const Color(0xFFE2DDD5),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    final isSelected = _engine!.activeRow == r && _engine!.activeCol == c;
    final activeClue = _engine!.activeClue;

    // Determine if this cell belongs to the active clue word
    bool isInActiveWord = false;
    if (activeClue != null) {
      if (activeClue.direction == CrosswordDirection.across &&
          r == activeClue.startRow &&
          c >= activeClue.startCol &&
          c < activeClue.startCol + activeClue.length) {
        isInActiveWord = true;
      } else if (activeClue.direction == CrosswordDirection.down &&
          c == activeClue.startCol &&
          r >= activeClue.startRow &&
          r < activeClue.startRow + activeClue.length) {
        isInActiveWord = true;
      }
    }

    // Cell Background Styling
    Color cellBg;
    Color borderColor;

    if (cell.isLocked) {
      cellBg = isDark ? const Color(0xFF1E3A2B) : AppColors.mintLockLight;
      borderColor = isDark ? AppColors.mintLock : AppColors.mintLockBorder;
    } else if (isSelected) {
      cellBg = isDark ? AppColors.cellActiveDark : AppColors.cellActiveLight;
      borderColor = AppColors.primaryRose;
    } else if (isInActiveWord) {
      cellBg = isDark ? AppColors.cellHighlightDark : AppColors.cellHighlightLight;
      borderColor = isDark ? AppColors.cellBorderDark : AppColors.cellBorderLight;
    } else {
      cellBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
      borderColor = isDark ? AppColors.cellBorderDark : AppColors.cellBorderLight;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _engine!.selectCell(r, c);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: cellBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.5 : 1.2,
          ),
        ),
        child: Stack(
          children: [
            // Number indicator
            if (cell.number != null)
              Positioned(
                top: 2,
                left: 3,
                child: Text(
                  '${cell.number}',
                  style: TextStyle(
                    fontFamily: AppTypography.headingFont,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                  ),
                ),
              ),

            // Letter glyph
            Center(
              child: Text(
                cell.userLetter,
                style: AppTypography.cellLetter(isDark, isLocked: cell.isLocked),
              ),
            ),

            // Mint Checkmark badge when locked
            if (cell.isLocked)
              const Positioned(
                bottom: 2,
                right: 2,
                child: Icon(Icons.check, size: 10, color: AppColors.mintLock),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClueRibbon(bool isDark) {
    final clue = _engine!.activeClue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.primaryRoseLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.cellBorderDark : AppColors.primaryRose.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Direction Badge
          GestureDetector(
            onTap: () {
              setState(() {
                _engine!.toggleDirection();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryRose,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                clue != null ? '${clue.number} ${clue.direction.name.toUpperCase()}' : 'ACROSS',
                style: const TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Clue description text
          Expanded(
            child: Text(
              clue?.clue ?? 'Select a cell to view clue',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(bool isDark) {
    return Container(
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

          // Toggle Across/Down button
          IconButton(
            onPressed: () {
              setState(() {
                _engine!.toggleDirection();
              });
            },
            icon: const Icon(Icons.sync_alt, color: AppColors.primaryRose),
            tooltip: 'Toggle Direction',
          ),
        ],
      ),
    );
  }
}
