---
description: Cancel the active Ralph Wiggum autonomous loop
argument-hint: ""
---

# Cancel Ralph Loop

Immediately cancel any active Ralph Wiggum autonomous loop.

## Usage

```bash
/josephanson-tools:cancel-ralph
```

## Task Execution

When this command is invoked:

1. **Check for active loop**:
   ```bash
   STATE_DIR="${CLAUDE_PLUGIN_ROOT}/hooks/.ralph-state"
   if [ -f "$STATE_DIR/active" ] && [ "$(cat "$STATE_DIR/active")" = "1" ]; then
     # Loop is active
   else
     echo "No active Ralph loop to cancel."
     exit 0
   fi
   ```

2. **Read current state**:
   ```bash
   ITERATION=$(cat "$STATE_DIR/iteration" 2>/dev/null || echo "0")
   MAX_ITERATIONS=$(cat "$STATE_DIR/max_iterations" 2>/dev/null || echo "0")
   ```

3. **Deactivate loop**:
   ```bash
   echo "0" > "$STATE_DIR/active"
   ```

4. **Report cancellation**:
   ```
   Ralph Loop Cancelled

   Completed iterations: N of M

   The loop has been stopped. The next session exit will proceed normally.

   To review work done:
   - git log --oneline -N
   - git diff HEAD~N

   To resume work manually, start a new loop or continue normally.
   ```

## Effect

- Clears the active loop state
- Next session exit will proceed normally
- Current iteration completes before cancellation takes effect

## When to Use

- Loop is stuck in unproductive iterations
- Task direction needs to change
- Cost concerns
- Manual intervention needed
