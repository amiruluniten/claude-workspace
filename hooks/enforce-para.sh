#!/bin/bash
# Ensures all new files are created inside PARA folders, not loose at the root

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Get path relative to project root
REL_PATH="${FILE_PATH#$CLAUDE_PROJECT_DIR/}"

# Allow root-level config files
case "$REL_PATH" in
  .gitignore|.git/*|.claude/*|CLAUDE.md|.DS_Store|.env*|README.md|hooks/*)
    exit 0
    ;;
esac

# Allow anything inside PARA folders
PARA_FOLDERS=("00-Inbox" "01-Projects" "02-Areas" "03-Resources" "04-Archives" "05-Goals")
for folder in "${PARA_FOLDERS[@]}"; do
  if [[ "$REL_PATH" == "$folder"/* ]]; then
    exit 0
  fi
done

# Block anything else at the root level
echo "Blocked: '$REL_PATH' is not inside a PARA folder. Use one of: ${PARA_FOLDERS[*]}. Drop unsorted files in 00-Inbox/." >&2
exit 2
