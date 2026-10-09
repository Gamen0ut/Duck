#!/usr/bin/env bash
# Usage: ./dev.sh link | reload | status | shot <name> [delay] | record <name> [seconds] | release <x.y.z>
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.config/DankMaterialShell/plugins/Duck"
case "$1" in
  link)   mkdir -p "$(dirname "$DEST")"; ln -sfn "$DIR" "$DEST"; echo "Linked $DIR -> $DEST" ;;
  reload)
    # Limits of `dms ipc call plugins reload` for a multi-file plugin:
    # - DMS adds ?t=<now> to Duck.qml only. Relative imports drop the query, so
    #   sibling files (*.js, other *.qml) come back from Qt's cache: edits to
    #   them are NOT picked up. For a full fresh reload use the Reloader
    #   plugin's bar button (or restart the shell).
    # - A file added since the last load can make the first attempt fail
    #   ("X is not a type"), so retry once.
    # rescan first: it rebuilds Duck's paths from plugin.json, undoing a
    # Reloader farm path that would hide files added after it was made.
    dms ipc call plugin-scan rescan duck >/dev/null
    out="$(dms ipc call plugins reload duck)"
    [[ "$out" == *FAILED* ]] && out="$(dms ipc call plugins reload duck)"
    echo "$out"
    [[ "$out" != *FAILED* ]] ;;
  status) dms ipc call plugins status duck ;;
  shot)
    # Captures the last-selected screen region after a delay, so there's time
    # to open the popout first (picking a region could close it). Pick the
    # region once beforehand: dms screenshot region --no-file
    # "screenshot" goes to the plugin root (the main image, like other DMS
    # plugins); anything else to screenshots/.
    name="$2"; delay="${3:-3}"
    [ -n "$name" ] || { echo "Usage: $0 shot <name> [delay]"; exit 1; }
    out="$DIR/screenshots"; [ "$name" = "screenshot" ] && out="$DIR"
    mkdir -p "$out"
    echo "Capturing $name.png in ${delay}s..."; sleep "$delay"
    dms screenshot last --dir "$out" --filename "$name.png" --no-clipboard ;;
  record)
    # Records a region to screenshots/<name>.gif: select the region, then 3 s
    # to open the popout, then <seconds> of recording (default 6), converted
    # with an optimised palette (15 fps, 480 px wide). Needs wf-recorder.
    name="$2"; secs="${3:-6}"
    [ -n "$name" ] || { echo "Usage: $0 record <name> [seconds]"; exit 1; }
    command -v wf-recorder >/dev/null || { echo "wf-recorder is not installed"; exit 1; }
    tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
    echo "Select the region to record..."
    geo="$(dms screenshot region -g)"
    [ -n "$geo" ] || { echo "No region selected"; exit 1; }
    echo "Recording $geo in 3 s, for ${secs} s..."; sleep 3
    timeout -s INT "$secs" wf-recorder -g "$geo" -f "$tmp/rec.mp4" >/dev/null 2>&1 || true
    [ -s "$tmp/rec.mp4" ] || { echo "Recording failed"; exit 1; }
    mkdir -p "$DIR/screenshots"
    ffmpeg -loglevel error -y -i "$tmp/rec.mp4" \
      -vf "fps=15,scale=480:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse" \
      "$DIR/screenshots/$name.gif"
    echo "Saved screenshots/$name.gif ($(du -h "$DIR/screenshots/$name.gif" | cut -f1))" ;;
  release)
    v="$2"
    [[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Usage: $0 release <x.y.z>"; exit 1; }
    cd "$DIR"
    [ -z "$(git status --porcelain --untracked-files=no)" ] || { echo "Working tree not clean (commit or stash first)"; exit 1; }
    prev="$(sed -n 's/.*"version": "\([^"]*\)".*/\1/p' plugin.json)"
    sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$v\"/" plugin.json
    sed -i "s/^## \[Unreleased\]$/## [Unreleased]\n\n## [$v] - $(date +%F)/" CHANGELOG.md
    sed -i "s#^\[Unreleased\]: \(.*\)/compare/v$prev\.\.\.HEAD#[Unreleased]: \1/compare/v$v...HEAD\n[$v]: \1/compare/v$prev...v$v#" CHANGELOG.md
    git commit -am "chore(release): v$v"
    git tag -a "v$v" -m "v$v"
    echo "Tagged v$v. Review with: git show --stat HEAD, then: git push --follow-tags"
    ;;
  *)      echo "Usage: $0 link | reload | status | shot <name> [delay] | record <name> [seconds] | release <x.y.z>"; exit 1 ;;
esac
