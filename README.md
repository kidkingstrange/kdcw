# K-Drama Crosswords (2010–2026)

[![CI/CD Pipeline](https://github.com/kidkingstrange/kdcw/actions/workflows/ci.yml/badge.svg)](https://github.com/kidkingstrange/kdcw/actions/workflows/ci.yml)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Pure Dart Test Coverage](https://img.shields.io/badge/Test%20Coverage-95.1%25-brightgreen)](test/)
[![100% Offline](https://img.shields.io/badge/Permissions-Zero%20Network-blue)](#legal--zero-data-shield)
[![License](https://img.shields.io/badge/License-Proprietary-lightgrey)](#legal--zero-data-shield)

A premium, 100% offline South Korean drama puzzle game for Android. Featuring **400 hand-crafted launch levels**, **163 verified dramas** spanning 2010 to 2026, and **1,605 dual-verified trivia clues**.

---

## 🎮 Key Features

- **Dual Game Modes**:
  - **Classic Crosswords (200 Levels)**: Connected alphanumeric grids ranging from Easy (7x7) to Expert (13x13) with word-locking feedback (mint green highlight and checkmark badges).
  - **Emoji & Icon Title Rebus (200 Levels)**: 2-to-6 visual emoji sequences representing famous drama titles. Structured in **Dedicated Word Rows** with `FittedBox` scale-down and inline fixed punctuation.
- **163 Verified Dramas (2010–2026)**:
  - Hits including *Crash Landing on You*, *Goblin*, *Vincenzo*, *Squid Game*, *Extraordinary Attorney Woo*, *Queen of Tears*, *Lovely Runner*, *Descendants of the Sun*, *Reply 1988*, *Signal*, *Hospital Playlist*, and many more.
- **In-Game Economy & Progression**:
  - Sequential level unlocking (earn 1–3 stars).
  - Virtual coins earned through play (+50 per word, +100 per rebus, +200 level bonus).
  - **3-Tier Hint Shop**: 50 coins (Reveal Starting Letter), 100 coins (Reveal Random Letter), 250 coins (Solve Word).
- **Trophy Hall / Dex**:
  - Collectible trivia lore cards unlocked with each solved puzzle, citing 2 independent sources per fact.
- **Native IME Integration**:
  - Native software keyboard input with `WidgetsBindingObserver` lifecycle focus recovery on app resume.
- **100% Offline & Instant Loading**:
  - Zero runtime backtracking search. All 400 levels are pre-compiled into static JSON assets loaded instantly at 60/120 FPS.

---

## 🛡️ Legal & Zero-Data Shield

This game is designed to be fully commercial, zero-risk, and 100% compliant:
- **Zero Network Permissions**: The `android.permission.INTERNET` permission is completely omitted from `AndroidManifest.xml`.
- **Zero Third-Party SDKs**: No ad networks, no analytics, no trackers, and no user accounts.
- **Zero Copyrighted Artwork**: Contains no scraped posters, studio stills, logos, or actor likenesses. All visuals are original flat geometric vectors ([BrandIcon](lib/widgets/brand_icon.dart)) or standard Unicode glyphs.
- **Dual-Source Fact Verification**: Every single fact in `content/titles.json` and clue in `content/clues.json` is verified against $\ge 2$ public references (cataloged in [ASSETS_LICENSES.md](ASSETS_LICENSES.md)).

> **Disclaimer**: *K-Drama Crosswords is an unofficial fan trivia game. It is not affiliated with, sponsored by, or endorsed by any television network, production company, streaming platform, or studio. All drama titles, characters, and registered trademarks belong to their respective copyright holders.*

---

## 📁 Repository Structure

```
├── .github/workflows/ci.yml       # GitHub Actions CI build & test pipeline
├── assets/
│   └── puzzles/                   # 400 pre-compiled static puzzle JSONs
│       ├── crossword/             # 200 classic crossword level files
│       ├── rebus/                 # 200 dedicated-row rebus level files
│       └── manifest.json          # Master level manifest & metadata
├── content/
│   ├── titles.json                # 163 verified dramas with dual sources
│   └── clues.json                 # 1,605 dual-verified trivia clues
├── docs/
│   ├── DECISIONS.md               # Architecture Decision Records (ADRs)
│   ├── DESIGN.md                  # Design system, palette tokens & wireframes
│   ├── PROJECT_LOG.md             # 7-phase gate execution tracking log
│   ├── STORE_LISTING.md           # Google Play Store listing copy & metadata
│   ├── PRIVACY_POLICY.md          # 100% offline zero-data privacy policy
│   ├── DATA_SAFETY.md             # Google Play Data Safety answers
│   └── PRICING_STRATEGY.md        # ₩5,000 / $4.99 premium pricing model
├── lib/
│   ├── engine/                    # Pure-Dart puzzle engines (95.1% test coverage)
│   │   ├── crossword_engine.dart
│   │   └── rebus_engine.dart
│   ├── screens/                   # Flutter game screens (Home, Crossword, Rebus, Dex, etc.)
│   ├── services/                  # Offline game storage & persistence
│   ├── theme/                     # Pastel Rose & Sage tokens, typography, dark mode
│   └── widgets/                   # Native keyboard wrapper, hint shop, brand motif
├── test/                          # Comprehensive engine unit test suite
└── tools/                         # Build-time dataset & puzzle compilers
```

---

## 🚀 Development & Build

### Prerequisites
- [Flutter SDK](https://flutter.dev) (3.x stable)
- [Python 3.10+](https://python.org) (for build-time compilers in `tools/`)

### Setup & Run
```bash
# Install dependencies
flutter pub get

# Run static analysis
dart analyze

# Run unit tests
flutter test test/crossword_engine_test.dart test/rebus_engine_test.dart

# Launch on a connected device
flutter run
```

### Build-Time Compilation (Optional Re-Generation)
```bash
# Rebuild titles dataset
python tools/build_titles_dataset.py

# Rebuild clues dataset (1,600+ clues)
python tools/build_clues_dataset.py

# Recompile all 400 puzzle levels
python tools/compile_puzzles.py
```

### Android Production Build
```bash
flutter build appbundle --release --no-codesign
```
