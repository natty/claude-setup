$ARGUMENTS

# Tidy — Surface Cleanup

Run `git diff --name-only` to identify modified files. Scan ALL of them.
Do not stop after finding the first few issues. Complete the full scan before making any changes.

If $ARGUMENTS is provided, scope the cleanup to those files or directories only.

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

## What to look for

- Dead code, unused imports, unused variables
- Overly complex logic that can be simplified without changing behavior
- Inconsistent naming or style
- Redundant comments
- Copy-pasted blocks that should be extracted (2+ copies = extract)
- Unnecessary nesting
- Magic numbers or strings

Collect all findings, then apply changes in one pass.

## Rules

- **Preserve all functionality.** Zero behavior changes.
- **Do not refactor architecture.** Cosmetic cleanup, not redesign.
- **Do not add features, tests, or dependencies.**
- **If unsure whether something qualifies, skip it.** Conservative > aggressive.
- **Follow existing project conventions** — don't impose new patterns.
- **Run lint and tests after changes** (if configured). Report failures, do not suppress.

## Output

After changes, give a brief summary of what was tidied and why.
