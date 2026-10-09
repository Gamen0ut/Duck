# 🦆 Duck Roadmap

Duck is a sandbox. Each idea here exists to **learn one part of the DMS plugin API** before using it in a "real" plugin. Tick items off as you try them, and note what you learned (gotchas, API quirks) under each one.

Legend: 🟢 easy · 🟡 medium · 🔴 hard. **Learns** = the DMS/Quickshell concept the idea exercises.

> Some APIs named here (component names, permissions, IPC targets) are from memory of the DMS plugin docs and may have changed. Check the current docs / bundled example plugins before starting an item.

---

## 0.1.0 — Hello Duck ✅

- [x] Bar pill for horizontal and vertical bars
- [x] Click to quack (temporary text + timer)
- [x] Toast notification via `ToastService`
- [x] Settings: `StringSetting`, `ToggleSetting`
- [x] `dev.sh` link / reload / status

---

## 0.2.0 — Settings playground ✅

Try every settings widget DMS offers.

- [x] 🟢 **Quack duration** slider (0.5–5 s). *Learns:* `SliderSetting`, numeric `pluginData`
- [x] 🟢 **Duck emoji picker** (🦆 🐤 🐥 🐣 🦢). *Learns:* `SelectionSetting` with `{label, value}` options
- [x] 🟢 **Quack color** override. *Learns:* `ColorSetting`, mixing user colors with `Theme`
- [x] 🟡 **Random quack list**: a list of phrases, pick one at random. *Learns:* `ListSettingWithInput`, arrays of objects in `pluginData`
- [x] 🟢 **Hide emoji when quacking** toggle. *Learns:* conditional layout in pills
- [x] 🟢 **Reset to defaults** button with click-twice confirmation. *Learns:* `DankButton`, iterating `PluginSettings.content`, `saveValue`
- [x] 🟡 **Settings sections** with headers and descriptions. *Learns:* settings page layout, `StyledText`, spacing tokens

## 0.3.0 — State & persistence ✅

- [x] 🟢 **Quack counter** shown in the pill or tooltip. *Learns:* `savePluginState` / `loadPluginState`, `pluginStateChanged`, `DankTooltip`
- [x] 🟢 **Reset counter** button in settings. *Learns:* reading/clearing plugin state from the settings page, `clearPluginState`
- [x] 🟡 **Daily stats**: quacks per day, current streak. *Learns:* storing structured JSON, dates (local-time day keys, pruning old days)
- [x] 🟡 **Achievements** ("100 quacks!") with a toast when unlocked. *Learns:* reacting to state changes
- [x] 🟢 **Persist the last quack text** across restarts. *Learns:* what survives a shell reload and what doesn't

## 0.4.0 — Achievements+ ✅

From 7 to 21 achievements, plus secret ones and unlock dates.

**A. Milestones & streaks** (fit the existing stats)
- [x] 🟢 🎲 **The answer**: 42 quacks
- [x] 🟢 😈 **Devil's quack**: 666 quacks
- [x] 🟢 🕶️ **Leet quacker**: 1337 quacks
- [x] 🟢 🌪️ **Quack frenzy**: 100 quacks in one day
- [x] 🟢 📅 **Fortnight flock**: 14-day streak
- [x] 🟢 🗓️ **Monthly migration**: 30-day streak

**B. Time & calendar.** *Learns:* extending the achievement `test` with the quack's `Date` without breaking existing tests
- [x] 🟢 🦉 **Night owl**: quack between 00:00 and 04:00
- [x] 🟢 🐓 **Early bird**: quack between 05:00 and 07:00
- [x] 🟢 🎆 **Happy new quack**: January 1st
- [x] 🟢 💘 **Love quack**: February 14th
- [x] 🟢 🐸 **Leap duck**: February 29th
- [x] 🟢 🎃 **Spooky quack**: October 31st
- [x] 🟢 🎄 **Jingle quack**: December 25th

**C. Around achievements**
- [x] 🟡 🥚 **Secret achievements**: `hidden: true`, shown as `🔒 ???` until unlocked (the calendar ones)
- [x] 🟡 🏅 **Completionist**: unlock every other achievement (must not count itself)
- [x] 🟢 **Unlock dates** in settings. *Learns:* additive data changes (a new `unlockedAt` map, so old saves need no migration)
- [x] 🟢 **Grouped toast** when more than 2 achievements unlock at once
- [x] 🟢 **"Achievement toasts" setting**: grouped / one per achievement / off (your request after testing). *Learns:* `SelectionSetting` driving logic, missing keys falling back to the default

## Achievement backlog

