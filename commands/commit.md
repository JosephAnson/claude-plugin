---
description: Create atomic conventional commits following strict standards
argument-hint: [message]
---

# Commit Command

Delegate this task to the `@commit-agent` specialised agent.

The agent will:
1. Analyse staged and unstaged changes
2. Group changes by type (feat, fix, refactor, test, docs, etc.)
3. Create atomic commits (one logical change per commit)
4. Push all commits after creation

## Usage

```bash
/ja:commit              # Auto-detect and commit all changes
/ja:commit "message"    # Use provided message hint
```

## Features

- Atomic commits (multiple small, focused commits)
- Conventional Commits format
- No AI attribution lines
- Batch push after all commits created
