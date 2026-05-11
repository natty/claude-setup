---
name: skill-authoring
description: Authors Claude Code SKILL.md files following 2026 Anthropic best practices for Claude Opus 4.7. Use when creating or revising skills in ~/.claude/skills/ or .claude/skills/, writing skill frontmatter descriptions for reliable auto-loading, structuring skill body content with progressive disclosure, or deciding when a workflow should be a skill versus a subagent. Sibling skills: prompt-authoring (general system prompts), subagent-authoring (.claude/agents files).
claude-md-version: 2026-05-06
---

# Skill Authoring

Reference for writing Claude Code SKILL.md files. Current for Claude Opus 4.7 (released 2026-04-16).

For general system prompts, use `prompt-authoring`. For `.claude/agents/` subagent files, use `subagent-authoring`. This skill is specifically for `SKILL.md` files in `~/.claude/skills/` or `.claude/skills/`.

## What a skill is (and isn't)

A skill is a markdown file at `<skills-dir>/<skill-name>/SKILL.md` with YAML frontmatter and a body. Claude Code loads the frontmatter `description` from every skill at session start (~100 tokens per skill), and reads the body only when the skill is triggered. This is **progressive disclosure** — the description always pays a small cost; the body only pays when relevant.

A skill is NOT:
- A subagent (subagents run in their own context window — see `subagent-authoring`)
- A general system prompt (system prompts are sent via the API `system` field — see `prompt-authoring`)
- A CLAUDE.md file (CLAUDE.md is loaded every session unconditionally)
- A custom command — but note: custom commands (`.claude/commands/<name>.md`) and skills (`.claude/skills/<name>/SKILL.md`) are now functionally equivalent. Both create `/<name>`. Skills are the recommended path going forward.

Skills load on demand. CLAUDE.md loads always. This is the central design tension: **put broadly-applicable rules in CLAUDE.md, put specialized expertise in skills.**

## Frontmatter rules (hard constraints)

```yaml
---
name: my-skill
description: Brief description of what this skill does and when to use it
---
```

**`name` field:**
- Required
- Lowercase letters, numbers, and hyphens only
- Maximum 64 characters
- Cannot contain "anthropic" or "claude" (reserved)
- **Naming convention:** prefer gerund form (`processing-pdfs`, `analyzing-spreadsheets`) or noun phrases (`pdf-processing`). Avoid vague names (`helper`, `utils`, `tools`).

**`description` field:**
- Recommended (technically optional, but without it auto-loading is unreliable; falls back to first paragraph if omitted)
- Combined with `when_to_use` (see below), capped at **1,536 characters** in the skill listing
- **Front-load the trigger keywords.** The first ~250 characters are what Claude relies on most heavily when deciding whether to load. Sibling references and meta-info go after.
- Must be in **third person**. "Processes Excel files" not "I help you process Excel files" not "You can use this to process Excel files." Inconsistent point-of-view causes discovery problems because the description is injected into the system prompt.
- Should contain both **what the skill does** AND **when to use it.** The "Use when..." clause is the auto-load trigger. Without it, the skill rarely fires.

**`when_to_use` field (optional, separate from `description`):**
- Additional trigger phrases and example user requests that should fire the skill
- Appended to `description` in the listing (the 1,536-char cap covers both combined)
- Use when the trigger conditions don't fit cleanly inside `description` — for example, when you want to enumerate several phrasings of the same request without bloating the primary description

