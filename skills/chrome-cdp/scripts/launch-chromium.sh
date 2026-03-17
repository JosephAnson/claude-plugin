#!/bin/bash
# Launch Playwright's Chromium with remote debugging and persistent profile
# Sessions (cookies, logins) are retained across restarts

CHROMIUM="$HOME/Library/Caches/ms-playwright/chromium-1212/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing"
DATA_DIR="$HOME/.chromium-cdp"
PORT=9222

# If already running, just refresh the port file and exit
if lsof -i :$PORT -sTCP:LISTEN >/dev/null 2>&1; then
  WS_PATH=$(curl -s "http://127.0.0.1:$PORT/json/version" 2>/dev/null | node -e "process.stdin.on('data',d=>{try{const u=new URL(JSON.parse(d).webSocketDebuggerUrl);console.log(u.pathname)}catch{}})")
  if [ -n "$WS_PATH" ]; then
    printf "%s\n%s\n" "$PORT" "$WS_PATH" > "$DATA_DIR/DevToolsActivePort"
  fi
  echo "Chromium already running on port $PORT"
  exit 0
fi

# Remove stale port file before launching
rm -f "$DATA_DIR/DevToolsActivePort"

"$CHROMIUM" \
  --remote-debugging-port=$PORT \
  --no-first-run \
  --no-default-browser-check \
  --user-data-dir="$DATA_DIR" \
  "$@" &

# Wait for DevToolsActivePort to appear, then copy it
for i in $(seq 1 20); do
  sleep 0.5
  # Find the actual port file Chrome creates
  if [ -f "$DATA_DIR/DevToolsActivePort" ]; then
    echo "Chromium ready on port $PORT"
    exit 0
  fi
done

# Fallback: create port file from the known port
WS_PATH=$(curl -s "http://127.0.0.1:$PORT/json/version" 2>/dev/null | node -e "process.stdin.on('data',d=>{try{const u=new URL(JSON.parse(d).webSocketDebuggerUrl);console.log(u.pathname)}catch{}})")
if [ -n "$WS_PATH" ]; then
  printf "%s\n%s\n" "$PORT" "$WS_PATH" > "$DATA_DIR/DevToolsActivePort"
  echo "Chromium ready on port $PORT (port file created manually)"
  exit 0
fi

echo "Failed to start Chromium" >&2
exit 1
