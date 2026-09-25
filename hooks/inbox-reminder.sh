#!/bin/bash
# Reminds about inbox items when Claude stops

INPUT=$(cat)

# Don't nag if this is already a stop-hook continuation
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

INBOX_DIR="$CLAUDE_PROJECT_DIR/00-Inbox"
INBOX_COUNT=$(find "$INBOX_DIR" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')

if [ "$INBOX_COUNT" -gt 5 ]; then
  echo "Reminder: $INBOX_COUNT items in 00-Inbox/ — consider running /process-inbox to sort them." >&2
fi

exit 0
