# Feedback Loop

A system for turning mid-session corrections into persistent behavioral changes across future sessions. Most Claude setups are static — you write instructions, Claude follows them. This system learns from mistakes.

## The Problem

You correct Claude's behavior in conversation ("don't mock the database," "check the reference docs first"). Claude adjusts — for that session. Next session, same mistake. The correction was ephemeral.

## The System

### /retro — Capture feedback in the moment

When you notice Claude did something it shouldn't have, run `/retro`:

```
/retro should have checked docs/claude/reference/ before web searching
```

The `/retro` skill:
1. Reviews the conversation to understand what went wrong
2. Identifies the root cause (specific, not vague)
3. Saves a **feedback memory** — a markdown file with the rule, why it matters, and when it applies
4. Indexes it so future sessions find it automatically

### Memory structure

Each feedback memory is a markdown file with frontmatter:

```markdown
---
name: Check reference docs first
description: Always check docs/claude/reference/ before web searching for project-specific data
type: feedback
---

Check docs/claude/reference/ before web searching for project-specific data (quest IDs, game data, API details, etc.)

**Why:** Wasted time web searching for data that was already saved locally from a previous research session.

**How to apply:** When looking up project-specific information, search docs/claude/reference/ first. Only web search if the reference docs don't have it or might be outdated.
```

### MEMORY.md — The index

A lightweight index file that lists all memories with one-line descriptions. Claude reads this at the start of every session to know what memories exist. Each line points to a memory file:

```markdown
# Memory Index

## Feedback
- [feedback_check_reference_docs.md](feedback_check_reference_docs.md) — Check reference docs before web searching
- [feedback_no_mocks.md](feedback_no_mocks.md) — Integration tests must hit real database, not mocks
```

### Memory types

Not all memories are feedback. The system supports four types:

| Type | What it stores | When to save |
|------|---------------|--------------|
| **feedback** | Corrections and confirmed approaches | When Claude does something wrong, or when a non-obvious approach is validated |
| **user** | Who you are, your preferences, your expertise | When you share context about yourself |
| **project** | Ongoing work, goals, deadlines | When you learn about project state that isn't in the code |
| **reference** | Pointers to external resources | When you discover where information lives |

### What NOT to save

- Code patterns or architecture (derivable from the code)
- Git history (use `git log`)
- Debugging solutions (the fix is in the code)
- Anything already in CLAUDE.md
- Ephemeral task details

## How to Adopt

1. **Create the memory directory.** Claude Code stores memories in `~/.claude/projects/{project-hash}/memory/`. Create a `MEMORY.md` index file there.

2. **Copy the `/retro` skill** from this repo's `skills/retro/` to your `~/.claude/skills/retro/`.

3. **Use it when you notice a mistake.** The habit is the hard part — the system is simple. When Claude does something you've told it not to do, or when you notice a pattern that should be different, run `/retro`.

4. **Review periodically.** Memory files can go stale. If a rule no longer applies, update or remove it.

## Why It Works

- **Corrections persist.** A feedback memory written today changes behavior in every future session.
- **Root causes, not symptoms.** `/retro` forces you to identify *why* Claude did the wrong thing, not just *what* it did wrong.
- **It captures success too.** When a non-obvious approach works ("yes, the single bundled PR was the right call"), saving that prevents future Claude sessions from being overly cautious about it.
- **Lightweight.** It's just markdown files. No database, no service, no dependencies. You can read, edit, and delete them with any text editor.
