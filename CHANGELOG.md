# Changelog

All notable changes to Duck are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project uses [Semantic Versioning](https://semver.org/).
While Duck is a playground (`0.x`), minor bumps may break settings.

## [Unreleased]

### Added
- 6 new milestone and streak achievements: 🎲 The answer (42), 😈 Devil's quack (666), 🕶️ Leet quacker (1337), 🌪️ Quack frenzy (100 in one day), 📅 Fortnight flock (14-day streak), 🗓️ Monthly migration (30-day streak).

## [0.3.0] - 2026-10-09

### Added
- Quack statistics: total, today and day streak, saved across restarts.
- Hover tooltip on the duck with your quack stats.
- "Show quack counter" option to display the total next to the duck.
- The last quack text is remembered across restarts.
- 7 achievements (🥚 first quack, 🐣 10, 🦆 100, 👑 1000, ⚡ 25 in a day, 🔥 3-day and 🏆 7-day streaks), with a toast when unlocked.
- Stats section in settings: live numbers, achievement list and a "Reset stats" button.

## [0.2.0] - 2026-10-09

### Added
- Duck picker: 🦆 🐤 🐥 🐣 🦢 (`SelectionSetting`).
- Quack duration slider, 500–5000 ms (`SliderSetting`).
- Custom quack color with a toggle to go back to the theme accent (`ColorSetting`).
- Random quacks from a user-defined phrase list (`ListSettingWithInput`).
- Option to hide the duck while it quacks.
- Settings page split into Look / Quack / Notifications sections.
- "Reset to defaults" button (click twice to confirm).

## [0.1.0] - 2026-10-09

### Added
- 🦆 Bar widget for horizontal and vertical bars.
- Click to quack: shows the quack text in the pill for 1.5 s.
- Optional toast notification on quack.
- Settings: custom quack text, toast toggle.
- `dev.sh` helper to link, reload and check the plugin status.

[Unreleased]: https://github.com/Gamen0ut/Duck/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/Gamen0ut/Duck/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/Gamen0ut/Duck/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/Gamen0ut/Duck/releases/tag/v0.1.0
