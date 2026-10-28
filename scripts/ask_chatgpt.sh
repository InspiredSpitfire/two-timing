#!/usr/bin/env bash
# Ask ChatGPT (via the Codex CLI) one thing and print only its answer.
#
#   ask_chatgpt.sh [options] "prompt"
#   ask_chatgpt.sh [options] -f prompt.md
#   echo "prompt" | ask_chatgpt.sh [options] -
#
# Options:
#   -m MODEL        Codex model override (default: the user's Codex config)
#   -s SANDBOX      read-only (default) | workspace-write | danger-full-access
#   -i IMAGE        attach an image (repeatable). Forces stdin mode, see below.
#   -r THREAD_ID    continue an earlier conversation (codex exec resume)
#   -t FILE         write the thread id here so the caller can resume later
#   -C DIR          working directory for Codex (default: current dir)
#   -o FILE         also save the answer to FILE
#   -e EFFORT       reasoning effort: low | medium | high
#   --isolated      stock-model mode: scratch CODEX_HOME (a symlink to your own
#                   auth file, nothing else), --ephemeral, --ignore-user-config.
#                   Use for fair comparisons.
#   --web           allow web search (tools.web_search=true)
#   --raw           print the full JSON event stream instead of the last message
#   -h              help
#
# Two Codex gotchas this script exists to absorb:
#   1. `codex exec` reads stdin whenever stdin is a non-TTY pipe, even with the
#      prompt given as an argument, and hangs forever in a background shell.
#      The prompt is therefore ALWAYS fed on stdin from a temp file, and stdin
#      is never left open.
#   2. `-i IMAGE` is variadic, so a positional prompt after it is swallowed as
#      another image path. With images there is no positional at all; the
#      prompt arrives on stdin only.
set -euo pipefail
. "$(dirname "$0")/lib.sh"

model=""; sandbox="read-only"; images=(); thread=""; thread_file=""; cwd=""; save=""
isolated=0; raw=0; web=0; effort=""; prompt_file=""; prompt=""
usage() { sed -n '2,32p' "$0" | sed 's/^# \{0,1\}//'; }
while [ $# -gt 0 ]; do
  case "$1" in
    -m) model="$2"; shift 2;;
    -s) sandbox="$2"; shift 2;;
    -i) images+=("$2"); shift 2;;
    -r) thread="$2"; shift 2;;
    -t) thread_file="$2"; shift 2;;
    -C) cwd="$2"; shift 2;;
    -o) save="$2"; shift 2;;
    -e) effort="$2"; shift 2;;
    -f) prompt_file="$2"; shift 2;;
    --isolated) isolated=1; shift;;
    --web) web=1; shift;;
    --raw) raw=1; shift;;
    -h|--help) usage; exit 0;;
    -) prompt_file="/dev/stdin"; shift;;
    --) shift; prompt="${1:-}"; shift || true;;
    -*) tt_err "unknown option $1"; usage >&2; exit 64;;
    *) prompt="$1"; shift;;
  esac
done

codex=$(tt_find_codex) || exit 69
tmp=$(tt_mktemp); trap 'rm -rf "$tmp"' EXIT

# Prompt always ends up in a file so it can be fed on stdin.
if [ -n "$prompt_file" ]; then cat "$prompt_file" > "$tmp/prompt.md"
elif [ -n "$prompt" ]; then printf '%s' "$prompt" > "$tmp/prompt.md"
else tt_err "no prompt given"; usage >&2; exit 64; fi
[ -s "$tmp/prompt.md" ] || { tt_err "prompt is empty"; exit 64; }

args=(exec)
[ -n "$thread" ] && args+=(resume)
args+=(--json --skip-git-repo-check -o "$tmp/answer.md")
# `resume` inherits the thread's sandbox and rejects -s.
[ -z "$thread" ] && args+=(-s "$sandbox")
[ -n "$model" ] && args+=(-m "$model")
[ -n "$effort" ] && args+=(-c "model_reasoning_effort=\"$effort\"")
[ "$web" = 1 ] && args+=(-c "tools.web_search=true")
[ -n "$cwd" ] && [ -z "$thread" ] && args+=(-C "$cwd")
if [ "$isolated" = 1 ]; then
  args+=(--ephemeral --ignore-user-config)
  export CODEX_HOME; CODEX_HOME=$(tt_isolated_codex_home "$tmp") || exit 69
fi
for img in "${images[@]+"${images[@]}"}"; do args+=(-i "$img"); done
[ -n "$thread" ] && args+=("$thread")
# No positional when images are attached (gotcha 2); otherwise `-` = stdin.
[ ${#images[@]} -eq 0 ] && args+=(-)

set +e
NO_COLOR=1 "$codex" "${args[@]}" < "$tmp/prompt.md" > "$tmp/events.jsonl" 2> "$tmp/stderr.txt"
rc=$?
set -e

tid=$(grep -m1 '"thread.started"' "$tmp/events.jsonl" 2>/dev/null | sed -E 's/.*"thread_id":"([^"]+)".*/\1/' || true)
[ -n "$thread_file" ] && [ -n "$tid" ] && printf '%s\n' "$tid" > "$thread_file"

if [ "$raw" = 1 ]; then cat "$tmp/events.jsonl"; fi
if [ -s "$tmp/answer.md" ]; then
  [ "$raw" = 1 ] || cat "$tmp/answer.md"
  [ -n "$save" ] && cp "$tmp/answer.md" "$save"
elif [ "$rc" -eq 0 ]; then
  tt_err "codex returned no final message"; rc=70
fi
if [ "$rc" -ne 0 ]; then
  tt_err "codex exec exited $rc"
  grep -v -E 'rmcp::transport|AuthRequired|skills context budget' "$tmp/stderr.txt" | tail -n 20 >&2 || true
  grep -q -i -E 'not logged in|login|unauthorized|401' "$tmp/stderr.txt" "$tmp/events.jsonl" 2>/dev/null \
    && tt_err "Codex looks logged out. Run: codex login"
fi
[ -n "$tid" ] && printf '[thread: %s]\n' "$tid" >&2
exit "$rc"
