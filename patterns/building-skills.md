# Building Skills

How to create effective Claude Code skills (slash commands) that produce consistent, high-quality behavior.

## What Skills Are

Skills are markdown files that get loaded as additional instructions when invoked with `/skill-name`. They live in `~/.claude/skills/[name]/SKILL.md` and are available across all projects.

A skill is essentially a system prompt fragment that gets appended to Claude's context. The frontmatter controls metadata:

```yaml
---
name: my-skill
description: One-line description shown in skill listings
user-invocable: true          # Can be called with /my-skill
disable-model-invocation: true # Claude can't invoke it autonomously
---
```

## The Layered Prompt Structure

The best skills follow a consistent structure. This isn't mandatory, but it produces reliable behavior:

### 1. Identity — Who the persona is

Define through behavior, not adjectives. "You investigate before responding" beats "You are thorough."

```markdown
You are a staff-level software engineer with 20+ years of experience.
You lead with curiosity — when someone says "this isn't working," your
first instinct is to look at the code, not explain why it should be working.
```

### 2. Principles — What they believe

These are the decision-making framework. When two good options exist, principles determine which one the persona picks. Order them by priority — the first principle wins when they conflict.

```markdown
## Your Principles (In Priority Order)
1. **Correctness.** Working software that does the right thing.
2. **Clarity.** Code others can understand and build on.
3. **Simplicity.** The least complexity that solves the problem.
4. **Velocity.** Moving fast, but only after 1-3 are satisfied.
```

### 3. Behaviors — What they do

Concrete actions, not abstract qualities. Include the action posture — should the skill discuss first, or act directly?

```markdown
## Your Default Posture
- **Discuss first, implement second.** Present your approach before writing code.
- **Investigate before claiming.** Search thoroughly before saying something doesn't exist.
```

### 4. Examples — Showing, not just telling

Few-shot examples inside `<example>` tags are one of the most reliable ways to steer behavior. Include 2-3 diverse scenarios:

```markdown
<example>
<scenario>A teammate reports a bug you think shouldn't be possible</scenario>
<response>"Let me pull that up and take a look." [Investigates, finds edge case]</response>
<why>Believe the reporter first. Investigate before defending.</why>
</example>
```

### 5. Self-correction — Catching drift

Red flags the persona watches for in its own output. These target the specific failure modes most likely for this persona:

```markdown
## What You Watch For In Yourself
- If you're about to say "the code looks correct" in response to a bug report — look harder.
- If you're about to add complexity "for future flexibility" — question whether that future is real.
```

## Skill Types

Different skills serve different purposes. Here are the common patterns:

### Persona skills (bots)

A persistent persona Claude adopts for the session. Has identity, principles, behaviors, examples.

Examples: `/eng-bot`, `/prompt-bot`, `/docs-bot`

### Workflow skills

A step-by-step procedure Claude executes. No persona — just instructions.

Examples: `/start`, `/gg`, `/brb`, `/review`, `/tidy`

### Mode skills

Temporarily changes how Claude interacts without a full persona shift.

Examples: `/grill-me` (interrogation mode), `/retro` (reflection mode)

## Calibration Tips (Claude 4.6)

- **Use calm, direct language.** "CRITICAL" and "YOU MUST" cause overtriggering on 4.6.
- **Don't restate global rules.** Reference the CLAUDE.md hierarchy instead.
- **Add overengineering guardrails.** 4.6 tends to add unrequested features. Include: "Only make changes that are directly requested."
- **Say what TO do, not what to avoid.** "Write in clear prose" steers better than "Don't use jargon."
- **Explain the why behind rules.** Rules with motivation produce better generalization than bare rules.

## Using /prompt-bot to Build Skills

The `/prompt-bot` skill is designed to craft Claude system prompts from rough descriptions. You can use it to build new skills:

```
/prompt-bot I want a skill that acts as a database expert who reviews
schema designs, suggests indexes, and catches N+1 query patterns. It
should be conservative about migrations and always ask before suggesting
schema changes.
```

Prompt-bot will produce a complete skill prompt following the layered structure, with examples and self-correction signals. Copy the output to `~/.claude/skills/[name]/SKILL.md`.

## Practical Advice

- **Start simple.** A 20-line skill that does one thing well beats a 200-line skill that tries to cover everything.
- **Test with realistic scenarios.** After creating a skill, invoke it and give it a real task. Watch for drift, overengineering, or failure to follow its own principles.
- **Iterate based on use.** Use `/retro` when a skill misbehaves. The feedback loop captures what went wrong so you can adjust the skill.
- **Skills are cheap to create.** If you find yourself giving Claude the same instructions repeatedly, that's a skill waiting to be written.
