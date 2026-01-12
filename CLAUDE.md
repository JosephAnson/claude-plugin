# josephanson-tools - Claude Guide

When reporting information, be extremely concise and sacrifice grammar for concision.
Talk in UK english and produce all documentation in UK english

# Commit Messages
- NO Claude attribution
- NO "Generated with" footers
- Use conventional commits (feat:, fix:, etc.)
- First line under 72 characters

# Code Style
- DO NOT over-engineer
- DO NOT add features I didn't request
- Keep solutions simple and direct
- Prefer boring, readable code

## MCP Tools
- Always create specs from spec mcp server in `.claude/specs/{task-name}`

## Project Context
- @docs/ddd-architecture.md

### TypeScript
- Prefer interfaces over types for objects
- Avoid `any`, use `unknown` for unknown types
- Use `import type` for type-only imports (top-level, not inline)
