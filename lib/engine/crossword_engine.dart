/// Direction of word placement or active navigation in a Crossword grid.
enum CrosswordDirection { across, down }

/// Represents an individual cell within a Crossword grid.
class CrosswordCell {
  final int row;
  final int col;
  final String correctLetter; // Uppercase A-Z or empty for blocked/black cells
  final bool isBlocked;
  final int? number; // Clue number (e.g., 1, 2, 3...)
  final String? acrossClueId;
  final String? downClueId;

  String userLetter;
  bool isLocked;

  CrosswordCell({
    required this.row,
    required this.col,
    required this.correctLetter,
    this.isBlocked = false,
    this.number,
    this.acrossClueId,
    this.downClueId,
    this.userLetter = '',
    this.isLocked = false,
  });

  bool get isEmpty => userLetter.isEmpty;
  bool get isCorrect => !isBlocked && userLetter.toUpperCase() == correctLetter.toUpperCase();

  CrosswordCell copyWith({
    String? userLetter,
    bool? isLocked,
  }) {
    return CrosswordCell(
      row: row,
      col: col,
      correctLetter: correctLetter,
      isBlocked: isBlocked,
      number: number,
      acrossClueId: acrossClueId,
      downClueId: downClueId,
      userLetter: userLetter ?? this.userLetter,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  Map<String, dynamic> toJson() => {
        'row': row,
        'col': col,
        'correctLetter': correctLetter,
        'isBlocked': isBlocked,
        'number': number,
        'acrossClueId': acrossClueId,
        'downClueId': downClueId,
        'userLetter': userLetter,
        'isLocked': isLocked,
      };

  factory CrosswordCell.fromJson(Map<String, dynamic> json) => CrosswordCell(
        row: json['row'] as int,
        col: json['col'] as int,
        correctLetter: json['correctLetter'] as String? ?? '',
        isBlocked: json['isBlocked'] as bool? ?? false,
        number: json['number'] as int?,
        acrossClueId: json['acrossClueId'] as String?,
        downClueId: json['downClueId'] as String?,
        userLetter: json['userLetter'] as String? ?? '',
        isLocked: json['isLocked'] as bool? ?? false,
      );
}

/// A clue definition embedded in a crossword level.
class CrosswordClueEntry {
  final String id;
  final int number;
  final CrosswordDirection direction;
  final String clue;
  final String answer;
  final int startRow;
  final int startCol;
  final int length;

  CrosswordClueEntry({
    required this.id,
    required this.number,
    required this.direction,
    required this.clue,
    required this.answer,
    required this.startRow,
    required this.startCol,
    required this.length,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'direction': direction.name,
        'clue': clue,
        'answer': answer,
        'startRow': startRow,
        'startCol': startCol,
        'length': length,
      };

  factory CrosswordClueEntry.fromJson(Map<String, dynamic> json) => CrosswordClueEntry(
        id: json['id'] as String,
        number: json['number'] as int,
        direction: json['direction'] == 'down' ? CrosswordDirection.down : CrosswordDirection.across,
        clue: json['clue'] as String,
        answer: json['answer'] as String,
        startRow: json['startRow'] as int,
        startCol: json['startCol'] as int,
        length: json['length'] as int,
      );
}

/// Level specification for a Crossword puzzle.
class CrosswordLevel {
  final int levelNumber;
  final String title;
  final String difficulty;
  final int rows;
  final int cols;
  final List<CrosswordClueEntry> clues;
  final List<List<CrosswordCell>> grid;

  CrosswordLevel({
    required this.levelNumber,
    required this.title,
    required this.difficulty,
    required this.rows,
    required this.cols,
    required this.clues,
    required this.grid,
  });

  Map<String, dynamic> toJson() => {
        'levelNumber': levelNumber,
        'title': title,
        'difficulty': difficulty,
        'rows': rows,
        'cols': cols,
        'clues': clues.map((c) => c.toJson()).toList(),
        'grid': grid.map((row) => row.map((cell) => cell.toJson()).toList()).toList(),
      };

  factory CrosswordLevel.fromJson(Map<String, dynamic> json) {
    final gridRaw = json['grid'] as List;
    final grid = gridRaw
        .map((row) => (row as List).map((cell) => CrosswordCell.fromJson(cell as Map<String, dynamic>)).toList())
        .toList();

    final cluesRaw = json['clues'] as List;
    final clues = cluesRaw.map((c) => CrosswordClueEntry.fromJson(c as Map<String, dynamic>)).toList();

    return CrosswordLevel(
      levelNumber: json['levelNumber'] as int,
      title: json['title'] as String,
      difficulty: json['difficulty'] as String? ?? 'Medium',
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      clues: clues,
      grid: grid,
    );
  }
}

/// Pure-Dart Crossword Game Engine.
/// Decoupled from Flutter UI for 90%+ unit test coverage.
class CrosswordEngine {
  final CrosswordLevel level;

  int activeRow;
  int activeCol;
  CrosswordDirection activeDirection;

  // Track solved words to avoid duplicate coin rewards (+50 per word)
  final Set<String> _solvedClueIds = {};

  CrosswordEngine(this.level)
      : activeRow = 0,
        activeCol = 0,
        activeDirection = CrosswordDirection.across {
    _initSelection();
  }

  void _initSelection() {
    // Find the first non-blocked cell in the grid
    for (int r = 0; r < level.rows; r++) {
      for (int c = 0; c < level.cols; c++) {
        if (!level.grid[r][c].isBlocked) {
          activeRow = r;
          activeCol = c;
          if (level.grid[r][c].acrossClueId != null) {
            activeDirection = CrosswordDirection.across;
          } else if (level.grid[r][c].downClueId != null) {
            activeDirection = CrosswordDirection.down;
          }
          return;
        }
      }
    }
  }

  CrosswordCell get activeCell => level.grid[activeRow][activeCol];

  CrosswordClueEntry? get activeClue {
    final cell = activeCell;
    final clueId = activeDirection == CrosswordDirection.across ? cell.acrossClueId : cell.downClueId;
    if (clueId == null) return null;
    return level.clues.firstWhere(
      (c) => c.id == clueId,
      orElse: () => level.clues.first,
    );
  }

  /// Select a cell. If tapping the already selected cell without explicit direction, toggles direction.
  void selectCell(int r, int c, {CrosswordDirection? direction}) {
    if (r < 0 || r >= level.rows || c < 0 || c >= level.cols) return;
    if (level.grid[r][c].isBlocked) return;

    if (direction != null) {
      activeRow = r;
      activeCol = c;
      activeDirection = direction;
      return;
    }

    if (activeRow == r && activeCol == c) {
      toggleDirection();
    } else {
      activeRow = r;
      activeCol = c;
      // If the current direction does not exist for this cell, flip direction
      final currentClueId =
          activeDirection == CrosswordDirection.across ? activeCell.acrossClueId : activeCell.downClueId;
      if (currentClueId == null) {
        activeDirection = activeDirection == CrosswordDirection.across
            ? CrosswordDirection.down
            : CrosswordDirection.across;
      }
    }
  }

  /// Toggle direction between Across and Down.
  void toggleDirection() {
    final newDir = activeDirection == CrosswordDirection.across
        ? CrosswordDirection.down
        : CrosswordDirection.across;
    final hasNewDirClue =
        newDir == CrosswordDirection.across ? activeCell.acrossClueId != null : activeCell.downClueId != null;

    if (hasNewDirClue) {
      activeDirection = newDir;
    }
  }

  /// Enter a character in the active cell.
  /// Returns list of newly solved clue IDs (if any word locked as a result).
  List<String> enterLetter(String letter) {
    if (letter.isEmpty) return [];
    final char = letter[0].toUpperCase();
    if (!RegExp(r'[A-Z]').hasMatch(char)) return [];

    final cell = activeCell;
    if (cell.isLocked) {
      advanceCursor();
      return [];
    }

    cell.userLetter = char;

    final newlySolved = checkAndLockWords();
    advanceCursor();
    return newlySolved;
  }

  /// Delete the current character or move to previous cell.
  void backspace() {
    final cell = activeCell;
    if (!cell.isLocked && cell.userLetter.isNotEmpty) {
      cell.userLetter = '';
    } else {
      retreatCursor();
      final prevCell = activeCell;
      if (!prevCell.isLocked) {
        prevCell.userLetter = '';
      }
    }
  }

  /// Advance cursor forward to next cell in active direction.
  void advanceCursor() {
    int r = activeRow;
    int c = activeCol;

    if (activeDirection == CrosswordDirection.across) {
      while (c + 1 < level.cols) {
        c++;
        if (!level.grid[r][c].isBlocked) {
          activeRow = r;
          activeCol = c;
          return;
        }
      }
    } else {
      while (r + 1 < level.rows) {
        r++;
        if (!level.grid[r][c].isBlocked) {
          activeRow = r;
          activeCol = c;
          return;
        }
      }
    }
  }

  /// Retreat cursor backward to previous cell in active direction.
  void retreatCursor() {
    int r = activeRow;
    int c = activeCol;

    if (activeDirection == CrosswordDirection.across) {
      while (c - 1 >= 0) {
        c--;
        if (!level.grid[r][c].isBlocked) {
          activeRow = r;
          activeCol = c;
          return;
        }
      }
    } else {
      while (r - 1 >= 0) {
        r--;
        if (!level.grid[r][c].isBlocked) {
          activeRow = r;
          activeCol = c;
          return;
        }
      }
    }
  }

  /// Check each clue to see if it is completely and correctly solved.
  /// If so, marks all corresponding cells as `isLocked = true`.
  /// Returns the IDs of newly solved clues.
  List<String> checkAndLockWords() {
    final List<String> newlySolved = [];

    for (final clue in level.clues) {
      if (_solvedClueIds.contains(clue.id)) continue;

      bool wordCompleteAndCorrect = true;
      final List<CrosswordCell> clueCells = [];

      for (int i = 0; i < clue.length; i++) {
        final r = clue.direction == CrosswordDirection.across ? clue.startRow : clue.startRow + i;
        final c = clue.direction == CrosswordDirection.across ? clue.startCol + i : clue.startCol;

        final cell = level.grid[r][c];
        clueCells.add(cell);

        if (cell.userLetter.toUpperCase() != cell.correctLetter.toUpperCase()) {
          wordCompleteAndCorrect = false;
          break;
        }
      }

      if (wordCompleteAndCorrect) {
        for (final cell in clueCells) {
          cell.isLocked = true;
        }
        _solvedClueIds.add(clue.id);
        newlySolved.add(clue.id);
      }
    }

    return newlySolved;
  }

  /// Check if the whole crossword puzzle is solved.
  bool get isPuzzleComplete {
    for (int r = 0; r < level.rows; r++) {
      for (int c = 0; c < level.cols; c++) {
        final cell = level.grid[r][c];
        if (!cell.isBlocked) {
          if (!cell.isLocked || !cell.isCorrect) {
            return false;
          }
        }
      }
    }
    return true;
  }

  // --- 3-TIER HINT SYSTEM ---

  /// Hint Tier 1 (Cost: 50 Coins): Reveal starting letter of active word.
  bool hintRevealStartingLetter() {
    final clue = activeClue;
    if (clue == null) return false;

    final cell = level.grid[clue.startRow][clue.startCol];
    if (cell.isLocked) return false;

    cell.userLetter = cell.correctLetter;
    checkAndLockWords();
    return true;
  }

  /// Hint Tier 2 (Cost: 100 Coins): Reveal a random unsolved letter in active word.
  bool hintRevealAnotherLetter() {
    final clue = activeClue;
    if (clue == null) return false;

    for (int i = 0; i < clue.length; i++) {
      final r = clue.direction == CrosswordDirection.across ? clue.startRow : clue.startRow + i;
      final c = clue.direction == CrosswordDirection.across ? clue.startCol + i : clue.startCol;
      final cell = level.grid[r][c];

      if (!cell.isCorrect) {
        cell.userLetter = cell.correctLetter;
        checkAndLockWords();
        return true;
      }
    }

    return false;
  }

  /// Hint Tier 3 (Cost: 250 Coins): Solve and lock entire active word.
  bool hintSolveWord() {
    final clue = activeClue;
    if (clue == null) return false;

    for (int i = 0; i < clue.length; i++) {
      final r = clue.direction == CrosswordDirection.across ? clue.startRow : clue.startRow + i;
      final c = clue.direction == CrosswordDirection.across ? clue.startCol + i : clue.startCol;
      final cell = level.grid[r][c];
      cell.userLetter = cell.correctLetter;
    }

    checkAndLockWords();
    return true;
  }
}
