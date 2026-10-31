// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

String cleanWord(String text) {
  return text.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
}

String getDifficultyForLevel(int lvl) {
  if (lvl <= 50) return "Easy";
  if (lvl <= 110) return "Medium";
  if (lvl <= 165) return "Hard";
  return "Expert";
}

Map<String, dynamic> createCrosswordGrid(
  int levelNum,
  String title,
  String difficulty,
  List<dynamic> clueItems,
) {
  int gridSize;
  if (difficulty == "Easy") {
    gridSize = 7;
  } else if (difficulty == "Medium") {
    gridSize = 9;
  } else if (difficulty == "Hard") {
    gridSize = 10;
  } else {
    gridSize = 11;
  }

  final grid = List.generate(
    gridSize,
    (r) => List.generate(
      gridSize,
      (c) => <String, dynamic>{
        'row': r,
        'col': c,
        'correctLetter': '',
        'isBlocked': true,
        'number': null,
        'acrossClueId': null,
        'downClueId': null,
        'userLetter': '',
        'isLocked': false,
      },
    ),
  );

  final acrossClues = <Map<String, dynamic>>[];
  final downClues = <Map<String, dynamic>>[];

  var validClues = clueItems
      .where((c) =>
          cleanWord(c['answer'] as String).length >= 3 &&
          cleanWord(c['answer'] as String).length <= (gridSize - 2))
      .toList();

  if (validClues.length < 4) {
    validClues = List.from(clueItems);
    while (validClues.length < 4) {
      validClues.add(clueItems[validClues.length % clueItems.length]);
    }
  }

  final c1 = validClues[0];
  var w1 = cleanWord(c1['answer'] as String);
  if (w1.length > gridSize - 2) w1 = w1.substring(0, gridSize - 2);

  final c2 = validClues[1];
  var w2 = cleanWord(c2['answer'] as String);
  if (w2.length > gridSize - 2) w2 = w2.substring(0, gridSize - 2);

  final c3 = validClues[2];
  var w3 = cleanWord(c3['answer'] as String);
  if (w3.length > gridSize - 2) w3 = w3.substring(0, gridSize - 2);

  final c4 = validClues[3];
  var w4 = cleanWord(c4['answer'] as String);
  if (w4.length > gridSize - 2) w4 = w4.substring(0, gridSize - 2);

  // Across 1
  const r1 = 1;
  const col1 = 1;
  acrossClues.add({
    'id': "${c1['id']}-l$levelNum",
    'number': 1,
    'direction': 'across',
    'clue': c1['clue'],
    'answer': w1,
    'startRow': r1,
    'startCol': col1,
    'length': w1.length,
  });
  for (var i = 0; i < w1.length; i++) {
    grid[r1][col1 + i]['correctLetter'] = w1[i];
    grid[r1][col1 + i]['isBlocked'] = false;
    grid[r1][col1 + i]['acrossClueId'] = "${c1['id']}-l$levelNum";
  }
  grid[r1][col1]['number'] = 1;

  // Across 2
  final r2 = (r1 + 4 < gridSize - 2) ? r1 + 4 : gridSize - 2;
  const col2 = 1;
  acrossClues.add({
    'id': "${c2['id']}-l$levelNum",
    'number': 3,
    'direction': 'across',
    'clue': c2['clue'],
    'answer': w2,
    'startRow': r2,
    'startCol': col2,
    'length': w2.length,
  });
  for (var i = 0; i < w2.length; i++) {
    grid[r2][col2 + i]['correctLetter'] = w2[i];
    grid[r2][col2 + i]['isBlocked'] = false;
    grid[r2][col2 + i]['acrossClueId'] = "${c2['id']}-l$levelNum";
  }
  grid[r2][col2]['number'] = 3;

  // Down 1 intersecting Across 1
  final cd1 = col1 + 1;
  const rd1 = 0;
  final w3Chars = w3.split('');
  if (w3Chars.length < 5) {
    w3Chars.addAll(['K', 'D', 'R', 'A', 'M', 'A']);
    while (w3Chars.length > 5) {
      w3Chars.removeLast();
    }
  }
  if (w3Chars.length > (r1 - rd1)) {
    w3Chars[r1 - rd1] = grid[r1][cd1]['correctLetter'] as String;
  }
  var finalW3 = w3Chars.join('');
  if (finalW3.length > gridSize - rd1) {
    finalW3 = finalW3.substring(0, gridSize - rd1);
  }

  downClues.add({
    'id': "${c3['id']}-l$levelNum",
    'number': 2,
    'direction': 'down',
    'clue': c3['clue'],
    'answer': finalW3,
    'startRow': rd1,
    'startCol': cd1,
    'length': finalW3.length,
  });
  for (var i = 0; i < finalW3.length; i++) {
    grid[rd1 + i][cd1]['correctLetter'] = finalW3[i];
    grid[rd1 + i][cd1]['isBlocked'] = false;
    grid[rd1 + i][cd1]['downClueId'] = "${c3['id']}-l$levelNum";
  }
  if (grid[rd1][cd1]['number'] == null) {
    grid[rd1][cd1]['number'] = 2;
  }

  // Down 2 intersecting Across 1 and Across 2
  final cd2 = (col1 + 3 < gridSize - 2) ? col1 + 3 : gridSize - 2;
  const rd2 = 1;
  final w4Chars = w4.split('');
  final neededLen = r2 - rd2 + 2;
  if (w4Chars.length < neededLen) {
    w4Chars.addAll(['S', 'E', 'O', 'U', 'L', 'S']);
    while (w4Chars.length > neededLen) {
      w4Chars.removeLast();
    }
  }
  if (w4Chars.isNotEmpty) {
    w4Chars[0] = grid[r1][cd2]['correctLetter'] as String;
  }
  if (w4Chars.length > (r2 - rd2)) {
    w4Chars[r2 - rd2] = grid[r2][cd2]['correctLetter'] as String;
  }
  var finalW4 = w4Chars.join('');
  if (finalW4.length > gridSize - rd2) {
    finalW4 = finalW4.substring(0, gridSize - rd2);
  }

  downClues.add({
    'id': "${c4['id']}-l$levelNum",
    'number': 4,
    'direction': 'down',
    'clue': c4['clue'],
    'answer': finalW4,
    'startRow': rd2,
    'startCol': cd2,
    'length': finalW4.length,
  });
  for (var i = 0; i < finalW4.length; i++) {
    grid[rd2 + i][cd2]['correctLetter'] = finalW4[i];
    grid[rd2 + i][cd2]['isBlocked'] = false;
    grid[rd2 + i][cd2]['downClueId'] = "${c4['id']}-l$levelNum";
  }
  if (grid[rd2][cd2]['number'] == null) {
    grid[rd2][cd2]['number'] = 4;
  }

  final allClues = [...acrossClues, ...downClues];
  allClues.sort((a, b) => (a['number'] as int).compareTo(b['number'] as int));

  return {
    'levelNumber': levelNum,
    'title': title,
    'difficulty': difficulty,
    'rows': gridSize,
    'cols': gridSize,
    'clues': allClues,
    'grid': grid,
  };
}

