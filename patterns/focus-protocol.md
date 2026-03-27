# Focus Protocol

A system for maintaining focus during Claude Code sessions. Useful if you tend to context-drift — getting excited about new ideas mid-task and losing the thread of what you were doing.

Inspired by the "Focus Harness" concept. The key insight: ideas feel safe when they're captured somewhere, so your brain can let go and return to the current task. The anxiety isn't about losing focus — it's about losing the idea.

## Components

### 1. FOCUS.md

A file in the project root with exactly three fields and a progress counter:

```markdown
# Focus

**YOU ARE DOING:** Implement user authentication with JWT tokens

**NEXT ACTION:** Write the token validation middleware

**DONE WHEN:** Login, logout, and token refresh all pass integration tests

**Progress:** 2/5
```

- One task at a time. If it doesn't fit in one line, it's too big — break it down.
- The progress counter is motivating. Increment it when a task completes.
- `/start` reads this file at the beginning of every session.
- `/gg` updates it at the end.

### 2. Stash

Two markdown files for capturing ideas without exploring them:

- **Project stash** (`docs/claude/stash.md`) — ideas related to the current project
- **Global stash** (`~/claude-output/stash.md`) — cross-project thoughts, random tangents, non-project ideas

Items in the stash are not prioritized, not explored, just safe. They can be freely deleted when promoted to the roadmap or discarded.

### 3. The Redirect Protocol

Add this to your global CLAUDE.md:

> When I bring up an idea or tangent that isn't the current task, don't explore it. Instead:
> 1. Add it to the appropriate stash with a timestamp
> 2. Tell me you stashed it
> 3. Redirect to the current focus
>
> Only change focus if I explicitly ask to. "That's interesting" is not a focus change. "Let's do that instead" is.

The right response from Claude sounds like: *"Good idea — stashed it. Back to [current task]: we were [doing X]. Next step is [Y]."*

### 4. The Hook

A `UserPromptSubmit` hook that fires on every message. It reads FOCUS.md and injects the current task into Claude's context, so Claude always knows what you're supposed to be working on.

See `hooks/focus-check.sh` and `hooks/settings-example.json` for the implementation.

The hook also:
- Counts stash items so you know how many ideas are waiting
- Nudges you to create a FOCUS.md if you have a roadmap but no focus file

## How to Adopt

**Minimal version (no hooks):** Just create FOCUS.md manually and add the redirect protocol to your global CLAUDE.md. Use `/start` and `/gg` to manage it.

**Full version:** Install the hook (copy `focus-check.sh` to `~/.claude/hooks/` and add the UserPromptSubmit entry from `settings-example.json`). The hook makes the protocol automatic — Claude is reminded of your focus on every message without you having to think about it.

## Why It Works

- **Ideas are safe.** The stash means nothing gets lost, so your brain stops holding onto tangents.
- **Focus is visible.** FOCUS.md makes the current task explicit, not implicit. When you drift, Claude can point to it.
- **The redirect is gentle.** Claude doesn't scold — it acknowledges the idea, saves it, and redirects. The protocol respects that the tangent might be genuinely good; it just isn't right now.
- **Progress is tracked.** The counter in FOCUS.md gives a visible sense of momentum.
