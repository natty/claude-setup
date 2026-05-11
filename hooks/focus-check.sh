#!/bin/bash
# ADHD Protocol hook — reminds Claude of current focus when FOCUS.md exists.
# If no FOCUS.md but a roadmap exists, nudges to create one.
# Fires on UserPromptSubmit.

FOCUS_FILE="FOCUS.md"
ROADMAP_FILE="docs/claude/roadmap.md"

if [ -f "$FOCUS_FILE" ]; then
  CONTENT=$(cat "$FOCUS_FILE")
  PARKING_COUNT=0

  # Count project stash items if it exists
  if [ -f "docs/claude/stash.md" ]; then
    PARKING_COUNT=$(sed '1,/^---$/d' "docs/claude/stash.md" 2>/dev/null | grep -c '[^ ]' || echo 0)
  fi

  # Count global stash items
  GLOBAL_PARKING=0
  GLOBAL_LOT="$HOME/claude-output/stash.md"
  if [ -f "$GLOBAL_LOT" ]; then
    GLOBAL_PARKING=$(sed '1,/^---$/d' "$GLOBAL_LOT" 2>/dev/null | grep -c '[^ ]' || echo 0)
  fi

  cat <<EOF
{"userMessage": "ADHD PROTOCOL ACTIVE. Current FOCUS.md:\n${CONTENT}\n\nStash: ${PARKING_COUNT} project items, ${GLOBAL_PARKING} global items.\n\nRemember: if the user brings up an idea that isn't the current task, stash it (don't explore it) and redirect to the current focus. Only change focus if explicitly asked."}
EOF

elif [ -f "$ROADMAP_FILE" ]; then
  # Roadmap exists but no FOCUS.md — nudge to create one
  cat <<EOF
{"userMessage": "This project has a roadmap but no FOCUS.md. Before diving in, ask the user: 'What are you working on this session?' Then create FOCUS.md with their answer (YOU ARE DOING / NEXT ACTION / DONE WHEN). Keep it to one task. If they say they don't want one, drop it — don't ask again this session."}
EOF
fi