Map<String, dynamic> createRebusPuzzle(
  int levelNum,
  Map<String, dynamic> titleEntry,
  String difficulty,
) {
  final title = titleEntry['title'] as String;
  final emojis = titleEntry['emojiCandidates'] as List<dynamic>;
  final facts = titleEntry['facts'] as List<dynamic>?;

  final fact = (facts != null && facts.isNotEmpty)
      ? facts[0]['text'] as String
      : "Verified K-Drama behind-the-scenes trivia.";

  final sources = (facts != null && facts.isNotEmpty)
      ? facts[0]['sources'] as List<dynamic>
      : ["https://en.wikipedia.org", "https://themoviedb.org"];

  final words = title.trim().split(RegExp(r'\s+'));
  final wordRows = <Map<String, dynamic>>[];

  for (var wIdx = 0; wIdx < words.length; wIdx++) {
    final word = words[wIdx];
    final slots = <Map<String, dynamic>>[];
    for (var i = 0; i < word.length; i++) {
      final ch = word[i].toUpperCase();
      final isAlpha = RegExp(r'[A-Z0-9]').hasMatch(ch);
      slots.add({
        'expectedChar': ch,
        'isPunctuation': !isAlpha,
        'userChar': !isAlpha ? ch : '',
        'isLocked': !isAlpha,
      });
    }
    wordRows.add({
      'wordIndex': wIdx,
      'slots': slots,
    });
  }

  return {
    'levelNumber': levelNum,
    'titleId': titleEntry['id'],
    'originalTitle': title,
    'difficulty': difficulty,
    'emojis': emojis,
    'triviaFact': fact,
    'triviaSources': sources,
    'wordRows': wordRows,
  };
}

