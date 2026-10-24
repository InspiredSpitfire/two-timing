#!/usr/bin/env bash
# Run ONE prompt through stock Claude and stock ChatGPT under identical,
# isolated conditions and write both answers verbatim to a markdown file.
#
#   showdown.sh [-d OUTDIR] [-c CLAUDE_MODEL] [-g CODEX_MODEL] [--web] "prompt"
#   showdown.sh ... -f prompt.md
#
# Writes OUTDIR/showdown-YYYY-MM-DD-HHMMSS.md with: prompt, CLI versions,
# models, conditions, and the two answers labelled A and B in a random order.
# The mapping A/B -> Claude/ChatGPT goes to a sibling .key file so graders can
# be kept blind. Grading is the skill's job, not this script's.
#
# Fair-fight rules enforced here: same prompt text, one shot each, both
# isolated from the user's config, both models pinned, both run in parallel,
# an error is recorded as that side's answer (no silent retry).
set -euo pipefail
. "$(dirname "$0")/lib.sh"
here=$(cd "$(dirname "$0")" && pwd)

outdir="${TWO_TIMING_SHOWDOWNS:-$HOME/.two-timing/showdowns}"
cmodel="${TWO_TIMING_CLAUDE_MODEL:-claude-opus-5-5}"
gmodel="${TWO_TIMING_CODEX_MODEL:-$(sed -n -E 's/^model *= *"([^"]+)".*/\1/p' "$HOME/.codex/config.toml" 2>/dev/null | head -1)}"
web=0; prompt_file=""; prompt=""
while [ $# -gt 0 ]; do
  case "$1" in
    -d) outdir="$2"; shift 2;;
    -c) cmodel="$2"; shift 2;;
    -g) gmodel="$2"; shift 2;;
    -f) prompt_file="$2"; shift 2;;
    --web) web=1; shift;;
    -h|--help) sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    *) prompt="$1"; shift;;
  esac
done
tmp=$(tt_mktemp); trap 'rm -rf "$tmp"' EXIT
if [ -n "$prompt_file" ]; then cat "$prompt_file" > "$tmp/prompt.md"; else printf '%s' "$prompt" > "$tmp/prompt.md"; fi
[ -s "$tmp/prompt.md" ] || { tt_err "no prompt"; exit 64; }
mkdir -p "$outdir"
stamp=$(date +%Y-%m-%d-%H%M%S)
out="$outdir/showdown-$stamp.md"

cver=$("$(tt_find_claude)" --version 2>/dev/null | head -1 || echo unknown)
gver=$("$(tt_find_codex)" --version 2>/dev/null | head -1 || echo unknown)

ctools=""; gweb=()
[ "$web" = 1 ] && { ctools="WebSearch,WebFetch"; gweb=(--web); }

# Both sides in parallel, stdin closed (</dev/null) so neither can hang.
( "$here/ask_claude.sh" --isolated -m "$cmodel" --tools "$ctools" -f "$tmp/prompt.md" > "$tmp/claude.md" 2> "$tmp/claude.err" </dev/null || printf '\n[ERROR: claude side exited %s]\n%s\n' "$?" "$(cat "$tmp/claude.err")" >> "$tmp/claude.md" ) &
gm=(); [ -n "$gmodel" ] && gm=(-m "$gmodel")
( "$here/ask_chatgpt.sh" --isolated "${gm[@]+"${gm[@]}"}" -e medium "${gweb[@]+"${gweb[@]}"}" -f "$tmp/prompt.md" > "$tmp/chatgpt.md" 2> "$tmp/chatgpt.err" </dev/null || printf '\n[ERROR: chatgpt side exited %s]\n%s\n' "$?" "$(cat "$tmp/chatgpt.err")" >> "$tmp/chatgpt.md" ) &
wait

if [ $((RANDOM % 2)) -eq 0 ]; then a=claude; b=chatgpt; else a=chatgpt; b=claude; fi
printf 'A=%s\nB=%s\n' "$a" "$b" > "${out%.md}.key"

{
  printf '# Showdown %s\n\n' "$stamp"
  printf '**Prompt:**\n\n```\n%s\n```\n\n' "$(cat "$tmp/prompt.md")"
  printf -- '- Claude: %s (%s)\n- ChatGPT: %s (%s)\n' "$cmodel" "$cver" "${gmodel:-CLI default, not pinned}" "$gver"
  printf -- '- Conditions: headless, user config isolated, one shot each, tools: %s\n\n' "${ctools:-none}"
  printf '## Answer A\n\n%s\n\n## Answer B\n\n%s\n\n' "$(cat "$tmp/$a.md")" "$(cat "$tmp/$b.md")"
  printf '## Key\n\nWhich answer was which is in `%s`. Open it only after grading.\n' "$(basename "${out%.md}.key")"
} > "$out"
printf '%s\n' "$out"
