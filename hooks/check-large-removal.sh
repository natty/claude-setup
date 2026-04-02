#!/bin/bash
# Blocks Write/Edit tool calls that remove 50+ lines from a file.
# Exempts docs/claude/ files and memory files.
# User can approve a blocked edit by running: touch /tmp/.claude-large-edit-allow

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

# Check for one-time bypass file (must be less than 2 minutes old)
bypass_file="/tmp/.claude-large-edit-allow"
if [[ -f "$bypass_file" ]]; then
  if [[ $(find "$bypass_file" -mmin -2 2>/dev/null) ]]; then
    rm -f "$bypass_file"
    exit 0
  else
    rm -f "$bypass_file"
  fi
fi

current_lines=$(wc -l < "$file_path" 2>/dev/null || echo 0)

if [[ "$tool" == "Write" ]]; then
  new_lines=$(echo "$input" | jq -r '.tool_input.content' | wc -l)
  removed=$((current_lines - new_lines))

  if [[ $removed -ge 50 ]]; then
    echo "{\"decision\":\"block\",\"reason\":\"BLOCKED: This Write would remove $removed lines from $file_path (from $current_lines to $new_lines). Do NOT work around this. Tell the user and ask them to run: touch /tmp/.claude-large-edit-allow — then retry the same edit.\"}"
    exit 2
  fi

elif [[ "$tool" == "Edit" ]]; then
  old_lines=$(echo "$input" | jq -r '.tool_input.old_string' | wc -l)
  new_lines=$(echo "$input" | jq -r '.tool_input.new_string' | wc -l)
  removed=$((old_lines - new_lines))

  if [[ $removed -ge 50 ]]; then
    echo "{\"decision\":\"block\",\"reason\":\"BLOCKED: This Edit would remove $removed lines from $file_path. Do NOT work around this. Tell the user and ask them to run: touch /tmp/.claude-large-edit-allow — then retry the same edit.\"}"
    exit 2
  fi
fi
