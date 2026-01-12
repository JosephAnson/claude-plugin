#!/bin/bash

# Safety Guards - PreToolUse hook for Bash commands
# Blocks dangerous operations and warns on risky patterns
#
# Exit codes:
# 0 - Allow command to proceed
# 2 - Block command execution

set -euo pipefail

# Read JSON input from stdin (Claude Code passes tool input this way)
INPUT=$(cat)

# Extract the command from JSON input
# The input format is: {"tool_input": {"command": "..."}}
COMMAND=$(echo "$INPUT" | grep -oP '"command"\s*:\s*"\K[^"]*' 2>/dev/null || echo "")

# If we couldn't extract command, allow (fail open for non-Bash tools)
if [ -z "$COMMAND" ]; then
  exit 0
fi

# ============================================
# BLOCK: Destructive filesystem operations
# ============================================

# Block rm -rf targeting home or root directories
if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|.*-rf)\s'; then
  # Check for dangerous paths: ~, $HOME, /Users/username, /home/username, /
  if echo "$COMMAND" | grep -qE '(~[/\s]|\$HOME|/Users/[^/\s]+[/\s]|/home/[^/\s]+[/\s]|^\s*/\s*$|\s+/\s+)'; then
    echo "BLOCKED: Destructive rm command targeting home or root directory" >&2
    echo "Command: $COMMAND" >&2
    exit 2
  fi

  # Block rm -rf with wildcards at dangerous levels
  if echo "$COMMAND" | grep -qE 'rm\s+-rf\s+/[^/]*\*'; then
    echo "BLOCKED: rm -rf with wildcard at root level" >&2
    exit 2
  fi
fi

# ============================================
# BLOCK: Hardcoded secrets in commands
# ============================================

# Pattern: API_KEY=, SECRET=, TOKEN=, PASSWORD= with 16+ char alphanumeric values
# This catches things like: export API_KEY=abc123... or echo "TOKEN=xyz..."
SECRET_PATTERNS="(API_KEY|SECRET|TOKEN|PASSWORD|PRIVATE_KEY|ACCESS_KEY|SECRET_KEY|AUTH_TOKEN)=['\"]?[a-zA-Z0-9_\-]{16,}"

if echo "$COMMAND" | grep -qE "$SECRET_PATTERNS"; then
  echo "BLOCKED: Potential hardcoded secret detected in command" >&2
  echo "Use environment variables or secrets management instead" >&2
  exit 2
fi

# ============================================
# BLOCK: .env file modifications via shell
# ============================================

# Block direct writes to .env files
if echo "$COMMAND" | grep -qE '(echo|cat|printf|>>|>)\s+.*\.env'; then
  echo "BLOCKED: Attempting to modify .env file via shell" >&2
  echo "Manage secrets through proper secrets management" >&2
  exit 2
fi

# ============================================
# BLOCK: Unsafe git force push
# ============================================

# Block git push --force without --force-with-lease
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*--force(?!-with-lease)'; then
  echo "BLOCKED: git push --force without --force-with-lease" >&2
  echo "Use --force-with-lease for safer force pushes" >&2
  exit 2
fi

# Also catch -f flag
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*\s-f(\s|$)'; then
  echo "BLOCKED: git push -f (force) detected" >&2
  echo "Use --force-with-lease for safer force pushes" >&2
  exit 2
fi

# ============================================
# WARN: Dangerous git operations (not blocked)
# ============================================

# git reset --hard
if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  echo "WARNING: git reset --hard will destroy uncommitted changes" >&2
fi

# git clean -f
if echo "$COMMAND" | grep -qE 'git\s+clean\s+-[a-zA-Z]*f'; then
  echo "WARNING: git clean will permanently delete untracked files" >&2
fi

# ============================================
# WARN: Production keywords
# ============================================

PROD_KEYWORDS="(production|prod\.|prod-|\.prod|PROD_|--production|@production)"

if echo "$COMMAND" | grep -qiE "$PROD_KEYWORDS"; then
  echo "WARNING: Command contains production-related keywords" >&2
  echo "Please verify this is intentional" >&2
fi

# ============================================
# WARN: Database operations
# ============================================

if echo "$COMMAND" | grep -qiE '(DROP\s+TABLE|DROP\s+DATABASE|TRUNCATE|DELETE\s+FROM)'; then
  echo "WARNING: Potentially destructive database operation detected" >&2
fi

# ============================================
# If we get here, command is allowed
# ============================================

exit 0
