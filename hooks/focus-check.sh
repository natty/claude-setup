#!/bin/bash
# Focus Protocol hook — reminds Claude of current focus when FOCUS.md exists.
# If no FOCUS.md but a roadmap exists, nudges to create one.
# Fires on UserPromptSubmit (see settings-example.json).

FOCUS_FILE="FOCUS.md"
ROADMAP_FILE="docs/claude/roadmap.md"

if [ -f "$FOCUS_FILE" ]; then
  CONTENT=$(cat "$FOCUS_FILE")
  STASH_COUNT=0

  # Count project stash items if it exists
  if [ -f "docs/claude/stash.md" ]; then
    STASH_COUNT=$(sed '1,/^---$/d' "docs/claude/stash.md" 2>/dev/null | grep -c '[^ ]' || echo 0)
  fi

  # Count global stash items
  GLOBAL_STASH=0
  GLOBAL_STASH_FILE="$HOME/claude-output/stash.md"
  if [ -f "$GLOBAL_STASH_FILE" ]; then
    GLOBAL_STASH=$(sed '1,/^---$/d' "$GLOBAL_STASH_FILE" 2>/dev/null | grep -c '[^ ]' || echo 0)
  fi

  cat <<EOF
{"userMessage": "FOCUS PROTOCOL ACTIVE. Current FOCUS.md:\n${CONTENT}\n\nStash: ${STASH_COUNT} project items, ${GLOBAL_STASH} global items.\n\nRemember: if the user brings up an idea that isn't the current task, stash it (don't explore it) and redirect to the current focus. Only change focus if explicitly asked."}
EOF

elif [ -f "$ROADMAP_FILE" ]; then
  # Roadmap exists but no FOCUS.md — nudge to create one
  cat <<EOF
{"userMessage": "This project has a roadmap but no FOCUS.md. Before diving in, ask the user: 'What are you working on this session?' Then create FOCUS.md with their answer (YOU ARE DOING / NEXT ACTION / DONE WHEN). Keep it to one task. If they say they don't want one, drop it — don't ask again this session."}
EOF
fi