**Anthropic's canonical example:**
```yaml
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

Two clauses. What it does, when to use it. Both fit in 250 chars. This is the pattern.

**For high-precision auto-loading, use the explicit TRIGGER pattern:**
```yaml
description: <what it does>. TRIGGER when: <comma-separated trigger conditions>. DO NOT TRIGGER for: <anti-trigger conditions>.
```
The "DO NOT TRIGGER" half prevents over-firing when the skill is adjacent-but-not-relevant to a task.

## Optional Claude Code frontmatter fields

Claude Code skills support additional frontmatter beyond `name` and `description`:

| Field | Purpose |
|---|---|
| `disable-model-invocation: true` | User can `/invoke` it, Claude won't auto-load. For workflows with side effects (`/commit`, `/deploy`). |
| `user-invocable: false` | Inverse: Claude auto-loads, user never types `/skill-name`. For background expertise that isn't a meaningful command. |
| `allowed-tools` | Restrict which tools Claude can use when this skill is active. Space-separated or YAML list. |
| `paths` | Glob patterns that scope when the skill auto-loads. Example: `paths: src/**/*.swift`. |
| `model` | Override the model when this skill is active. |
| `effort` | Override effort level when this skill is active (`low`/`medium`/`high`/`xhigh`/`max`). |
| `context: fork` | Run the skill in a forked subagent context. |
| `agent` | Which subagent type to use when `context: fork` is set. |
| `argument-hint` | Autocomplete hint for arguments. Example: `[issue-number]`. |
| `hooks` | Lifecycle hooks scoped to this skill. |
| `claude-md-version` | Date-based version marker (`YYYY-MM-DD`) matching the current convention in `~/.claude/CLAUDE.md`. Read by the session-start staleness hook. Required for persona skills. |
| `shell` | Shell for `!`command`` blocks. `bash` (default) or `powershell`. |
| `when_to_use` | Additional trigger phrases / example requests appended to `description` in the listing. Combined cap with `description`: 1,536 chars. |
| `arguments` | Named positional arguments for `$name` substitution in the skill body. |

**Decision matrix for `disable-model-invocation` and `user-invocable`:**

| Frontmatter | User invokes | Claude auto-loads | When loaded into context |
|---|---|---|---|
| (default) | yes | yes | description always; body when invoked |
| `disable-model-invocation: true` | yes | no | description NOT in context; body loads when user invokes |
| `user-invocable: false` | no | yes | description always; body when Claude invokes |

**Use `user-invocable: false` for** background expertise that should activate when relevant but isn't a meaningful command. Example: a `legacy-system-context` skill that explains an old codebase. Claude should know it when relevant; users shouldn't have a `/legacy-system-context` button.

**Use `disable-model-invocation: true` for** workflows with side effects you want to control. Example: `/deploy`, `/commit`, `/send-message`. You don't want Claude deciding to deploy because the code looks ready.

**Effort levels (Opus 4.7):**
- `xhigh` — new tier between `high` and `max`. Claude Code default for coding and agentic work.
- `max` — prone to doom loops (Anthropic's own migration guide acknowledges this). Reserve for isolated hard subproblems.
- Use `xhigh` as the ceiling for persona skills that do analytically demanding work.

## Body structure

**Keep SKILL.md body under 500 lines.** This is a soft cap from Anthropic; over → split into reference files. The body-sizing rule has a second motivation beyond initial-load cost: during auto-compaction, Claude Code re-attaches the most recent invocation of each skill, first 5,000 tokens per skill, with a 25,000-token combined budget across all skills (filled starting from most-recently-invoked). A 200-line SKILL.md fits comfortably; a 1,000-line one gets truncated and loses the bottom half.

**Concise is key.** Default assumption: Claude is already very smart. Only add context Claude doesn't already have. Before each paragraph, ask: "does Claude really need this explanation?"

**Bad — too verbose:**
> PDF (Portable Document Format) files are a common file format that contains text, images, and other content. To extract text from a PDF, you'll need to use a library...

**Good — concise:**
> Use pdfplumber for text extraction:
> ```python
> import pdfplumber
> with pdfplumber.open("file.pdf") as pdf:
>     text = pdf.pages[0].extract_text()
> ```

The concise version assumes Claude knows what PDFs are and how libraries work.

**Claude Opus 4.7 specific:** scan the body for hedge language ("consider whether," "you might want to," "feel free to," "worth noting"). 4.7 interprets hedges as optional and skips them. Replace with directives. See `prompt-authoring` for the hedge → directive replacement table.

## Match specificity to fragility (degrees of freedom)

This is the framework `prompt-authoring` points at. It lives here because skills span a wider range of fragility than general prompts.

**Think of Claude as a robot exploring a path:**
- **Open field with no hazards** → many paths lead to success → **high freedom** → text-based instructions, general direction, trust the model
- **Narrow bridge with cliffs on both sides** → only one safe way forward → **low freedom** → specific scripts, exact commands, "do not modify the command or add additional flags"

**High freedom is right when:**
- Multiple approaches are valid
- Decisions depend on context
- Heuristics guide the approach
- Example: `## Code review process: 1. Analyze structure 2. Check for bugs 3. Suggest improvements`