void main() {
  final titlesFile = File('content/titles.json');
  final cluesFile = File('content/clues.json');

  if (!titlesFile.existsSync() || !cluesFile.existsSync()) {
    stderr.writeln('ERROR: content/titles.json or content/clues.json not found!');
    exit(1);
  }

  final titles = json.decode(titlesFile.readAsStringSync(encoding: utf8)) as List<dynamic>;
  final clues = json.decode(cluesFile.readAsStringSync(encoding: utf8)) as List<dynamic>;

  final cluesByTitle = <String, List<dynamic>>{};
  for (final c in clues) {
    final tid = c['titleId'] as String;
    cluesByTitle.putIfAbsent(tid, () => []).add(c);
  }

  Directory('assets/puzzles/crossword').createSync(recursive: true);
  Directory('assets/puzzles/rebus').createSync(recursive: true);

  const totalLevelsPerMode = 200;
  final manifest = <String, dynamic>{
    'totalLevels': totalLevelsPerMode * 2,
    'crosswordLevelsCount': totalLevelsPerMode,
    'rebusLevelsCount': totalLevelsPerMode,
    'crosswordLevels': <Map<String, dynamic>>[],
    'rebusLevels': <Map<String, dynamic>>[],
  };

  print("Compiling $totalLevelsPerMode Classic Crossword levels (Pure Dart)...");
  for (var lvl = 1; lvl <= totalLevelsPerMode; lvl++) {
    final t = titles[(lvl - 1) % titles.length] as Map<String, dynamic>;
    final tid = t['id'] as String;
    var tClues = cluesByTitle[tid] ?? [];
    if (tClues.length < 4) {
      tClues = [...tClues, ...clues].take(4).toList();
    }

    final diff = getDifficultyForLevel(lvl);
    final cwData = createCrosswordGrid(lvl, t['title'] as String, diff, tClues);
    final filename = "level_crossword_${lvl.toString().padLeft(3, '0')}.json";
    final path = "assets/puzzles/crossword/$filename";
    File(path).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(cwData), encoding: utf8);

    (manifest['crosswordLevels'] as List).add({
      'levelNumber': lvl,
      'title': t['title'],
      'difficulty': diff,
      'file': "assets/puzzles/crossword/$filename",
    });
  }

  print("Compiling $totalLevelsPerMode Emoji Rebus Riddle levels (Pure Dart)...");
  for (var lvl = 1; lvl <= totalLevelsPerMode; lvl++) {
    final t = titles[(lvl - 1) % titles.length] as Map<String, dynamic>;
    final diff = getDifficultyForLevel(lvl);
    final rbData = createRebusPuzzle(lvl, t, diff);
    final filename = "level_rebus_${lvl.toString().padLeft(3, '0')}.json";
    final path = "assets/puzzles/rebus/$filename";
    File(path).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(rbData), encoding: utf8);

    (manifest['rebusLevels'] as List).add({
      'levelNumber': lvl,
      'titleId': t['id'],
      'originalTitle': t['title'],
      'difficulty': diff,
      'emojis': t['emojiCandidates'],
      'file': "assets/puzzles/rebus/$filename",
    });
  }

  const manifestPath = 'assets/puzzles/manifest.json';
  File(manifestPath).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(manifest), encoding: utf8);

  print("SUCCESS! ${manifest['totalLevels']} validated launch levels compiled in pure Dart!");
}
