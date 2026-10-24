#!/usr/bin/env bash
# Print the path of the routing table that is in force, or set one up.
#
#   routing_table.sh            print the active table's path
#   routing_table.sh --cat      print its contents
#   routing_table.sh --init     copy the default to ~/.two-timing/routing-table.md
#   routing_table.sh --init .   copy the default to ./.two-timing/routing-table.md
#
# Precedence (first hit wins):
#   1. ./.two-timing/routing-table.md        (this project)
#   2. $TWO_TIMING_ROUTING_TABLE              (explicit path)
#   3. ~/.two-timing/routing-table.md         (this user)
#   4. <plugin>/references/routing-table.md   (shipped default, never edit in place)
set -euo pipefail
. "$(dirname "$0")/lib.sh"
default="$(tt_root)/references/routing-table.md"

active() {
  if [ -f "./.two-timing/routing-table.md" ]; then printf '%s\n' "$PWD/.two-timing/routing-table.md"
  elif [ -n "${TWO_TIMING_ROUTING_TABLE:-}" ] && [ -f "$TWO_TIMING_ROUTING_TABLE" ]; then printf '%s\n' "$TWO_TIMING_ROUTING_TABLE"
  elif [ -f "$HOME/.two-timing/routing-table.md" ]; then printf '%s\n' "$HOME/.two-timing/routing-table.md"
  else printf '%s\n' "$default"; fi
}

case "${1:-}" in
  --cat) cat "$(active)";;
  --init)
    if [ "${2:-}" = "." ]; then dest="./.two-timing/routing-table.md"; else dest="$HOME/.two-timing/routing-table.md"; fi
    if [ -e "$dest" ]; then tt_err "$dest already exists; edit it directly"; exit 1; fi
    mkdir -p "$(dirname "$dest")"; cp "$default" "$dest"; printf '%s\n' "$dest";;
  -h|--help) sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//';;
  "") active;;
  *) tt_err "unknown option $1"; exit 64;;
esac
