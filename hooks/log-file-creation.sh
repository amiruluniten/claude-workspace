#!/bin/bash
# Logs every file write to an audit log

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

LOG_FILE="$CLAUDE_PROJECT_DIR/.claude/file-audit.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
REL_PATH="${FILE_PATH#$CLAUDE_PROJECT_DIR/}"

echo "[$TIMESTAMP] WRITE $REL_PATH" >> "$LOG_FILE"

exit 0