**Low freedom is right when:**
- Operations are fragile and error-prone
- Consistency is critical
- A specific sequence must be followed
- Example: `## Database migration: Run exactly this script: \`python scripts/migrate.py --verify --backup\`. Do not modify the command or add flags.`

**The default mistake** is over-specifying open-ended work (produces robotic output, prevents Claude from using judgment) or under-specifying fragile work (produces plausible-but-wrong output that Claude thought was fine).

## Dynamic context injection

SKILL.md bodies support a preprocessing syntax that runs a shell command at load time and substitutes the output into the body before Claude sees it:

```markdown
Current branch state:
!`git status --short`

Recent commits:
!`git log --oneline -5`
```

The `` !`command` `` token is **not executed by Claude.** It's preprocessed — the command runs at skill-invocation time and its output replaces the placeholder in the rendered SKILL.md. Use this for skills that need fresh state at every invocation (git status, current file list, environment summary) without paying a tool-call round-trip.

Use the `shell` frontmatter field to select `bash` (default) or `powershell` for these blocks.

## Progressive disclosure (multi-file skills)

For skills that grow beyond ~500 lines or span multiple domains, split content into reference files:

```text
my-skill/
├── SKILL.md              (overview and navigation — always loaded body)
├── reference/
│   ├── finance.md        (loaded only when Claude needs finance context)
│   ├── sales.md          (loaded only when Claude needs sales context)
│   └── product.md        (loaded only when Claude needs product context)
└── scripts/
    └── helper.py         (executed via bash, never loaded into context)
```

`SKILL.md` becomes a table of contents that points at the right reference file:

```markdown
**Finance metrics**: see [reference/finance.md](reference/finance.md)
**Sales metrics**: see [reference/sales.md](reference/sales.md)
```

Claude loads only the file that matches the current task. The others stay on disk consuming zero tokens.

**Two hard rules for progressive disclosure:**

1. **Keep references one level deep from SKILL.md.** Anthropic warns that Claude may use `head -100` to preview files when they're referenced from other referenced files. Nested chains break under partial reads. If `SKILL.md → advanced.md → details.md`, Claude might never reach `details.md`.

2. **Long reference files (>100 lines) need a table of contents at the top.** This ensures Claude can see the full scope of a file even when previewing with partial reads.

## Workflows and feedback loops

For multi-step processes, give Claude an explicit checklist to copy and check off:

```markdown
## Database migration workflow

Copy this checklist and track progress:
- [ ] Step 1: Backup production database
- [ ] Step 2: Run migration script
- [ ] Step 3: Verify row counts match
- [ ] Step 4: Smoke-test the affected endpoints
- [ ] Step 5: Notify the team
```

For quality-critical operations, build in a validation loop:

```markdown
1. Make the change
2. Run the validator
3. If validation fails, fix the issue and run validator again
4. Only proceed when validation passes
```

This pattern catches errors early instead of letting them compound through later steps.

## The Why-line convention (for persona skills)

For persona skills with load-bearing principles, use the Why-line convention from `~/.claude/CLAUDE.md <maintenance>`:

```markdown
- **[Principle, imperative form].** [Brief elaboration.]
  **Why:** [Durable intent — survives model-version shifts]
```

