# Design System & Wireframes (DESIGN.md)

**App Title**: K-Drama Crosswords  
**Theme**: South Korean Dramas (2010–2026)  
**Palette Motif**: Pastel Rose & Sage  
**Brand Motif**: Soju Bottle & Korean Finger Heart (🫰 / 🍶)

---

## 1. Color Palette & Semantic Tokens

The visual identity combines traditional Korean aesthetics (Dancheong pastels and celadon sage) with modern tactile UI design.

### Light Mode Palette
| Token Name | Hex Code | Purpose |
|---|---|---|
| `primaryRose` | `#D9727F` | Primary branding, active selections, CTA buttons, streak flames |
| `primaryRoseLight` | `#FCECEF` | Highlight backgrounds, clue banner backgrounds, soft badges |
| `primaryRoseDark` | `#A64B57` | Pressed states, active text accents |
| `sageGreen` | `#7E9F8E` | Secondary branding, Rebus mode accents, success states |
| `sageGreenLight` | `#EBF2EE` | Solved row backgrounds, secondary card containers |
| `mintLock` | `#52B788` | **Word-Locking Cell Color**: Permanently solved crossword cells |
| `mintLockLight` | `#D8F3DC` | Word-locking cell background tint |
| `goldCoin` | `#E9A825` | Coin counters, star ratings, hint shop currency |
| `goldCoinLight` | `#FFF3D6` | Coin badge container background |
| `bgLight` | `#FBF9F6` | App background (warm ivory porcelain) |
| `surfaceLight` | `#FFFFFF` | Card surfaces, modal sheets, crossword cell base |
| `cellBorderLight` | `#D8D2C8` | Grid cell borders, subtle dividers |
| `textPrimaryLight` | `#2D2B2A` | High-contrast body, clue text, level headers |
| `textSecondaryLight` | `#736B65` | Subtitles, source attributions, difficulty tags |

### Dark Mode Palette
| Token Name | Hex Code | Purpose |
|---|---|---|
| `primaryRose` | `#E88B97` | High-contrast rose for dark surfaces |
| `primaryRoseContainer` | `#4A2027` | Soft rose container fill |
| `sageGreen` | `#96B6A5` | Muted sage for dark mode accents |
| `mintLock` | `#68D391` | High-contrast solved cell highlight |
| `goldCoin` | `#F6C85F` | Bright gold coin counter |
| `bgDark` | `#161719` | Deep charcoal background |
| `surfaceDark` | `#222428` | Elevated card & modal surfaces |
| `cellBorderDark` | `#3A3E45` | High-visibility dark grid borders |
| `textPrimaryDark` | `#F5F3EF` | Maximum readability text |
| `textSecondaryDark` | `#A59E97` | Muted metadata and hints |

---

## 2. Typography

All typography is strictly bundled offline (SIL Open Font License).

- **Headings & Badges**: `Fredoka` (Rounded, playful, friendly, readable at small sizes).
  - `displayLarge`: 32 sp, Bold (Home title, Level complete banner)
  - `headlineMedium`: 22 sp, SemiBold (Modal headers, Trophy titles)
  - `titleMedium`: 16 sp, Bold (Crossword cell letters, button labels)
- **Body & Clues**: `Nunito` (Exceptional legibility on mobile screens).
  - `bodyLarge`: 16 sp, Regular / Medium (Active clue ribbon, trivia text)
  - `bodyMedium`: 14 sp, Regular (Source citations, secondary descriptions)
  - `labelSmall`: 11 sp, SemiBold (Category tags, difficulty indicators)
- **Emoji Rendering**: `Noto Color Emoji` (Bundled locally to guarantee uniform glyph appearance across all Android versions).

---

## 3. Touch Targets & Ergonomic Rules

- **48 dp Minimum Rule**: All interactive elements (crossword grid cells, direction toggles, hint buttons, shop cards, navigation tabs) enforce a minimum touch target bounding box of $48 \times 48\text{ dp}$.
- **Haptic Feedback**:
  - Cell select: `HapticFeedback.selectionClick()`
  - Letter entry: `HapticFeedback.lightImpact()`
  - Word locked / Rebus solved: `HapticFeedback.mediumImpact()`
  - Level complete: `HapticFeedback.heavyImpact()`
- **Dynamic Text Scaling**: Responsive clue ribbon scaling with fallback ellipsis and full-view tap preview modal for long clues.

---

## 4. Screen Wireframes & Component Specs

