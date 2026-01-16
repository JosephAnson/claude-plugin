---
description: Run all quality checks before committing
argument-hint: "[--skip-mr]"
---

# Pre-Commit Checks

Run all quality gates before committing: typecheck, tests, formatting, MR comments, and code review.

## Usage

```bash
/ja:pre-commit              # Full check including MR comments
/ja:pre-commit --skip-mr    # Skip MR comment check
```

## Arguments

| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--skip-mr` | No | false | Skip MR comment resolution check |

## Workflow

### 1. Auto-Detect Projects

Scan working directory for project directories containing:
- `package.json` (JS/TS project)
- `pyproject.toml` or `requirements.txt` (Python project)

For each detected project, auto-detect commands:

**Typecheck:**
- `tsconfig.json` exists → `pnpm typecheck` or `npm run typecheck`
- `pyproject.toml` with mypy config → `mypy` or `just typecheck`
- Check `package.json` scripts for `typecheck` or `type-check`

**Tests:**
- `pnpm-lock.yaml` exists → `pnpm test`
- `package-lock.json` exists → `npm test`
- `pyproject.toml` exists → `pytest`

**Format/Lint:**
- `.pre-commit-config.yaml` exists → `pre-commit run --all-files`
- `pnpm-lock.yaml` exists → `pnpm lint:fix`
- `pyproject.toml` exists → `ruff format && ruff check --fix`
- else → `npm run lint:fix`

### 2. Create Checklist

Use TodoWrite to track:

```
- [ ] Run typecheck (all projects)
- [ ] Run tests (all projects)
- [ ] Run formatting/linting (all projects)
- [ ] Check MR comments (if applicable)
- [ ] Run code review
```

### 3. Run Typecheck

For each project:
```bash
cd {project-dir} && {typecheck-cmd}
```

If frontend project has API type generation:
```bash
cd {frontend-project-dir} && {type-generation-cmd}  # e.g., pnpm generate:types
cd {frontend-project-dir} && {typecheck-cmd}
```

**On failure:** Fix type errors before proceeding.

### 4. Run Tests

For each project:
```bash
cd {project-dir} && {test-cmd}
```

**Python projects:** Require 100% test coverage on all changed files.
**On failure:** Fix failing tests or underlying code.

### 5. Run Formatting/Linting

For each project:
```bash
cd {project-dir} && {format-cmd}
```

Stage any auto-fixed files.

### 6. Check MR Comments (unless --skip-mr)

If current branch has an MR:
```bash
glab mr view $(git branch --show-current) -F json
```

If MR exists, fetch unresolved threads:
```bash
glab api "/projects/<project_id>/merge_requests/<iid>/discussions" | \
  jq '[.[] | select(.notes[0].type == "DiffNote") | select(.notes[0].resolvable == true) | select(.notes[0].resolved == false)]'
```

**If unresolved threads exist:**
- List them with file:line and comment summary
- Ask user whether to resolve now or skip

### 7. Run Code Review

Invoke `pr-review-toolkit:code-reviewer` agent on unstaged/staged changes:
```bash
git diff HEAD
```

**On issues found:** Present findings, ask user to confirm fixes or skip.

### 8. Final Report

```markdown
## Pre-Commit Checks Complete

### Typecheck
| Project | Status |
|---------|--------|
{for each: | {project} | PASS/FAIL |}

### Tests
| Project | Status |
|---------|--------|
{for each: | {project} | PASS/FAIL |}

### Formatting
| Project | Status |
|---------|--------|
{for each: | {project} | PASS/FAIL |}

### MR Comments
- Unresolved: {count}
- Status: {CLEAR/PENDING}

### Code Review
- Status: {APPROVED/ISSUES}

---

**Ready to commit:** YES/NO
```

## Error Handling

| Scenario | Action |
|----------|--------|
| No projects detected | Warn user, ask for manual config |
| Typecheck cmd not found | Skip with warning |
| Tests timeout | Retry once, then report |
| No MR for branch | Skip MR check silently |
| glab not installed | Skip MR check with warning |
| Code review finds issues | Present issues, ask user decision |

## Strict Rules

1. Typecheck MUST pass before tests
2. All projects must pass individually
3. Never auto-resolve MR comments
4. Present code review findings before declaring complete
5. User confirms final "ready to commit" status
