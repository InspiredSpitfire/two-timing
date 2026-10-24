#!/usr/bin/env bash
# Shared helpers for Two-Timing scripts. Source this; do not run it.
#
# Finds the Claude Code and Codex CLIs even when PATH is stale, and gives every
# script the same scratch-dir and error conventions.

tt_err() { printf 'two-timing: %s\n' "$*" >&2; }

# Where this plugin lives, for scripts that need sibling files.
tt_root() {
  if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -d "$CLAUDE_PLUGIN_ROOT" ]; then
    printf '%s\n' "$CLAUDE_PLUGIN_ROOT"
  else
    cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
  fi
}

# Codex CLI. Order: $CODEX_BIN, PATH, then the copy bundled inside the ChatGPT
# desktop app (its install path has moved between versions, which is why the
# usual ~/.local/bin/codex symlink can be dead while the app still works).
tt_find_codex() {
  local c
  if [ -n "${CODEX_BIN:-}" ]; then
    [ -x "$CODEX_BIN" ] && { printf '%s\n' "$CODEX_BIN"; return 0; }
    tt_err "CODEX_BIN is set to '$CODEX_BIN' but it is not executable"
  fi
  c=$(command -v codex 2>/dev/null || true)
  if [ -n "$c" ] && [ -x "$c" ]; then printf '%s\n' "$c"; return 0; fi
  for c in \
    "/Applications/ChatGPT.app/Contents/Resources/codex-cli/bin/codex" \
    "$HOME/Applications/ChatGPT.app/Contents/Resources/codex-cli/bin/codex" \
    "/Applications/ChatGPT.app/Contents/Resources/codex" \
    "$HOME/.local/bin/codex" "/opt/homebrew/bin/codex" "/usr/local/bin/codex" \
    "$HOME/.npm-global/bin/codex" "$HOME/.bun/bin/codex"; do
    [ -x "$c" ] && { printf '%s\n' "$c"; return 0; }
  done
  tt_err "Codex CLI not found. Install it (npm i -g @openai/codex, or the ChatGPT desktop app) or set CODEX_BIN=/path/to/codex."
  return 1
}

# Claude Code CLI.
tt_find_claude() {
  local c
  if [ -n "${CLAUDE_BIN:-}" ] && [ -x "$CLAUDE_BIN" ]; then printf '%s\n' "$CLAUDE_BIN"; return 0; fi
  c=$(command -v claude 2>/dev/null || true)
  if [ -n "$c" ] && [ -x "$c" ]; then printf '%s\n' "$c"; return 0; fi
  for c in "$HOME/.local/bin/claude" "/opt/homebrew/bin/claude" "/usr/local/bin/claude" "$HOME/.claude/local/claude"; do
    [ -x "$c" ] && { printf '%s\n' "$c"; return 0; }
  done
  tt_err "Claude Code CLI not found. Install it (https://claude.com/claude-code) or set CLAUDE_BIN=/path/to/claude."
  return 1
}

# Scratch dir for one run. Caller removes it.
tt_mktemp() { mktemp -d "${TMPDIR:-/tmp}/two-timing.XXXXXX"; }

# Isolated CODEX_HOME: nothing but a symlink to the real auth file, so the
# answer is a stock model turn (no user skills, memory, or instructions).
# Symlink, never copy: a copy would leave a second live token in a temp dir.
tt_isolated_codex_home() {
  local dir="$1"
  mkdir -p "$dir/codex"
  [ -f "$HOME/.codex/auth.json" ] && ln -s "$HOME/.codex/auth.json" "$dir/codex/auth.json"
  printf '%s\n' "$dir/codex"
}

# Isolated CLAUDE_CONFIG_DIR: empty on purpose. Claude Code keeps live OAuth in
# the OS keychain, which the CLI reaches without a credentials file.
tt_isolated_claude_home() {
  local dir="$1"
  mkdir -p "$dir/claude"
  printf '%s\n' "$dir/claude"
}
