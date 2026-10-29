import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Pure-Dart Offline Storage & Game Economy Service.
/// Completely decoupled from cloud/network. Zero data leakage.
class GameStorage extends ChangeNotifier {
  static final GameStorage _instance = GameStorage._internal();
  factory GameStorage() => _instance;
  GameStorage._internal();

  // Economy Constants
  static const int starterCoins = 100;
  static const int wordRewardCoins = 50;
  static const int rebusRewardCoins = 100;
  static const int levelCompleteBonusCoins = 200;

  static const int hint1Cost = 50;
  static const int hint2Cost = 100;
  static const int hint3Cost = 250;

  // State
  int _coins = starterCoins;
  int _maxUnlockedCrosswordLevel = 1;
  int _maxUnlockedRebusLevel = 1;

  final Map<int, int> _crosswordStars = {}; // levelNumber -> stars (1..3)
  final Map<int, int> _rebusStars = {}; // levelNumber -> stars (1..3)
  final Set<String> _unlockedTrophyIds = {}; // Set of titleIds

  int _dailyStreak = 0;
  String _lastDailyDate = '';

  bool _isDarkMode = false;
  bool _hapticsEnabled = true;
  bool _soundEnabled = true;

  File? _storageFile;
  bool _isInitialized = false;

  // Getters
  int get coins => _coins;
  int get maxUnlockedCrosswordLevel => _maxUnlockedCrosswordLevel;
  int get maxUnlockedRebusLevel => _maxUnlockedRebusLevel;
  Map<int, int> get crosswordStars => Map.unmodifiable(_crosswordStars);
  Map<int, int> get rebusStars => Map.unmodifiable(_rebusStars);
  Set<String> get unlockedTrophyIds => Set.unmodifiable(_unlockedTrophyIds);
  int get dailyStreak => _dailyStreak;
  String get lastDailyDate => _lastDailyDate;
  bool get isDarkMode => _isDarkMode;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get soundEnabled => _soundEnabled;

  int get totalStarsEarned =>
      _crosswordStars.values.fold(0, (a, b) => a + b) +
      _rebusStars.values.fold(0, (a, b) => a + b);

  int get totalLevelsCompleted => _crosswordStars.length + _rebusStars.length;

  /// Initialize local file storage
  Future<void> init([File? customFile]) async {
    if (_isInitialized && customFile == null) return;

    if (customFile != null) {
      _storageFile = customFile;
    } else {
      try {
        final path = Directory.current.path;
        _storageFile = File('$path/.kdrama_game_save.json');
      } catch (_) {
        _storageFile = null;
      }
    }

    await load();
    _isInitialized = true;
  }

  Future<void> load() async {
    if (_storageFile == null || !await _storageFile!.exists()) return;

    try {
      final content = await _storageFile!.readAsString();
      final data = json.decode(content) as Map<String, dynamic>;

      _coins = data['coins'] as int? ?? starterCoins;
      _maxUnlockedCrosswordLevel = data['maxUnlockedCrosswordLevel'] as int? ?? 1;
      _maxUnlockedRebusLevel = data['maxUnlockedRebusLevel'] as int? ?? 1;

      _crosswordStars.clear();
      if (data['crosswordStars'] != null) {
        final rawMap = data['crosswordStars'] as Map<String, dynamic>;
        rawMap.forEach((k, v) => _crosswordStars[int.parse(k)] = v as int);
      }

      _rebusStars.clear();
      if (data['rebusStars'] != null) {
        final rawMap = data['rebusStars'] as Map<String, dynamic>;
        rawMap.forEach((k, v) => _rebusStars[int.parse(k)] = v as int);
      }

      _unlockedTrophyIds.clear();
      if (data['unlockedTrophyIds'] != null) {
        final rawList = data['unlockedTrophyIds'] as List;
        _unlockedTrophyIds.addAll(rawList.cast<String>());
      }

      _dailyStreak = data['dailyStreak'] as int? ?? 0;
      _lastDailyDate = data['lastDailyDate'] as String? ?? '';
      _isDarkMode = data['isDarkMode'] as bool? ?? false;
      _hapticsEnabled = data['hapticsEnabled'] as bool? ?? true;
      _soundEnabled = data['soundEnabled'] as bool? ?? true;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading game save: $e');
    }
  }

