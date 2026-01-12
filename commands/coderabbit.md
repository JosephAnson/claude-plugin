---
allowed-tools: Bash(coderabbit:*), Read, Edit, Grep, Glob
argument-hint: [review|config|help] [options]
description: Run CodeRabbit AI code review with automatic issue detection and fixing
---

## Overview

CodeRabbit integration for AI-powered code review with automatic issue detection and fixing capabilities.

## Usage

```bash
/josephanson-tools:coderabbit [command] [options]
/josephanson-tools:coderabbit review [--scope <scope>] [--file <path>] [--fix]
/josephanson-tools:coderabbit config
/josephanson-tools:coderabbit help
```

## Commands

### 1. Review (Default)

Analyse code for issues and optionally fix them.

**Options:**
- `--scope <scope>`: Limit review scope
  - `diff`: Only staged/uncommitted changes
  - `branch`: All changes since branching from main
  - `file`: Specific file(s)
  - `all`: Entire codebase (default)
- `--file <path>`: Review specific file(s)
- `--no-fix`: Show issues without fixing (dry-run)
- `--priority <level>`: Focus on specific severity (critical|high|medium|low)

**Examples:**
```bash
/josephanson-tools:coderabbit review --scope diff
/josephanson-tools:coderabbit review --file src/components/
/josephanson-tools:coderabbit review --no-fix --priority high
```

### 2. Config

Check CodeRabbit configuration and authentication.

### 3. Help

Display usage information.

---

## Task Execution

### When command is: `/coderabbit` or `/coderabbit review [args]`

#### Step 1: Gather Context

```bash
git status --short
git branch --show-current
git log --oneline -10
git diff --name-only           # For diff scope
git diff main...HEAD --name-only  # For branch scope
```

#### Step 2: Parse Arguments

Extract scope, target files, fix mode, and priority filter.

#### Step 3: Execute CodeRabbit Analysis

**For `--scope diff`:**
```bash
coderabbit --prompt-only $(git diff --name-only)
```

**For `--scope branch`:**
```bash
coderabbit --prompt-only $(git diff main...HEAD --name-only)
```

**For specific files:**
```bash
coderabbit --prompt-only <file1> <file2>
```

**For all (default):**
```bash
coderabbit --prompt-only <path-or-current-dir>
```

#### Step 4: Analyse Findings

Parse CodeRabbit output for:

1. **Security Vulnerabilities** - Priority: CRITICAL - Always fix
2. **Bugs and Logic Errors** - Priority: HIGH - Always fix
3. **Performance Issues** - Priority: HIGH - Fix if straightforward
4. **Code Quality Issues** - Priority: MEDIUM - Fix if improves maintainability
5. **Style and Conventions** - Priority: LOW - Fix if enforced by project

#### Step 5: Implement Fixes

**If `--no-fix` flag:** Skip to report only

**For each fixable issue:**
1. Read affected file for full context
2. Analyse impact on existing functionality
3. Implement fix using Edit tool
4. Verify fix quality

**For architectural issues:**
- Summarise the problem
- Propose solution
- **DO NOT implement** without explicit user approval

#### Step 6: Run Tests

Detect and run project test suite:

```bash
# Node.js projects
npm test || pnpm test || yarn test

# Python projects
pytest || python -m pytest || python manage.py test

# Other projects - check for test scripts
```

#### Step 7: Generate Report

```
CodeRabbit Review Complete

Scope: [diff|branch|file|all]
Files analysed: X
Issues found: Y
Issues fixed: Z

Breakdown by severity:
- Critical: A (B fixed)
- High: C (D fixed)
- Medium: E (F fixed)
- Low: G (H fixed)

Files modified:
- path/to/file.ts (N issues fixed)

Tests: [PASSED|FAILED]

Next steps:
- Review changes: git diff
- Run full test suite
- Commit: git commit -am "fix: resolve code quality issues"
```

---

### When command is: `/coderabbit config`

1. Check CLI Installation: `coderabbit --version`
2. Check Authentication: `coderabbit auth status`
3. Verify Configuration: Read `.coderabbit.yaml`
4. Test API Connection
5. Generate status report

---

### When command is: `/coderabbit help`

Display usage information in concise format.

---

## Best Practices

**When to Use:**
- Pre-commit checks (catch issues early)
- PR preparation (ensure quality before review)
- Periodic audits (identify technical debt)
- Security reviews (catch vulnerabilities)

**Performance Tips:**
- Fast reviews: `--scope diff --priority critical`
- Balanced reviews: `--scope diff`
- Thorough reviews: `--scope branch`
- Full audits: `--scope all --no-fix`
