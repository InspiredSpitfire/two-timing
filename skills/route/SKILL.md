---
name: route
description: >-
  Decide which AI should take a task, or which step goes to which, using the
  plugin's editable routing table (project > user > shipped default). Returns a
  decision card: Lead, Check, Pattern, Why, and the exact next command. Use when
  the user asks "which AI should do this", "route this", "Claude or ChatGPT for
  this", "who should I ask", "what's the move", names a brain state (Feral,
  Froggy, Foggy, Fried) with a task, or runs /two-timing on a task. Also handles
  "edit the routing table" and "show me the routing table". Route only advises;
  to actually run the two-AI work use duet, second-opinion, showdown, or
  handoff, whichever the card names.
argument-hint: "<task, or: show | edit | init [.]> [--brain feral|froggy|foggy|fried] [--run]"
---

# Route

The routing table decides, not Claude's instinct. Claude's job here is to read
the table, match the task, and say the move in five lines.

## Table management

- `show`: print the active table and its path:
  `bash "${CLAUDE_PLUGIN_ROOT}/scripts/routing_table.sh" --cat`
- `edit`: print the active path; if it is the shipped default (inside the
  plugin), run `--init` first so the user edits a copy, then tell them the
  path. Never edit the shipped default in place.
- `init` or `init .`: `routing_table.sh --init` (user copy) or `--init .`
  (project copy).

## Routing a task

1. Load the active table (`routing_table.sh --cat`). The first line of output
   from `routing_table.sh` with no flags is the path; name it in the card so
   the user knows which copy decided.
2. Match the task against "Task looks like" rows **top to bottom on meaning**,
   first match wins. The catch-all is last. If two rows plausibly match, take
   the higher one and say which row was the runner-up.
3. If a brain state was given (`--brain` or in plain words), apply the
   brain-state dial section of the table. It can downgrade a pattern (Fried
   turns a duet into claude-only) but never upgrade one.
4. Produce the card:

```
Route: <task in 8 words>
Table: <path of the copy that decided>
Row: "<Task looks like text>"
Lead: <Claude|ChatGPT|both> · Check: <ChatGPT|Claude|none> · Pattern: <pattern>
Why: <the row's Why, one line>
Next: /<duet --lead ...|second-opinion|showdown|handoff|or "just do it here">
```

5. With `--run`, or when the user said "and do it", invoke the Next command
   immediately with the task. Otherwise stop at the card.

Multi-step tasks: when the task clearly has stages with different shapes
("research it, then write it, then check it"), give one card per stage, two
lines each, then the sequence of commands.

## Honesty rules

- If no row matches well, say so and use the catch-all; do not invent a row.
- The card names the table copy that decided, so an edited user table is
  visibly in force.
- Routing is advice about process, not about content. It never answers the
  task itself unless `--run` is set.
