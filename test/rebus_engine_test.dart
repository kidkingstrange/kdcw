import 'package:flutter_test/flutter_test.dart';
import 'package:kdrama_crosswords/engine/rebus_engine.dart';

void main() {
  group('RebusSlot & WordRow Tests', () {
    test('Slot serialization and punctuation handling', () {
      final slotAlpha = RebusSlot(expectedChar: 'S');
      expect(slotAlpha.isPunctuation, false);
      expect(slotAlpha.isLocked, false);
      expect(slotAlpha.isFilled, false);

      final slotPunct = RebusSlot(expectedChar: '-', isPunctuation: true);
      expect(slotPunct.isPunctuation, true);
      expect(slotPunct.isLocked, true);
      expect(slotPunct.userChar, '-');
      expect(slotPunct.isCorrect, true);

      final json = slotAlpha.toJson();
      final fromJson = RebusSlot.fromJson(json);
      expect(fromJson.expectedChar, 'S');

      // Word row serialization
      final row = RebusWordRow(wordIndex: 0, slots: [slotAlpha, slotPunct]);
      final rowJson = row.toJson();
      final fromRowJson = RebusWordRow.fromJson(rowJson);
      expect(fromRowJson.wordIndex, 0);
      expect(fromRowJson.slots.length, 2);
    });

    test('RebusLevel.fromTitle creates Dedicated Word Rows correctly and serializes', () {
      final level = RebusLevel.fromTitle(
        levelNumber: 1,
        titleId: 'squid-game-2021',
        originalTitle: 'Squid Game',
        emojis: ['🦑', '🍭'],
        triviaFact: 'Lee Jung-jae won an Emmy.',
        triviaSources: ['https://source1.com', 'https://source2.com'],
      );

      expect(level.wordRows.length, 2); // Two dedicated word rows!
      expect(level.wordRows[0].slots.length, 5); // S-Q-U-I-D
      expect(level.wordRows[1].slots.length, 4); // G-A-M-E
      expect(level.displayTitle, 'Level 1 • Rebus'); // Mystery title hides spoiler

      final levelJson = level.toJson();
      final fromLevelJson = RebusLevel.fromJson(levelJson);
      expect(fromLevelJson.titleId, 'squid-game-2021');
      expect(fromLevelJson.originalTitle, 'Squid Game');
      expect(fromLevelJson.emojis.first, '🦑');
    });

    test('RebusLevel handles punctuation within words as fixed separators', () {
      final level = RebusLevel.fromTitle(
        levelNumber: 2,
        titleId: 'its-okay-thats-love-2014',
        originalTitle: "It's Okay",
        emojis: ['🧠', '❤️'],
        triviaFact: 'Destigmatized psychiatric illnesses.',
        triviaSources: ['https://source1.com', 'https://source2.com'],
      );

      // "It's" -> I, T, ', S (apostrophe is locked punctuation)
      final row0 = level.wordRows[0];
      expect(row0.slots[2].isPunctuation, true);
      expect(row0.slots[2].userChar, "'");
      expect(row0.slots[2].isLocked, true);
    });
  });

  group('RebusEngine Logic & Gameplay Tests', () {
    late RebusLevel mockLevel;

    setUp(() {
      mockLevel = RebusLevel.fromTitle(
        levelNumber: 1,
        titleId: 'squid-game-2021',
        originalTitle: 'Squid Game',
        emojis: ['🦑', '🍭'],
        triviaFact: 'Emmy award winner.',
        triviaSources: ['https://s1.com', 'https://s2.com'],
      );
    });

    test('Initializes with first editable slot', () {
      final engine = RebusEngine(mockLevel);
      expect(engine.activeRowIndex, 0);
      expect(engine.activeSlotIndex, 0);
      expect(engine.isSolved, false);
      expect(engine.activeSlot?.expectedChar, 'S');
    });

    test('selectSlot respects boundaries and skips punctuation', () {
      final engine = RebusEngine(mockLevel);

      engine.selectSlot(1, 0); // Select 'G' in "Game"
      expect(engine.activeRowIndex, 1);
      expect(engine.activeSlotIndex, 0);
      expect(engine.activeSlot?.expectedChar, 'G');

      // Out of bounds selection is ignored
      engine.selectSlot(10, 10);
      expect(engine.activeRowIndex, 1);
      expect(engine.activeSlotIndex, 0);
    });

    test('Letter entry auto-advances across word boundaries', () {
      final engine = RebusEngine(mockLevel);

      // Type "SQUID"
      engine.enterLetter('s');
      expect(engine.level.wordRows[0].slots[0].userChar, 'S');
      expect(engine.activeSlotIndex, 1); // Advanced to Q

      engine.enterLetter('q');
      engine.enterLetter('u');
      engine.enterLetter('i');
      engine.enterLetter('d');

      // Now cursor crosses boundary to Word Row 1 (Game), slot 0
      expect(engine.activeRowIndex, 1);
      expect(engine.activeSlotIndex, 0);
      expect(engine.isSolved, false);
    });

    test('Solving all slots completes puzzle and locks all slots', () {
      final engine = RebusEngine(mockLevel);

      // Enter Word 1: SQUID
      for (final ch in 'SQUID'.split('')) {
        engine.enterLetter(ch);
      }

      // Enter Word 2: GAM
      for (final ch in 'GAM'.split('')) {
        engine.enterLetter(ch);
      }

      expect(engine.isSolved, false);

      // Enter final 'E'
      final newlySolved = engine.enterLetter('E');
      expect(newlySolved, true);
      expect(engine.isSolved, true);

      // All slots are now locked
      for (final row in engine.level.wordRows) {
        for (final slot in row.slots) {
          expect(slot.isLocked, true);
          expect(slot.isCorrect, true);
        }
      }
    });

    test('Backspace deletes character or retreats cursor', () {
      final engine = RebusEngine(mockLevel);
      engine.enterLetter('S');
      expect(engine.level.wordRows[0].slots[0].userChar, 'S');

      // Cursor is at slot 1 (empty). Backspace retreats to slot 0 and clears
      engine.backspace();
      expect(engine.level.wordRows[0].slots[0].userChar, '');
    });

    test('3-Tier Hint Shop operations', () {
      final engine = RebusEngine(mockLevel);

      // Tier 1: Reveal first letter ('S')
      final h1 = engine.hintRevealStartingLetter();
      expect(h1, true);
      expect(engine.level.wordRows[0].slots[0].userChar, 'S');
      expect(engine.level.wordRows[0].slots[0].isLocked, true);

      // Tier 2: Reveal another letter ('Q')
      final h2 = engine.hintRevealAnotherLetter();
      expect(h2, true);
      expect(engine.level.wordRows[0].slots[1].userChar, 'Q');

      // Tier 3: Solve entire title
      final h3 = engine.hintSolveTitle();
      expect(h3, true);
      expect(engine.isSolved, true);

      // Calling hints or letter entry when already solved returns false
      expect(engine.enterLetter('A'), false);
      expect(engine.hintRevealStartingLetter(), false);
      expect(engine.hintRevealAnotherLetter(), false);
      expect(engine.hintSolveTitle(), false);

      // Backspace when solved is a no-op
      engine.backspace();
    });
  });
}
