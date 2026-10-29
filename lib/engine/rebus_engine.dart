/// An individual slot inside a Rebus word row.
class RebusSlot {
  final String expectedChar; // Uppercase A-Z or punctuation (e.g. '-', ':', ''')
  final bool isPunctuation;
  String userChar;
  bool isLocked;

  RebusSlot({
    required this.expectedChar,
    this.isPunctuation = false,
    this.userChar = '',
    this.isLocked = false,
  }) {
    if (isPunctuation) {
      userChar = expectedChar;
      isLocked = true;
    }
  }

  bool get isFilled => userChar.isNotEmpty;
  bool get isCorrect => isPunctuation || userChar.toUpperCase() == expectedChar.toUpperCase();

  Map<String, dynamic> toJson() => {
        'expectedChar': expectedChar,
        'isPunctuation': isPunctuation,
        'userChar': userChar,
        'isLocked': isLocked,
      };

  factory RebusSlot.fromJson(Map<String, dynamic> json) => RebusSlot(
        expectedChar: json['expectedChar'] as String,
        isPunctuation: json['isPunctuation'] as bool? ?? false,
        userChar: json['userChar'] as String? ?? '',
        isLocked: json['isLocked'] as bool? ?? false,
      );
}

/// A dedicated word row to prevent awkward line breaks in multi-word titles.
class RebusWordRow {
  final int wordIndex;
  final List<RebusSlot> slots;

  RebusWordRow({
    required this.wordIndex,
    required this.slots,
  });

  bool get isWordComplete => slots.every((s) => s.isCorrect);

  Map<String, dynamic> toJson() => {
        'wordIndex': wordIndex,
        'slots': slots.map((s) => s.toJson()).toList(),
      };

  factory RebusWordRow.fromJson(Map<String, dynamic> json) {
    final slotsRaw = json['slots'] as List;
    final slots = slotsRaw.map((s) => RebusSlot.fromJson(s as Map<String, dynamic>)).toList();
    return RebusWordRow(
      wordIndex: json['wordIndex'] as int,
      slots: slots,
    );
  }
}

/// Rebus Level Specification.
class RebusLevel {
  final int levelNumber;
  final String titleId;
  final String originalTitle;
  final List<String> emojis;
  final String triviaFact;
  final List<String> triviaSources;
  final List<RebusWordRow> wordRows;

  RebusLevel({
    required this.levelNumber,
    required this.titleId,
    required this.originalTitle,
    required this.emojis,
    required this.triviaFact,
    required this.triviaSources,
    required this.wordRows,
  });

  /// Mystery level title before solving to prevent spoilers.
  String get displayTitle => "Level $levelNumber • Rebus";

  Map<String, dynamic> toJson() => {
        'levelNumber': levelNumber,
        'titleId': titleId,
        'originalTitle': originalTitle,
        'emojis': emojis,
        'triviaFact': triviaFact,
        'triviaSources': triviaSources,
        'wordRows': wordRows.map((w) => w.toJson()).toList(),
      };

  factory RebusLevel.fromJson(Map<String, dynamic> json) {
    final rowsRaw = json['wordRows'] as List;
    final rows = rowsRaw.map((r) => RebusWordRow.fromJson(r as Map<String, dynamic>)).toList();

    return RebusLevel(
      levelNumber: json['levelNumber'] as int,
      titleId: json['titleId'] as String,
      originalTitle: json['originalTitle'] as String,
      emojis: (json['emojis'] as List).cast<String>(),
      triviaFact: json['triviaFact'] as String,
      triviaSources: (json['triviaSources'] as List).cast<String>(),
      wordRows: rows,
    );
  }

  /// Factory helper that automatically structures multi-word titles into Dedicated Word Rows
  /// with inline fixed punctuation.
  factory RebusLevel.fromTitle({
    required int levelNumber,
    required String titleId,
    required String originalTitle,
    required List<String> emojis,
    required String triviaFact,
    required List<String> triviaSources,
  }) {
    final words = originalTitle.trim().split(RegExp(r'\s+'));
    final List<RebusWordRow> rows = [];

    for (int wIdx = 0; wIdx < words.length; wIdx++) {
      final word = words[wIdx];
      final List<RebusSlot> slots = [];

      for (int i = 0; i < word.length; i++) {
        final char = word[i].toUpperCase();
        final isAlpha = RegExp(r'[A-Z0-9]').hasMatch(char);

        slots.add(RebusSlot(
          expectedChar: char,
          isPunctuation: !isAlpha,
          userChar: !isAlpha ? char : '',
          isLocked: !isAlpha,
        ));
      }

      rows.add(RebusWordRow(wordIndex: wIdx, slots: slots));
    }

    return RebusLevel(
      levelNumber: levelNumber,
      titleId: titleId,
      originalTitle: originalTitle,
      emojis: emojis,
      triviaFact: triviaFact,
      triviaSources: triviaSources,
      wordRows: rows,
    );
  }
}

/// Pure-Dart Rebus Game Engine.
/// Handles Dedicated Word Rows, keyboard input, lifecycle focus, and 3-tier hints.
class RebusEngine {
  final RebusLevel level;

  int activeRowIndex;
  int activeSlotIndex;
  bool isSolved;

  RebusEngine(this.level)
      : activeRowIndex = 0,
        activeSlotIndex = 0,
        isSolved = false {
    _initFirstEditableSlot();
    _checkInitialSolved();
  }

