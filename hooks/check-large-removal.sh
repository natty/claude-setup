#!/bin/bash
# Blocks Write/Edit tool calls that remove 50+ lines from a file.
# Prevents accidental large deletions. Exempts docs/claude/ and memory files.
# Fires on PreToolUse for Write and Edit (see settings-example.json).

set -e

input=$(cat)
tool=$(echo "$input" | jq -r '.tool_name')
file_path=$(echo "$input" | jq -r '.tool_input.file_path')

# Skip docs/claude/ files
if [[ "$file_path" == *"docs/claude/"* ]]; then
  exit 0
fi

# Skip memory files
if [[ "$file_path" == *".claude/"*"memory/"* ]]; then
  exit 0
fi

# Skip if file doesn't exist yet (new file creation)
if [[ ! -f "$file_path" ]]; then
  exit 0
fi

current_lines=$(wc -l < "$file_path" 2>/dev/null || echo 0)

if [[ "$tool" == "Write" ]]; then
  new_lines=$(echo "$input" | jq -r '.tool_input.content' | wc -l)
  removed=$((current_lines - new_lines))

  if [[ $removed -ge 50 ]]; then
    echo "{\"decision\":\"block\",\"reason\":\"This Write would remove $removed lines from $file_path (from $current_lines to $new_lines). Confirm with the user before proceeding.\"}"
    exit 2
  fi

elif [[ "$tool" == "Edit" ]]; then
  old_lines=$(echo "$input" | jq -r '.tool_input.old_string' | wc -l)
  new_lines=$(echo "$input" | jq -r '.tool_input.new_string' | wc -l)
  removed=$((old_lines - new_lines))

  if [[ $removed -ge 50 ]]; then
    echo "{\"decision\":\"block\",\"reason\":\"This Edit would remove $removed lines from $file_path. Confirm with the user before proceeding.\"}"
    exit 2
  fi
fi
