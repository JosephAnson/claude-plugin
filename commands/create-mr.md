---
description: Create GitLab merge request for current branch
argument-hint: [--target <branch>] [--title <title>]
---

# Create Merge Request (GitLab)

Delegate this task to the `@merge-request-agent` specialised agent.

**Platform**: GitLab (uses `glab` CLI)

## Usage

```bash
/josephanson-tools:create-mr                    # Auto-generate title from commits
/josephanson-tools:create-mr --target develop   # Specify target branch
/josephanson-tools:create-mr --title "My MR"    # Specify title
```

## Requirements

- `glab` CLI installed and authenticated
- GitLab repository

## Process

1. Analyse commits since branching from target
2. Generate MR title from primary commit
3. Create description with summary and changes
4. Create MR via `glab mr create`
5. Return MR URL
