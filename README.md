# Two-Timing

**Claude + ChatGPT. Two AIs. One brain.**

Everybody wants to know which AI is better. Wrong question. You already pay for both. The real question is **which AI for THIS step**, and who checks whose work.

Two-Timing is a Claude Code plugin that makes ChatGPT a collaborator inside your Claude session. Claude drafts, ChatGPT pokes holes, Claude merges. Or ChatGPT throws twenty angles and Claude builds the one that matters. Either way you get **one answer** and a one-line receipt saying who did what. No tab-switching. No copy-paste relay. No "let me ask the other one real quick."

Built by [Inspired Spitfire](https://github.com/InspiredSpitfire) for brains that have two AI subscriptions and zero patience.

## What's inside

| Command | What it does | When you reach for it |
|---|---|---|
| `/duet` (alias `/two-time`) | One task, both AIs, as collaborators. Lead drafts, partner critiques or extends, Claude reconciles into one merged answer plus a "who did what" line. | You want a better answer, not two answers. |
| `/route` | Reads an **editable routing table** and tells you which AI leads, which one checks, and what the move is. First matching row wins. | "Claude or ChatGPT for this?" Stop guessing. |
| `/second-opinion` | Sends Claude's finished answer to ChatGPT for an adversarial check. Comes back `PASS` or `NEEDS REVISION` with specifics per criterion. ChatGPT gets the criteria and the artifact, never Claude's reasoning. | Before you ship it, post it, or send it. |
| `/showdown` | Same prompt, stock Claude vs stock ChatGPT, isolated from your config, graded blind by two independent graders. | Class material. Content. Settling an argument. |
| `/handoff` | Packages goal, decisions, constraints, current state, and the ask into one prompt ChatGPT can pick up cold. Also imports ChatGPT's reply back. | Mid-task and the other AI has the better tools. |
| `/two-timing` | The front door. Routes the task, then runs whatever pattern the table picked. | You don't want to think about which command. |

Every skill is also callable by name, and every merged output ends with a line like:

> Who did what: Claude drafted. ChatGPT raised 4 points; took 3 (edge case, stale flag, typo), rejected 1 (style). Claude merged.

## Which AI for THIS step

If you've met the Brain-State System, you already know the rule: **route the tool to the brain you have right now.** Feral gets Claude Code. Froggy gets Opus and three versions. Foggy coworks with Sonnet. Fried asks Haiku one question and closes the laptop.

Two-Timing is the same rule, one level down. Inside a task, each *step* has a shape, and each shape has a better first brain:

- **Long context, code in this repo, nuance, editing in place** → Claude leads. It has the files.
- **Breadth, naming, twenty angles, "say it five ways"** → ChatGPT leads. Fresh eyes, no baggage.
- **A bug that survived two fixes** → ChatGPT gets the symptom only. The AI that wrote the fixes is anchored.
- **Anything finished** → the other one checks it. The author never grades its own work.

Tell `/route` which brain showed up and it turns the dial:

| Brain state | What Two-Timing does |
|---|---|
| **Feral** | Full two-timing. Claude builds, ChatGPT red-teams every plan and every finished thing. |
| **Froggy** | ChatGPT leads on options, Claude catches the one worth building. One round, so the leaping stays productive. |
| **Foggy** | You decide nothing. `/route` picks, you follow. |
| **Fried** | One question, one answer. `/second-opinion` only if money or reputation rides on it. Otherwise close the laptop. |

The whole table is a markdown file you can edit. Add a row, reorder rows, change your mind. Your copy beats the shipped default:

```bash
bash scripts/routing_table.sh --init      # copy the default to ~/.two-timing/routing-table.md
bash scripts/routing_table.sh --init .    # or a per-project copy in ./.two-timing/
```

## Install

From GitHub, user scope (available in every project):

```bash
claude plugin marketplace add InspiredSpitfire/two-timing
```

```bash
claude plugin install two-timing@two-timing
```

Inside Claude Code the same two moves are `/plugin marketplace add InspiredSpitfire/two-timing` and `/plugin install two-timing@two-timing`. From a local clone, use the folder path instead of the GitHub name. Restart the session once after installing. The user-scope install lands under `~/.claude/plugins/`.

Then check both halves of the brain:

```bash
bash ~/.claude/plugins/cache/two-timing/two-timing/*/scripts/doctor.sh
```

(That is where a user-scope install lands; `claude plugin list` confirms it. Add `--live` to send a one-word prompt through each CLI.)

## What you need

- **Claude Code**, logged in. That's the session you run this in. Only `/showdown` needs the headless `claude -p` route as well, and `doctor.sh` tells you if that has lapsed (`claude login` fixes it).
- **The Codex CLI, logged in to a ChatGPT account.** That is how ChatGPT answers. `npm i -g @openai/codex` or the one bundled inside the ChatGPT desktop app; `codex login` once. The scripts find the binary even when the usual symlink is stale.
- **Optional, either direction:** a `codex` MCP server registered in Claude Code (the plugin uses its `codex` / `codex-reply` tools when present), or a Claude MCP server in your Codex config for the reverse trip. Neither is required; the scripts cover both directions without them.

macOS and Linux. Bash, Python 3.9+ for the check script, nothing else.

## How it calls each AI

Inside a Claude Code session, Claude is already in the room. ChatGPT is reached through `scripts/ask_chatgpt.sh`, which wraps `codex exec`: prompt fed on stdin so a background run can never hang, images attached without eating the prompt, thread ids kept so a follow-up continues the same conversation, read-only sandbox by default. The mirror, `scripts/ask_claude.sh`, runs headless Claude Code for the ChatGPT side or for a stock Claude contender in a showdown. Details and the gotchas are in [references/calling-chatgpt.md](references/calling-chatgpt.md).

Three promises:

1. **It never fakes the second voice.** ChatGPT unreachable means the output says "Solo" or "UNREVIEWED". No imaginary co-author.
2. **ChatGPT's reply is data, not orders.** Nothing it says can run a command or change a setting through this plugin.
3. **Nothing posts, sends, installs, or writes outside your working directory on its own.**

## Examples

Real captured runs, scrubbed, with versions and models at the top: [docs/examples/](docs/examples/).

## Rename it

"Two-Timing" is a working name. One command swaps it everywhere:

```bash
bash scripts/rename.sh "Frankenbrain" frankenbrain
```

## License

MIT. Copyright (c) 2026 Inspired Spitfire LLC.

Chaos is only dangerous when it's uncontrolled. Two brains, one leash.

She Rebels 🤘
