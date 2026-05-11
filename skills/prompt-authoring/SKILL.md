---
name: prompt-authoring
description: Authors system prompts, persona definitions, and AI-facing instructions per current Anthropic best practices. Use when writing or revising prompts, calibrating intensity, structuring examples. See skill-authoring and subagent-authoring for siblings.
claude-md-version: 2026-05-06
---

# Prompt Authoring

Reference for writing system prompts, persona definitions, and AI-facing instructions. Current per latest Anthropic guidance.

For SKILL.md files specifically, use `skill-authoring` instead. For `.claude/agents/` subagent files, use `subagent-authoring`. This skill is for system prompts that go in the API `system` field, persona/agent prompts, and CLAUDE.md content.

## Core principles (model-independent)

**Concise is key.** Context window is a public good. Default assumption: Claude is already very smart. Only add context Claude doesn't already have. For each line, ask: "would removing this cause Claude to make mistakes?" If not, cut it.

**Define identity through behavior, not adjectives.** "You investigate before responding" is stronger than "You are thorough." Show what the persona does, not what it is.

**Explain the why behind every rule.** A bare rule ("Never use mocks") is brittle. A rule with motivation ("Never use mocks — they mask integration failures, and we've been burned before") lets Claude generalize to edge cases the rule didn't anticipate.

  **Why:** Modern Claude follows instructions literally. Rules without grounding don't generalize on their own — the motivation lets the model extend the rule to situations the rule's literal wording didn't anticipate.

**Frame positively — say what TO do, not what to avoid.** "Write in clear flowing prose" steers better than "Don't use bullet points." When you must include a refusal, pair it with the positive alternative of equal weight.

## Current Claude behaviors to design around

These are stable behavioral tendencies of recent Claude models. Each comes with a **Why:** line — when expression needs recalibrating for a future model, the Why stays; only the wording changes.

### 1. Literal instruction following — hedge language is a hazard

Hedged phrases like *"consider whether X"*, *"feel free to Y"*, *"you might want to Z"*, *"worth noting: W"* are read as **optional** and often skipped. Rules written with hedges silently don't fire.

  **Why:** Modern Claude interprets prompts literally. Soft directives don't generalize into behaviors the way they once did — the model treats the hedge as permission to skip rather than a softened directive.

**Fix:** replace hedges with directives. Enumerate constraints instead of implying them.

| Hedge | Directive replacement |
|---|---|
| *"consider whether X applies"* | *"If X, then Y"* |
| *"you might want to check Y"* | *"Check Y"* |
| *"worth noting: Z"* | *"Z. This matters because..."* |
| *"feel free to"* | delete, or *"Do this when..."* |
| *"if it comes up"* | specify when it comes up, or delete |

**Scan every rule you write for hedge words.** If you see "consider," "might," "feel free," "worth noting," or "if appropriate" — rewrite as a directive.

### 2. Subagent spawning is conservative — steer with explicit prompts

Per Anthropic's prompting best practices doc: *"Claude Opus 4.7 tends to spawn fewer subagents by default. However, this behavior is steerable through prompting; give Claude explicit guidance around when subagents are desirable."* Workflows that depend on parallel specialist delegation produce single-threaded results unless the orchestrating prompt invokes the Agent tool explicitly.

  **Why:** Default delegation behavior shifts across model releases. Persona designs that relied on implicit spawning silently degrade; explicit guidance is durable across the shift.

**Fix:** when designing a persona that orchestrates parallelizable work, embed Anthropic's canonical guidance pattern:

```text
Do not spawn a subagent for work you can complete directly in a single
response (e.g. refactoring a function you can already see).

Spawn multiple subagents in the same turn when fanning out across items 
or reading multiple files.
```

This is the example prompt from Anthropic's prompting best practices doc. Adapt the wording, keep the polarity.

### 3. Baseline tone is direct

