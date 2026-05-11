---
name: subagent-authoring
description: Authors Claude Code subagent definitions in .claude/agents/ following 2026 Anthropic best practices for Claude Opus 4.7. Use when creating or revising custom subagents, writing subagent descriptions for reliable delegation, deciding between subagent and skill, or restricting subagent tool access. Sibling skills: prompt-authoring (general system prompts), skill-authoring (SKILL.md format).
claude-md-version: 2026-05-06
---

# Subagent Authoring

Reference for writing Claude Code subagents (`.claude/agents/<name>.md` files). Current per latest Anthropic guidance.

For SKILL.md files, use `skill-authoring`. For general system prompts, use `prompt-authoring`.

## What a subagent is (and how it differs from a skill)

A subagent is a specialized AI assistant that handles a specific kind of task. It runs in **its own isolated context window** with its own system prompt, its own tool restrictions, and its own permissions. When the main Claude encounters a task that matches a subagent's description, it delegates to that subagent, which works independently and returns a summary.

**The fundamental difference from skills:** subagents have **no shared context** with the main conversation. A skill loads content into the main Claude's context window. A subagent runs in a separate context, receives only its own system prompt + basic environment info (working directory, etc.), executes the delegated task, and reports back. The main Claude sees the summary, not the work.

**This matters for design.** A subagent prompt has to be **self-contained**. It cannot assume the user's previous messages, the project's CLAUDE.md content, or the conversation history are available. Skills can lean on shared context; subagents cannot.

## Subagent spawning is conservative — design for explicit dispatch

Per Anthropic's prompting best practices doc: *"Claude Opus 4.7 tends to spawn fewer subagents by default. However, this behavior is steerable through prompting; give Claude explicit guidance around when subagents are desirable."* Agentic pipelines designed to parallelize specialist review produce single-threaded results unless the main Claude is explicitly steered to invoke the Agent tool — no error, just slower serial execution.

  **Why:** Default delegation behavior shifts across model releases. Designs that rely on implicit spawning silently degrade when the model recalibrates; explicit guidance survives the shifts.

**The canonical Anthropic example prompt for steering toward parallel spawning:**

```text
Do not spawn a subagent for work you can complete directly in a single
response (e.g. refactoring a function you can already see).

Spawn multiple subagents in the same turn when fanning out across items 
or reading multiple files.
```

Embed this (or an adapted version) in any orchestrating persona.

**Design implications:**

- **Subagent definitions alone are not enough to get delegation.** The main Claude needs explicit guidance to invoke the Agent tool. The existence of a subagent file does not imply automatic delegation.
- **If the main workflow depends on parallel subagent execution**, add guidance in the *invoking* skill or CLAUDE.md — not just in the subagent definition. The subagent itself is passive; the decision to spawn happens upstream.
- **Test delegation paths before assuming they work.** Run the subagent-shim verification pattern: dispatch a subagent, grep the response against its SKILL.md for confabulation vs. actual preload, confirm the skill body was applied.

Subagent overhead is real, and trivial tasks shouldn't be delegated. But the dominant failure mode on current models is under-spawning, not over-spawning. Design accordingly.

## When to use a subagent vs a skill vs CLAUDE.md

| If the goal is... | Use... |
|---|---|
| Add reusable knowledge that should be available alongside the main conversation | **Skill** |
| Run a specialized task in isolation that produces a summary, preserving the main context | **Subagent** |
| Add persistent project-wide rules that should always apply | **CLAUDE.md** |
| Add expertise that auto-loads only for specific tasks | **Skill** with good description |
| Run a research-heavy operation that would otherwise blow up the main context | **Subagent** (or `context: fork` skill) |
| Restrict tool access for a specific kind of work | **Subagent** (or skill with `allowed-tools`) |
| Run a task in a different model than the main conversation | **Subagent** with `model:` field |

**Default heuristic:** if the task can run alongside the conversation and the result should be visible to the main Claude as part of the same context, it's a skill. If the task should run in isolation and only the conclusion should land back in the main context, it's a subagent. **Context preservation is the question to ask.**

## Frontmatter rules

