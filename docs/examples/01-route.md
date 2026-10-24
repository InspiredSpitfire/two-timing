# /route

No AI call is made; the skill reads the active routing table and matches the task on meaning, first row wins.

## 1. Shipped default table

`/route fix the failing test in tests/test_slug.py`

```
Route: fix the failing test in tests/test_slug.py
Table: ~/.claude/plugins/cache/two-timing/two-timing/0.1.0/references/routing-table.md
Row: "Code in this repo: write, fix, refactor, tests"
Lead: Claude · Check: ChatGPT · Pattern: claude→chatgpt
Why: Claude has the files and the tools. ChatGPT reviews the diff with fresh eyes.
Next: /duet --lead claude fix the failing test in tests/test_slug.py
```

`/route 20 title options for a workshop on terminal basics`

```
Route: 20 workshop title options, terminal basics
Table: ~/.claude/plugins/cache/two-timing/two-timing/0.1.0/references/routing-table.md
Row: "Give me 20 options", names, angles, hooks, titles
Lead: ChatGPT · Check: Claude · Pattern: chatgpt→claude
Why: Breadth first, then Claude picks and sharpens three.
Next: /duet --lead chatgpt 20 title options for a workshop on terminal basics
```

## 2. A project table overrides the default

```
$ bash scripts/routing_table.sh --init .
./.two-timing/routing-table.md
```

The user adds one row at the top of the table:

```
| Newsletter or email for subscribers | Claude | none | claude-only | House rule: voice work stays in Claude, no second pass. |
```

`/route write this week's newsletter from these notes`

```
Route: write this week's newsletter from notes
Table: ./.two-timing/routing-table.md
Row: "Newsletter or email for subscribers"
Lead: Claude · Check: none · Pattern: claude-only
Why: House rule: voice work stays in Claude, no second pass.
Next: just do it here
```

Running `--init .` a second time refuses rather than overwrite:

```
two-timing: ./.two-timing/routing-table.md already exists; edit it directly
```

## 3. Brain-state dial

`/route --brain fried plan the migration of the blog to the new host`

```
Route: plan the blog migration to the new host
Table: ~/.claude/plugins/cache/two-timing/two-timing/0.1.0/references/routing-table.md
Row: "Plans, architecture, anything with a sequence of steps"  (dial: Fried)
Lead: Claude · Check: none · Pattern: claude-only
Why: Fried turns the plan's duet into one pass. Money or reputation on the line? Then /second-opinion, otherwise close the laptop.
Next: just do it here
```

The dial only ever downgrades a pattern; it never adds a second AI.

## 4. Captured from a fresh headless session

Typed into a brand-new `claude -p` session (Claude Code 2.1.310, Sonnet) with the plugin installed user-scope, no other context:

`/route 20 title options for a workshop on terminal basics`

```
Route: 20 title options for a terminal basics workshop
Table: ~/dev/two-timing/references/routing-table.md (shipped default)
Row: "Give me 20 options", names, angles, hooks, titles
Lead: ChatGPT · Check: Claude · Pattern: chatgpt→claude
Why: Breadth first, then Claude picks and sharpens three.
Next: /duet --lead chatgpt "20 title options for a workshop on terminal basics"
```

It also named the runner-up row ("Nuanced writing, matching a voice"), noted that no project, user, or env-var copy existed, and stopped at the card because no `--run` was given. That is the slash command triggering and the skill being followed, unprompted.
