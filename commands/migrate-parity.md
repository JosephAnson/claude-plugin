---
description: Iterative migration workflow with parity checks, tests, and code review
argument-hint: "<legacy-url> <new-url> [--pages page1,page2] [--video] [--max-iterations N]"
---

# Migration Parity Command

Combines Ralph Wiggum loops with Claude's Chrome browser automation for iterative legacy→Vue migration validation.

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
| `--pages` | No | - | Comma-separated additional pages/paths to test |
| `--video` | No | `false` | Enable GIF recording for temporal bugs (flickering, animations) |
| `--max-iterations` | No | `20` | Ralph loop safety limit |

## Prerequisites

- Chrome browser with Claude in Chrome extension installed
- Both legacy and new applications accessible (servers running)
- Chrome extension MCP server configured in Claude Code
- ImageMagick installed for screenshot comparison (`brew install imagemagick` or `apt-get install imagemagick`)

## Examples

```bash
# Single page comparison (different paths allowed)
/ja:migrate-parity https://legacy.provetcloud.com/4/organization/administration/catalog/item_lists/ http://localhost:5171/4/catalog/management/item-lists

# Multiple pages with video recording
/ja:migrate-parity https://legacy.example.com/ http://localhost:3000/ --pages /about,/products,/contact --video

# Full site comparison with increased iterations
/ja:migrate-parity https://legacy.example.com/ http://localhost:3000/ --pages /dashboard,/settings,/profile --max-iterations 30
```

## Your Workflow

### 1. Parse Arguments

Extract from `$ARGUMENTS`:
- `legacy-url` (required) - full URL including path
- `new-url` (required) - full URL including path
- `--pages` (optional) - comma-separated paths (e.g., "/about,/products,/contact")
- `--video` (optional) - enable GIF recording for each page comparison
- `--max-iterations` (default: 20)

Build page list:
- Start with main URLs: `[{legacy: legacy-url, new: new-url}]`
- If `--pages` provided, add each: `[{legacy: legacy-base + page, new: new-base + page}]`

### 2. Verify Prerequisites

Before proceeding, verify required tools are installed:

```bash
# Check ImageMagick
which compare || echo "ERROR: ImageMagick not installed. Run: brew install imagemagick"

# Check Chrome extension (will be verified when first tool is called)
```

### 3. Auto-Detect Projects and Commands

Scan working directory for project directories containing:
- `package.json` (JS/TS project)
- `pyproject.toml` or `requirements.txt` (Python project)

#### 3.1. Test Commands

For each detected project, auto-detect test command:
- `pnpm-lock.yaml` exists → `pnpm test`
- `package-lock.json` exists → `npm test`
- `pyproject.toml` exists → `pytest`

#### 3.2. Format Commands

For each detected project, auto-detect format command:
- `.pre-commit-config.yaml` exists → `pre-commit run --all-files`
- `pnpm-lock.yaml` exists → `pnpm lint:fix`
- `pyproject.toml` exists → `ruff format`
- else → `npm run lint:fix`

#### 3.3. Typecheck Commands

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
- Legacy Base URL: {legacy-url}
- New Base URL: {new-url}
- Video Recording: {enabled/disabled}
- Pages to Test: {count}

## Projects
| Project | Test Command | Format Command | Typecheck Command |
|---------|--------------|----------------|-------------------|
{for each project: | {project} | {test-cmd} | {format-cmd} | {typecheck-cmd} |}

## Parity Status by Page
| Page | Status | Similarity | Critical | Major | Minor | Diff Image | Last Check |
|------|--------|------------|----------|-------|-------|------------|------------|
| {page-1} | PENDING | - | 0 | 0 | 0 | - | - |
| {page-2} | PENDING | - | 0 | 0 | 0 | - | - |

## Overall Parity Health
- Status: PENDING
- Total Pages: {count}
- Pages with CRITICAL issues: 0
- Pages with MAJOR issues: 0
- Pages with MINOR issues only: 0
- Pages with no issues: 0

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

Use Claude's Chrome browser automation to compare legacy and new URLs.

#### 5.1. Setup Browser Session

1. Get browser tab context:
   ```
   mcp__claude-in-chrome__tabs_context_mcp with createIfEmpty: true
   ```

2. Create a new tab for this comparison:
   ```
   mcp__claude-in-chrome__tabs_create_mcp
   ```

3. If `--video` flag enabled, start GIF recording:
   ```
   mcp__claude-in-chrome__gif_creator with action: "start_recording"
   ```

#### 5.2. Compare Each Page

For each page in the page list (main URL + any `--pages`):

1. Navigate to legacy URL and capture state:
   ```
   mcp__claude-in-chrome__navigate to {legacy-url}
   mcp__claude-in-chrome__wait_for with time: 2 (let page fully load)
   mcp__claude-in-chrome__snapshot (save to .claude/parity-{page-slug}-legacy-snapshot.md)
   mcp__claude-in-chrome__take_screenshot (save as .claude/parity-{page-slug}-legacy.png)
   ```

