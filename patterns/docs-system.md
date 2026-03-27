# Documentation System

A project-level documentation structure optimized for Claude consumption. These docs exist so that every new Claude session can orient quickly, understand the project's current state, and avoid repeating past mistakes.

## The Problem

Without persistent documentation:
- Claude re-discovers the same gotchas every session
- Settled decisions get relitigated
- Context from previous sessions is lost after compaction or new conversations
- The same research gets redone

## The Structure

All Claude working docs live in `docs/claude/`. This folder is for brainstorming, planning, tracking, and context — not shipped with the project.

### Core files (every project)

| File | Purpose | Key rule |
|------|---------|----------|
| `roadmap.md` | What's done, what's next, backlog | Single source of truth for project status |
| `decisions.md` | Why we chose X over Y, with alternatives | Prevents re-litigating settled questions |
| `gotchas.md` | External quirks, counterintuitive behaviors | "What happened / Fix / Rule" format |
| `changelog.md` | Session-by-session log of doc changes | Keep last ~10 sessions, archive the rest |
| `archive.md` | Removed/replaced content from other docs | Never delete — always archive first |
| `session-handoff.md` | Notes from paused sessions | Most recent entry first |

### Created as needed

| File | Purpose | Lifecycle |
|------|---------|-----------|
| `plans/[topic].md` | Active implementation plans | Extract decisions when done, archive, delete |
| `reference/[topic].md` | Research findings, API details | Persistent — update when info changes |
| `stash.md` | Project-specific ideas captured mid-session | Delete when promoted or discarded |

## CLAUDE.md Integration

CLAUDE.md is always loaded into context. It should contain:

1. **Current Focus** (2-3 lines at the top) — what's done, in progress, and next
2. **Project Docs section** — index pointing to docs/claude/ files
3. **Doc maintenance rules** — when to update which file

The full roadmap lives in `docs/claude/roadmap.md`. CLAUDE.md has the summary.

## Archive Policy

These docs may not be in git. Once deleted, content could be unrecoverable.

- **Don't delete lines.** Strikethrough done/cancelled items instead.
- When a file gets long, move struck-through items to `archive.md` with an H2 header noting the source file and date.
- `changelog.md` over ~10 sessions: archive older entries.
- `decisions.md`: only archive if a decision was fully reversed and no longer relevant.
- `plans/` files: when completed, extract decisions → `decisions.md`, archive plan → `archive.md`, delete file.
- Any file over ~300 lines: split or archive stale parts.
- If `archive.md` exceeds ~1,000 lines: split into `archive-YYYY.md` by year.

## Git Visibility

By default, `/init-proj` hides Claude files from git using `.git/info/exclude` (not `.gitignore`). This keeps Claude's working docs out of your repo history without affecting the project's gitignore.

Use `/cloak` to toggle visibility. Some projects benefit from tracking these files — especially if multiple people work with Claude on the same codebase.

## How to Adopt

1. **Run `/init-proj`** in your project. It scaffolds the full structure, creates starter files, and hides them from git.

2. **Fill in the roadmap** and **Current Focus** in CLAUDE.md. These are the most important files — they're what Claude reads first.

3. **Use `/start` at the beginning of sessions** and **`/gg` at the end.** These commands read and update the docs automatically.

4. **Use `/brb` for mid-session checkpoints.** It saves all accumulated context without wrapping up the session.

5. **Use `/docs-bot`** for periodic audits and maintenance. It identifies stale content, oversized files, and gaps.

## Design Principles

- **Context window is a budget.** Every line Claude reads is a line it can't use for reasoning. Keep active files under 300 lines.
- **Freshness over completeness.** A stale "Current Focus" actively misleads. Current state must reflect reality.
- **Teach, don't just record.** The best gotchas explain the pattern so Claude recognizes it in new situations.
- **Signal over noise.** A future Claude needs load-bearing decisions, not the full history of every conversation.