Ideas not scheduled yet. New achievements are mostly one line in `DuckStats.js` plus a unit test; some need data we don't track yet (noted in *Needs*).

### Milestones (total quacks)

- [ ] 🟢 💎 **Quackillionaire**: 5 000 quacks
- [ ] 🟢 🌌 **Duck singularity**: 10 000 quacks

### Daily & streaks

- [ ] 🟡 🏛️ **Century pond**: 100-day streak. *Needs:* `bestStreak` (history only keeps 90 days, so a streak can't exceed 91)
- [ ] 🟡 🌍 **Year of the duck**: 365-day streak. *Needs:* keep more than 90 days of history, or store `bestStreak` / `currentStreakStart` instead of recomputing
- [ ] 🟡 🗂️ **Every day of the week**: quack at least once on each weekday. *Learns:* `Date.getDay()`

### Time of day & calendar

- [ ] 🟡 ⏱️ **Exactly midnight**: quack at 00:00 on the dot. *Learns:* `achievement tests` that need the full `Date`, not just the summary

### Speed & behavior

- [ ] 🟡 ⚡ **Quack storm**: 10 quacks in 5 seconds. *Needs:* timestamps of recent quacks (in memory only, no need to persist)
- [ ] 🟡 🐢 **Patience**: quack after not quacking for 7 days. *Needs:* `lastQuackAt` timestamp
- [ ] 🟡 🔄 **Prodigal duck**: come back after a 30-day break
- [ ] 🟡 🖥️ **Multi-monitor duck**: quack from two different bars/screens. *Learns:* `parentScreen.name`, multiple instances

### Settings-based (playing with the plugin itself)

- [ ] 🟡 🐦 **Bird watcher**: quack with every bird (🦆 🐤 🐥 🐣 🦢). *Needs:* set of birds used
- [ ] 🟡 ✍️ **Poet**: have 10 phrases in the random list. *Learns:* reading settings (`pluginData`) inside achievement checks
- [ ] 🟡 🤫 **Silent duck**: 50 quacks with toasts turned off
- [ ] 🟡 🎨 **Fashionista**: change the quack color 5 times
- [ ] 🟢 🧹 **Fresh start**: reset your stats (the unlock survives the reset!). *Learns:* keeping some state through `clearPluginState`

### Systems around achievements

- [ ] 🟡 **Progress bars** in settings (`63 / 100 quacks`). *Learns:* `progress(summary)` next to `test(summary)`, DMS progress widgets
- [ ] 🟡 **Tiers** 🥉🥈🥇 for the same goal (100 / 1000 / 10 000). *Learns:* data-driven achievement definitions
- [ ] 🟡 **Duck levels & XP**: each quack gives XP, level shown in the tooltip (Lv. 1 duckling → Lv. 10 legendary). *Learns:* derived state, curves
- [ ] 🟡 **Evolution**: the bird evolves with level (🥚 → 🐣 → 🐥 → 🦆 → 🦢), unless a bird is picked in settings
- [ ] 🟡 **Daily goal**: "Quack 10 times today", progress in the tooltip, small celebration toast
- [ ] 🔴 **Weekly quests**: 3 random goals per week, rerolled every Monday. *Learns:* seeded randomness by week number
- [ ] 🔴 **Achievement gallery** in the popout (pairs with 0.6.0)
- [ ] 🟡 **Unlock sound / animation** (pairs with 0.7.0 & 0.8.0)
- [ ] 🟢 **Export / import stats** as JSON. *Learns:* `FileView`, clipboard

## 0.5.0 — Interaction

- [x] 🟢 **Right-click / middle-click** actions (e.g. right-click = silent quack). *Learns:* `pillRightClickAction`, `MouseArea.acceptedButtons` (middle only, the rest falls through), one action list shared by two settings
- [x] 🟢 **Scroll wheel** cycles through ducks. *Learns:* `onWheel`, accumulating touchpad deltas, a widget writing its own setting (`savePluginData`)
- [x] 🟢 **Hover tooltip** with stats. *Learns:* DMS tooltip components
- [x] 🟡 **Combo** instead of double-click: rapid clicks show "Quack! ×3". *Learns:* click timing; why a real double-click (which delays every single click) is worse here
- [x] 🟢 **Toast levels**: warning at combo ×10, error at ×25. *Learns:* `ToastService.showWarning` / `showError`

## 0.6.0 — Popout

- [ ] 🟡 **Popout window** on click with a big duck and the stats. *Learns:* `popoutContent`, `PopoutComponent`, `popoutWidth` / `popoutHeight`
- [ ] 🟡 **Pond view**: several ducks swimming in the popout. *Learns:* QML layouts in popouts
- [ ] 🟡 **Quack history** list in the popout. *Learns:* `ListView`, models, scrolling
- [ ] 🟢 **Buttons in the popout** (feed the duck, reset). *Learns:* DMS button widgets, closing the popout from code

## 0.7.0 — Animation & looks

- [ ] 🟢 **Wiggle** the duck on click. *Learns:* `SequentialAnimation`, `RotationAnimation`
- [ ] 🟡 **Idle animation**: the duck bobs every N seconds. *Learns:* timers + animations, CPU cost of always-on animations
- [ ] 🟡 **Waddle** across the pill. *Learns:* `NumberAnimation` on `x`, clipping
- [ ] 🟢 **Material icon** instead of the emoji (`DankIcon`). *Learns:* icon components, `Theme` colors
- [ ] 🟡 **Custom SVG / PNG duck** shipped with the plugin. *Learns:* loading assets relative to the plugin dir
- [ ] 🟢 **Respect the theme**: light/dark, accent color, font scale. *Learns:* `Theme.*` tokens

## 0.8.0 — System integration

- [ ] 🟡 **Quack sound** (play a bundled `.wav`). *Learns:* QtMultimedia or running `paplay` / `pw-play` via `Process`
- [ ] 🟡 **Run a shell command** and show the result ("duck says: `uptime`"). *Learns:* `Quickshell.Io` `Process`, stdout parsing, permissions
- [ ] 🟡 **Duck reacts to the battery**: sleepy duck below 20 %. *Learns:* DMS `BatteryService`
- [ ] 🟡 **Duck reacts to notifications**: quacks when one arrives. *Learns:* notification service hooks
- [ ] 🟡 **Duck reacts to the time**: sleeps at night, 🌅 at dawn. *Learns:* `SystemClock` / time bindings
- [ ] 🟡 **Duck reacts to audio**: dances when music plays. *Learns:* `MprisController` / media services
- [ ] 🟡 **Workspace duck**: changes when you switch workspace. *Learns:* compositor services (niri / Hyprland)
- [ ] 🟡 **Read a file** (e.g. a fortune list) and quack a random line. *Learns:* `FileView`, file paths

## 0.9.0 — IPC & automation

- [ ] 🟡 **`dms ipc call duck quack`** from the terminal. *Learns:* exposing an `IpcHandler` from a plugin
- [ ] 🟡 **Keybind to quack** via the compositor calling IPC. *Learns:* wiring keybinds to plugin IPC
- [ ] 🟡 **`dms ipc call duck say "text"`** with arguments. *Learns:* IPC function arguments and return values
- [ ] 🔴 **Rubber-duck debugging**: pipe a command's exit code to the duck (`make; dms ipc call duck result $?`). *Learns:* scripting around IPC

## 0.10.0 — Other plugin types

Same duck, different entry points.

- [ ] 🟡 **Control Center tile**: a quack toggle in the control center. *Learns:* `ccWidget*` properties
- [ ] 🔴 **Launcher plugin**: type `duck ` in the launcher to search quacks. *Learns:* launcher plugin type, `trigger`, item lists
- [ ] 🔴 **Daemon plugin**: background duck that quacks every hour without a bar widget. *Learns:* `daemon` type, lifecycle with no UI
- [ ] 🔴 **Desktop widget**: a duck sitting on the wallpaper. *Learns:* desktop widget type, positioning, layers
- [ ] 🟡 **Multiple instances** with different settings on different bars/monitors. *Learns:* plugin variants / per-instance data

## 1.0.0 — Polished & published

- [ ] 🟢 Screenshots / GIF in the README
- [ ] 🟢 Translations (i18n) for the settings labels. *Learns:* DMS i18n helpers, if any
- [ ] 🟡 Handle missing `pluginData` keys and bad values gracefully
- [ ] 🟡 Check performance: no busy timers, no leaks across reloads
- [ ] 🟡 Submit Duck to the DMS plugin registry. *Learns:* registry format and review process
- [ ] 🟢 Declare the minimum DMS version in `plugin.json` if supported (`requires_dms` or similar)

---

## Just-for-fun ideas (unscheduled)

- 🦆 **Duck pet / Tamagotchi**: hunger and happiness that decay over time; feed it from the popout
- 🥚 **Egg mode**: hatches after N clicks
- 🦆🦆 **Duck army**: each click adds a duckling to the pill (with a cap)
- 🌧️ **Weather duck**: umbrella when it rains (DMS weather service)
- 🍅 **Pomodoro duck**: quacks when focus time is over
- 📋 **Clipboard duck**: quacks the length of what you just copied
- 🧠 **Rubber duck chat**: popout text box; the duck "listens" and answers with a random wise quack
- 🎲 **Duck of the day**: a different duck species with a fun fact every day
- 🔔 **Quack on events**: low disk space, high CPU temperature, long-running command finished
- 🎨 **Seasonal ducks**: 🎃 Halloween, 🎄 Christmas, by date

---

## Notes & learnings

Write down anything surprising about the DMS plugin API here as you go.

- **Docs ship with DMS**: `/usr/share/quickshell/dms/PLUGINS/` has a README, a JSON schema for `plugin.json`, and ~12 example plugins. The settings components live in `/usr/share/quickshell/dms/Modules/Plugins/`.
- **`SliderSetting` is int-only** (`property int value`), so durations are stored in ms rather than fractional seconds.
- **`ColorSetting` saves a string** (`value.toString()`, e.g. `#ff8800`). Older saves could be `{}`, so check `typeof` before trusting it.
- **`ListSettingWithInput` saves an array of objects** keyed by field `id` (`[{text: "Quack!"}, …]`), not plain strings.
- **`pluginData` updates live**: bindings like `pluginData.quackDuration || 1500` re-evaluate as soon as a setting changes, so you don't need a reload.
- **No built-in reset / delete-key API** for plugin settings. But every `*Setting` exposes `settingKey` + `defaultValue`, so a reset can loop over `content` and `saveValue()` each default. `savePluginData` emits `pluginDataChanged`, which makes `PluginSettings` reload every control.
- **`plugins reload` alternates success/failure** once the plugin imports a sibling file (`import "X.js"`, or another `.qml` used as a type). The error is a misleading *File name case mismatch*. It happens with a symlink or a real folder, with any file name, with or without `.pragma library`. Startup and enable/disable load fine, so only the dev loop is affected: `dev.sh reload` retries once.
- **Settings vs state.** `savePluginData` = user *settings* (in DMS's settings file, edited by the settings page). `savePluginState` = runtime *data* (counters, history) in `~/.local/state/DankMaterialShell/plugins/duck_state.json`. Writes are batched by a timer, and `pluginStateChanged(id)` fires so other instances/the settings page can refresh.
- **Bar tooltips**: `DankTooltipV2` draws inside the widget's own window (clipped by the bar). Bar widgets use `DankTooltip` in a `Loader`, which is its own layer window placed in screen coordinates; compute the position from `axis.edge`, `barThickness`, `barSpacing`, `parentScreen` (see DMS's `Vpn.qml`).
- **Change saved data by adding, not reshaping**: unlock dates went into a new `unlockedAt` map next to the existing `achievements` id list. Old saves just lack the map, so no migration code is needed. A test loads a simulated 0.3.0 save to prove it.
- **Grow APIs by adding, not changing**: achievement checks went from `test(summary)` to `test(summary, now)`. JS ignores extra arguments, so every existing `s => s.total >= 10` kept working untouched.
- **Only `var` is exported from a JS library**: QML sees `Stats.ACHIEVEMENTS` only if it's declared with `var`, not `const`/`let`.
- **Keep logic in a `.pragma library` JS file** to unit-test it with `node`: see `tests/DuckStats.test.js` (strips the pragma, evaluates in a `vm` sandbox; compare results as plain JSON).
- **Use the pill's own clicks**: `BasePill` already has a MouseArea over the whole pill (padding included) with the ripple effect, handling left and right press. Plug into it with `pillClickAction` / `pillRightClickAction` instead of adding your own MouseArea on top, which hides the ripple and leaves the padding dead. It doesn't handle middle-click or the wheel, so for those keep a MouseArea with `acceptedButtons` set to only what you handle; other buttons fall through to the pill.
- **Wheel deltas**: a mouse notch is `angleDelta` 120, but touchpads send many small deltas. Accumulate and step once per 120, or a touchpad flips through everything.
- **Combos beat double-clicks**: a double-click handler must wait (~250 ms) after every click to see if a second one follows, so single clicks feel laggy. Counting rapid clicks with timestamps reacts instantly, and a pure `nextCombo(combo, lastMs, nowMs)` is trivial to test.
- **Use `??` for booleans**: `pluginData.showToast || true` would ignore a saved `false`.
- **`PluginComponent` already has** `pillClickAction`, `pillRightClickAction`, `popoutContent`, `controlCenterWidget` / `ccWidget*`: useful for 0.5–0.10.
