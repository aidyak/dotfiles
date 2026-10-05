#!/bin/bash
# ~/.codex/notify_macos.sh

LAST_MESSAGE=$(echo "$1" | jq -r '.["last-assistant-message"] // "Codex task completed"')

osascript - "$LAST_MESSAGE" <<'APPLESCRIPT'
on run argv
  set lastMessage to item 1 of argv
  display notification lastMessage with title "Codex"
end run
APPLESCRIPT
