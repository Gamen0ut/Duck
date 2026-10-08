#!/usr/bin/env bash
# Usage: ./dev.sh link | reload | status | release <x.y.z>
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.config/DankMaterialShell/plugins/Duck"
case "$1" in
  link)   mkdir -p "$(dirname "$DEST")"; ln -sfn "$DIR" "$DEST"; echo "Linked $DIR -> $DEST" ;;
  reload) dms ipc call plugins reload duck ;;
  status) dms ipc call plugins status duck ;;
  release)
    v="$2"
    [[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Usage: $0 release <x.y.z>"; exit 1; }
    cd "$DIR"
    [ -z "$(git status --porcelain)" ] || { echo "Working tree not clean"; exit 1; }
    sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$v\"/" plugin.json
    sed -i "s/^## \[Unreleased\]$/## [Unreleased]\n\n## [$v] - $(date +%F)/" CHANGELOG.md
    git commit -am "chore(release): v$v"
    git tag -a "v$v" -m "v$v"
    echo "Tagged v$v. Check CHANGELOG.md links, then: git push --follow-tags"
    ;;
  *)      echo "Usage: $0 link | reload | status | release <x.y.z>"; exit 1 ;;
esac
