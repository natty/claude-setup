---
name: retro
description: Quick retrospective — review what just happened and save a feedback memory so future sessions don't repeat the mistake
disable-model-invocation: false
---

# Retro

The user noticed something that should have been handled differently in this conversation.

Their observation: $ARGUMENTS

## Instructions

1. If `$ARGUMENTS` is empty, ask the user one question: "What did you notice?" — then wait for their response before continuing.
2. Review the recent conversation context — what was being worked on, what approach was taken, what went wrong or was suboptimal.
3. Based on the user's observation, identify the root cause. Be specific — not "should have been more careful" but "should have checked the reference docs before web searching."
4. Save a **feedback memory** to the project's memory directory:
   - Filename: `feedback_<short_descriptive_name>.md`
   - Use the feedback memory format with frontmatter (name, description, type: feedback)
   - Lead with the rule
   - **Why:** what went wrong this time
   - **How to apply:** when/where this guidance kicks in
5. Update `MEMORY.md` in the same directory with a pointer to the new file.
6. Respond with a **one-liner** summary of what you saved. No lengthy post-mortem.

## Guidelines

- Keep it lightweight. This is a quick correction, not a retrospective meeting.
- Be specific and actionable. Vague rules don't help future sessions.
- Check for existing feedback memories first — update an existing one rather than creating a duplicate.
- The memory is local only — just a markdown file on disk that future Claude Code sessions read. Nothing leaves the machine.
