import 'package:flutter_test/flutter_test.dart';
import 'package:kdrama_crosswords/engine/crossword_engine.dart';

void main() {
  group('CrosswordCell & ClueEntry Tests', () {
    test('Cell serialization roundtrip', () {
      final cell = CrosswordCell(
        row: 1,
        col: 2,
        correctLetter: 'K',
        isBlocked: false,
        number: 1,
        acrossClueId: 'clue-1',
        downClueId: 'clue-2',
        userLetter: 'K',
        isLocked: true,
      );

      final json = cell.toJson();
      final fromJson = CrosswordCell.fromJson(json);

      expect(fromJson.row, 1);
      expect(fromJson.col, 2);
      expect(fromJson.correctLetter, 'K');
      expect(fromJson.userLetter, 'K');
      expect(fromJson.isLocked, true);
      expect(fromJson.isCorrect, true);
      expect(fromJson.isEmpty, false);
    });

    test('ClueEntry serialization roundtrip', () {
      final clue = CrosswordClueEntry(
        id: 'clue-1',
        number: 1,
        direction: CrosswordDirection.across,
        clue: 'Hit 2016 romance drama',
        answer: 'GOBLIN',
        startRow: 2,
        startCol: 1,
        length: 6,
      );

      final json = clue.toJson();
      final fromJson = CrosswordClueEntry.fromJson(json);

      expect(fromJson.id, 'clue-1');
      expect(fromJson.number, 1);
      expect(fromJson.direction, CrosswordDirection.across);
      expect(fromJson.answer, 'GOBLIN');
      expect(fromJson.length, 6);
    });

    test('CrosswordLevel serialization roundtrip and copyWith', () {
      final cell = CrosswordCell(row: 0, col: 0, correctLetter: 'A');
      final updatedCell = cell.copyWith(userLetter: 'B', isLocked: true);
      expect(updatedCell.userLetter, 'B');
      expect(updatedCell.isLocked, true);

      final level = CrosswordLevel(
        levelNumber: 42,
        title: 'Test Level',
        difficulty: 'Hard',
        rows: 1,
        cols: 1,
        clues: [
          CrosswordClueEntry(
            id: 'c-1',
            number: 1,
            direction: CrosswordDirection.down,
            clue: 'Single letter down',
            answer: 'A',
            startRow: 0,
            startCol: 0,
            length: 1,
          )
        ],
        grid: [[cell]],
      );

      final levelJson = level.toJson();
      final fromJson = CrosswordLevel.fromJson(levelJson);
      expect(fromJson.levelNumber, 42);
      expect(fromJson.title, 'Test Level');
      expect(fromJson.difficulty, 'Hard');
      expect(fromJson.clues.first.direction, CrosswordDirection.down);
    });
  });

  group('CrosswordEngine Gameplay & Logic Tests', () {
    late CrosswordLevel mockLevel;

    setUp(() {
      // Create a 3x3 simple test grid with 1 across clue and 1 down clue
      // [K][O][R] (Across 1: KOR)
      // [A][#][#]
      // [T][#][#] (Down 1: KAT)
      final grid = List.generate(
        3,
        (r) => List.generate(
          3,
          (c) => CrosswordCell(
            row: r,
            col: c,
            correctLetter: '',
            isBlocked: true,
          ),
        ),
      );

      // Across 1: row 0, cols 0, 1, 2 ('K', 'O', 'R')
      grid[0][0] = CrosswordCell(
        row: 0,
        col: 0,
        correctLetter: 'K',
        number: 1,
        acrossClueId: 'c-across',
        downClueId: 'c-down',
      );
      grid[0][1] = CrosswordCell(
        row: 0,
        col: 1,
        correctLetter: 'O',
        acrossClueId: 'c-across',
      );
      grid[0][2] = CrosswordCell(
        row: 0,
        col: 2,
        correctLetter: 'R',
        acrossClueId: 'c-across',
      );

      // Down 1: col 0, rows 0, 1, 2 ('K', 'A', 'T')
      grid[1][0] = CrosswordCell(
        row: 1,
        col: 0,
        correctLetter: 'A',
        downClueId: 'c-down',
      );
      grid[2][0] = CrosswordCell(
        row: 2,
        col: 0,
        correctLetter: 'T',
        downClueId: 'c-down',
      );

      mockLevel = CrosswordLevel(
        levelNumber: 1,
        title: 'Korean Test',
        difficulty: 'Easy',
        rows: 3,
        cols: 3,
        clues: [
          CrosswordClueEntry(
            id: 'c-across',
            number: 1,
            direction: CrosswordDirection.across,
            clue: 'Abbreviation for Korea',
            answer: 'KOR',
            startRow: 0,
            startCol: 0,
            length: 3,
          ),
          CrosswordClueEntry(
            id: 'c-down',
            number: 1,
            direction: CrosswordDirection.down,
            clue: 'Feline companion test',
            answer: 'KAT',
            startRow: 0,
            startCol: 0,
            length: 3,
          ),
        ],
        grid: grid,
      );
    });

    test('Initializes with first non-blocked cell and active clue', () {
      final engine = CrosswordEngine(mockLevel);
      expect(engine.activeRow, 0);
      expect(engine.activeCol, 0);
      expect(engine.activeDirection, CrosswordDirection.across);
      expect(engine.activeClue?.id, 'c-across');
    });

    test('selectCell and direction toggling', () {
      final engine = CrosswordEngine(mockLevel);

      // Tapping same cell toggles direction
      engine.selectCell(0, 0);
      expect(engine.activeDirection, CrosswordDirection.down);
      expect(engine.activeClue?.id, 'c-down');

      engine.selectCell(0, 0);
      expect(engine.activeDirection, CrosswordDirection.across);

      // Selecting cell with only across direction
      engine.selectCell(0, 2);
      expect(engine.activeRow, 0);
      expect(engine.activeCol, 2);
      expect(engine.activeDirection, CrosswordDirection.across);

      // Out of bounds selection is ignored
      engine.selectCell(99, 99);
      expect(engine.activeRow, 0);
      expect(engine.activeCol, 2);

      // Blocked cell selection is ignored
      engine.selectCell(1, 1);
      expect(engine.activeRow, 0);
      expect(engine.activeCol, 2);
    });

    test('Letter entry, auto-advance, and word-locking', () {
      final engine = CrosswordEngine(mockLevel);

      engine.selectCell(0, 0, direction: CrosswordDirection.across);
      final s1 = engine.enterLetter('k'); // lower case normalized to K
      expect(s1, isEmpty);
      expect(engine.level.grid[0][0].userLetter, 'K');

      // Auto-advanced to (0, 1)
      expect(engine.activeRow, 0);
      expect(engine.activeCol, 1);

      final s2 = engine.enterLetter('O');
      expect(s2, isEmpty);

      // Auto-advanced to (0, 2)
      expect(engine.activeRow, 0);
      expect(engine.activeCol, 2);

      // Enter final letter of 'c-across'
      final s3 = engine.enterLetter('R');
      expect(s3, contains('c-across'));

      // Check that all cells of 'c-across' are now locked
      expect(engine.level.grid[0][0].isLocked, true);
      expect(engine.level.grid[0][1].isLocked, true);
      expect(engine.level.grid[0][2].isLocked, true);

      // Entering another letter in locked cell skips/advances without overwriting
      engine.selectCell(0, 0, direction: CrosswordDirection.across);
      final s4 = engine.enterLetter('Z');
      expect(s4, isEmpty);
      expect(engine.level.grid[0][0].userLetter, 'K');
    });

    test('Non-alphabetical character entry is ignored', () {
      final engine = CrosswordEngine(mockLevel);
      engine.selectCell(0, 1, direction: CrosswordDirection.across);
      final s = engine.enterLetter('1');
      expect(s, isEmpty);
      expect(engine.level.grid[0][1].userLetter, '');
    });

    test('Backspace functionality', () {
      final engine = CrosswordEngine(mockLevel);
      engine.selectCell(0, 1, direction: CrosswordDirection.across);
      engine.enterLetter('O');
      expect(engine.level.grid[0][1].userLetter, 'O');

      // Cursor is at (0, 2). Backspace deletes current empty and retreats to (0, 1)
      engine.backspace();
      expect(engine.level.grid[0][1].userLetter, '');

      // Down direction advance and retreat
      engine.selectCell(0, 0, direction: CrosswordDirection.down);
      engine.advanceCursor();
      expect(engine.activeRow, 1);
      expect(engine.activeCol, 0);

      engine.retreatCursor();
      expect(engine.activeRow, 0);
      expect(engine.activeCol, 0);
    });

    test('Full puzzle completion detection', () {
      final engine = CrosswordEngine(mockLevel);
      expect(engine.isPuzzleComplete, false);

      // Complete across: K, O, R
      engine.selectCell(0, 0, direction: CrosswordDirection.across);
      engine.enterLetter('K');
      engine.enterLetter('O');
      engine.enterLetter('R');

      // Complete down: (0,0) is already K, enter A at (1,0) and T at (2,0)
      engine.selectCell(1, 0, direction: CrosswordDirection.down);
      engine.enterLetter('A');
      engine.enterLetter('T');

      expect(engine.isPuzzleComplete, true);
    });

    test('3-Tier Hint Shop operations', () {
      final engine = CrosswordEngine(mockLevel);

      // Tier 1: Reveal starting letter of across
      engine.selectCell(0, 0, direction: CrosswordDirection.across);
      final h1 = engine.hintRevealStartingLetter();
      expect(h1, true);
      expect(engine.level.grid[0][0].userLetter, 'K');

      // Tier 2: Reveal another letter in across
      final h2 = engine.hintRevealAnotherLetter();
      expect(h2, true);
      expect(engine.level.grid[0][1].userLetter, 'O');

      // Tier 3: Solve entire word
      final h3 = engine.hintSolveWord();
      expect(h3, true);
      expect(engine.level.grid[0][2].userLetter, 'R');
      expect(engine.level.grid[0][2].isLocked, true);
    });
  });
}
