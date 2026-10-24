---
name: showdown
description: >-
  Run the same prompt through stock Claude and stock ChatGPT side by side under
  identical isolated conditions, grade the two answers blind, and declare a
  winner with scores. Use when the user says "showdown", "compare Claude and
  ChatGPT on this", "which AI does this better", "run this through both" and
  wants to SEE both answers, or wants comparison material for a class, post, or
  video. For one merged answer use duet instead.
argument-hint: "<the prompt> [--web] [--claude-model ID] [--codex-model ID]"
---

# Showdown

A fair fight: same prompt, one shot each, both models stripped of the user's
config, graders who cannot tell which answer is whose.

## If a fuller showdown skill is installed, defer to it

Check for `~/.claude/skills/ai-showdown/SKILL.md`. If it exists, load it and
follow it instead of the steps below: it carries the same protocol plus a
content virality audit and a run log, and the plugin would only duplicate it.
Say in one line that the local skill took over. Otherwise continue.

## 1. Run both sides

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/showdown.sh" [--web] [-c CLAUDE_MODEL] [-g CODEX_MODEL] -f prompt.md
```

The script runs both in parallel, isolated from user config, pins and records
both models and CLI versions, and writes `showdown-<stamp>.md` with the two
answers as **A** and **B** in random order, plus a `.key` file with the
mapping. Do not open the key yet.

If the prompt asks either side to research anything, pass `--web` so both get
web access; one side with search and one without is rigged. If a side errors
(the script records the error as that side's answer), report it as the result.
Do not rerun for a better answer; one fix of a broken invocation is allowed,
one "try again" is not.

## 2. Grade blind, never here

The session that ran the race does not score it. Spawn **two** independent
graders. Preferred: one `ask_chatgpt.sh` run (different vendor) and one
Claude subagent with a different model than the session; acceptable fallback:
two fresh-context subagents. Each grader gets exactly three things: the prompt,
Answer A, Answer B. Not the key, not the session's opinion.

Rubric, scored per criterion 0 to 5, not one blended number:

- Correctness
- Completeness
- Prompt compliance
- Style fit (for the audience the prompt implies)

Ask each grader for a table and a one-line winner. If graders split, run a
third or report a split decision. Never average two verdicts into a fake
consensus.

## 3. Reveal and write up

Only after all scores are in, read the `.key` file and map A/B back to
Claude/ChatGPT. Append to the showdown file:

```
## Grader scores
| Criterion | A | B | Grader 1 | Grader 2 |
...
## Verdict
<3 to 6 sentences: who won, why, where each shined. Name the grader tier.>
A = <claude|chatgpt>, B = <claude|chatgpt>
```

Answer in chat with the verdict, the grader tier, and the file path. Do not
paste both full answers into chat if they are long; the file has them.

## Headless Claude must be logged in

`/showdown` is the one command that needs `claude -p` to work, because the
Claude contender has to be a stock model outside this session. If the script
reports the Claude side as "Not logged in", that is the result for that side;
tell the user to run `claude login` in a terminal and rerun. Never substitute
this session's own answer as the Claude contender: it is pre-coached by the
user's config and is not a like-for-like contender.
