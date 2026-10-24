# /showdown

`/showdown In two sentences, explain to a non-programmer what a shell alias is and give one example.`

The script ran both contenders in parallel, isolated from user config, and wrote the file below. On the capture machine headless Claude was logged out, so the Claude side is an error, recorded as that side's result. Nothing was rerun and this session's own answer was not substituted: it is pre-coached by the user's config and would not be a like-for-like contender.

Because one side had no answer, the blind-grading step was skipped and no winner was declared. After `claude login`, the same command produces two answers and the skill spawns two graders who see only the prompt, Answer A, and Answer B.

## The file the script wrote

````markdown
# Showdown 2026-10-23-191428

**Prompt:**

```
In two sentences, explain to a non-programmer what a shell alias is and give one example.
```

- Claude: claude-opus-5-5 (2.1.220 (Claude Code))
- ChatGPT: gpt-6.1-sol (codex-cli 0.163.0-alpha.11.1)
- Conditions: headless, user config isolated, one shot each, tools: none

## Answer A


[ERROR: claude side exited 77]
two-timing: Claude Code is logged out machine-wide. Run 'claude login' (or /login inside claude) in an interactive terminal, then retry.
Not logged in · Please run /login

## Answer B

A shell alias is a shortcut you create for a command you type in the terminal. For example, `alias ll='ls -la'` lets you type `ll` to list all files, including hidden ones, with details.

## Key

Which answer was which is in `showdown-2026-10-23-191428.key`. Open it only after grading.
````

## The key file (opened only after grading)

```
A=claude
B=chatgpt
```

Result for this capture: **no contest, Claude side unavailable (logged out).** UNVERIFIED on the capture machine until headless Claude is logged in.