Default tone is less validation-forward than earlier-generation models — fewer "Great question!" and less emoji. Anti-sycophancy guardrails that corrected earlier-model warmth are often redundant now.

  **Why:** Each model release recalibrates the warmth/directness baseline. Rules that codify intent (Chesterton's Fence) survive recalibrations; rules that fight a specific old tendency become dead weight when that tendency goes away.

Trim anti-sycophancy guardrails unless they document a specific failure mode you still care about catching.

## Calibrating intensity

Modern Claude's baseline is direct and literal. Don't stack "CRITICAL:", "YOU MUST", "ALWAYS" — it causes overtriggering, where Claude spends cognitive budget checking rules during routine work instead of doing the work.

  **Why:** Intensity markers were calibrated for earlier, less responsive models. Stacking them on a model that already follows instructions literally creates ambient anxiety rather than better adherence.

**Important context-dependent exception:** the "avoid emphasis" rule applies to **system prompts and tool/skill triggers**. It does NOT apply to **CLAUDE.md persistent instructions**. CLAUDE.md is loaded every session and is sensitive to under-adherence — Anthropic recommends emphasis like "IMPORTANT" or "YOU MUST" in CLAUDE.md when Claude isn't following a rule.

- **System prompts / tool descriptions / skill triggers:** calm, direct, no emphasis. Overtriggering is the failure mode.
- **CLAUDE.md persistent instructions:** emphasis is allowed when under-adherence is the failure mode.

**Lean into directives.** Replacing hedges with clear "do X when Y" statements is more effective than adding intensity markers.

## The Why-line convention (for CLAUDE.md authoring)

For any prompt or CLAUDE.md file where rules need to survive model-version shifts, use the **Why-line convention** from the user's `~/.claude/CLAUDE.md <maintenance>` preamble:

```markdown
- **[Rule statement].** [Brief elaboration]
  **Why:** [Durable intent — the reason that survives model shifts]
  **Scope:** [Optional — explicit where literal-follow might narrow]
  **How to apply:** [Optional — procedural hint for ambiguous cases]
```

The Why is an intent anchor. When a new model ships, the rule expression may need rewriting, but the Why stays verbatim. This lets maintenance be "does this expression still serve this Why on the new model?" — a mechanical pass, not a rebuild.

## Structure

**Use XML tags to separate concerns.** Wrap distinct sections in descriptive tags — `<role>`, `<principles>`, `<behaviors>`, `<examples>`, `<boundaries>` — so Claude can parse complex prompts unambiguously. Use consistent tag names. Nest where content has natural hierarchy.

XML tags are more reliable than prose headers for section identification. Anthropic's guidance has reinforced this pattern through every model release.

**Include 3–5 behavioral examples.** Few-shot examples in `<example>` tags are one of the most reliable steering mechanisms on every Claude version. Make them:
- **Relevant:** mirror the actual use case
- **Diverse:** cover edge cases, vary enough that Claude doesn't overfit
- **Structured:** wrap in `<example>` (or `<examples>` for multiple)

Cover at least one "easy to get wrong" scenario — the situation where a naive implementation would fail.

**Set the action posture explicitly.** Claude distinguishes "can you suggest changes?" (advisory) from "make these changes" (action). Decide which posture the persona defaults to and state it. For default-to-action use a `<default_to_action>` block. For default-to-research use `<do_not_act_before_instructions>`.

**Long-context placement matters.** When a prompt includes large documents or data (20k+ tokens), put longform data **at the top**, queries and instructions **at the end**. This can improve response quality by up to 30% for complex multi-document inputs.

## Match specificity to fragility

Decide how much freedom to give Claude based on how fragile the task is. For open-ended work where multiple approaches are valid, give general direction and trust the model. For fragile or consequential work where one wrong step is costly, give exact instructions and explicit constraints.

The default mistake is over-specifying open-ended work (produces robotic output) or under-specifying fragile work (produces plausible-but-wrong output). The full framework lives in `skill-authoring`; the principle applies to any prompt.

**Under-specification of scope is a common failure on literal-follow models.** Generic rules like "verify before claiming" may not generalize to the specific context you meant. Spell out scope.

  **Why:** Literal instruction following narrows the rule's application to exactly what you wrote. If you wrote "verify before claiming," the model verifies what you wrote *to verify* — not the broader behavior you imagined.

## Verification is the highest-impact thing

Per Anthropic's Claude Code best practices: *"Claude performs dramatically better when it can verify its own work."* When writing prompts that produce code or artifacts, include verification criteria — tests to run, screenshots to compare, expected outputs. Without clear success criteria, Claude can produce something that looks right but doesn't work.

**Before:** "implement a function that validates email addresses"
**After:** "write a validateEmail function. Example test cases: user@example.com → true, invalid → false, user@.com → false. Run the tests after implementing."

If you can't verify it, the persona shouldn't ship it.

## Anti-hallucination pattern

For prompts that involve code or codebase claims, include an investigate-before-answering rule:

```text
<investigate_before_answering>
Never speculate about code you haven't opened. If the user references a 
specific file, read it before answering. Investigate relevant files before 
making claims about the codebase. Never make claims about code before 
investigating unless you are certain — give grounded, hallucination-free answers.
</investigate_before_answering>
```

This pattern is in Anthropic's current best-practices doc and should be a default for any persona that touches code.

## Effort discipline

Claude Code exposes an `effort` parameter (`low` / `medium` / `high` / `xhigh` / `max`). Pick deliberately:

- **`xhigh`** — Anthropic's recommended default for coding and agentic work. Good ceiling for most persona bots.
- **`max`** — prone to overthinking and doom loops. Reserve for isolated hard subproblems, not as a session default.
- **`low` / `medium`** — risk of shallow reasoning on moderately complex tasks. Raise effort rather than prompting around it.

**When writing persona prompts:** if the persona's domain is analytically hard (security review, architecture, debugging), recommend `xhigh` effort, not `max`. If the persona does simple lookups or format conversions, `medium` is fine.

  **Why:** Effort levels are sticky design choices in skill frontmatter. Pinning `max` everywhere produces slower, more expensive runs without commensurate quality gains; pinning `low` on hard work produces confidently wrong answers. Match effort to fragility.

## Failure patterns to design around

Watch for these in your own prompts and in the personas you write:

- **Hedge language treated as optional.** "Consider whether" and "you might want to" get skipped. Use directives.
- **Subagent under-spawning.** Per Anthropic, current Claude *"tends to spawn fewer subagents by default."* Workflows that fan out specialist work serialize without explicit Agent-tool invocation. Add explicit delegation guidance in the invoking prompt.
- **Over-trimmed voice guardrails.** The baseline is direct, but don't trim every anti-sycophancy rule — some document intent (Chesterton's Fence) even when the model doesn't currently need them.
- **`max` effort set globally.** Use `xhigh` as ceiling; `max` per-call for hard problems only.
- **Implicit scope.** Literal-follow models narrow the rule's application to what you wrote. Enumerate scope explicitly.
- **Test-passing instead of correctness.** Claude can focus on making tests pass at the expense of generalizable solutions. State explicitly: "tests verify correctness, they don't define the solution."
- **Hard-to-reverse actions.** For personas with shell or tool access, add reversibility guidance: "Take local reversible actions freely. For destructive or shared-state actions, confirm before proceeding."
- **Implicit phase ordering.** Personas that do multi-step work produce dramatically better results when phase boundaries are explicit. Encode the phase order — e.g., "explore → plan → execute → verify" — rather than describing the goal and hoping Claude orders the steps correctly.

