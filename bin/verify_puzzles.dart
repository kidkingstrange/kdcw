// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final manifestFile = File('assets/puzzles/manifest.json');
  if (!manifestFile.existsSync()) {
    stderr.writeln('ERROR: manifest.json not found at ${manifestFile.path}');
    exit(1);
  }

  final content = manifestFile.readAsStringSync(encoding: utf8);
  final data = json.decode(content) as Map<String, dynamic>;

  final crosswordCount = data['crosswordLevelsCount'] as int? ?? 0;
  final rebusCount = data['rebusLevelsCount'] as int? ?? 0;
  final totalLevels = data['totalLevels'] as int? ?? 0;

  print('=== K-Drama Crosswords Puzzle Verification ===');
  print('Total Levels: $totalLevels');
  print('Crossword Levels: $crosswordCount');
  print('Rebus Levels: $rebusCount');

  if (crosswordCount != 200 || rebusCount != 200 || totalLevels != 400) {
    stderr.writeln('FAIL: Expected 200 crosswords and 200 rebus levels (total 400). Found $totalLevels');
    exit(1);
  }

  // Verify each file exists on disk
  final crosswordList = data['crosswordLevels'] as List<dynamic>? ?? [];
  final rebusList = data['rebusLevels'] as List<dynamic>? ?? [];

  for (final item in crosswordList) {
    final path = item['file'] as String;
    if (!File(path).existsSync()) {
      stderr.writeln('FAIL: Missing crossword file: $path');
      exit(1);
    }
  }

  for (final item in rebusList) {
    final path = item['file'] as String;
    if (!File(path).existsSync()) {
      stderr.writeln('FAIL: Missing rebus file: $path');
      exit(1);
    }
  }

  print('SUCCESS: All 400 levels verified on disk and indexed in manifest.json.');
}
