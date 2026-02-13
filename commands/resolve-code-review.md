---
description: Fetch MR code review comments and create resolution plan
argument-hint: "[MR-number]"
---

# Resolve Code Review

**Platform**: GitLab (uses `glab` CLI)

Fetch code review comments from the current branch's MR and create a plan to address them.

## Usage

```bash
/ja:resolve-code-review          # Current branch MR
/ja:resolve-code-review 123      # Specific MR number
```

## Requirements

- `glab` CLI installed and authenticated
- GitLab repository

## Workflow

### 1. Get MR Information

**If MR number provided:** Use that
**Otherwise:** Find MR for current branch:
```bash
glab mr view $(git branch --show-current) -F json
```

### 2. Fetch Review Threads

Use `--paginate` to fetch all pages of results (GitLab defaults to 20 per page):

```bash
glab api --paginate "/projects/<project_id>/merge_requests/<iid>/discussions" | \
  jq '[.[] | select(.notes[0].type == "DiffNote")]'
```

### 3. Parse Review Comments

For each discussion thread:
- Extract comment text
- Get file path and line number
- Check if thread is resolved
- Identify reviewer

### 4. Categorise Comments

Group by type:
- **Required Changes**: Must fix before merge
- **Type Issues**: mypy/static type errors flagged by reviewers or CI
- **Suggestions**: Optional improvements
- **Nitpicks**: Minor stylistic preferences (often prefixed with "nit:" or "nitpick:")
- **Questions**: Need response/clarification

Group by file for efficient resolution.

### 5. Create Resolution Plan

```markdown
## Code Review Resolution Plan

**MR**: #123 - Feature title
**Reviewers**: @reviewer1, @reviewer2
**Unresolved Threads**: X

### Required Changes

#### Thread 1: [filename:line]
**Reviewer**: @name
**Comment**: "Consider using X instead of Y because..."
**Resolution**: Update to use X pattern

#### Thread 2: [filename:line]
**Reviewer**: @name
**Comment**: "Missing null check here"
**Resolution**: Add null check

### Type Issues

#### Thread 3: [filename:line]
**Error**: `Argument 1 to "foo" has incompatible type "str | None"; expected "str"`
**Resolution**: Add None check or update type signature

### Suggestions (Optional)

#### Thread 4: [filename:line]
**Comment**: "This could be simplified"
**Decision**: Will implement / Will skip (reason)

### Nitpicks (Optional)

#### Thread 5: [filename:line]
**Comment**: "nit: prefer const over let here"
**Decision**: Will fix / Will skip (reason)

### Questions

#### Thread 6: [filename:line]
**Question**: "Why did you choose this approach?"
**Response**: [Your response]

---

Implementation order:
1. Fix required changes
2. Fix type issues
3. Address suggestions (if applicable)
4. Fix nitpicks (if applicable)
5. Respond to questions
6. Request re-review
```

### 6. Implement Resolutions (If Approved)

For each resolution:
1. Read affected file
2. Apply fix using Edit
3. Track progress with TodoWrite

After all fixes:
1. Run `/ja:pre-commit --skip-mr` to verify typecheck, tests, and formatting
2. Commit changes
3. Push to update MR
4. Suggest re-requesting review

## Edge Cases

- **No unresolved threads**: Report all resolved
- **Conflicting feedback**: Flag for user decision
- **Outdated comments**: Note if code has changed since comment

## Strict Rules

1. Show full comment context
2. Distinguish required vs optional changes
3. Group by file for efficiency
4. Never auto-resolve without implementing
5. Suggest re-review after addressing feedback
