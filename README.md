# claude-setup

A framework for building your own Claude Code setup — skills, commands, hooks, and patterns that make Claude a better collaborator.

You can use these files directly (copy what you want into `~/.claude/`) or use them as examples to build your own.

## New to Claude Code?

Claude Code is Anthropic's CLI agent. It reads your codebase, runs commands, edits files, and uses tools — all guided by instructions you give it. The key customization points:

- **CLAUDE.md** — a markdown file at your project root (or `~/.claude/CLAUDE.md` for global). Claude reads it every turn. Think of it as persistent instructions.
- **Skills** — slash commands (`/eng-bot`, `/review`) that load additional instructions when invoked. They live in `~/.claude/skills/`.
- **Commands** — simpler slash commands for workflows. They live in `~/.claude/commands/`.
- **Hooks** — shell scripts that fire on Claude Code events (before a tool runs, when you send a message). They enforce rules automatically.
- **Memory** — markdown files Claude reads at session start. Used for persistent preferences and feedback across conversations.

If you haven't used any of these yet, start with the `examples/` folder — the annotated CLAUDE.md files show you how the pieces fit together.

## Quick Start

1. **Copy what you need** into your `~/.claude/` directory:
   - Skills → `~/.claude/skills/[name]/SKILL.md`
   - Commands → `~/.claude/commands/[name].md`
   - Hooks → `~/.claude/hooks/` (then configure in `~/.claude/settings.json`)

2. **Read the patterns** if you want to understand the thinking behind it and build your own.

3. **Run `/init-proj`** in a project to scaffold the documentation system.

## What's Here

### `skills/`

Drop-in skills you invoke with `/skill-name`. Copy the folder to `~/.claude/skills/`.

| Skill | What it does |
|-------|-------------|
| **eng-bot** | Staff engineer persona — investigates before acting, plans before building, stays in scope |
| **prompt-bot** | Crafts polished Claude system prompts from rough descriptions |
| **maestro** | Orchestrates parallel work across git worktrees with file ownership and merge planning |
| **docs-bot** | Maintains project documentation optimized for Claude consumption |
| **opie** | Claude power-user coach — teaches prompting techniques and workflow strategies |
| **grill-me** | Stress-tests a plan through relentless one-at-a-time questioning |
| **retro** | Quick retrospective — captures a mistake as a persistent feedback memory |
| **brb** | Mid-session checkpoint — saves all accumulated context without wrapping up |

### `commands/`

Workflow commands. Copy to `~/.claude/commands/`.

| Command | What it does |
|---------|-------------|
| **start** | Session orientation — reads project state, sets focus, asks task type |
| **gg** | Session wrap-up — updates focus, saves context, runs lint/tests, git status |
| **review** | Reviews uncommitted changes for bugs, patterns, security, performance |
| **tidy** | Surface cleanup — dead code, unused imports, inconsistent style |
| **audit** | Deeper analysis — parallel agents check reuse, quality, efficiency |
| **code-health-check** | Full codebase sweep against DRY, KISS, SOLID principles |
| **init-proj** | Scaffolds the docs/claude/ directory structure for a project |
| **cloak** | Toggles Claude file visibility in git |

### `hooks/`

Shell scripts that fire on Claude Code events. Copy to `~/.claude/hooks/` and add entries to your `settings.json` (see `settings-example.json`).

| Hook | What it does |
|------|-------------|
| **focus-check.sh** | Reminds Claude of current focus on every message (part of the Focus Protocol) |
| **check-large-removal.sh** | Blocks Write/Edit that removes 50+ lines — prevents accidental large deletions |
| **settings-example.json** | Example settings.json with hook config, permissions, and safety rules |

### `patterns/`

The "build your own" guides — explains the thinking behind each system so you can adapt it.

| Pattern | What it covers |
|---------|---------------|
| **focus-protocol.md** | FOCUS.md + stash + redirect protocol + hooks for maintaining focus |
| **intensity-calibration.md** | How instruction tone affects Claude 4.6 behavior — and how to fix overtriggering |
| **feedback-loop.md** | /retro → memory → behavioral change across sessions |
| **docs-system.md** | The docs/claude/ structure, archive policy, and maintenance workflow |
| **layered-hierarchy.md** | Global → workspace → project → skill, with deduplication |
| **building-skills.md** | How to create effective skills with the layered prompt structure |

### `examples/`

Annotated example CLAUDE.md files with comments explaining each section.

### `templates/`

Blank starter files — `FOCUS.md` and `stash.md`.

## Installation

There's no installer. Copy what you want:

```bash
# Copy a skill
cp -r skills/eng-bot ~/.claude/skills/

# Copy a command
cp commands/review.md ~/.claude/commands/

# Copy hooks
cp hooks/focus-check.sh ~/.claude/hooks/
cp hooks/check-large-removal.sh ~/.claude/hooks/
# Then add the hook entries from settings-example.json to your ~/.claude/settings.json
```

## Philosophy

This setup is built on a few core ideas:

1. **Claude is a collaborator, not a tool.** The instructions shape a working relationship, not a command interface.
2. **Static configs aren't enough.** The feedback loop (`/retro` → memory) means the system learns from mistakes.
3. **The human side matters.** The Focus Protocol addresses the human's tendency to drift — not just Claude's behavior.
4. **Tone affects behavior.** How you phrase instructions changes how Claude responds (see `patterns/intensity-calibration.md`).
5. **Documentation is context.** The `docs/claude/` system gives Claude persistent memory across sessions.

## License

MIT
