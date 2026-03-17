---
description: "Comprehensive PR review using specialised agents"
argument-hint: "[review-aspects]"
---

# Comprehensive PR Review

Run a comprehensive pull request review using multiple specialised agents, each focusing on a different aspect of code quality.

Uses the `pr-review-toolkit` skill — refer to `skills/pr-review-toolkit/SKILL.md` for full details and `skills/pr-review-toolkit/agents/` for agent specifications.

**Review Aspects (optional):** "$ARGUMENTS"

## Review Workflow

1. **Determine Review Scope**
   - Check git status to identify changed files
   - Parse arguments to see if user requested specific review aspects
   - Default: Run all applicable reviews

2. **Available Review Aspects**

   - **comments** — Analyse code comment accuracy and maintainability
   - **tests** — Review test coverage quality and completeness
   - **errors** — Check error handling for silent failures
   - **types** — Analyse type design and invariants (if new types added)
   - **code** — General code review for project guidelines
   - **simplify** — Simplify code for clarity and maintainability
   - **all** — Run all applicable reviews (default)

3. **Identify Changed Files**
   - Run `git diff --name-only` to see modified files
   - Check if PR already exists: `gh pr view` or `glab mr view`
   - Identify file types and what reviews apply

4. **Determine Applicable Reviews**

   Based on changes:
   - **Always applicable**: code-reviewer (general quality)
   - **If test files changed**: pr-test-analyzer
   - **If comments/docs added**: comment-analyzer
   - **If error handling changed**: silent-failure-hunter
   - **If types added/modified**: type-design-analyzer
   - **After passing review**: code-simplifier (polish and refine)

5. **Launch Review Agents**

   **Sequential approach** (default):
   - Easier to understand and act on
   - Each report is complete before next

   **Parallel approach** (user can request):
   - Launch all agents simultaneously
   - Faster for comprehensive review
   - Results come back together

6. **Aggregate Results**

   After agents complete, summarise:
   - **Critical Issues** (must fix before merge)
   - **Important Issues** (should fix)
   - **Suggestions** (nice to have)
   - **Positive Observations** (what's good)

7. **Provide Action Plan**

   ```markdown
   # PR Review Summary

   ## Critical Issues (X found)
   - [agent-name]: Issue description [file:line]

   ## Important Issues (X found)
   - [agent-name]: Issue description [file:line]

   ## Suggestions (X found)
   - [agent-name]: Suggestion [file:line]

   ## Strengths
   - What's well-done in this PR

   ## Recommended Action
   1. Fix critical issues first
   2. Address important issues
   3. Consider suggestions
   4. Re-run review after fixes
   ```

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

**Before committing:**
1. Write code
2. Run: `/review-pr code errors`
3. Fix any critical issues
4. Commit

**Before creating PR:**
1. Stage all changes
2. Run: `/review-pr all`
3. Address all critical and important issues
4. Re-run specific reviews to verify
5. Create PR

**After PR feedback:**
1. Make requested changes
2. Run targeted reviews based on feedback
3. Verify issues are resolved
4. Push updates
