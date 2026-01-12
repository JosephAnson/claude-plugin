---
description: Complete implementation tasks from a spec with QA testing and code review
argument-hint: [spec-name]
---

# Complete Spec

Implement tasks from a specification, verify with QA testing, and run code review.

## Usage

```bash
/ja:complete-spec lstock-469    # With spec name
/ja:complete-spec               # Prompts for selection
```

## Requirements

- spec-workflow MCP server configured (optional, for task tracking)

## Workflow

### 1. Identify the Spec

**If spec name provided:** Use `.claude/specs/$ARGUMENTS`

**If no argument:** List available specs and prompt for selection:
```bash
ls .claude/specs/
```

### 2. Read Spec Tasks

Read tasks from `.claude/specs/{spec-name}/tasks.md` to understand what needs implementing.

### 3. Implement Tasks

Work through each task systematically:

1. Read task description and acceptance criteria
2. Implement the task (create/edit files)
3. Test locally
4. Mark task complete using spec-workflow MCP:

```
mcp__spec-workflow__specs-workflow({
  path: ".claude/specs/{spec-name}",
  action: {
    type: "complete_task",
    taskNumber: "1"  // or ["1", "2", "3"] for batch
  }
})
```

### 4. Run QA Testing

Once all tasks complete, invoke `@qa-tester` agent:

```
@qa-tester Test the {feature-name} implementation
```

The QA tester will:
- Use Playwright to test the feature
- Verify happy paths and edge cases
- Check accessibility
- Report any issues

**Fix issues found before proceeding.**

### 5. Run Code Review

After QA passes, invoke `@code-reviewer` agent:

```
@code-reviewer Review the {feature-name} implementation
```

The code reviewer will:
- Review code quality and patterns
- Check TypeScript types
- Verify project standards
- Provide approval status

**Address any requested changes.**

### 6. Return Summary

Provide concise summary:
- Tasks completed (X of Y)
- QA test results (pass/fail, issues found)
- Code review status (approved/changes requested)
- Location of spec files
- Ready for PR? (yes/no)

## Spec Structure

Each spec directory contains:
- `requirements.md` - What to build
- `design.md` - How to build it
- `tasks.md` - Implementation checklist

## Important Notes

- Always work from specs in `.claude/specs/{spec-name}`
- Mark tasks complete as you finish them
- Don't skip QA or code review steps
- If QA finds issues, fix before code review
- If code review requests changes, address them

## Workflow Summary

```
1. Read tasks → 2. Implement → 3. Mark complete
                     ↓
              4. QA Testing → Fix issues
                     ↓
              5. Code Review → Address feedback
                     ↓
              6. Report status
```
