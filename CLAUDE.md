# two-timing

Claude Code plugin: Claude + ChatGPT working as one brain from inside a Claude Code session. Five skills (`duet`, `route`, `second-opinion`, `showdown`, `handoff`), two commands (`/two-timing` front door, `/two-time` alias for duet), shell scripts in `scripts/`, shared knowledge in `references/`.

Rules for editing this repo:

- **No personal names, emails, or legal names anywhere**, including examples, commit metadata, and screenshots. Public author is "Inspired Spitfire"; copyright holder is "Inspired Spitfire LLC". Run `python3 scripts/check_plugin.py --forbid "<terms>"` before a release with the terms supplied on the command line, never stored in the repo.
- **Brand voice lives in README.md only.** Skills, references, scripts, and examples are plain and brand-agnostic so the plugin works for anyone.
- **Skills never fake the second AI.** If ChatGPT or headless Claude is unreachable, the output says so and is labelled single-AI or UNREVIEWED.
- **Scripts never leave stdin open** (`codex exec` hangs on an open pipe) and never pass a positional prompt after `-i` (it is swallowed as an image path). Keep the comments that explain both.
- **The shipped routing table (`references/routing-table.md`) is a default**, copied by `scripts/routing_table.sh --init`. Skills never edit it in place.
- **Read-only sandbox for ChatGPT by default.** Nothing in this plugin posts, sends, installs, or writes outside the working directory on its own.
- **Renaming** the plugin is `scripts/rename.sh "New Name" new-slug`; keep the name out of places that script cannot reach (binary assets, URLs it does not know).
- Examples in `docs/examples/` are real captured runs with any personal data scrubbed, each with the date, CLI versions, and models at the top.
