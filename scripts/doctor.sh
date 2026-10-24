#!/usr/bin/env bash
# Check that both halves of the brain are installed and logged in.
#   doctor.sh          quick checks (no model calls)
#   doctor.sh --live   also send a one-word prompt through each CLI
set -uo pipefail
. "$(dirname "$0")/lib.sh"
here=$(cd "$(dirname "$0")" && pwd)
live=0; [ "${1:-}" = "--live" ] && live=1
ok=0; bad=0
pass() { printf '  OK    %s\n' "$*"; ok=$((ok+1)); }
fail() { printf '  FAIL  %s\n' "$*"; bad=$((bad+1)); }

echo "Two-Timing doctor"
echo "Claude Code"
if c=$(tt_find_claude 2>/dev/null); then
  pass "binary: $c ($("$c" --version 2>/dev/null | head -1))"
  st=$(env -u CLAUDECODE "$c" auth status 2>/dev/null || true)
  if printf '%s' "$st" | grep -q '"loggedIn": *true'; then pass "logged in"
  else fail "not logged in for headless use. Run: claude login   (only /showdown and the ChatGPT-side scripts need this; inside a Claude Code session you already are Claude)"; fi
else fail "claude CLI not found"; fi

echo "Codex CLI (ChatGPT)"
if g=$(tt_find_codex 2>/dev/null); then
  pass "binary: $g ($("$g" --version 2>/dev/null | head -1))"
  if [ -L "$HOME/.local/bin/codex" ] && [ ! -e "$HOME/.local/bin/codex" ]; then
    fail "~/.local/bin/codex is a dead symlink (ChatGPT.app moved its CLI). Fix: ln -sf \"$g\" ~/.local/bin/codex"
  fi
  st=$("$g" login status 2>&1 || true)
  if printf '%s' "$st" | grep -q -i 'logged in'; then pass "logged in ($(printf '%s' "$st" | head -1))"
  else fail "not logged in. Run: codex login"; fi
else fail "codex CLI not found"; fi

echo "MCP routes (optional)"
if c=$(tt_find_claude 2>/dev/null); then
  if env -u CLAUDECODE "$c" mcp list 2>/dev/null | grep -q -i codex; then pass "a 'codex' MCP server is registered in Claude Code (the codex / codex-reply tools)"
  else printf '  --    no codex MCP server in Claude Code; scripts/ask_chatgpt.sh is used instead\n'; fi
fi
if [ -f "$HOME/.codex/config.toml" ] && grep -q -i 'claude' "$HOME/.codex/config.toml" 2>/dev/null; then
  pass "Codex config mentions a Claude MCP server"
else printf '  --    no Claude MCP server in Codex config; scripts/ask_claude.sh is used instead\n'; fi

if [ "$live" = 1 ]; then
  echo "Live round trip"
  r=$("$here/ask_chatgpt.sh" -e low "Reply with only the word: OK" 2>/dev/null </dev/null || true)
  [ "$(printf '%s' "$r" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')" = "OK" ] && pass "ChatGPT answered" || fail "ChatGPT round trip failed: ${r:-no output}"
  r=$("$here/ask_claude.sh" -m claude-haiku-5-5 "Reply with only the word: OK" 2>/dev/null </dev/null || true)
  [ "$(printf '%s' "$r" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')" = "OK" ] && pass "Claude answered" || fail "Claude headless round trip failed: ${r:-no output}"
fi
echo
echo "$ok ok, $bad failing."
[ "$bad" -eq 0 ]