  Future<void> save() async {
    if (_storageFile == null) return;

    try {
      final Map<String, String> cwStarsStr = {};
      _crosswordStars.forEach((k, v) => cwStarsStr[k.toString()] = v.toString());

      final Map<String, String> rbStarsStr = {};
      _rebusStars.forEach((k, v) => rbStarsStr[k.toString()] = v.toString());

      final data = {
        'coins': _coins,
        'maxUnlockedCrosswordLevel': _maxUnlockedCrosswordLevel,
        'maxUnlockedRebusLevel': _maxUnlockedRebusLevel,
        'crosswordStars': _crosswordStars.map((k, v) => MapEntry(k.toString(), v)),
        'rebusStars': _rebusStars.map((k, v) => MapEntry(k.toString(), v)),
        'unlockedTrophyIds': _unlockedTrophyIds.toList(),
        'dailyStreak': _dailyStreak,
        'lastDailyDate': _lastDailyDate,
        'isDarkMode': _isDarkMode,
        'hapticsEnabled': _hapticsEnabled,
        'soundEnabled': _soundEnabled,
      };

      await _storageFile!.writeAsString(json.encode(data));
    } catch (e) {
      debugPrint('Error saving game save: $e');
    }
  }

  // Coin Actions
  void addCoins(int amount) {
    if (amount <= 0) return;
    _coins += amount;
    save();
    notifyListeners();
  }

  bool spendCoins(int amount) {
    if (amount <= 0) return true;
    if (_coins < amount) return false;
    _coins -= amount;
    save();
    notifyListeners();
    return true;
  }

  // Crossword Completion
  void completeCrosswordLevel(int levelNumber, int stars, {String? titleId}) {
    final existingStars = _crosswordStars[levelNumber] ?? 0;
    if (stars > existingStars) {
      _crosswordStars[levelNumber] = stars;
    }

    if (levelNumber >= _maxUnlockedCrosswordLevel) {
      _maxUnlockedCrosswordLevel = levelNumber + 1;
    }

    if (titleId != null && titleId.isNotEmpty) {
      _unlockedTrophyIds.add(titleId);
    }

    _coins += levelCompleteBonusCoins;
    save();
    notifyListeners();
  }

  // Rebus Completion
  void completeRebusLevel(int levelNumber, int stars, {String? titleId}) {
    final existingStars = _rebusStars[levelNumber] ?? 0;
    if (stars > existingStars) {
      _rebusStars[levelNumber] = stars;
    }

    if (levelNumber >= _maxUnlockedRebusLevel) {
      _maxUnlockedRebusLevel = levelNumber + 1;
    }

    if (titleId != null && titleId.isNotEmpty) {
      _unlockedTrophyIds.add(titleId);
    }

    _coins += rebusRewardCoins + levelCompleteBonusCoins;
    save();
    notifyListeners();
  }

  // Daily Challenge
  bool completeDailyChallenge(String dateToday) {
    if (_lastDailyDate == dateToday) {
      return false; // Already completed today
    }

    _dailyStreak += 1;
    _lastDailyDate = dateToday;
    _coins += levelCompleteBonusCoins + 100; // Extra daily bonus
    save();
    notifyListeners();
    return true;
  }

  // Settings
  void toggleDarkMode(bool enabled) {
    _isDarkMode = enabled;
    save();
    notifyListeners();
  }

  void toggleHaptics(bool enabled) {
    _hapticsEnabled = enabled;
    save();
    notifyListeners();
  }

  void toggleSound(bool enabled) {
    _soundEnabled = enabled;
    save();
    notifyListeners();
  }

  // Debug reset (for testing)
  void resetProgress() {
    _coins = starterCoins;
    _maxUnlockedCrosswordLevel = 1;
    _maxUnlockedRebusLevel = 1;
    _crosswordStars.clear();
    _rebusStars.clear();
    _unlockedTrophyIds.clear();
    _dailyStreak = 0;
    _lastDailyDate = '';
    save();
    notifyListeners();
  }
}
