#!/bin/bash
# Loads PARA folder summary into Claude's context on session start

PROJECT_DIR="$CLAUDE_PROJECT_DIR"

echo "=== PARA Workspace Snapshot ==="
echo ""

for folder in "00-Inbox" "01-Projects" "02-Areas" "03-Resources" "04-Archives" "05-Goals"; do
  DIR="$PROJECT_DIR/$folder"
  if [ -d "$DIR" ]; then
    COUNT=$(find "$DIR" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')
    echo ":: $folder/ ($COUNT items)"

    # List top-level contents for active folders
    if [ "$COUNT" -gt 0 ] && [ "$COUNT" -le 20 ]; then
      find "$DIR" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort | while read -r item; do
        echo "   - $item"
      done
    fi
  else
    echo "!!  $folder/ (missing — run /setup-para to create)"
  fi
  echo ""
done

# Flag inbox items that need sorting
INBOX_COUNT=$(find "$PROJECT_DIR/00-Inbox" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')
if [ "$INBOX_COUNT" -gt 0 ]; then
  echo ">> $INBOX_COUNT item(s) in Inbox need sorting."
fi

exit 0
