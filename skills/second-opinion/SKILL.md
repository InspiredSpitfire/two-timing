---
name: second-opinion
description: >-
  Send a finished Claude answer to ChatGPT for an adversarial, independent
  review and return PASS or NEEDS REVISION with specifics per criterion.
  ChatGPT gets the acceptance criteria and the artifact, never Claude's
  reasoning. Use when the user says "second opinion", "have ChatGPT check this",
  "is this actually right", "review this before I ship/post/send it", "grade
  this", "poke holes in this", or before calling substantive work done. For
  improving a draft collaboratively use duet; for comparing two fresh answers
  use showdown.
argument-hint: "[what to review: last answer | a file path | pasted text] [--criteria \"...\"] [--fix]"
---

# Second opinion

The author never grades its own work. This skill hands the finished thing to a
different vendor's model in a fresh context, with the criteria and nothing
else, and brings back a verdict that can be acted on.

Read `${CLAUDE_PLUGIN_ROOT}/references/calling-chatgpt.md` once per session
before the first ChatGPT call.

## 1. Fix the artifact and the criteria

- **Artifact**: the last Claude answer by default; otherwise the file, diff,
  or text named. Put the full text in the prompt file. If it is a file on this
  machine, also give the path (Codex can read the working directory).
- **Criteria**: take `--criteria` if given. Otherwise write three to six
  checkable statements from the original request ("every command listed
  exists", "no sentence over 25 words", "the total matches the invoice") and
  show them to the user in the output. Work with no definition of done cannot
  be reviewed, only admired.
- **How to exercise it**: the command to run, the input that should produce
  the output, the page to open. Include it when it exists.

## 2. Send it, cold

Write a prompt file containing exactly this, then send it with
`ask_chatgpt.sh -f prompt.md -t thread.txt` (or the `codex` MCP tool):

```
You are an independent reviewer. Your job is to falsify, not confirm.
Try to break this. Report what you actually observe, not what you expect.

ACCEPTANCE CRITERIA
1. ...
2. ...

ARTIFACT
<full text, or path plus text>

HOW TO EXERCISE IT (if runnable)
<command / input / expected output>

Return exactly this and nothing else:
Verdict: PASS | NEEDS REVISION
Criteria:
  1. <criterion> — PASS | FAIL | NOT CHECKED — <what you observed>
  ...
Defects:
  - <specific defect, with the input, line, or state that triggers it>
Not checked:
  - <what you could not exercise, and why>
```

Withhold: why Claude thinks it is right, what was already tested, what was
hard. All of that anchors the reviewer.

## 3. Report

Return ChatGPT's verdict block verbatim, then two lines from Claude:

```
Reviewer: ChatGPT (different vendor, fresh context). Thread: <id>
Claude's read: <agree | disagree on points N, M, because ...>
```

Disagreeing is allowed; arguing the verdict away is not. If a criterion was
wrong, say the criterion was wrong and rerun with the corrected one.

## 4. On NEEDS REVISION

- With `--fix`, or when the user says fix it: apply the defects, then send the
  revised artifact to a **fresh** thread (no `-r`): a reviewer that has seen
  its own verdict is invested in it.
- Cap at three review-fix rounds. A fourth means the task is misunderstood;
  stop and say so.

## When ChatGPT is unreachable

Report `Verdict: UNREVIEWED` with the reason, and do not substitute a Claude
self-review under the second-opinion label. A Claude subagent review is a
weaker tier; if you run one, name it as "same vendor, fresh context".
