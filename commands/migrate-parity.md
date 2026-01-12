---
description: Iterative migration workflow with parity checks, tests, and code review
argument-hint: "<legacy-url> <new-url> [--max-iterations N]"
---

# Migration Parity Command

Combines Ralph Wiggum loops with headless parity checks for iterative legacy→Vue migration validation.

## Usage

```bash
/ja:migrate-parity <legacy-url> <new-url> [options]
```

**Note**: Pass full URLs including paths - legacy and new paths can differ.

## Arguments

| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `legacy-url` | Yes | - | Full legacy URL (source of truth) |
| `new-url` | Yes | - | Full new Vue URL |
| `--max-iterations` | No | `20` | Ralph loop safety limit |

## Examples

```bash
# Single page comparison (different paths allowed)
/ja:migrate-parity https://legacy.provetcloud.com/4/organization/administration/catalog/item_lists/ http://localhost:5171/4/catalog/management/item-lists
```

## Your Workflow

### 1. Parse Arguments

Extract from `$ARGUMENTS`:
- `legacy-url` (required) - full URL including path
- `new-url` (required) - full URL including path
- `--max-iterations` (default: 20)

### 2. Auto-Detect Projects and Commands

Scan working directory for project directories containing:
- `package.json` (JS/TS project)
- `pyproject.toml` or `requirements.txt` (Python project)

For each detected project, auto-detect test command:
- `pnpm-lock.yaml` exists → `pnpm test`
- `package-lock.json` exists → `npm test`
- `pyproject.toml` exists → `pytest`

For each detected project, auto-detect format command:
- `.pre-commit-config.yaml` exists → `pre-commit run --all-files`
- `pnpm-lock.yaml` exists → `pnpm lint:fix`
- `pyproject.toml` exists → `ruff format`
- else → `npm run lint:fix`

For each detected project, auto-detect typecheck command:
- `tsconfig.json` exists → `pnpm typecheck` or `npm run typecheck`
- `pyproject.toml` with mypy config → `mypy` or `just typecheck`
- Check `package.json` scripts for `typecheck` or `type-check` script

**Important**: Frontend projects often generate types from backend APIs. When backend APIs change, frontend types must be regenerated. Look for:
- `pnpm generate:types` or similar scripts in package.json
- OpenAPI/Swagger type generation scripts
- Run type generation BEFORE typecheck if backend API changed

### 3. Setup Ralph Loop

Create `.claude/ralph-loop.local.md` with this content:

```yaml
---
active: true
iteration: 1
max_iterations: {max-iterations}
completion_promise: "MIGRATION_PARITY_ACHIEVED"
started_at: "{ISO timestamp}"
---

Migration parity check for:
- Legacy: {legacy-url}
- New: {new-url}
- Projects: {projects}
- Test cmds: {test-cmds}
- Format cmds: {format-cmds}
- Typecheck cmds: {typecheck-cmds}

Check parity, fix issues, run typecheck, run tests for all projects, format code.
Output <promise>MIGRATION_PARITY_ACHIEVED</promise> when complete.
```

### 4. Create State Tracking File

Create `.claude/.migrate-parity-state.md`:

```markdown
# Migration Parity State

## Configuration
- Legacy URL: {legacy-url}
- New URL: {new-url}

## Projects
| Project | Test Command | Format Command | Typecheck Command |
|---------|--------------|----------------|-------------------|
{for each project: | {project} | {test-cmd} | {format-cmd} | {typecheck-cmd} |}

## Parity Status
- Status: PENDING
- Last Check: -

## Typecheck
| Project | Status | Last Run |
|---------|--------|----------|
{for each project: | {project} | PENDING | - |}

## Tests
| Project | Status | Last Run |
|---------|--------|----------|
{for each project: | {project} | PENDING | - |}

## Iteration: 1 of {max-iterations}
```

### 5. Each Iteration - Check Parity

Invoke the `/headless:parity` skill to compare the legacy and new URLs:

```bash
/headless:parity {legacy-url} {new-url}
```

Or spawn a `headless:parity-browser` agent via Task tool.

### 6. Each Iteration - Fix Parity Issues

For each FAIL result:
1. Read the parity diff report
2. Identify Vue components needing changes
3. Edit files to match legacy behaviour
4. Update state file with new status

Focus on:
- Visual differences (layout, colours, spacing)
- Functional differences (buttons, forms, navigation)
- Content differences (text, data rendering)

### 7. Each Iteration - Run Typecheck

**Critical for API changes**: When backend API changes, frontend types must be regenerated first.

For frontend projects with API type generation:
```bash
# First regenerate types from backend API (if applicable)
cd {frontend-project-dir} && {type-generation-cmd}  # e.g., pnpm generate:types

# Then run typecheck
cd {frontend-project-dir} && {typecheck-cmd}  # e.g., pnpm typecheck
```

For backend projects:
```bash
cd {backend-project-dir} && {typecheck-cmd}  # e.g., mypy or just typecheck
```

If typecheck fails:
1. Read error output carefully
2. For frontend type errors from API changes:
   - Ensure types are regenerated from latest backend schema
   - Update frontend code to match new API contract
3. For backend type errors:
   - Fix type annotations or code logic
4. Re-run to verify

Update state file with typecheck results for each project.

### 8. Each Iteration - Run Tests

For each project, execute its test command:

```bash
# For each project directory
cd {project-dir} && {test-cmd}
```

If tests fail in any project:
1. Read test output
2. Fix failing tests or code causing failures
3. Re-run to verify

Update state file with test results for each project.

### 9. Each Iteration - Format Code

For each project, execute its format command:

```bash
# For each project directory
cd {project-dir} && {format-cmd}
```

Ensure no lint errors remain in any project.

### 10. Check Completion

Read `.claude/.migrate-parity-state.md`. Check if:
- Parity status = PASS
- ALL projects have typecheck status = PASS
- ALL projects have tests status = PASS

If NOT complete:
- Update iteration count
- Continue to next iteration (Ralph loop handles this)

If COMPLETE:
- Invoke `@code-reviewer` agent for final review
- If review approved, output completion promise

### 11. Final Output

When all conditions met:

```markdown
## Migration Parity Complete

### Parity Check
- Legacy: {legacy-url}
- New: {new-url}
- Status: PASS

### Typecheck Results
| Project | Status | Command |
|---------|--------|---------|
{for each project: | {project} | PASS | {typecheck-cmd} |}

### Test Results
| Project | Status | Command |
|---------|--------|---------|
{for each project: | {project} | PASS | {test-cmd} |}

### Code Review: APPROVED

<promise>MIGRATION_PARITY_ACHIEVED</promise>
```

## Error Handling

| Scenario | Action |
|----------|--------|
| Server not running | Prompt user to start servers |
| URL 404 | Mark as SKIP, warn user |
| Flaky tests | Retry up to 3 times |
| Max iterations reached | Report progress, suggest manual completion |
| Parity check timeout | Retry with increased timeout |
| Project not found | Warn user, skip that project |
| Mixed test results | Continue until all projects pass |
| Typecheck fails | Fix type errors before running tests |
| Frontend types out of sync | Regenerate types from backend API first |
| API type generation fails | Check backend server is running, schema is valid |

## Important Notes

- Legacy UI is ALWAYS source of truth
- Minor CSS differences (cosmetic) may be acceptable
- Critical/major functional differences MUST be fixed
- **Typecheck MUST pass before running tests** - type errors often indicate API contract mismatches
- **Frontend types depend on backend API** - when backend changes, regenerate frontend types first
- Always run tests before declaring completion
- Code review is triggered automatically on completion

## State Files

- `.claude/ralph-loop.local.md` - Ralph loop state (iteration, promise)
- `.claude/.migrate-parity-state.md` - Migration progress tracking