2. Scroll and capture additional content (if page has scroll):
   ```
   mcp__claude-in-chrome__computer with action: "scroll", scroll_direction: "down"
   mcp__claude-in-chrome__take_screenshot (save as .claude/parity-{page-slug}-legacy-scrolled.png)
   ```

3. Navigate to new URL and capture state:
   ```
   mcp__claude-in-chrome__navigate to {new-url}
   mcp__claude-in-chrome__wait_for with time: 2 (let page fully load)
   mcp__claude-in-chrome__snapshot (save to .claude/parity-{page-slug}-new-snapshot.md)
   mcp__claude-in-chrome__take_screenshot (save as .claude/parity-{page-slug}-new.png)
   ```

4. Scroll and capture additional content (if page has scroll):
   ```
   mcp__claude-in-chrome__computer with action: "scroll", scroll_direction: "down"
   mcp__claude-in-chrome__take_screenshot (save as .claude/parity-{page-slug}-new-scrolled.png)
   ```

5. If `--video` enabled, stop and export recording:
   ```
   mcp__claude-in-chrome__gif_creator with action: "stop_recording"
   mcp__claude-in-chrome__gif_creator with action: "export", download: true, filename: "parity-{page-slug}.gif"
   ```

#### 5.3. Analyze Differences

For each page comparison:

1. **Automated Screenshot Comparison** (initial viewport):
   ```bash
   compare -metric RMSE -fuzz 5% \
     .claude/parity-{page-slug}-legacy.png \
     .claude/parity-{page-slug}-new.png \
     .claude/parity-{page-slug}-diff.png 2>&1 | tee .claude/parity-{page-slug}-score.txt
   ```
   - Captures RMSE (Root Mean Square Error) score
   - `-fuzz 5%` tolerates minor anti-aliasing/font rendering differences
   - Generates diff image highlighting differences in red

2. **Automated Screenshot Comparison** (scrolled state):
   ```bash
   compare -metric RMSE -fuzz 5% \
     .claude/parity-{page-slug}-legacy-scrolled.png \
     .claude/parity-{page-slug}-new-scrolled.png \
     .claude/parity-{page-slug}-diff-scrolled.png 2>&1
   ```

3. **Parse Similarity Score**:
   - Extract RMSE score from output
   - Lower score = more similar (0 = identical)
   - Calculate similarity percentage: `100 - (RMSE / max_possible_error * 100)`
   - Typical thresholds:
     - ≥98% similarity: PASS (minor cosmetic differences)
     - 95-97% similarity: MINOR issues (review diff image)
     - 90-94% similarity: MAJOR issues (review diff image carefully)
     - <90% similarity: CRITICAL issues (significant visual differences)

4. **Manual Review** (if needed):
   - Read both snapshot files
   - Compare accessibility trees for structural differences
   - Review diff images to classify issues
   - Review GIF recording if available for temporal issues

5. **Document Results** in `.claude/.migrate-parity-state.md`:
   - Similarity score for each page
   - Issue classification (CRITICAL/MAJOR/MINOR)
   - Path to diff image for review

#### 5.4. Classify Differences by Severity

Combine automated similarity scores with manual review:

**Automated Classification (from similarity score):**
- **≥98% similarity**: Auto-classify as PASS with possible MINOR cosmetic differences
- **95-97% similarity**: Flag for manual review, likely MINOR issues
- **90-94% similarity**: Flag for manual review, likely MAJOR issues
- **<90% similarity**: Flag for manual review, likely CRITICAL issues

**Manual Classification Criteria** (review diff image + accessibility tree):
- **CRITICAL**: Missing functionality, broken interactions, data not rendering, error states, wrong content
- **MAJOR**: Wrong layout, incorrect styling, navigation issues, significant alignment problems, color scheme differences
- **MINOR**: Small cosmetic differences (acceptable, e.g., slightly different padding, font smoothing, shadows)

**Final Decision:**
- If automated score suggests PASS (≥98%), accept unless manual review finds functional issues
- If automated score flags issues (<98%), use diff image + accessibility tree to classify severity
- Prioritize functional correctness over pixel-perfect matching

#### 5.5. Overall Health Assessment

After all pages tested, calculate migration health:
- Total pages tested: X
- Pages with CRITICAL issues: Y
- Pages with MAJOR issues: Z
- Pages with MINOR issues only: W
- Pages with no issues: V

Migration health: `PASS` if no CRITICAL/MAJOR issues, otherwise `FAIL`

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

### 10. Pre-Commit Verification

Before declaring complete, run `/ja:pre-commit --skip-mr` to ensure all quality gates pass.

