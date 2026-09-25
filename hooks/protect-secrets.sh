#!/bin/bash
# Funnels secrets into .env files — blocks them from being written anywhere else

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.newString // empty')

# Allow writes to .env files — this is where secrets belong
if [[ "$FILE_PATH" == *.env ]] || [[ "$FILE_PATH" == *.env.local ]] || [[ "$FILE_PATH" == *.env.production ]]; then
  exit 0
fi

# For all other files, block if content contains secret patterns
if [ -n "$CONTENT" ]; then
  PATTERNS=("sk-" "sk_live" "sk_test" "API_KEY=" "SECRET_KEY=" "ACCESS_TOKEN=" "PRIVATE_KEY=" "password=" "aws_secret" "ghp_" "gho_" "glpat-")
  for pattern in "${PATTERNS[@]}"; do
    if echo "$CONTENT" | grep -qi "$pattern"; then
      echo "Blocked: Detected a secret ($pattern) being written to $FILE_PATH. Write secrets to a .env file instead, not in source code." >&2
      exit 2
    fi
  done
fi

exit 0
