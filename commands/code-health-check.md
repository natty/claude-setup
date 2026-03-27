$ARGUMENTS

# Code Health Check — Full Codebase Structural Analysis

Full codebase sweep against DRY, KISS, and SOLID principles. Unlike `/audit`
(which scopes to modified files), this reads every source file and evaluates
the codebase as a whole.

Run this before starting a new milestone, after completing a large feature,
or when the codebase feels like it needs a health check.

## Step 0: Context

Read the project's CLAUDE.md (all levels), then read:
- `docs/claude/decisions.md` — settled decisions (do not flag these as issues)
- `docs/claude/gotchas.md` — known quirks (do not flag documented workarounds)
- `docs/claude/plans/` — existing extraction plans (confirm or challenge)

Build a "do NOT flag" list from these docs. Intentional patterns documented
in decisions or gotchas are not findings.

## Step 1: Identify all source files

Find all source files in the project. If $ARGUMENTS is provided, scope to
those files or directories only.

## Step 2: Audit (3 parallel agents, read-only)

Launch three agents in parallel. Each reads ALL source files plus the
context docs. **No changes — findings only.**

Each agent returns findings with: category, file:line, brief code excerpt,
severity (HIGH/MEDIUM/LOW), and a one-sentence fix.

**Agent 1 — DRY:**
- Duplicated iteration patterns (same data walked the same way in multiple places)
- Repeated UI/component creation patterns (count exact instances)
- Copy-pasted logic blocks (3+ lines appearing nearly identically in 2+ places)
- Magic numbers/strings appearing in multiple places
- Repeated guard/nil-check patterns

**Agent 2 — KISS:**
- Dead code (unused functions, variables, unreachable branches, commented-out code)
- Unnecessary complexity (could be expressed more simply)
- Unused features (settings/config that nothing reads)
- Unnecessary indirection (wrappers that just call through)
- Code that does nothing (no-op functions still being called, redundant operations)

**Agent 3 — SOLID + Quality:**
- Single responsibility violations (files/functions doing too many things)
- Open/closed violations (adding a feature requires modifying N existing files)
- Coupling (files reaching into each other's internals, shared mutable state)
- Naming inconsistencies across the codebase
- Fragile patterns (implicit assumptions that could break silently)
- Inconsistent error handling

Each agent MUST be told what NOT to flag (from Step 0). Include the
specific patterns from decisions.md and gotchas.md that are intentional.

## Step 3: Consolidate

Review all three agent reports. For each finding:
- Deduplicate across agents (same issue found by multiple agents = one finding)
- Cross-reference against existing architecture plans (confirm or challenge)
- Assign final severity:
  - **HIGH:** Blocks new features, causes bugs, or has 3+ copies of significant logic
  - **MEDIUM:** Real maintenance burden, visible bugs, or performance issues
  - **LOW:** Stylistic, minor, or fix-when-touching-the-file

Present a unified table grouped by severity. For each finding: number, description,
which agents found it, files involved, suggested fix.

End with a recommended action order that respects dependencies.

**Present findings to the user. Do NOT make any changes.**

## Step 4: Plan (if user approves)

If the user wants to proceed with fixes, create a plan. Group changes to
minimize file touches — apply all changes to a given file in one pass.

## Rules

- **This is a read-only analysis by default.** Do not edit files unless
  the user explicitly asks to proceed with fixes.
- **Do not relitigate settled decisions.** If decisions.md says "X is
  intentional," it is not a finding.
- **Confirm existing plans, don't duplicate them.** If an existing plan
  already identified an extraction, say "confirmed" — don't present it
  as a new discovery.
- **Severity must be justified.** HIGH means "fix before building more."
  Don't inflate.
- **Count instances.** "This pattern is repeated" is weak. "This pattern
  appears 7 times across 3 files (auth.ts:55,67,77, users.ts:104,188)"
  is useful.
