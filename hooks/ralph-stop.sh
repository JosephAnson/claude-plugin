#!/bin/bash

# Ralph Wiggum Stop Hook
# Intercepts exit attempts to implement autonomous development loop
#
# Exit codes:
# 0 - Allow normal exit
# 2 - Block exit and re-inject prompt (continue loop)

set -uo pipefail

# State directory location
STATE_DIR="${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")}/hooks/.ralph-state"

# ============================================
# Check if Ralph loop is active
# ============================================

if [ ! -d "$STATE_DIR" ] || [ ! -f "$STATE_DIR/active" ]; then
  # No state directory or active file, allow normal exit
  exit 0
fi

ACTIVE=$(cat "$STATE_DIR/active" 2>/dev/null || echo "0")

if [ "$ACTIVE" != "1" ]; then
  # Loop not active, allow normal exit
  exit 0
fi

# ============================================
# Read loop state
# ============================================

PROMPT=$(cat "$STATE_DIR/prompt" 2>/dev/null || echo "")
ITERATION=$(cat "$STATE_DIR/iteration" 2>/dev/null || echo "0")
MAX_ITERATIONS=$(cat "$STATE_DIR/max_iterations" 2>/dev/null || echo "50")
PROMISE=$(cat "$STATE_DIR/promise" 2>/dev/null || echo "")

# ============================================
# Increment iteration counter
# ============================================

ITERATION=$((ITERATION + 1))
echo "$ITERATION" > "$STATE_DIR/iteration"

# ============================================
# Check max iterations limit
# ============================================

if [ "$ITERATION" -ge "$MAX_ITERATIONS" ]; then
  echo ""
  echo "======================================"
  echo "Ralph Loop: MAXIMUM ITERATIONS REACHED"
  echo "======================================"
  echo "Completed $MAX_ITERATIONS iterations"
  echo "Loop is now complete. Allowing exit."
  echo ""

  # Deactivate loop
  echo "0" > "$STATE_DIR/active"
  exit 0
fi

# ============================================
# Check for completion promise in recent work
# ============================================

if [ -n "$PROMISE" ]; then
  # Check git diff from last commit
  if git diff HEAD~1 2>/dev/null | grep -qF "$PROMISE"; then
    echo ""
    echo "======================================"
    echo "Ralph Loop: COMPLETION PROMISE FOUND!"
    echo "======================================"
    echo "Detected: $PROMISE"
    echo "Loop completed successfully after $ITERATION iterations."
    echo ""

    # Deactivate loop
    echo "0" > "$STATE_DIR/active"
    exit 0
  fi

  # Also check staged changes
  if git diff --staged 2>/dev/null | grep -qF "$PROMISE"; then
    echo ""
    echo "======================================"
    echo "Ralph Loop: COMPLETION PROMISE FOUND!"
    echo "======================================"
    echo "Detected in staged changes: $PROMISE"
    echo "Loop completed successfully after $ITERATION iterations."
    echo ""

    # Deactivate loop
    echo "0" > "$STATE_DIR/active"
    exit 0
  fi

  # Check recent files for promise
  if grep -rq "$PROMISE" . --include="*.md" --include="*.txt" 2>/dev/null | head -1 | grep -q .; then
    echo ""
    echo "======================================"
    echo "Ralph Loop: COMPLETION PROMISE FOUND!"
    echo "======================================"
    echo "Detected in files: $PROMISE"
    echo "Loop completed successfully after $ITERATION iterations."
    echo ""

    # Deactivate loop
    echo "0" > "$STATE_DIR/active"
    exit 0
  fi
fi

# ============================================
# Re-inject prompt (block exit, continue loop)
# ============================================

echo ""
echo "======================================"
echo "Ralph Loop: Iteration $ITERATION of $MAX_ITERATIONS"
echo "======================================"
echo ""
echo "Completion promise not yet detected. Continuing loop..."
echo ""
echo "--- RALPH LOOP PROMPT ---"
echo ""
echo "$PROMPT"
echo ""
echo "--- END PROMPT ---"
echo ""

# Exit code 2 blocks the stop and re-feeds prompt
exit 2
