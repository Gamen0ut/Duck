# 🦆 Duck

A tiny [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) bar widget: a duck that says **quack** when you click it.

Duck is a playground plugin: a place to try out the DMS plugin API before building bigger plugins. See [ROADMAP.md](ROADMAP.md) for what's planned.

## Features

- Works in horizontal and vertical bars
- Click the duck → it shows the quack text (duration is configurable)
- Pick your bird: 🦆 🐤 🐥 🐣 🦢
- Custom quack color, or follow the theme accent
- Random quacks from your own phrase list
- Optional toast notification on every quack
- Quack stats (total, today, streak) in a hover tooltip, with an optional counter in the bar
- Achievements to unlock 🏅, some of them secret

## Requirements

- DankMaterialShell with plugin support
- `dms` CLI available in `$PATH` (for `dev.sh reload` / `status`)

## Installation

### From source

```bash
git clone https://github.com/Gamen0ut/Duck.git
cd Duck
./dev.sh link      # symlinks this folder into ~/.config/DankMaterialShell/plugins/Duck
```

Then in DMS: **Settings → Plugins → Scan for plugins**, enable **Duck**, and add it to a bar section.

### From a release

Download `Duck-vX.Y.Z.zip` from [Releases](https://github.com/Gamen0ut/Duck/releases) and extract it into `~/.config/DankMaterialShell/plugins/`.

## Settings

| Setting                    | Key                     | Default      | Description                                     |
|----------------------------|-------------------------|--------------|-------------------------------------------------|
| Duck                       | `duckEmoji`             | `🦆`         | Which bird lives in your bar                    |
| Hide duck while quacking   | `hideEmojiWhenQuacking` | `false`      | Only show the quack text during a quack         |
| Show quack counter         | `showCounter`           | `false`      | Show the total number of quacks next to the duck |
| Custom quack color         | `useCustomColor`        | `false`      | Use the color below instead of the theme accent |
| Quack color                | `quackColor`            | theme accent | Color of the quack text                         |
| Quack text                 | `quackText`             | `Quack!`     | What the duck says when clicked                 |
| Quack duration             | `quackDuration`         | `1500` (ms)  | How long the quack stays visible                |
| Random quacks              | `randomQuack`           | `false`      | Pick a random phrase from the list              |
| Quack phrases              | `quackPhrases`          | `[]`         | Phrases used when random quacks are on          |
| Show toast                 | `showToast`             | `true`       | Also pop a notification on each quack           |

## Development

```bash
./dev.sh link      # symlink the plugin into the DMS plugins folder
./dev.sh reload    # hot-reload the plugin after editing QML
./dev.sh status    # check whether the plugin is loaded
```

### Project layout

```
Duck/
├── plugin.json        # manifest (id, version, entry points, permissions)
├── Duck.qml           # widget: bar pills + quack logic
├── DuckSettings.qml   # settings page
├── DuckStats.js       # pure stats logic (testable with node)
├── ConfirmButton.qml  # click-twice confirmation button
├── dev.sh             # dev helper (link / reload / status / release)
├── CHANGELOG.md
└── ROADMAP.md
```

## Versioning & releases

Duck follows [Semantic Versioning](https://semver.org/). The single source of truth for the version is `plugin.json`.

To cut a release:

1. Add your changes under `## [Unreleased]` in [CHANGELOG.md](CHANGELOG.md).
2. Run `./dev.sh release 0.2.0`: it bumps `plugin.json`, dates the changelog entry, updates the compare links, commits and creates the `v0.2.0` tag.
3. `git push --follow-tags`. GitHub Actions checks the tag matches `plugin.json`, zips the plugin and publishes a release with the changelog notes.

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `chore:` …).

## License

[MIT](LICENSE) © Gamen0ut
