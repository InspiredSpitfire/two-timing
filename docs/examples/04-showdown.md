# /showdown

`/showdown In two sentences, explain to a non-programmer what a shell alias is and give one example.`

Captured 2026-10-24 with both contenders authenticated. The script ran stock Claude and stock ChatGPT in parallel, isolated from user config, and labelled the answers A and B in random order. Grading happened before anyone opened the key.

## 1. The file the script wrote

````markdown
# Showdown 2026-10-24-152254

**Prompt:**

```
In two sentences, explain to a non-programmer what a shell alias is and give one example.
```

- Claude: claude-opus-5-5 (2.1.310 (Claude Code))
- ChatGPT: gpt-6.1-sol (codex-cli 0.163.0-alpha.11.1)
- Conditions: headless, user config isolated, one shot each, tools: none

## Answer A

A shell alias is a shortcut you type in a terminal to run a longer command. For example, `alias ll='ls -l'` lets you type `ll` to see a detailed list of files.

## Answer B

A shell alias is a nickname you create for a longer command you type in the terminal, so you can run it with a short word instead of retyping the whole thing each time. For example, `alias ll="ls -la"` lets you type just `ll` to see a detailed list of all the files in a folder.

## Key

Which answer was which is in `showdown-2026-10-24-152254.key`. Open it only after grading.
````

## 2. Blind grading

Three graders, each given only the prompt, Answer A, Answer B, and the rubric. Grader 1 and grader 3 were ChatGPT on fresh threads (different vendor from the session); grader 2 was a Claude Sonnet subagent (different model from the session). A third grader was added because the first two split.

| Criterion | Grader 1 (A / B) | Grader 2 (A / B) | Grader 3 (A / B) |
|---|---|---|---|
| Correctness | 5 / 5 | 5 / 5 | 5 / 5 |
| Completeness | 5 / 5 | 4 / 5 | 5 / 5 |
| Prompt compliance | 5 / 5 | 4 / 5 | 5 / 5 |
| Style fit | 5 / 5 | 4 / 5 | 5 / 5 |
| **Total** | **20 / 20** | **17 / 20** | **20 / 20** |
| Winner | tie | B | tie |

Grader 2's reason: B explains the "nickname" idea and the benefit (no retyping) in plain language and describes the example's result more clearly; A uses "terminal" and "shortcut" with less explanation.

## 3. Verdict

Tie by majority, with one grader preferring B. Both answers are correct, two sentences long, and give a valid `alias ll` example. The only daylight any grader found was B's extra plain-language explanation of *why* you would want an alias. Not a split decision: two of three graders saw no difference, and the dissent was consistent in direction, so it is reported as a tie with a lean to B.

Grader tier: different-vendor (two graders) and different-model (one grader). The session that ran the race did not score it.

## 4. Key, opened after grading

```
A=chatgpt
B=claude
```

So the lean, where there was one, was toward Claude.

## Earlier attempt (2026-10-23): the honest failure mode

The first run of the same command on 2026-10-23 produced this Claude side, because headless Claude was logged out on the machine:

```
[ERROR: claude side exited 77]
two-timing: Claude Code is logged out machine-wide. Run 'claude login' (or /login inside claude) in an interactive terminal, then retry.
Not logged in · Please run /login
```

The script recorded the error as that side's answer, grading was skipped, and no winner was declared. The session's own answer was not substituted: it is pre-coached by the user's config and is not a like-for-like contender.
