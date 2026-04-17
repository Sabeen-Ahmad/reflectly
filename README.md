# ArvyaX — Immersive Session + Reflection App

A Flutter mini-app built as part of the ArvyaX Flutter Developer assignment. The experience guides the user through **Explore Ambiences → Start Session → Control Player → Journaling → History** in a calm, minimal, and premium feel.

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart `>=3.0.0`
- Android Studio / VS Code with Flutter plugin
- A connected Android device or emulator

### Run the project

```bash
# Clone the repository
git clone <your-repo-url>
cd arvyax_app

# Install dependencies
flutter pub get

# Run on a connected device
flutter run

# Build a release APK
flutter build apk --release
```

The APK can be found at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Architecture

### State Management — Riverpod

The app uses **Riverpod** for state management. It was chosen because:

- It is compile-safe and does not rely on the widget tree for dependency injection.
- `AsyncNotifierProvider` gives clean, expressive loading/error/data states.
- Providers are easily scoped, testable, and composable without boilerplate.

### Data Flow

```
JSON / Hive
    │
    ▼
Repository  (data/repositories/)
    │   Exposes typed Future / Stream results
    ▼
Notifier / Provider  (features/*/providers/)
    │   Transforms data into UI state
    ▼
UI Widget  (features/*/screens/, features/*/widgets/)
```

- The **UI never touches repositories directly**.
- **Notifiers** own business logic (session timer, journal saving, filter state).
- **Repositories** abstract all I/O (JSON loading, Hive reads/writes).

### Folder Structure

```
lib/
├── main.dart                  # App entry point, ProviderScope, theme setup
│
├── data/
│   ├── models/                # Pure Dart data classes (Ambience, JournalEntry, SessionState)
│   └── repositories/          # AmbienceRepository, JournalRepository, SessionRepository
│
├── features/
│   ├── ambience/
│   │   ├── providers/         # ambienceListProvider, searchQueryProvider, tagFilterProvider
│   │   ├── screens/           # AmbienceHomeScreen, AmbienceDetailScreen
│   │   └── widgets/           # AmbienceCard, TagFilterChip, SearchBar
│   │
│   ├── player/
│   │   ├── providers/         # sessionPlayerProvider (timer, audio state)
│   │   ├── screens/           # SessionPlayerScreen
│   │   └── widgets/           # SeekBar, PlayPauseButton, BreathingAnimation, MiniPlayer
│   │
│   └── journal/
│       ├── providers/         # journalProvider
│       ├── screens/           # ReflectionScreen, JournalHistoryScreen, JournalDetailScreen
│       └── widgets/           # MoodSelector, JournalCard
│
└── shared/
    ├── widgets/               # AppScaffold (mini-player host), EmptyState, LoadingOverlay
    └── theme/                 # AppTheme, color tokens, text styles
```

---

## Local Storage — Hive

**Hive** was chosen over SQLite and SharedPreferences because:

- It is a lightweight, pure-Dart NoSQL store — no native code, easy setup.
- It supports typed adapters (`TypeAdapter`) so journal entries are stored as structured objects, not raw JSON strings.
- Faster read/write than SQLite for simple key-value and list structures.

**What is persisted:**

| Data | Hive Box |
|---|---|
| Journal entries | `journalBox` |
| Last active session state | `sessionBox` |

---

## Packages Used

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management — compile-safe, scalable, testable |
| `riverpod_annotation` | Code-gen for providers (reduces boilerplate) |
| `just_audio` | Audio playback — supports looping, seeking, background audio |
| `hive_flutter` | Local persistence for journal entries and session state |
| `hive_generator` | Code-gen for Hive `TypeAdapter` classes |
| `go_router` | Declarative navigation with deep-link support |
| `build_runner` | Code generation runner for Riverpod + Hive |

---

## Features

### Ambience Library (Home Screen)
- 6 ambiences loaded from `assets/data/ambiences.json`
- Search bar with client-side filtering
- Tag filter chips: Focus / Calm / Sleep / Reset
- Empty state with **Clear Filters** button

### Ambience Details Screen
- Hero image, title, tag, duration, description
- Sensory recipe chips (Breeze, Warm Light, Mist, Binaural, Soft Rain)
- **Start Session** button

### Session Player
- Play / Pause, seek bar, elapsed + total time
- Audio loops continuously via `just_audio` (`LoopMode.one`)
- Session ends when the timer reaches the JSON-defined duration
- **Breathing gradient animation** — a subtle, slow-pulsing background overlay
- **End Session** button with confirmation dialog (Cancel / End)

### Mini Player
- Appears on Home and Details screens when a session is active
- Shows ambience title, play/pause, and a thin linear progress indicator
- Tapping returns to the Session Player

### Post-Session Reflection
- Prompt: *"What is gently present with you right now?"*
- Multiline text input
- Mood selector: Calm / Grounded / Energized / Sleepy
- **Save** persists the entry to Hive

### Journal History
- List of saved reflections with date/time, ambience title, mood, and first-line preview
- Tap to view full entry
- Empty state: *"No reflections yet. Start a session to begin."*

### Bonus — App Lifecycle Handling
The session timer pauses automatically when the app goes to background (`AppLifecycleState.paused`) and resumes when it returns to the foreground (`AppLifecycleState.resumed`). This prevents timer drift and incorrect session durations.

---

## Tradeoffs & What I'd Improve With Two More Days

**1. Background audio service**
Currently audio stops if the OS kills the app. With more time I'd integrate `audio_service` to run the player as a foreground service with lock-screen controls.

**2. Animated transitions**
Screen transitions are standard routes. A hero animation between the ambience card and the detail screen would significantly elevate the premium feel.

**3. Offline-first sync layer**
Journal entries are stored locally in Hive. A proper repository abstraction with a remote sync adapter (e.g. Supabase or Firebase) would make the architecture production-ready with minimal changes.

**4. Unit + widget tests**
Repositories and notifiers are structured to be testable, but no tests were written within the timebox. I'd add tests for the session timer logic, filter providers, and journal persistence.

**5. Richer ambience JSON**
The current JSON has 6 static entries. I'd add pagination support and a seed script so the content can grow without touching app code.

---

## Screen Recording

A 30–60 second screen recording is included in the submission demonstrating the full flow: Home → Details → Session → Journal → History.

---

## Notes

- Placeholder images are sourced from Unsplash (royalty-free).
- Audio loop is a royalty-free nature sound (included in `assets/audio/`).
- Minimum SDK: Android 21 (Lollipop).