  void _initFirstEditableSlot() {
    for (int r = 0; r < level.wordRows.length; r++) {
      for (int s = 0; s < level.wordRows[r].slots.length; s++) {
        if (!level.wordRows[r].slots[s].isPunctuation) {
          activeRowIndex = r;
          activeSlotIndex = s;
          return;
        }
      }
    }
  }

  void _checkInitialSolved() {
    if (_allSlotsCorrect()) {
      isSolved = true;
    }
  }

  RebusSlot? get activeSlot {
    if (activeRowIndex < 0 || activeRowIndex >= level.wordRows.length) return null;
    final row = level.wordRows[activeRowIndex];
    if (activeSlotIndex < 0 || activeSlotIndex >= row.slots.length) return null;
    return row.slots[activeSlotIndex];
  }

  void selectSlot(int rowIndex, int slotIndex) {
    if (rowIndex < 0 || rowIndex >= level.wordRows.length) return;
    final row = level.wordRows[rowIndex];
    if (slotIndex < 0 || slotIndex >= row.slots.length) return;
    if (row.slots[slotIndex].isPunctuation) return;

    activeRowIndex = rowIndex;
    activeSlotIndex = slotIndex;
  }

  /// Enter a character in the active slot.
  /// Automatically advances to next editable slot and validates puzzle completion.
  bool enterLetter(String letter) {
    if (isSolved || letter.isEmpty) return false;
    final char = letter[0].toUpperCase();
    if (!RegExp(r'[A-Z0-9]').hasMatch(char)) return false;

    final slot = activeSlot;
    if (slot == null || slot.isLocked) {
      advanceCursor();
      return false;
    }

    slot.userChar = char;

    if (_allSlotsCorrect()) {
      isSolved = true;
      _lockAllSlots();
      return true; // Newly solved!
    }

    advanceCursor();
    return false;
  }

  /// Delete character or retreat cursor.
  void backspace() {
    if (isSolved) return;
    final slot = activeSlot;
    if (slot != null && !slot.isLocked && slot.userChar.isNotEmpty) {
      slot.userChar = '';
    } else {
      retreatCursor();
      final prevSlot = activeSlot;
      if (prevSlot != null && !prevSlot.isLocked) {
        prevSlot.userChar = '';
      }
    }
  }

  void advanceCursor() {
    int r = activeRowIndex;
    int s = activeSlotIndex;

    while (r < level.wordRows.length) {
      s++;
      if (s >= level.wordRows[r].slots.length) {
        r++;
        s = -1;
        continue;
      }
      if (!level.wordRows[r].slots[s].isPunctuation && !level.wordRows[r].slots[s].isLocked) {
        activeRowIndex = r;
        activeSlotIndex = s;
        return;
      }
    }
  }

  void retreatCursor() {
    int r = activeRowIndex;
    int s = activeSlotIndex;

    while (r >= 0) {
      s--;
      if (s < 0) {
        r--;
        if (r >= 0) {
          s = level.wordRows[r].slots.length;
        }
        continue;
      }
      if (!level.wordRows[r].slots[s].isPunctuation && !level.wordRows[r].slots[s].isLocked) {
        activeRowIndex = r;
        activeSlotIndex = s;
        return;
      }
    }
  }

  bool _allSlotsCorrect() {
    for (final row in level.wordRows) {
      for (final slot in row.slots) {
        if (!slot.isCorrect) return false;
      }
    }
    return true;
  }

  void _lockAllSlots() {
    for (final row in level.wordRows) {
      for (final slot in row.slots) {
        slot.isLocked = true;
      }
    }
  }

  // --- 3-TIER HINT SYSTEM ---

  /// Hint Tier 1 (Cost: 50 Coins): Reveal starting letter of title.
  bool hintRevealStartingLetter() {
    if (isSolved) return false;
    for (final row in level.wordRows) {
      for (final slot in row.slots) {
        if (!slot.isPunctuation && !slot.isCorrect) {
          slot.userChar = slot.expectedChar;
          slot.isLocked = true;
          if (_allSlotsCorrect()) {
            isSolved = true;
            _lockAllSlots();
          }
          return true;
        }
      }
    }
    return false;
  }

  /// Hint Tier 2 (Cost: 100 Coins): Reveal a random unsolved letter.
  bool hintRevealAnotherLetter() {
    if (isSolved) return false;
    final List<RebusSlot> unsolved = [];
    for (final row in level.wordRows) {
      for (final slot in row.slots) {
        if (!slot.isPunctuation && !slot.isCorrect) {
          unsolved.add(slot);
        }
      }
    }

    if (unsolved.isEmpty) return false;
    // Reveal first unsolved found
    final target = unsolved.first;
    target.userChar = target.expectedChar;
    target.isLocked = true;

    if (_allSlotsCorrect()) {
      isSolved = true;
      _lockAllSlots();
    }
    return true;
  }

  /// Hint Tier 3 (Cost: 250 Coins): Solve entire title instantly.
  bool hintSolveTitle() {
    if (isSolved) return false;
    for (final row in level.wordRows) {
      for (final slot in row.slots) {
        slot.userChar = slot.expectedChar;
        slot.isLocked = true;
      }
    }
    isSolved = true;
    return true;
  }
}
