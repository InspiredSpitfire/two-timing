# Captured examples

Real runs, captured on the release machine on 2026-10-23 and scrubbed of user paths (`~` and `<tmp>` replace them). Nothing here is mocked; every ChatGPT reply is the text the Codex CLI returned, with its thread id.

| | |
|---|---|
| Claude Code | 2.1.220 for the 2026-10-23 runs, 2.1.310 for the 2026-10-24 runs; installed plugin, user scope |
| Codex CLI | codex-cli 0.163.0-alpha.11.1, model `gpt-6.1-sol` (the user's configured default), ChatGPT login |
| Claude headless (`claude -p`) | logged out on 2026-10-23 (the first showdown attempt shows that failure honestly); logged in on 2026-10-24 for the full showdown and the fresh-session trigger capture |

How the runs were made: each skill was executed step by step inside a Claude Code session with the plugin installed, calling the plugin's own scripts for every ChatGPT turn. On 2026-10-24 `/route` was additionally typed into a fresh headless session and triggered on its own (end of 01-route.md), and `/showdown` ran with both contenders authenticated and was graded blind by two independent graders.

| File | Skill | What it shows |
|---|---|---|
| [01-route.md](01-route.md) | `/route` | Decision cards from the shipped table, from an edited project table, and with the Fried brain-state dial |
| [02-duet.md](02-duet.md) | `/duet` | Claude draft, ChatGPT's four-point critique, Claude's reconcile, one merged answer with "who did what" |
| [03-second-opinion.md](03-second-opinion.md) | `/second-opinion` | Three rounds of NEEDS REVISION, each from a fresh thread, four real defects the author missed, and the three-round cap being honoured (final fix labelled UNREVIEWED) |
| [04-showdown.md](04-showdown.md) | `/showdown` | Both stock contenders answering under isolation, two blind graders, the verdict, then the key revealed; plus the earlier honest failure when one side was logged out |
| [05-handoff.md](05-handoff.md) | `/handoff` | A packet sent cold to ChatGPT, its reply in the requested format, and the import step |