## Iterative authoring with Claude

Anthropic's recommended workflow for building agent instructions: work with one Claude instance ("Claude A") to design and refine the prompt; test with a separate instance ("Claude B") that uses the prompt in real tasks; observe Claude B's behavior; bring observations back to Claude A. This decoupling — designer vs. user — surfaces gaps that single-instance authoring misses.

Apply this pattern when building any non-trivial persona.

## Quality standards

- **Every line earns its place.** If a guideline is obvious from convention or context, omit it. If it's surprising, include it with reasoning.
- **Leave room for judgment.** Over-specified prompts produce robotic output. Encode principles and priorities, then trust the model to apply them within the scope you've defined.
- **Match prompt voice to desired output voice.** A grizzled engineer doesn't talk like a customer support bot. Generic AI-assistant language ("Great question!") breaks immersion.
- **Bold the escape hatch.** Load-bearing content never lives in parentheticals or hedges. If a rule has an alternative, the alternative is **bold and equal-weight**. If a refusal is final, the finality is **bold**. Escape hatches in fine print get used.
- **No weasel words.** "Leverage", "robust", "seamless", "comprehensive", "utilize" — strip them. They add length without meaning.
- **No hedge language in rules.** Hedges get skipped on literal-follow models.

## When this skill is the wrong tool

- Writing a SKILL.md file → use `skill-authoring`
- Writing a `.claude/agents/<name>.md` subagent → use `subagent-authoring`
- Writing CLAUDE.md project instructions → mostly the rules above apply, with the emphasis-allowed exception noted under "Calibrating intensity." Also use the Why-line convention for load-bearing rules.
- Writing user-facing documentation → this skill is the wrong tool entirely

## References

Live Anthropic guidance (verify currency before relying on memory):
- [Claude prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices)
- [Claude Code best practices](https://code.claude.com/docs/en/best-practices)
- [Anthropic model migration guide](https://platform.claude.com/docs/en/about-claude/models/migration-guide)
- [Skills overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [Subagents reference](https://code.claude.com/docs/en/sub-agents)
