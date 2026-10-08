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

## 0.3.0 — State & persistence

- [ ] 🟢 **Quack counter** shown in the pill or tooltip. *Learns:* `PluginService.savePluginData` / `loadPluginData`
- [ ] 🟢 **Reset counter** button in settings. *Learns:* writing data from the settings page
- [ ] 🟡 **Daily stats**: quacks per day, current streak. *Learns:* storing structured JSON, dates
- [ ] 🟡 **Achievements** ("100 quacks!") with a toast when unlocked. *Learns:* reacting to state changes
- [ ] 🟢 **Persist the last quack text** across restarts. *Learns:* what survives a shell reload and what doesn't

## 0.4.0 — Interaction

- [ ] 🟢 **Right-click / middle-click** actions (e.g. right-click = silent quack). *Learns:* `MouseArea.acceptedButtons`
- [ ] 🟢 **Scroll wheel** cycles through ducks. *Learns:* `onWheel`
- [ ] 🟢 **Hover tooltip** with stats. *Learns:* DMS tooltip components
- [ ] 🟡 **Double-click** = "QUACK QUACK" combo. *Learns:* click timing, gesture disambiguation
- [ ] 🟢 **Toast levels**: info / warning / error depending on mood. *Learns:* `ToastService` variants

## 0.5.0 — Popout

- [ ] 🟡 **Popout window** on click with a big duck and the stats. *Learns:* `popoutContent`, `PopoutComponent`, `popoutWidth` / `popoutHeight`
- [ ] 🟡 **Pond view**: several ducks swimming in the popout. *Learns:* QML layouts in popouts
- [ ] 🟡 **Quack history** list in the popout. *Learns:* `ListView`, models, scrolling
- [ ] 🟢 **Buttons in the popout** (feed the duck, reset). *Learns:* DMS button widgets, closing the popout from code

## 0.6.0 — Animation & looks

- [ ] 🟢 **Wiggle** the duck on click. *Learns:* `SequentialAnimation`, `RotationAnimation`
- [ ] 🟡 **Idle animation**: the duck bobs every N seconds. *Learns:* timers + animations, CPU cost of always-on animations
- [ ] 🟡 **Waddle** across the pill. *Learns:* `NumberAnimation` on `x`, clipping
- [ ] 🟢 **Material icon** instead of the emoji (`DankIcon`). *Learns:* icon components, `Theme` colors
- [ ] 🟡 **Custom SVG / PNG duck** shipped with the plugin. *Learns:* loading assets relative to the plugin dir
- [ ] 🟢 **Respect the theme**: light/dark, accent color, font scale. *Learns:* `Theme.*` tokens

## 0.7.0 — System integration

- [ ] 🟡 **Quack sound** (play a bundled `.wav`). *Learns:* QtMultimedia or running `paplay` / `pw-play` via `Process`
- [ ] 🟡 **Run a shell command** and show the result ("duck says: `uptime`"). *Learns:* `Quickshell.Io` `Process`, stdout parsing, permissions
- [ ] 🟡 **Duck reacts to the battery**: sleepy duck below 20 %. *Learns:* DMS `BatteryService`
- [ ] 🟡 **Duck reacts to notifications**: quacks when one arrives. *Learns:* notification service hooks
- [ ] 🟡 **Duck reacts to the time**: sleeps at night, 🌅 at dawn. *Learns:* `SystemClock` / time bindings
- [ ] 🟡 **Duck reacts to audio**: dances when music plays. *Learns:* `MprisController` / media services
- [ ] 🟡 **Workspace duck**: changes when you switch workspace. *Learns:* compositor services (niri / Hyprland)
- [ ] 🟡 **Read a file** (e.g. a fortune list) and quack a random line. *Learns:* `FileView`, file paths

## 0.8.0 — IPC & automation

- [ ] 🟡 **`dms ipc call duck quack`** from the terminal. *Learns:* exposing an `IpcHandler` from a plugin
- [ ] 🟡 **Keybind to quack** via the compositor calling IPC. *Learns:* wiring keybinds to plugin IPC
- [ ] 🟡 **`dms ipc call duck say "text"`** with arguments. *Learns:* IPC function arguments and return values
- [ ] 🔴 **Rubber-duck debugging**: pipe a command's exit code to the duck (`make; dms ipc call duck result $?`). *Learns:* scripting around IPC

## 0.9.0 — Other plugin types

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
- **Don't symlink the plugin folder.** Qt checks that a file's path matches its real path, so through a symlinked folder any import of a sibling file (`import "X.js"`, another `.qml` used as a type) fails with *File name case mismatch*. A single self-contained `.qml` works, which hides the problem. `dev.sh` copies the files instead.
- **Use `??` for booleans**: `pluginData.showToast || true` would ignore a saved `false`.
- **`PluginComponent` already has** `pillClickAction`, `pillRightClickAction`, `popoutContent`, `controlCenterWidget` / `ccWidget*`: useful for 0.4–0.9.
