# Intensity Calibration (Claude 4.6)

How the tone and formatting of your instructions affects Claude's behavior. These findings are specific to Claude Opus 4.6 and Sonnet 4.6 — recalibrate when new models are released.

## The Problem

Claude 4.6 is more proactive and responsive to system prompts than earlier models. This means aggressive instruction language causes overtriggering — Claude spends cognitive budget checking rules during routine tasks instead of doing the work.

The most common symptom: Claude becomes hypervigilant, pausing to verify it isn't violating rules even when the current task has nothing to do with those rules.

## What We Found

### Intensity stacking is the real issue

No single formatting choice causes problems. The issue is *density* — when multiple high-intensity markers stack together, they create ambient anxiety:

```
❌ Dense intensity (causes overtriggering):

## Hard Rules (Non-Negotiable)
- **NEVER** delete files without permission
- **NEVER** modify code outside the current scope
- **ALWAYS** ask before making changes
- **CRITICAL:** Stay in scope at all times
```

```
✅ Calm authority (same rules, better behavior):

## Ground Rules
- Don't delete files without permission
- Don't modify code outside the current scope
- Ask before making changes
- Stay in scope
```

Both versions convey the same rules. The second version produces better compliance because Claude isn't burning cognitive cycles on threat assessment.

### Specific findings

| Change | Effect |
|--------|--------|
| "Never" → "Don't" | Same prohibition, lower activation energy. Claude follows it equally well. |
| ALL CAPS in rules | Causes overtriggering when combined with bold or "Never." Bold alone is sufficient. |
| Section headers like "Non-Negotiable" | Creates hypervigilance. "Ground Rules" conveys the same authority. |
| "CRITICAL:", "IMPORTANT:", "YOU MUST" | Overtriggers on 4.6. Use calm, direct statements instead. |
| Reason + rule vs. bare rule | Rules with explanations ("Don't use mocks — they mask integration failures") produce better generalization than bare rules ("Don't use mocks"). |

### Guardrails deduplication

If you use skills (slash commands), each skill's prompt is loaded alongside your CLAUDE.md. If both the skill and CLAUDE.md state the same rules, Claude sees them 2-3x per turn.

This causes two problems:
1. **Token waste** — ~80 redundant lines per skill invocation
2. **Intensity stacking** — seeing "Don't delete and recreate" three times makes it feel more critical than seeing it once

The fix: skills reference the hierarchy instead of restating rules.

```
❌ Each skill restates global rules:
- Don't delete and recreate files
- Prefer targeted edits
- Stay in scope
- Investigate before opining
[... 4-6 more rules identical to CLAUDE.md]

✅ Skills reference the hierarchy:
Follow the ground rules in the project's CLAUDE.md hierarchy.
Additionally: [domain-specific rules only]
```

## How to Apply

1. **Audit your CLAUDE.md files.** Search for "Never," "ALWAYS," "CRITICAL," "IMPORTANT," ALL CAPS phrases. Downshift to calm equivalents.
2. **Check section headers.** Replace anything that reads as a threat level ("Non-Negotiable," "Hard Rules") with neutral headers ("Ground Rules," "Conventions").
3. **Lead with principles, then list rules.** A one-line explanation of *why* these rules exist helps Claude generalize rather than memorize.
4. **Check skills for duplication.** If your skills restate global rules, replace with a one-line reference.
5. **Recalibrate on new models.** These findings are for 4.6. If a future model is less responsive to calm instructions, intensity may need to go back up.