### 11. Check Completion

Read `.claude/.migrate-parity-state.md`. Check if:
- Overall parity health = PASS (no CRITICAL or MAJOR issues)
- ALL pages have been tested
- ALL projects have typecheck status = PASS
- ALL projects have tests status = PASS

If NOT complete:
- Update iteration count in state file
- Continue to next iteration (Ralph loop handles this)

If COMPLETE:
- Invoke `pr-review-toolkit:code-reviewer` agent for final review
- If review approved, output completion promise

### 12. Final Output

When all conditions met:

```markdown
## Migration Parity Complete

### Overall Health Assessment
- Status: PASS
- Total Pages Tested: {count}
- Pages with CRITICAL issues: 0
- Pages with MAJOR issues: 0
- Pages with MINOR issues only: {count}
- Pages with no issues: {count}

### Parity Results by Page
| Page | Status | Similarity | Critical | Major | Minor | Diff Image |
|------|--------|------------|----------|-------|-------|------------|
| {page-1} | PASS | 98.7% | 0 | 0 | 2 | .claude/parity-{page-1}-diff.png |
| {page-2} | PASS | 99.2% | 0 | 0 | 0 | .claude/parity-{page-2}-diff.png |

### Typecheck Results
| Project | Status | Command |
|---------|--------|---------|
{for each project: | {project} | PASS | {typecheck-cmd} |}

### Test Results
| Project | Status | Command |
|---------|--------|---------|
{for each project: | {project} | PASS | {test-cmd} |}

### Code Review: APPROVED

### Artifacts Generated
- Accessibility snapshots: `.claude/parity-*-snapshot.md`
- Screenshots: `.claude/parity-*.png`
- Diff images: `.claude/parity-*-diff.png` (visual difference highlights)
- Similarity scores: `.claude/parity-*-score.txt`
{if --video: - GIF recordings: `parity-*.gif` (in downloads)}

**Review Tip**: Open diff images to see exact visual differences highlighted in red.

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
| Chrome extension not available | Prompt user to install Claude in Chrome extension |
| Chrome tab context lost | Re-establish tab context with tabs_context_mcp |
| Screenshot/snapshot capture fails | Retry up to 3 times, report error if persistent |
| Browser navigation timeout | Increase wait time, check if page is loading |
| ImageMagick not installed | Prompt user to install: `brew install imagemagick` or `apt-get install imagemagick` |
| ImageMagick compare fails | Check screenshot files exist, retry with different fuzz tolerance |
| Screenshots different dimensions | ImageMagick handles this, but warn about viewport size differences |

## Important Notes

- Legacy UI is ALWAYS source of truth
- Minor CSS differences (cosmetic) may be acceptable
- Critical/major functional differences MUST be fixed
- **Typecheck MUST pass before running tests** - type errors often indicate API contract mismatches
- **Frontend types depend on backend API** - when backend changes, regenerate frontend types first
- Always run tests before declaring completion
- Code review is triggered automatically on completion
- **Browser automation**: Uses Claude in Chrome for visual and structural comparison
- **Snapshot files** (.md) provide accessibility tree for structural analysis
- **Screenshots** (.png) provide visual comparison for layout/styling
- **Automated comparison**: ImageMagick compares screenshots and generates diff images
- **Similarity thresholds**: ≥98% auto-pass, 95-97% minor, 90-94% major, <90% critical
- **Diff images** highlight visual differences in red - review these for manual classification
- User should review critical differences in browser before accepting parity

## State Files

- `.claude/ralph-loop.local.md` - Ralph loop state (iteration, promise)
- `.claude/.migrate-parity-state.md` - Migration progress tracking

### Per-Page Artifacts

For each page tested, the following files are generated:

**Accessibility Trees:**
- `.claude/parity-{page-slug}-legacy-snapshot.md` - Legacy page accessibility tree
- `.claude/parity-{page-slug}-new-snapshot.md` - New page accessibility tree

**Screenshots:**
- `.claude/parity-{page-slug}-legacy.png` - Legacy page screenshot (initial viewport)
- `.claude/parity-{page-slug}-new.png` - New page screenshot (initial viewport)
- `.claude/parity-{page-slug}-legacy-scrolled.png` - Legacy page screenshot (scrolled)
- `.claude/parity-{page-slug}-new-scrolled.png` - New page screenshot (scrolled)

**Comparison Results:**
- `.claude/parity-{page-slug}-diff.png` - Visual diff image (initial viewport, differences highlighted in red)
- `.claude/parity-{page-slug}-diff-scrolled.png` - Visual diff image (scrolled state)
- `.claude/parity-{page-slug}-score.txt` - RMSE similarity score

**Video (if `--video` enabled):**
- `parity-{page-slug}.gif` - GIF recording of comparison (saved to downloads)
