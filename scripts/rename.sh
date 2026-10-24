#!/usr/bin/env bash
# Rename the plugin in one go. The working name is a placeholder; this swaps
# every occurrence of the display name and the slug across the repo.
#
#   scripts/rename.sh "Frankenbrain" frankenbrain
#
# Afterwards: rename the folder yourself (mv ../two-timing ../<slug>), re-add
# the marketplace, and reinstall. Nothing here touches git history.
set -euo pipefail
name="${1:-}"; slug="${2:-}"
[ -n "$name" ] && [ -n "$slug" ] || { echo "usage: rename.sh \"Display Name\" slug" >&2; exit 64; }
[[ "$slug" =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "slug must be lowercase letters, digits, hyphens" >&2; exit 64; }
root=$(cd "$(dirname "$0")/.." && pwd)
upper=$(printf '%s' "$slug" | tr '[:lower:]-' '[:upper:]_')
files=$(cd "$root" && grep -rl -E 'Two-Timing|two-timing|TWO_TIMING' --exclude-dir=.git --exclude=rename.sh . || true)
[ -n "$files" ] || { echo "nothing to rename"; exit 0; }
for f in $files; do
  sed -i '' -e "s/Two-Timing/$name/g" -e "s/two-timing/$slug/g" -e "s/TWO_TIMING/$upper/g" "$root/$f"
done
echo "Renamed to '$name' ($slug) in:"; printf '  %s\n' $files
echo "Next: mv \"$root\" \"$(dirname "$root")/$slug\"  then re-add the marketplace and reinstall."
