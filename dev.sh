#!/usr/bin/env bash
# Usage: ./dev.sh install | reload | status | release <x.y.z>
set -e
shopt -s nullglob
DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.config/DankMaterialShell/plugins/Duck"

# Files DMS needs at runtime (keep in sync with .github/workflows/release.yml).
# The plugin is copied, not symlinked: Qt refuses to import sibling files
# (.js, other .qml) through a symlinked folder ("File name case mismatch").
install_plugin() {
  cd "$DIR"
  rm -rf "$DEST"
  mkdir -p "$DEST"
  cp plugin.json *.qml *.js "$DEST"/
}

case "$1" in
  install) install_plugin; echo "Installed $DIR -> $DEST" ;;
  reload)  install_plugin; dms ipc call plugins reload duck ;;
  status)  dms ipc call plugins status duck ;;
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
  *)       echo "Usage: $0 install | reload | status | release <x.y.z>"; exit 1 ;;
esac
