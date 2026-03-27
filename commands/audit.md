$ARGUMENTS

# Audit — Structural Code Analysis

Deeper than `/tidy`. Spins up parallel agents to analyze reuse, quality, and efficiency
across all modified files, then consolidates into a single set of changes.

Run `git diff --name-only` to identify modified files. If $ARGUMENTS is provided, scope to
those files or directories only.

## Principles

### Readability
- Code should be easy to understand without explanation
- Consistent naming and style (follow existing project conventions)
- Comments explain *why*, not *what* — remove redundant comments that restate the code
- No magic numbers or strings — use named constants

### Maintainability
- Functions are concise and do one thing
- Components are separated by purpose (modular design)
- Easy to test and extend without touching unrelated code
- Don't repeat yourself — extract shared patterns into helpers

### Simplicity
- Avoid unnecessary complexity
- Flatten unnecessary nesting (early returns, guard clauses)
- If a simpler approach achieves the same result, use it
- No premature abstractions — three similar lines beats a helper used once

### Reliability
- Proper error handling at system boundaries
- No swallowed errors — log everything, even if the user doesn't see it
- Catch specific error types, not broad catch-all blocks

## Step 1: Audit (3 parallel agents, read-only)

Use the Agent tool to launch three agents in parallel in a single message.
Each agent reads all modified files plus surrounding context. **No changes — findings only.**
Each agent returns a list of findings with file paths, line numbers, and what it found.

**Agent 1 — Reuse:**
- Duplicated patterns across files that should be shared helpers
- Functions that do nearly the same thing and could be consolidated
- Constants or config repeated in multiple places
- Copy-pasted blocks (2+ copies = flag for extraction)

**Agent 2 — Quality:**
- Dead code, unused imports, unused variables
- Functions doing too many things (single responsibility violations)
- Poor separation of concerns
- Inconsistent naming or style
- Redundant comments
- Unnecessary nesting
- Code that would be hard to test or extend

**Agent 3 — Efficiency:**
- Inefficient approaches where a simpler/faster one exists
- Unnecessary allocations, redundant computations
- Work being done that could be avoided
- Hot paths that could be leaner
- Magic numbers or strings that should be constants

## Step 2: Consolidate

Review all three agent reports together. Resolve conflicts:
- If one agent wants to extract a helper and another flagged the same code as dead, determine which is correct
- If two agents suggest different changes to the same code, pick the better one
- Remove duplicate findings across agents
- Produce a single unified change plan

**Present the consolidated plan to the user and wait for approval before proceeding.**

## Step 3: Apply once

Execute the approved plan in one pass. No cascading re-runs.

## Rules

- **Preserve all functionality.** Zero behavior changes.
- **Do not refactor architecture.** Cleanup and consolidation, not redesign.
- **Do not add features, tests, or dependencies.**
- **If unsure whether something qualifies, skip it.** Conservative > aggressive.
- **Follow existing project conventions** — don't impose new patterns.
- **Run lint and tests after changes** (if configured). Report failures, do not suppress.

## Output

After changes, give a brief summary:
- What each agent found
- How findings were consolidated (any conflicts resolved)
- What was changed and why
- Any issues skipped and why
