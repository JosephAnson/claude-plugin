---
name: pr-review-toolkit
description: Comprehensive PR review using specialised agents for code quality, error handling, test coverage, type design, comment accuracy, and code simplification. Use when reviewing PRs or before committing/merging code.
---

# PR Review Toolkit

Run comprehensive pull request reviews using multiple specialised agents, each focusing on a different aspect of code quality.

## Review Workflow

1. **Determine Scope**: Check `git diff --name-only` for changed files. Parse arguments for specific review aspects.
2. **Launch Agents**: Run applicable review agents (sequentially by default, parallel if requested).
3. **Aggregate Results**: Summarise as Critical Issues → Important Issues → Suggestions → Positive Observations.
4. **Action Plan**: Organised findings with file:line references.

## Available Review Aspects

- **code** — General code review for project guidelines (always applicable)
- **tests** — Test coverage quality and completeness (if test files changed)
- **errors** — Error handling for silent failures (if error handling changed)
- **types** — Type design and invariants (if types added/modified)
- **comments** — Code comment accuracy and maintainability (if comments/docs added)
- **simplify** — Simplify code for clarity and maintainability (after passing review)
- **all** — Run all applicable reviews (default)

## Specialised Agents

Full agent specifications are in the `agents/` folder. Summary:

- **code-reviewer** — Reviews code against project guidelines with confidence-based filtering (>= 80). See `agents/code-reviewer.md`
- **silent-failure-hunter** — Identifies silent failures, inadequate error handling, inappropriate fallbacks. See `agents/silent-failure-hunter.md`
- **pr-test-analyzer** — Analyses behavioural test coverage quality and completeness. See `agents/pr-test-analyzer.md`
- **comment-analyzer** — Verifies comment accuracy, completeness, and long-term value. See `agents/comment-analyzer.md`
- **type-design-analyzer** — Analyses type design for encapsulation and invariant expression. See `agents/type-design-analyzer.md`
- **code-simplifier** — Simplifies code for clarity and maintainability while preserving functionality. See `agents/code-simplifier.md`

## Usage

**Full review (default):**
```
/review-pr
```

**Specific aspects:**
```
/review-pr tests errors
/review-pr comments
/review-pr simplify
```

**Parallel review:**
```
/review-pr all parallel
```

## Workflow Integration

**Before committing**: Run `code` and `errors` reviews, fix critical issues, then commit.

**Before creating PR**: Stage all changes, run `all` reviews, address critical and important issues, verify, then create PR.

**After PR feedback**: Make requested changes, run targeted reviews, verify, push updates.
