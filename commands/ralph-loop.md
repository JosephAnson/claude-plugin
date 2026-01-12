---
description: Start an autonomous development loop (Ralph Wiggum technique)
argument-hint: "<prompt>" --max-iterations <n> --completion-promise "<text>"
---

# Ralph Loop

Start an autonomous development loop that iteratively works on a task until completion.

## Usage

```bash
/josephanson-tools:ralph-loop "<prompt>" --max-iterations <n> --completion-promise "<text>"
```

## Parameters

- `<prompt>`: The task description with clear completion criteria
- `--max-iterations <n>`: Maximum iterations before stopping (required, recommended: 10-50)
- `--completion-promise <text>`: Exact text that signals completion (e.g., "COMPLETE")

## How It Works

1. Claude processes your prompt
2. On exit attempt, the Stop hook intercepts
3. If completion promise not found, prompt is re-fed
4. Loop continues until promise detected or max iterations reached
5. Each iteration sees previous work through files and git history

## Example

```bash
/josephanson-tools:ralph-loop "Build a REST API for todos. Requirements:
- CRUD endpoints for todos
- Input validation
- Unit tests with >80% coverage
- README with API docs

Output <promise>COMPLETE</promise> when done." --max-iterations 25 --completion-promise "COMPLETE"
```

## Task Execution

When this command is invoked:

1. **Parse arguments** from `$ARGUMENTS`:
   - Extract prompt (quoted string)
   - Extract `--max-iterations` value (default: 50)
   - Extract `--completion-promise` value (optional)

2. **Initialise Ralph state**:
   ```bash
   STATE_DIR="${CLAUDE_PLUGIN_ROOT}/hooks/.ralph-state"
   mkdir -p "$STATE_DIR"
   echo "1" > "$STATE_DIR/active"
   echo "$PROMPT" > "$STATE_DIR/prompt"
   echo "0" > "$STATE_DIR/iteration"
   echo "$MAX_ITERATIONS" > "$STATE_DIR/max_iterations"
   echo "$PROMISE" > "$STATE_DIR/promise"
   ```

3. **Confirm loop started**:
   ```
   Ralph Loop Initialised

   Prompt: [first 100 chars]...
   Max iterations: N
   Completion promise: [promise text]

   The loop will continue until:
   - Completion promise is detected in output/files
   - Maximum iterations reached
   - Loop is cancelled with /cancel-ralph

   Starting first iteration...
   ```

4. **Begin working on the prompt**

## Best Practices

### Clear Completion Criteria
Include measurable success criteria in your prompt:
- Tests passing
- Specific features implemented
- Documentation complete

### Self-Correction Instructions
Tell Claude to test and fix:
```
After each change:
1. Run tests
2. If failures, debug and fix
3. Repeat until green
4. Then continue to next task
```

### Safety Net
**Always set `--max-iterations`** - this is your primary safety mechanism.

## When to Use

**Good for:**
- Well-defined tasks with clear success criteria
- Tasks requiring iteration and refinement (getting tests to pass)
- Greenfield projects where you can walk away
- Tasks with automatic verification (tests, linters)

**Not good for:**
- Tasks requiring human judgement or design decisions
- One-shot operations
- Tasks with unclear success criteria
- Production debugging

## Warnings

- Autonomous loops consume tokens rapidly
- 50 iterations on large codebases can cost $50-100+
- Always review changes after loop completes
- Use for well-defined tasks with clear success criteria
