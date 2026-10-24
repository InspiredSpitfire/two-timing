# Two-Timing routing table

Which AI leads, which one checks, and in what pattern. **Edit this file.** The
`/route` skill reads it top to bottom and the **first row whose "Task looks
like" matches wins**, so put your most specific rows first and keep the
catch-all row last.

Where the live copy lives (first hit wins):

1. `./.two-timing/routing-table.md` in the project you are working in
2. the path in `$TWO_TIMING_ROUTING_TABLE`
3. `~/.two-timing/routing-table.md` for everything you do
4. this shipped default inside the plugin (do not edit it in place; run
   `scripts/routing_table.sh --init` to copy it somewhere editable)

## Columns

- **Lead**: who produces the first real draft. `Claude`, `ChatGPT`, or `both`.
- **Check**: who looks at that draft second. `ChatGPT`, `Claude`, or `none`.
- **Pattern**: the move `/route` will recommend.
  - `claude-only`: do it in Claude Code, no second AI.
  - `chatgpt-only`: send it to ChatGPT, bring the answer back.
  - `claude→chatgpt`: Claude drafts, ChatGPT critiques or extends, Claude reconciles (`/duet --lead claude`).
  - `chatgpt→claude`: ChatGPT brainstorms or drafts, Claude selects, structures, builds (`/duet --lead chatgpt`).
  - `second-opinion`: a finished answer goes to ChatGPT for an adversarial PASS / NEEDS REVISION (`/second-opinion`).
  - `showdown`: both answer blind, graders compare (`/showdown`).
  - `handoff`: package the context and move the whole task to the other AI (`/handoff`).

## Table

| Task looks like | Lead | Check | Pattern | Why |
|---|---|---|---|---|
| Code in this repo: write, fix, refactor, tests | Claude | ChatGPT | claude→chatgpt | Claude has the files and the tools. ChatGPT reviews the diff with fresh eyes. |
| A bug that has survived two fixes | ChatGPT | Claude | chatgpt→claude | The AI that wrote the last two fixes is anchored. Give ChatGPT the symptom only; Claude applies what comes back. |
| Long documents, many files, big transcripts, "read all of this" | Claude | ChatGPT | claude→chatgpt | Long context is Claude's lane. ChatGPT spot-checks the conclusion against a short excerpt. |
| Edit this but keep the structure, voice, or format | Claude | none | claude-only | Structured editing in place. A second AI here adds drift, not quality. |
| Nuanced writing, matching a voice, delicate wording | Claude | ChatGPT | claude→chatgpt | Claude drafts for nuance. ChatGPT reads it cold and says where it lands wrong. |
| "Give me 20 options", names, angles, hooks, titles | ChatGPT | Claude | chatgpt→claude | Breadth first, then Claude picks and sharpens three. |
| Say it five different ways, quick alternatives | ChatGPT | none | chatgpt-only | Fast, cheap, no context needed. |
| Plans, architecture, anything with a sequence of steps | Claude | ChatGPT | claude→chatgpt | Claude writes the plan. ChatGPT red-teams it: what breaks, what is missing, what is ordered wrong. |
| Math, logic, puzzles, anything with one right answer | both | both | showdown | Two blind answers that agree are worth more than one confident one. Disagreement means check the work. |
| Facts that could be stale: prices, versions, dates, "is this still true" | ChatGPT | Claude | chatgpt→claude | Send it with web search on (`--web`). Claude integrates and cites. |
| Something is finished and about to ship, post, or send | Claude | ChatGPT | second-opinion | Author never grades its own work. ChatGPT gets the criteria and the artifact, not the reasoning. |
| Claude hedged, refused, or went in circles | ChatGPT | Claude | chatgpt→claude | A different model is a different set of reflexes. Bring the answer back and let Claude integrate it. Not a tool for getting around safety rules; if both refuse, the answer is no. |
| Mid-task and the other AI has the better tools or the fresher context | both | none | handoff | Package goal, decisions, state, and the ask. Neither AI remembers the other's session. |
| Anything else | Claude | ChatGPT | claude→chatgpt | Default: draft here, check there, merge here. |

## Brain-state dial (optional)

If you run the four-state Brain-State System (Feral, Froggy, Foggy, Fried),
tell `/route` which brain showed up and it turns the dial:

| Brain state | What changes |
|---|---|
| **Feral** | Full two-timing. Claude leads the build, ChatGPT red-teams every plan and every finished thing. |
| **Froggy** | Breadth mode. ChatGPT leads on options and angles, Claude catches the one worth building. Cap rounds at one so the leaping stays productive. |
| **Foggy** | Decide nothing yourself. `/route` picks, you follow. One pattern, one pass, no showdowns. |
| **Fried** | One question, one answer. No duet. `/second-opinion` only when money or reputation rides on the result. |

## Adding rows

Copy a row, change the five cells, place it above the row it should beat.
Keep "Task looks like" in plain words that a tired person would type. `/route`
matches on meaning, not on exact text, so phrasing it as examples works best.