Not every principle needs a Why. Test: *would a cold-start Claude understand intent from the elaboration + examples alone?* If yes, skip the Why (it's bloat). If no, add it.

Apply Whys sparingly. A persona skill's *examples* carry much of the intent; duplicating in Whys is waste.

## Common patterns

**Template pattern** — provide an output template when format matters:
```markdown
ALWAYS use this exact template structure:
\`\`\`markdown
# [Title]
## Summary
[one paragraph]
## Findings
- [bullet]
\`\`\`
```

**Examples pattern** — for skills where output quality depends on examples, include input/output pairs:
```markdown
**Example:**
Input: Added user authentication with JWT
Output:
\`\`\`
feat(auth): implement JWT-based authentication
\`\`\`
```

**Conditional workflow pattern** — guide Claude through decision points:
```markdown
1. Determine the modification type:
   **Creating new content?** → Follow "Creation workflow"
   **Editing existing content?** → Follow "Editing workflow"
```

## Anti-patterns to avoid

- **Vague descriptions** like "Helps with documents" or "Does stuff with files." Auto-loading depends on specificity.
- **First-person descriptions** ("I help you process Excel files"). Must be third person.
- **Burying the trigger** in characters 250–1024 of the description. The first 250 are what Claude sees.
- **Time-sensitive information** ("Use the new API after August 2025"). Will become wrong. Use an "old patterns" section with collapsible details instead.
- **Inconsistent terminology** (mixing "API endpoint" / "URL" / "API route" / "path" for the same thing).
- **Too many options without a default** ("You can use pypdf, or pdfplumber, or PyMuPDF, or..."). Provide a default with an escape hatch.
- **Windows-style paths** (`scripts\helper.py`). Always use forward slashes even on Windows.
- **Magic numbers / voodoo constants** in scripts (`TIMEOUT = 47  # why 47?`). Self-document or remove.
- **Punting errors to Claude** in scripts. Handle errors explicitly; tell Claude what to do when something fails, don't just let the script crash.
- **Hedge language in rules** (4.7 era). "Consider whether," "you might want to," "feel free to" — 4.7 reads as optional. Use directives.
- **Missing `claude-md-version` on persona skills** — the staleness hook won't detect drift; the skill stays on an old convention indefinitely.

## Quality standards

- **Every line earns its place.** If Claude already knows it, cut it.
- **Bold the escape hatch.** Load-bearing content never lives in parentheticals or hedges. If a rule has an alternative, the alternative is **bold and equal-weight**. Escape hatches in fine print get used.
- **Use consistent terminology** within the skill.
- **Test descriptions empirically.** After writing, ask: "Would Claude know to load this skill from the description alone?" If you have to read the body to confirm relevance, the description is broken.
- **Prefer scripts over generated code** for deterministic operations. Bundled scripts are more reliable, save tokens, and ensure consistency.

## Iterative authoring with Claude

Anthropic's recommended workflow for refining skills: work with one Claude instance ("Claude A") to design the skill; test with a separate instance ("Claude B") that uses the skill on real tasks; observe Claude B's behavior; bring observations back to Claude A.

When Claude B fails to load your skill when it should: the description is broken. Claude A revises.
When Claude B loads your skill but applies it wrong: the body is broken. Claude A revises.
When Claude B loads your skill in situations it shouldn't: the description is too broad. Claude A adds DO NOT TRIGGER conditions.

Iterate based on observation, not assumption.

## Checklist before shipping a skill

- [ ] `name` is lowercase, hyphenated, ≤64 chars, no reserved words
- [ ] `description` is third person, includes both what + when, ≤250 effective chars, front-loads triggers
- [ ] If this is a persona skill: `claude-md-version` matches current convention in global CLAUDE.md
- [ ] Body is under 500 lines
- [ ] No first-person language in description
- [ ] Reference files (if any) are one level deep from SKILL.md
- [ ] Long reference files have a table of contents
- [ ] No time-sensitive information (or it's in an "old patterns" section)
- [ ] Consistent terminology throughout
- [ ] No Windows-style paths
- [ ] **No hedge language in load-bearing rules** (4.7 era — scan for "consider," "might," "feel free," "worth noting")
- [ ] If scripts: handle errors explicitly, no voodoo constants
- [ ] Load-bearing content is not hidden in parentheticals (bold the escape hatch)

## References

Live Anthropic guidance (verify currency before relying on memory):
- [Skills authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Skills overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [Claude Code skills](https://code.claude.com/docs/en/skills)
- [Opus 4.7 migration guide](https://platform.claude.com/docs/en/about-claude/models/migration-guide)

## Reference memories

- `reference_prompting_research` memory file — current prompting research with 4.7 behavioral notes.
