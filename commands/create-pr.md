---
description: Create GitHub pull request for current branch
argument-hint: [--base <branch>] [--title <title>]
---

# Create Pull Request (GitHub)

Delegate this task to the `@merge-request-agent` specialised agent.

**Platform**: GitHub (uses `gh` CLI)

## Usage

```bash
/josephanson-tools:create-pr                   # Auto-generate title from commits
/josephanson-tools:create-pr --base develop    # Specify base branch
/josephanson-tools:create-pr --title "My PR"   # Specify title
```

## Requirements

- `gh` CLI installed and authenticated
- GitHub repository

## Process

1. Analyse commits since branching from base
2. Generate PR title from primary commit
3. Create description with summary and changes
4. Create PR via `gh pr create`
5. Return PR URL
