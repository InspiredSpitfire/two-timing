# Captured examples

Real runs, captured on the release machine on 2026-10-23 and scrubbed of user paths (`~` and `<tmp>` replace them). Nothing here is mocked; every ChatGPT reply is the text the Codex CLI returned, with its thread id.

| | |
|---|---|
| Claude Code | 2.1.220, running the installed plugin (user scope, `~/.claude/plugins/cache/two-timing/two-timing/0.1.0`) |
| Codex CLI | codex-cli 0.163.0-alpha.11.1, model `gpt-6.1-sol` (the user's configured default), ChatGPT login |
| Claude headless (`claude -p`) | **logged out on the capture machine**, so the `/showdown` Claude contender errored and is shown erroring |

How the runs were made: each skill was executed step by step inside a Claude Code session with the plugin installed, calling the plugin's own scripts for every ChatGPT turn. The slash-command trigger itself (typing `/duet ...` into a fresh session) was not captured, because that needs headless Claude to be logged in; `claude plugin details two-timing` confirms all seven components are registered.

| File | Skill | What it shows |
|---|---|---|
| [01-route.md](01-route.md) | `/route` | Decision cards from the shipped table, from an edited project table, and with the Fried brain-state dial |
| [02-duet.md](02-duet.md) | `/duet` | Claude draft, ChatGPT's four-point critique, Claude's reconcile, one merged answer with "who did what" |
| [03-second-opinion.md](03-second-opinion.md) | `/second-opinion` | Three rounds of NEEDS REVISION, each from a fresh thread, four real defects the author missed, and the three-round cap being honoured (final fix labelled UNREVIEWED) |
| [04-showdown.md](04-showdown.md) | `/showdown` | The output file with one side erroring honestly (logged-out Claude) and the other answering |
| [05-handoff.md](05-handoff.md) | `/handoff` | A packet sent cold to ChatGPT, its reply in the requested format, and the import step |