```yaml
---
name: code-reviewer
description: Reviews code for quality, security, and best practices. Delegate after code changes are made.
tools: Read, Glob, Grep
model: sonnet
---

You are a senior code reviewer. When invoked, analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

**`name` field:**
- Required
- Lowercase letters and hyphens only
- Unique identifier

**`description` field:**
- Required
- This is **when Claude should delegate to this subagent** — phrase it as a delegation trigger, not a capability statement
- Front-load the keywords. Same 250-char rule as skills (descriptions are loaded into the main system prompt for delegation matching)
- **Use an explicit delegation verb** — "Delegate when..." or "Use for..." — rather than leaving delegation implicit. Less ambiguity = more reliable dispatch.
- Example (good): *"Reviews code for quality, security, and best practices. Delegate after code changes are made."*
- Example (bad): *"This subagent can help you with code review."*

  **Why:** Literal-follow models match descriptions against incoming tasks for delegation. An explicit verb ("Delegate when X") makes the match deterministic; an implicit capability statement ("can help with X") leaves the model to infer whether to delegate.

## Optional frontmatter fields (the full set)

| Field | Purpose |
|---|---|
| `tools` | Allowlist of tools the subagent can use (space-separated or YAML list). Inherits all if omitted. |
| `disallowedTools` | Denylist applied first; remaining tools are then filtered by `tools` if both are set. |
| `model` | Model alias (`sonnet`, `opus`, `haiku`), full model ID, or `inherit`. Defaults to `inherit`. Prefer aliases — pinned IDs go stale at the next model release. |
| `permissionMode` | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`. |
| `maxTurns` | Maximum number of agentic turns before the subagent stops. |
| `skills` | Skills to preload into the subagent's context at startup. The full skill content is injected, not just made available. Subagents do NOT inherit skills from the parent conversation. |
| `mcpServers` | MCP servers available to this subagent. |
| `hooks` | Lifecycle hooks scoped to this subagent. |
| `memory` | Persistent memory scope: `user`, `project`, or `local`. Enables cross-session learning. |
| `effort` | Effort level (`low`/`medium`/`high`/`xhigh`/`max`). Overrides session effort. Default to `xhigh` for analytically hard work; reserve `max` for isolated hard subproblems (it's prone to overthinking). |
| `isolation` | Set to `worktree` to run in a temporary git worktree (isolated copy of the repo). Auto-cleaned if no changes. |
| `background` | Set to `true` to always run as a background task. |
| `color` | Display color in the task list (`red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan`). |
| `initialPrompt` | Auto-submitted as the first user turn when this agent runs as the main session agent. |

## Tool restrictions

By default, subagents inherit all tools from the main conversation. To restrict, use `tools` (allowlist) or `disallowedTools` (denylist):

**Read-only research subagent:**
```yaml
---
name: safe-researcher
description: Research agent with restricted capabilities
tools: Read, Grep, Glob
---
```

**Subagent that can do anything except modify files:**
```yaml
---
name: no-writes
description: Inherits every tool except file writes
disallowedTools: Write, Edit
---
```

**Both can be combined.** `disallowedTools` is applied first, then `tools` is resolved against the remaining pool.

## Model selection

**Default to `inherit`** (use the same model as the main conversation) unless there's a specific reason to override. Reasons to override:

- **`haiku`** for fast, cheap, read-only operations (code search, file discovery, simple analysis). Built-in `Explore` subagent uses Haiku for this reason.
- **`opus`** for tasks requiring deep reasoning that the main session might be running with a cheaper model.
- **`sonnet`** for balanced cost/capability when the main session is on Opus and the subagent task doesn't need full Opus depth.

**When in doubt, omit `model:` and let it inherit.** Prefer aliases (`opus`, `sonnet`, `haiku`) over pinned IDs.

  **Why:** Hard-coding a pinned model ID in the subagent definition turns the file into model-version debt. When a new model ships, every shim pinned to a prior version silently misses improvements and has to be updated manually. Inheriting (or using aliases) tracks the session automatically.

## Scope and priority

Subagents live in five possible locations, resolved in priority order. When names conflict, higher priority wins:

| Location | Scope | Priority |
|---|---|---|
| Managed settings | Org-wide | 1 (highest) |
| `--agents` CLI flag | Current session | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin `agents/` | Wherever the plugin is enabled | 5 (lowest) |

**Two operational constraints worth knowing:**

- **Subagents are loaded at session start.** File edits to `.claude/agents/<name>.md` do **not** take effect until the session restarts. The `/agents` interactive interface is the exception — changes made through it apply immediately.
- **Subagents cannot spawn other subagents.** Nesting is blocked. The built-in `Plan` subagent uses read-only tools rather than spawning further agents because of this constraint. If your design depends on a subagent dispatching its own workers, the design is wrong — restructure so the main Claude does the orchestration.

## Built-in subagents (use these before writing your own)

Claude Code includes built-in subagents that often cover the use case:

| Name | Model | Tools | Purpose |
|---|---|---|---|
| `Explore` | Haiku | Read-only | File discovery, code search, codebase exploration |
| `Plan` | Inherits | Read-only | Codebase research during plan mode |
| `general-purpose` | Inherits | All | Complex multi-step tasks requiring exploration + action |
| `statusline-setup` | Sonnet | (limited) | Configuring the status line via `/statusline` |
| `Claude Code Guide` | Haiku | (limited) | Answering questions about Claude Code features |

**Before writing a custom subagent, check whether `Explore`, `Plan`, or `general-purpose` already covers it.** Custom subagents should add specialization the built-ins don't have.

## Shims vs full subagents

A **shim** is a minimal subagent file (~5–10 lines) that registers the subagent_type and preloads a skill via the `skills:` frontmatter field. It doesn't duplicate the persona content — the skill file is canonical.

Use shims when:
- The persona is also a `skill` that's invoked directly
- You want the same persona available as both `/bot-name` (via Skill) and as a delegation target (via Agent tool)

Full subagent files are appropriate when:
- The subagent has unique context or guidance that isn't already a skill
- Tool restrictions or model overrides are critical to the persona

**Shim example:**
```markdown
---
name: sys-bot
description: Senior systems architect persona with 20+ years of experience. Delegate for architecture design, design doc review, or systems work.
skills:
  - sys-bot
  - brb
---

Apply the preloaded `sys-bot` skill. That skill file is the canonical persona and contains all guidance, principles, and examples — follow it exactly. This subagent file exists only to register `sys-bot` as a `subagent_type` so the Agent tool can dispatch to it.
```

**Load-bearing caveat about `skills:` preload:** this field is documented as preloading the full skill content into the subagent's context at startup. Verify empirically — dispatch the subagent, ask for a verbatim quote from the skill's body, grep the quote against the actual SKILL.md to confirm it was preloaded (not confabulated by a generic Claude wearing a role name).

  **Why:** Documentation describes intended behavior; runtime can differ. Confabulated skill content is the silent failure mode — the subagent answers in the right voice but doesn't actually have the skill's body in context.

## Designing the system prompt body

The body of a subagent file becomes the subagent's system prompt. Subagents receive **only this prompt + basic environment info** — not the full Claude Code system prompt, not the project's CLAUDE.md, not the conversation history.

**This means:**
- The prompt has to be **self-contained**. Don't reference "the user's earlier message" or "the project conventions" unless you've embedded them in the prompt itself.
- If the subagent needs project context, either preload a skill via the `skills:` field or include the relevant context inline in the prompt.
- Don't assume the subagent has read the codebase. If you want it to read specific files first, say so explicitly.

**Match specificity to fragility (degrees of freedom).** Same principle from `prompt-authoring` and `skill-authoring`: open-ended subagents get general direction, fragile subagents get exact instructions. A code-review subagent can be high-freedom ("analyze the code, suggest improvements"). A deployment subagent should be low-freedom ("run exactly these commands in this order").

**Apply all of `prompt-authoring`'s general rules** to the body content: behavior over adjectives, explain the why, frame positively, calm intensity, 3–5 examples in `<example>` tags, no hedge language. The subagent body is a system prompt; `prompt-authoring` is the source of truth for how to write one.

  **Why:** Duplicating prompt-writing guidance across skill files creates drift. When `prompt-authoring` updates with new model insights, subagent body advice should follow automatically — keep one source of truth.

## When an orchestrating persona should spawn subagents

If the subagent itself orchestrates other subagents (a coordinator or workflow persona), include explicit guidance on when to delegate. Anthropic's canonical prompt is the starting point:

```text
Do not spawn a subagent for work you can complete directly in a single
response (e.g. refactoring a function you can already see).

Spawn multiple subagents in the same turn when fanning out across items 
or reading multiple files.
```

For more nuanced orchestration logic, extend with project-specific guidance:

```text
When tasks are independent and parallelizable, invoke the Agent tool 
explicitly to dispatch specialists in parallel. Current Claude tends 
to spawn fewer subagents by default — don't rely on the model to spawn 
subagents implicitly.

For tasks that take less than a minute of direct work (grep, read one 
file, check a config), work directly. Subagent overhead exceeds the 
savings on trivial tasks.

For tasks that benefit from isolation (heavy research, multi-file 
refactor with uncertain scope, context-consuming analysis), dispatch 
to a subagent to preserve the main context.
```

Remember: subagents cannot spawn other subagents. If the orchestrator itself is a subagent, its decision to "delegate" actually means doing the work directly within its own turn.

**The general rule:** subagent overhead is real (context setup, prompt round-trip, summary serialization). For trivial tasks, direct work is cheaper. For isolated, parallelizable, or context-protecting work, subagents pay for themselves.

## Example: Research subagent

```markdown
---
name: deep-research
description: Deep codebase research that produces a written summary. Delegate when investigating how a feature works, tracing a bug across multiple files, or building context before a complex change.
tools: Read, Glob, Grep, Bash
model: inherit
effort: xhigh
---

You are a research assistant focused on deep codebase exploration. When invoked, you investigate the requested topic and return a structured written summary.

## Process
1. Use Glob and Grep to find relevant files
2. Read the relevant files in full (not just preview)
3. Trace dependencies and call paths
4. Identify the key abstractions and where they live
5. Return findings as a structured summary

## Output format
Return a markdown summary with:
- **Files involved:** numbered list with brief description of each file's role
- **Key abstractions:** the main types/functions and what they do
- **Call paths:** how the code flows from entry point to the area of interest
- **Open questions:** anything you couldn't determine from the code alone

## Constraints
- Read files in full when they're relevant; don't rely on partial previews
- Quote specific line numbers when making claims about behavior
- If you can't find something, say so explicitly — don't guess
```

## Quality standards

- **Self-contained.** A subagent prompt that depends on parent context will silently fail in surprising ways. Test by reading the prompt cold and asking: "Could a fresh Claude do this task with only this information?"
- **Bold the escape hatch.** Load-bearing content never lives in parentheticals. If a rule has an alternative, the alternative is **bold and equal-weight**.
- **Description = delegation trigger.** Phrase the description as "Delegate when X happens" or "Delegate after Y is done", not as a capability statement. Explicit delegation verbs ("Delegate," "Use for") fire more reliably than implicit ones.
- **Tool restrictions are part of the design.** A subagent that can do anything is rarely the right call. Restrict to the minimum tools needed.
- **Don't write a custom subagent if a built-in covers it.** Check `Explore`, `Plan`, and `general-purpose` first.
- **No hedge language in the body.** "Consider," "might," "feel free to" — rewrite as directives.

## Iterative authoring

Same Claude A / Claude B pattern from `prompt-authoring` and `skill-authoring`. Build the subagent with one Claude instance, test with another, observe failures, refine.

When the subagent fails to be invoked when it should (the dominant failure mode on current models): the description doesn't match how Claude phrases the task internally, or the main Claude isn't explicitly invoking the Agent tool — revise the description AND add explicit delegation guidance to the invoking skill or CLAUDE.md.

When the subagent is invoked but produces poor output: the body prompt is wrong — revise the body.

When the subagent is invoked too often (rare on current models): the description is too broad — narrow the trigger language.

## References

Live Anthropic guidance (verify currency before relying on memory):
- [Subagents reference](https://code.claude.com/docs/en/sub-agents)
- [Claude Code best practices](https://code.claude.com/docs/en/best-practices)
- [Anthropic model migration guide](https://platform.claude.com/docs/en/about-claude/models/migration-guide)
- [Skills overview (for context on skill vs subagent)](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