### 4.1 Home Screen
```
+-----------------------------------------------+
|  [🫰 K-DRAMA CROSSWORDS]             🪙 1,250 |
+-----------------------------------------------+
|  OVERALL PROGRESS CARD                        |
|  [=========================>      ] 68%       |
|  🏆 84/163 Trophies  ⭐ 210 Stars  🔥 7 Days   |
+-----------------------------------------------+
|  DAILY CHALLENGE                              |
|  "Today's Drama: Goblin (2016)"               |
|  [ PLAY TODAY'S PUZZLE 🔥 STREAK: 7 ]         |
+-----------------------------------------------+
|  GAME MODES                                   |
|  +--------------------+  +--------------------+
|  | 📝 CLASSIC         |  | 🧩 EMOJI REBUS     |
|  | CROSSWORDS         |  | RIDDLES            |
|  | 200 Levels         |  | 200 Riddles        |
|  | [ CONTINUING L.42 ]|  | [ CONTINUING L.18 ]|
|  +--------------------+  +--------------------+
+-----------------------------------------------+
|  [ 🏆 TROPHY HALL ]         [ ⚙️ SETTINGS ]    |
+-----------------------------------------------+
```

### 4.2 Crossword Screen
```
+-----------------------------------------------+
|  < [Back]    Level 42: Crash Landing    🪙 1,250
+-----------------------------------------------+
|  CONNECTED GRID (e.g. 9x9)                    |
|   [P][A][R][A][G][L][I][D][E]  <- Mint Locked |
|   [I]   [O]      [U]      [A]                 |
|   [A]   [R]      [N]      [T]                 |
|   [N][O][K][E][Y]         [H]                 |
|   [O]                     [Y]                 |
+-----------------------------------------------+
|  CLUE RIBBON (Across: 1)              [ACROSS]|
|  "Yoon Se-ri's transport caught in a tornado" |
+-----------------------------------------------+
|  [ 💡 HINT SHOP (50 / 100 / 250) ]  [TOGGLE ⤯]|
+-----------------------------------------------+
|  NATIVE SOFTWARE KEYBOARD (Auto Lifecycle Rec)|
+-----------------------------------------------+
```

### 4.3 Rebus Screen (Dedicated Word Rows)
```
+-----------------------------------------------+
|  < [Back]       Level 18 • Rebus        🪙 1,250
+-----------------------------------------------+
|  EMOJI RIDDLE BANNER                          |
|             [ 🪂 ]  [ 🇰🇵 ]  [ 🇰🇷 ]             |
+-----------------------------------------------+
|  DEDICATED WORD ROWS (FittedBox auto-scaled)  |
|  Row 1: [ C ][ R ][ A ][ S ][ H ]             |
|  Row 2: [ L ][ A ][ N ][ D ][ I ][ N ][ G ]   |
|  Row 3: [ O ][ N ]                            |
|  Row 4: [ Y ][ O ][ U ]                       |
+-----------------------------------------------+
|  [ 💡 HINT SHOP ]              [ ⌫ BACKSPACE ] |
+-----------------------------------------------+
|  NATIVE SOFTWARE KEYBOARD                     |
+-----------------------------------------------+
```

### 4.4 3-Tier Hint Shop Modal
```
+-----------------------------------------------+
|                 💡 HINT SHOP                  |
|          Current Balance: 🪙 1,250            |
+-----------------------------------------------+
|  TIER 1: REVEAL STARTING LETTER               |
|  Fills in the first letter of the active word |
|  [ 🪙 50 COINS ]                              |
+-----------------------------------------------+
|  TIER 2: REVEAL ANOTHER LETTER                |
|  Uncovers one random unsolved tile            |
|  [ 🪙 100 COINS ]                             |
+-----------------------------------------------+
|  TIER 3: SOLVE ENTIRE WORD / TITLE            |
|  Instantly unlocks and confirms the full word |
|  [ 🪙 250 COINS ]                             |
+-----------------------------------------------+
```

### 4.5 Trophy Hall / Dex
```
+-----------------------------------------------+
|  < [Back]         Trophy Dex         84 / 163 |
+-----------------------------------------------+
|  [ All ] [ tvN ] [ JTBC ] [ Netflix ] [ SBS ] |
+-----------------------------------------------+
|  +--------------------+  +--------------------+
|  | 🫰 Goblin (2016)   |  | 🫰 CLOY (2019)     |
|  | Gong Yoo / Kim Shin|  | Hyun Bin & Son Y-j |
|  | [ VIEW TRIVIA CARD]|  | [ VIEW TRIVIA CARD]|
|  +--------------------+  +--------------------+
|  | 🔒 Level 85        |  | 🔒 Level 86        |
|  | Complete to unlock |  | Complete to unlock |
|  +--------------------+  +--------------------+
+-----------------------------------------------+
```

---

## 5. Original Brand Icon Motif Concept
- **Concept**: A minimalist, flat vector icon with a circular badge.
  - **Foreground**: A slender celadon-sage Korean Soju bottle silhouette angled gracefully next to a warm pastel-rose Korean Finger Heart hand gesture (🫰).
  - **Accents**: Two delicate sparkle stars (`#E9A825`) emanating from the finger tips, symbolizing puzzle breakthroughs and K-Drama magic.
  - **Zero Copyright**: 100% geometric vector composition, completely devoid of real actor portraits or commercial brand logos.
