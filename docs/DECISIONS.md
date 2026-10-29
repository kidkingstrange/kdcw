# Architecture & Design Decisions (DECISIONS.md)

This log documents foundational and evolving technical, design, and legal decisions for **K-Drama Crosswords**.

---

## 1. Project Parameters & Theme
- **Target App Title**: K-Drama Crosswords (`kdrama_crosswords`)
- **Niche Theme**: South Korean Dramas (K-Dramas)
- **Era / Timeframe**: 2010–2026
- **Brand Motif**: Soju bottle & Korean Finger Heart (🫰 / 🍶)
- **Color Palette**: Pastel Rose & Sage (with high contrast dark-mode variants)
- **Launch Price**: 5,000 KRW / $4.99 equivalent one-time purchase (Zero ads, zero IAP, zero subscriptions).

---

## 2. Technical Decisions

### ADR-001: Build-Time Puzzle Compilation vs Runtime Grid Backtracking
- **Context**: Dynamic crossword backtracking generation is computationally heavy ($O(N^K)$), leading to frame drops, latency, and potential OOM crashes on 2GB RAM budget Android devices.
- **Decision**: Pre-compile all 400+ puzzle levels at build time into validated static JSON asset bundles (`assets/puzzles/`).
- **Consequences**: Instantaneous 60/120 FPS puzzle loading, zero runtime search latency, deterministic quality assurance, and zero device battery drain during load.

### ADR-002: Native Keyboard & IME Focus Lifecycle Recovery
- **Context**: Mobile puzzle games using custom on-screen keyboards often feel cramped or foreign to users. Using the native IME, however, can lead to detached keyboard focus when switching apps or locking the screen on Android.
- **Decision**: Use the platform's native soft keyboard with a dedicated hidden `TextField` controlled by a `FocusNode` and wired into Flutter's `WidgetsBindingObserver`. On `AppLifecycleState.resumed`, the controller proactively re-requests focus if an active cell is selected.

### ADR-003: Dedicated Word Rows for Rebus Mode
- **Context**: Standard multi-line wrapping splits titles awkwardly across lines (e.g., "[S][Q][U]" on line 1 and "[I][D]" on line 2).
- **Decision**: Organize multi-word rebus titles into distinct, vertical word rows. Each row scales down cleanly via `FittedBox` on narrow screens. Punctuation (hyphens, colons, apostrophes) is rendered as non-editable static glyph separators.

### ADR-004: Pure-Dart Game Engines for High Test Coverage
- **Context**: Tightly coupling puzzle validation, cell selection, direction switching, and hint logic to Flutter UI widgets hinders automated unit testing and slows CI.
- **Decision**: Build `CrosswordEngine` and `RebusEngine` as pure Dart classes completely decoupled from `package:flutter`. Target $\ge 90\%$ automated test coverage.

### ADR-005: Offline-First Zero-Data Legal Shield
- **Context**: Storing user data or loading external network assets exposes the app to privacy regulations (GDPR/COPPA) and copyright liabilities.
- **Decision**:
  - Remove `android.permission.INTERNET` from `AndroidManifest.xml`.
  - Zero third-party ad networks, trackers, or analytics.
  - Zero copyrighted studio stills, posters, or actor portraits.
  - All visual assets are original flat vector art or standard Unicode emojis.
  - Typography bundled locally: `Fredoka`, `Nunito`, and `Noto Color Emoji`.

---

## 3. Content & Progression Policy
- **Starter Coin Balance**: 100 Coins.
- **Word Solve Reward**: +50 Coins.
- **Rebus Solve Reward**: +100 Coins.
- **Level Completion Bonus**: +200 Coins.
- **3-Tier Hint Shop**:
  - Tier 1: 50 Coins (Reveal Starting Letter of selected word).
  - Tier 2: 100 Coins (Reveal Next Unsolved Letter).
  - Tier 3: 250 Coins (Solve Entire Word / Title).
- **Trophy Hall / Dex**: Every completed level permanently reveals a behind-the-scenes trivia card with $\ge 2$ verified reference sources.
- **Rebus Level Titles**: Hidden until solved ("Level X • Rebus") to avoid spoiler leakage.

---

## 4. Release & Store Governance

### ADR-006: Gate 7 Release Packaging, Store Listing, Zero-Data Safety, and CI/CD Automation
- **Context**: Shipping a commercial paid app to Google Play requires strict conformance with metadata policies, zero-data safety disclosures, copyright liability protection, reproducible builds, and automated verification.
- **Decision**:
  - Set Android Application ID to `com.kdramacrosswords.app` and user-facing label to `K-Drama Crosswords`.
  - Ensure zero dangerous permissions; omit `android.permission.INTERNET` from `AndroidManifest.xml` to mathematically guarantee zero data leaks or tracking.
  - Formulate comprehensive Store Listing with prominent unofficial fan trivia disclaimer in `docs/STORE_LISTING.md`.
  - Author a formal `docs/PRIVACY_POLICY.md` declaring zero personal data collection, zero network calls, and 100% local sandboxed storage.
  - Provide a turnkey Google Play Data Safety declaration in `docs/DATA_SAFETY.md` with explicit "No data collected or shared" answers.
  - Document paid monetization strategy and global pricing parity in `docs/PRICING_STRATEGY.md` with a ₩5,000 / $4.99 upfront price tier.
  - Establish automated GitHub Actions workflow in `.github/workflows/ci.yml` running analysis, 100% offline unit tests, manifest validation, and release AAB artifact builds.
- **Consequences**: Streamlined Play Console review approval with zero compliance flags, verifiable legal shield for trademarks/copyrights, and fully automated deployment pipelines.
