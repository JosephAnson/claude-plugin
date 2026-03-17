---
description: Analyse Linear issue and create implementation specification
argument-hint: <linear-issue-url-or-id>
---

# Create Spec

Analyse a Linear issue and create a comprehensive implementation specification.

## Usage

```bash
/ja:create-spec PROJ-123
/ja:create-spec https://linear.app/team/issue/PROJ-123/title
```

## Requirements

- Linear MCP server configured (`mcp__linear-server__*`)
- spec-workflow MCP server configured (`mcp__spec-workflow__*`)

## Workflow

### 1. Gather Requirements

Fetch and analyse the Linear issue:

- Fetch issue details using `mcp__linear-server__get_issue`
- Analyse requirements and acceptance criteria
- Research codebase for related patterns
- Identify technical approach and dependencies

**Requirements analysis:**
- What is being requested?
- What is the expected outcome?
- Are there acceptance criteria?
- What constraints exist?

### 2. Codebase Research

Explore the existing codebase:

Questions to answer:
- How are similar features implemented?
- What patterns are established?
- What utilities/helpers exist?
- What testing patterns are used?

### 3. Technical Design

Create a specification covering:

- **Overview**: Feature summary, goals and non-goals
- **Technical Approach**: Architecture decisions, component breakdown, data flow
- **Implementation Tasks**: Numbered, actionable tasks with acceptance criteria
- **Dependencies**: External, internal, blocking items
- **Risks**: Technical risks with mitigation strategies
- **Testing Strategy**: Unit, integration, manual testing approach

### 4. Create Spec Using spec-workflow MCP

Use `mcp__spec-workflow__specs-workflow` to create specs:

**Initialise spec:**
```
mcp__spec-workflow__specs-workflow({
  path: ".claude/specs/{task-name}",
  action: {
    type: "init",
    featureName: "<feature name>",
    introduction: "<brief description>"
  }
})
```

This creates:
- `requirements.md` - Feature requirements, acceptance criteria, constraints
- `design.md` - Technical approach, architecture, component design
- `tasks.md` - Numbered implementation tasks

### 5. Return Summary

After analysis, provide concise summary:
- Issue title and key requirements
- Technical approach chosen
- Number of tasks created
- Location of spec files
- Next steps for implementation

## Spec Location

Specs are created in `.claude/specs/{task-name}/`

Use task name from Linear issue identifier (e.g., `PROJ-123` → `.claude/specs/proj-123`)

## Fallback (No Linear MCP)

If Linear MCP is not available:
1. Ask user for issue details manually
2. Create spec based on provided requirements
3. Still use spec-workflow MCP if available
