# Handoff packet

Neither AI remembers the other's session. A handoff is a single message that
lets the receiving AI start cold and still do the right thing. Fill every
section; "n/a" is an acceptable answer, a missing section is not.

```markdown
# Handoff: <five-word title>
From: <Claude Code | ChatGPT> · To: <ChatGPT | Claude Code> · <YYYY-MM-DD>

## Goal
One sentence: what finished looks like.

## Done so far
- bullets, past tense, only what is true

## Decisions already made (do not reopen)
- <decision> because <reason>

## Constraints
- rules, style, scope limits, things that must not change
- who the audience is, if it matters

## Current state
Paste the artifact or the relevant part of it. File paths are useful only if
the receiver runs on the same machine; otherwise paste content.

## The ask
Exactly what the receiving AI should do next. One task.

## Reply format
How to answer so the sender can take it straight back: e.g. "a numbered list
of defects with line references", "the full revised text, nothing else",
"three options, one paragraph each, then your pick".
```

## Return trip

The receiver answers in the requested format and, if the task continues,
appends its own packet using the same template with From/To swapped. The
sender then imports it: decisions move into "Decisions already made", new
facts into "Done so far", and the next ask gets written.
