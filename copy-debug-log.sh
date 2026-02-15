#!/bin/bash
# Copy debug log from iOS Simulator to project root (run after testing the app)
set -e
CONTAINER=$(xcrun simctl get_app_container booted com.hedaya.app data 2>/dev/null) || true
if [ -z "$CONTAINER" ] || [ ! -d "$CONTAINER" ]; then
  echo "No simulator running or app not installed. Run the app in simulator first."
  exit 1
fi
SRC="$CONTAINER/Documents/hedaya_debug.log"
DEST="$(dirname "$0")/hedaya_debug.log"
if [ -f "$SRC" ]; then
  cp "$SRC" "$DEST"
  echo "Copied log to $DEST"
else
  echo "Log file not found. Run the app and trigger the flow first."
  exit 1
fi
