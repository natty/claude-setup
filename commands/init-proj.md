# Initialize Project for Claude

Set up the `docs/claude/` directory structure for this project and wire up CLAUDE.md.

## Step 1: Create Directory Structure

Create `docs/claude/`, `docs/claude/plans/`, and `docs/claude/reference/` if they don't exist.

## Step 2: Create Doc Files

Create the following files with minimal starter content:

**docs/claude/roadmap.md**

Header: `# Roadmap`

Sections: `## Completed`, `## In Progress`, `## Next Up`, `## Backlog`

Each section starts empty with a placeholder comment.

---

**docs/claude/decisions.md**

Header: `# Decisions`

Brief note at top: "Log of architectural and design decisions. Includes rejected approaches and why. Do not revisit settled decisions without the human explicitly reopening them."

Include a template for entries with these fields: Date, Decision Title, Context (why this came up), Decision (what we decided), Alternatives considered (what we rejected and why).

---

**docs/claude/gotchas.md**

Header: `# Gotchas`

Brief note at top: "External quirks, counterintuitive behaviors, and environmental traps — things that can't be fixed by a code change in this repo. Check here before attempting unfamiliar approaches."

Include a template for entries with these fields: Date, Short description, What happened (what we tried and what went wrong), Why (root cause if known), Workaround (how we solved or avoided it).

---

**docs/claude/changelog.md**

Header: `# Changelog`

Brief note at top: "Recent changes to docs in this directory. Archive to archive.md when this gets long."

---

**docs/claude/archive.md**

Header: `# Archive`

Brief note at top: "Archived entries from other docs/claude/ files. See changelog.md for recent changes."

---

**docs/claude/session-handoff.md**

Header: `# Session Handoff Notes`

Brief note at top: "Created by the frustration protocol or manual session pauses. Most recent entry first."

## Step 3: Hide Claude Files From Git

Ensure `.git/info/exclude` exists, then append the following lines if not already present:

```
CLAUDE.md
.claude/
docs/claude/
```

Verify by reading the file back.

Claude files are hidden by default. Use `/cloak` to toggle visibility if needed.

## Step 4: Set Up CLAUDE.md

Check if a project-level CLAUDE.md exists at the project root.

If it exists, add the following section if not already present. Place it after any existing "About" or project description section, before any code style or rules sections.

If it doesn't exist, create one with this as the starting content:

The CLAUDE.md should include:

**A `## Current Focus` section** at the top with a placeholder comment for 2-3 lines describing what's done, what's in progress, and what's next.

**A `## Project Docs` section** that lists all docs/claude/ files with brief descriptions:
- Roadmap — current plan, milestones, what's next
- Decisions — settled questions, do not relitigate
- Gotchas — known traps, quirks, things that don't work as expected
- Plans — active implementation plans (temporary, archived when done)
- Reference — research findings, API details, technical notes
- Changelog — recent doc changes
- Session Handoff — notes from paused sessions

**A `### Doc maintenance rules` subsection** with these rules:
- After completing any milestone, update the roadmap and Current Focus above.
- After making any decision or rejecting an approach, log it in decisions.md.
- After hitting an external quirk or unexpected behavior, add it to gotchas.md.
- After researching any topic, save findings in reference/.
- When a plan is completed, extract lasting decisions into decisions.md, archive the plan to archive.md, then delete the plan file.
- When updating any doc in docs/claude/, add an entry to changelog.md.

## Step 5: Confirm

Report what was created. Remind the human:
- Fill in the roadmap and Current Focus
- Claude files are hidden from git by default — run `/cloak` to make them visible
