#!/usr/bin/env bash
# Ask Claude (headless Claude Code, `claude -p`) one thing and print only its answer.
#
#   ask_claude.sh [options] "prompt"
#   ask_claude.sh [options] -f prompt.md
#   echo "prompt" | ask_claude.sh [options] -
#
# Options:
#   -m MODEL     model override (e.g. claude-opus-5-5, claude-sonnet-5-5)
#   -o FILE      also save the answer to FILE
#   --isolated   stock-model mode: no settings, no skills, no MCP, no tools, run
#                from an empty scratch directory. Keeps the real config dir
#                because the login credential is bound to it. Use for fair
#                comparisons.
#   --tools LIST comma-separated tools to allow (default none in isolated mode,
#                Claude Code's default otherwise)
#   -h           help
#
# Use this from the ChatGPT side, or for a stock Claude contender in a showdown.
# Inside a Claude Code session you ARE Claude: answer directly instead.
#
# `claude -p` prints "Not logged in" with exit code 0 when the keychain OAuth
# session has lapsed, so the script checks the text and exits 77 for that.
set -euo pipefail
. "$(dirname "$0")/lib.sh"

model=""; save=""; isolated=0; tools=""; prompt_file=""; prompt=""
usage() { sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; }
while [ $# -gt 0 ]; do
  case "$1" in
    -m) model="$2"; shift 2;;
    -o) save="$2"; shift 2;;
    -f) prompt_file="$2"; shift 2;;
    --isolated) isolated=1; shift;;
    --tools) tools="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    -) prompt_file="/dev/stdin"; shift;;
    --) shift; prompt="${1:-}"; shift || true;;
    -*) tt_err "unknown option $1"; usage >&2; exit 64;;
    *) prompt="$1"; shift;;
  esac
done

claude=$(tt_find_claude) || exit 69
tmp=$(tt_mktemp); trap 'rm -rf "$tmp"' EXIT
if [ -n "$prompt_file" ]; then cat "$prompt_file" > "$tmp/prompt.md"
elif [ -n "$prompt" ]; then printf '%s' "$prompt" > "$tmp/prompt.md"
else tt_err "no prompt given"; usage >&2; exit 64; fi
[ -s "$tmp/prompt.md" ] || { tt_err "prompt is empty"; exit 64; }

args=(-p --no-session-persistence)
[ -n "$model" ] && args+=(--model "$model")
run_dir="."
if [ "$isolated" = 1 ]; then
  args+=(--setting-sources "" --disable-slash-commands --strict-mcp-config --tools "${tools}")
  run_dir=$(tt_isolated_claude_cwd "$tmp")
elif [ -n "$tools" ]; then
  args+=(--tools "$tools")
fi
# A nested Claude Code session must not inherit the parent's session markers.
set +e
( cd "$run_dir" && env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT "$claude" "${args[@]}" < "$tmp/prompt.md" > "$tmp/answer.md" 2> "$tmp/stderr.txt" )
rc=$?
set -e
if grep -q -i -E 'not logged in|oauth session expired|please run /login' "$tmp/answer.md" "$tmp/stderr.txt"; then
  tt_err "Claude Code is logged out machine-wide. Run 'claude login' (or /login inside claude) in an interactive terminal, then retry."
  cat "$tmp/answer.md" >&2
  exit 77
fi
cat "$tmp/answer.md"
[ -n "$save" ] && cp "$tmp/answer.md" "$save"
if [ "$rc" -ne 0 ]; then tt_err "claude -p exited $rc"; tail -n 20 "$tmp/stderr.txt" >&2; fi
exit "$rc"
