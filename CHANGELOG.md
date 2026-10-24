# Changelog

All notable changes to this plugin. Dates are release dates.

## [0.1.1] - 2026-10-24

### Fixed
- Isolated Claude contender (`ask_claude.sh --isolated`, used by `/showdown`) no longer uses an empty scratch `CLAUDE_CONFIG_DIR`. Claude Code binds the keychain login to the config dir, so that mode was always logged out. Isolation now comes from flags (no settings, skills, MCP, or tools) plus an empty scratch working directory; canary-checked for voice leakage.
- README doctor path no longer hard-codes the plugin version.

## [0.1.0] - 2026-10-23

First working version.

### Added
- `duet` skill (and `/two-time` alias): one task, both AIs as collaborators, one merged answer with a "who did what" line. Lead chosen by the routing table or `--lead`.
- `route` skill: decision card (Lead, Check, Pattern, Why, Next) from an editable routing table with project > user > shipped-default precedence, plus a brain-state dial.
- `second-opinion` skill: adversarial review by ChatGPT returning PASS / NEEDS REVISION per criterion; fresh thread on each re-review; three-round cap.
- `showdown` skill: stock-vs-stock comparison under isolated conditions, blind A/B, two independent graders; defers to a locally installed `ai-showdown` skill when present.
- `handoff` skill: context packet to ChatGPT (file, clipboard, or sent directly) and import of ChatGPT's reply back into the session.
- `/two-timing` front-door command: route, then run.
- Scripts: `ask_chatgpt.sh`, `ask_claude.sh`, `showdown.sh`, `doctor.sh`, `routing_table.sh`, `rename.sh`, `check_plugin.py`, shared `lib.sh` that finds both CLIs even when `PATH` is stale.
- References: routing table, calling guide with the Codex stdin and image gotchas, handoff template.
- Examples captured on this release's CLI versions in `docs/examples/`.
