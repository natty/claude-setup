# Layered Hierarchy

How to organize CLAUDE.md files and skills so they work together without duplication or conflict.

## The Layers

Claude Code reads CLAUDE.md files at multiple levels, from general to specific:

```
~/.claude/CLAUDE.md          ← Global: your preferences, applies everywhere
~/dev/CLAUDE.md              ← Workspace: shared rules for a group of projects
~/dev/my-project/CLAUDE.md   ← Project: project-specific rules and current state
```

When a skill is invoked, its prompt is loaded alongside all CLAUDE.md files. So Claude sees:

```
Global CLAUDE.md + Workspace CLAUDE.md + Project CLAUDE.md + Skill prompt
```

## What Goes Where

| Layer | Content | Example |
|-------|---------|---------|
| **Global** | Your preferences, communication style, core principles | "Always ask before editing," "Correctness over helpfulness" |
| **Workspace** | Shared coding standards, git workflow, language conventions | "Conventional commits," "2-space indent," "No dependencies without approval" |
| **Project** | Architecture rules, current focus, project-specific constraints | "SwiftUI + SwiftData," "iOS 17+," "Privacy first" |
| **Skill** | Domain-specific behaviors and examples | Eng-bot's investigation workflow, maestro's file ownership rules |

### The Rule

**Don't repeat rules across layers.** If your global CLAUDE.md says "prefer targeted edits over full file rewrites," your skills don't need to say it again. Claude reads all layers every turn — repetition wastes tokens and stacks intensity (see `intensity-calibration.md`).

## Skills and the Hierarchy

The most common mistake: skills that restate global rules.

```
❌ Skill restates global rules (80+ redundant lines):

## Guardrails
- Don't delete and recreate files
- Prefer targeted edits over full file rewrites
- Stay in scope — don't touch files not mentioned
- Investigate before opining on problems
- Search before claiming something doesn't exist
- If you've failed twice, stop and say so
[... more rules identical to CLAUDE.md]

✅ Skill references the hierarchy:

## Guardrails
Follow the ground rules in the project's CLAUDE.md hierarchy.
Additionally:
- Ask before making major structural changes
- If you've failed to fix something twice, stop and say so
```

The second version:
- Saves ~80 tokens per skill invocation
- Avoids intensity stacking (seeing the same "Don't" rules 2-3x)
- Only adds rules that are specific to this skill's domain

## How to Build Your Own Hierarchy

1. **Start with global CLAUDE.md.** Put your universal preferences here — how you want Claude to communicate, what it should always ask about, your core principles. Keep it under ~150 lines.

2. **Add a workspace CLAUDE.md if you have shared conventions.** If all your projects under `~/dev/` follow the same coding standards and git workflow, put those here instead of repeating them per project.

3. **Each project gets its own CLAUDE.md.** Architecture rules, current focus, project docs index. Only include rules that are specific to this project or that override workspace defaults.

4. **Skills reference the hierarchy.** One line: "Follow the ground rules in the project's CLAUDE.md hierarchy." Then add only domain-specific rules and behaviors.

## Common Pitfalls

- **Putting project rules in global.** If a rule only applies to Swift projects, it belongs in the Swift project's CLAUDE.md, not in your global file.
- **Duplicating between workspace and project.** If the workspace says "conventional commits," the project CLAUDE.md doesn't need to repeat it.
- **Skills that are self-contained.** A skill that restates all its rules internally works fine in isolation — but when loaded alongside CLAUDE.md files, the duplication causes problems.
- **Over-stuffing global.** Remember: global CLAUDE.md is read on every turn of every project. Each line has a cost. Be selective.
