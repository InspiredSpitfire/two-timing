---
name: duet
description: >-
  One task, both AIs, as collaborators. Claude drafts and ChatGPT critiques or
  extends (or the reverse, picked by task type), then Claude reconciles into ONE
  merged answer with a one-line "who did what". Use when the user says "duet",
  "two-time this", "run it through both and merge", "have ChatGPT check this
  draft", "get ChatGPT's take and fold it in", "use both brains on this", or
  wants a better single answer rather than a comparison. For a side-by-side
  comparison use showdown; for a pass/fail check of finished work use
  second-opinion.
argument-hint: "[--lead claude|chatgpt] [--rounds N] <the task>"
---

# Duet

Two AIs working one problem, in turns, ending in one answer. Not a debate, not
a comparison. The reader gets the merged result and one line saying who did
what.

Read `${CLAUDE_PLUGIN_ROOT}/references/calling-chatgpt.md` once per session
before the first ChatGPT call.

## 1. Pick the order

Parse `--lead claude|chatgpt` and `--rounds N` (default 1) off the front of the
arguments; the rest is the task. With no `--lead`, consult the routing table
(`bash "${CLAUDE_PLUGIN_ROOT}/scripts/routing_table.sh" --cat`) and take the
Lead column of the first matching row. Defaults when nothing matches:

- **Claude leads** for code in this repo, long context, nuance, voice,
  structured editing, plans.
- **ChatGPT leads** for breadth (many options, names, angles), quick
  alternatives, a bug that has already survived two fixes, anything where fresh
  eyes beat context.

State the choice in one line before starting: "Claude drafts, ChatGPT
critiques" or "ChatGPT drafts, Claude builds on it".

## 2. Lead drafts

- If Claude leads: write the draft here, complete, as if it were the only pass.
- If ChatGPT leads: write a self-contained brief (goal, context, constraints,
  reply format; see `references/handoff-template.md` for the long form) to a
  temp file and send it with `ask_chatgpt.sh -f brief.md -t thread.txt`, or the
  `codex` MCP tool when the session has it. Keep the thread id.

## 3. Partner's turn

Send the partner the task, the draft, and a specific job. Never "thoughts?".
Choose the job from the task type:

- **Critique** (default for code, plans, facts, arguments): "Find what is
  wrong, missing, or risky. Number each point. Quote the exact line it refers
  to. Propose the fix. Do not rewrite the whole thing. If you find nothing
  material, say so in one line."
- **Extend** (default for options, angles, creative work): "Add what the draft
  lacks: new angles, counter-cases, the version the author would not think of.
  Keep each addition under 60 words and label it NEW."

When ChatGPT is the partner, send the full draft in the prompt file: it cannot
see this session. When Claude is the partner (ChatGPT led), do this step here,
in writing, with the same rigor you would want from a reviewer.

## 4. Reconcile (always Claude)

Go through the partner's points one by one. For each: **take**, **take with
changes**, or **reject**, with a reason of ten words or fewer. Then produce the
single merged artifact. Rules:

- One answer. Never two versions side by side, never "ChatGPT suggested X, but
  you could also...". Decide.
- Keep the lead's structure unless a taken point requires changing it.
- If `--rounds` is more than 1, send the merged version back to the partner
  with "what is still wrong?" and reconcile again, up to N rounds. Stop early
  when the partner reports nothing material.

## 5. Output

```
<the merged answer>

---
Who did what: <Lead> drafted. <Partner> raised N points; took K (<the gist>),
rejected M (<why>). Claude merged. [ChatGPT thread: <id>]
```

Keep the "who did what" to two lines. It is attribution, not a transcript.

## When the second AI is not there

If the ChatGPT call fails (logged out, binary missing, timeout), deliver the
Claude draft anyway, and label it: "Solo: ChatGPT unavailable (<reason>). Not a
duet." Point to `scripts/doctor.sh`. Never simulate ChatGPT's half.
