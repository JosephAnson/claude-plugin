---
description: Analyse and resolve GitLab pipeline failures for current branch
argument-hint: "[--job <job-name>] [--rerun]"
---

# Resolve Pipeline Workflow

**Platform**: GitLab (uses `glab` CLI)

Analyses failed GitLab pipeline jobs from the current branch's MR and creates an actionable plan to resolve them.

## Usage

```bash
/ja:resolve-pipeline                    # Analyse all failures
/ja:resolve-pipeline --job lint         # Focus on specific job
/ja:resolve-pipeline --rerun            # Retry the pipeline
```

## Requirements

- `glab` CLI installed and authenticated
- GitLab repository with CI/CD

## Execution Mode

**ANALYSIS THEN FIX** - First analyse all failures, present plan for approval, then implement fixes.

## Workflow Phases

### Phase 1: Get Current Branch and MR

1. Get current branch:
   ```bash
   git rev-parse --abbrev-ref HEAD
   ```

2. Find MR for branch:
   ```bash
   glab mr view <branch-name> -F json
   ```

3. Extract MR info (number, title, URL, pipeline status)

### Phase 2: Fetch Pipeline Status

```bash
glab api "/projects/<project_id>/merge_requests/<iid>/pipelines" | head -1
```

Status handling:
- `success`: Exit - no failures to resolve
- `running`: Show current failures, ask to wait or proceed
- `failed`: Continue to Phase 3

### Phase 3: Fetch Failed Jobs

```bash
glab api "/projects/<project_id>/pipelines/<pipeline_id>/jobs?per_page=100"
```

Filter for jobs with `status: failed` and `allow_failure: false`.

### Phase 4: Analyse Job Logs

Fetch logs for each failed job:
```bash
glab api "/projects/<project_id>/jobs/<job_id>/trace" --raw | tail -300
```

Parse for:
- **Test Failures**: "FAILED", "AssertionError", test name
- **Lint Errors**: file:line:col format
- **Type Errors**: mypy/TypeScript patterns
- **Build Errors**: "error:", "Module not found"

### Phase 5: Categorise and Prioritise

1. **Test Failures** - BLOCKING
2. **Lint Errors** - REQUIRED
3. **Type Errors** - REQUIRED
4. **Build Errors** - BLOCKING
5. **Security** - Often ADVISORY (allow_failure)

### Phase 6: Create Resolution Plan

```markdown
## Pipeline Resolution Plan

**MR**: #<number> - <title>
**Pipeline**: <status> (<url>)
**Failed Jobs**: <count>

### Summary
| Category | Count | Blocking |
|----------|-------|----------|
| Test Failures | X | Yes |
| Lint Errors | Y | Yes |

### Priority 1: Test Failures

1. `test_name`
   **File**: path/to/file.py:45
   **Error**: AssertionError...
   **Resolution**: Fix approach

### Implementation Order

1. Fix A
2. Fix B
3. Run local tests
4. Push and verify

Would you like me to implement these fixes?
```

### Phase 7: Implementation (If Approved)

For each fix:
1. Read affected file
2. Apply fix using Edit
3. Track progress with TodoWrite
4. Run local validation after all fixes

## Arguments

### `--job <job-name>`
Focus on specific failed job.

### `--rerun`
Retry the pipeline:
```bash
glab api -X POST "/projects/<project_id>/pipelines/<pipeline_id>/retry"
```

## Edge Cases

- **Pipeline Running**: Show known failures, ask to wait
- **Flaky Tests**: Flag as potentially flaky, suggest `--rerun`
- **Merge Conflicts**: Note conflicts must be resolved first
- **Too Many Errors**: Group by type, suggest fixing in batches

## Local Validation Commands

Detect and run appropriate commands:

**Node.js projects:**
```bash
npm test && npm run lint && npm run type-check
```

**Python projects:**
```bash
pytest && ruff check . && mypy .
```

## Strict Rules

1. Never auto-fix - always get approval first
2. Show full error context
3. Prioritise blocking failures
4. Suggest local validation after fixes
5. Track progress for multi-step fixes
