# PocketNotes

PocketNotes is a Flutter app for billiards players who want to log their solo practice sessions, surface insights quickly, and keep their training streak alive. It combines a friendly calendar, structured drills, and a playful cue-ball mascot so you actually enjoy taking notes after each rack.

## Features

- **All-in-one practice log** – Track Bowliards, One Pocket Ghost, game days, and competitions without juggling spreadsheets.
- **At-a-glance calendar** – Color-coded markers show which drills you hit on any given day, with quick navigation to detailed entries.
- **Insightful stats** – Per-drill charts with best score, average, and median make progress obvious. One Pocket Ghost now focuses on total rack points instead of averages.
- **Pocket-ready UX** – Custom Material 3 theme, glassmorphism cards, and a bespoke cue-ball logo keep things polished on mobile, tablet, and desktop.
- **Offline-first storage** – Hive keeps every session locally so you can log drills anywhere, then sync or export later if you like.

## Architecture & Stack

- **Flutter 3.10** (Material 3, adaptive layouts)
- **State management:** Provider
- **Local persistence:** Hive + Hive type adapters for each practice model
- **Charts:** `fl_chart` for smooth trendlines
- **Calendar UI:** `table_calendar`
- **Other tooling:** build_runner for Hive codegen, font_awesome_flutter for iconography

## Getting Started

1. **Install Flutter** (3.10+) and the desired platform SDKs (Android/iOS/macOS/web).
2. **Clone the repo:**
	```sh
	git clone https://github.com/<you>/pocketnotes.git
	cd pocketnotes
	```
3. **Install dependencies:**
	```sh
	flutter pub get
	```
4. **Generate Hive adapters (if you add new models):**
	```sh
	flutter pub run build_runner build --delete-conflicting-outputs
	```
5. **Run the app:**
	```sh
	flutter run
	```

## Testing

PocketNotes ships with widget tests that cover the main app scaffold. Run them with:

```sh
flutter test
```

Add more golden/widget/unit tests under `test/` as you expand the feature set.

## Roadmap Ideas

- Cloud sync or export to share practice stats with coaches
- Additional drill types (straight pool, 9-ball ghost, custom templates)
- Rich media notes (tables, photos, quick voice snippets)
- Push reminder nudges tied to your calendar streak


## License

MIT License. See [LICENSE](LICENSE) for details.
