# claude-plugin

Personal development productivity tools for Claude Code with safety guardrails, workflow automation, and autonomous loops.

## Installation

### Local Development

```bash
claude --plugin-dir ~/i/josephanson-tools
```

### From GitHub Repository

```bash
# Add marketplace
/plugin marketplace add JosephAnson/claude-plugin

# Install core plugin
/plugin install ja@josephanson
```

### Quick Setup (All Plugins)

After installing the core plugin, run:

```
/ja:plugin-setup
```

This installs all recommended marketplaces and plugins in one command. Restart Claude Code after installation.

## Commands

| Command | Description |
|---------|-------------|
| `/ja:commit` | Create atomic conventional commits |
| `/ja:create-mr` | Create GitLab merge request |
| `/ja:create-pr` | Create GitHub pull request |
| `/ja:coderabbit` | Run CodeRabbit CLI code review (requires coderabbit CLI) |
| `/ja:resolve-pipeline` | Fix GitLab pipeline failures |
| `/ja:resolve-code-review` | Address MR review comments |
| `/ja:create-spec` | Create spec from Linear issue |
| `/ja:complete-spec` | Implement spec with QA/review |
| `/ja:migrate-parity` | Iterative migration validation with parity checks, tests, and code review |
| `/ja:ralph-loop` | Start autonomous development loop |
| `/ja:cancel-ralph` | Cancel active Ralph loop |

## Safety Features

This plugin includes comprehensive safety guardrails:

### Blocked Operations
- `rm -rf` targeting home (`~`) or root (`/`) directories
- Hardcoded secrets (API_KEY, TOKEN, PASSWORD patterns 16+ chars)
- Modifications to `.env` files via shell
- `git push --force` without `--force-with-lease`

### Warnings
- Commands containing production keywords
- `git reset --hard` (destructive)
- `git clean` (deletes untracked files)
- Destructive database operations

## Ralph Wiggum Autonomous Loops

Implements the Ralph Wiggum technique for iterative AI development:

```bash
/ja:ralph-loop "Build a REST API for todos.
Requirements:
- CRUD endpoints
- Input validation
- Unit tests >80% coverage

Output <promise>COMPLETE</promise> when done." --max-iterations 25 --completion-promise "COMPLETE"
```

The loop continues until:
- Completion promise detected in files/git
- Maximum iterations reached
- Manually cancelled with `/ja:cancel-ralph`

**Always set `--max-iterations` as your safety net.**

## Agents

| Agent | Description |
|-------|-------------|
| `@commit-agent` | Atomic conventional commits |
| `@merge-request-agent` | MR/PR creation (GitLab/GitHub) |
| `@code-reviewer` | Code quality review |
| `@technical-analyst` | Requirements analysis |
| `@qa-tester` | Playwright-based QA testing |

## Skills

| Skill | Description |
|-------|-------------|
| `skill-creator` | Guide for creating Claude Code skills with validation and packaging |
| `testing-summary` | Generate QA testing documentation from Linear issues and git commits |
| `tanstack-query-basics` | TanStack Query fundamentals: useQuery, useMutation, cache management |
| `tanstack-query-advanced` | Advanced patterns: optimistic updates, infinite queries, prefetching |
| `tanstack-query-integration` | Integration with VeeValidate forms and TanStack Table |

### skill-creator

```bash
# Initialise new skill
python skills/skill-creator/scripts/init_skill.py my-skill --path ./skills

# Package skill
python skills/skill-creator/scripts/package_skill.py ./skills/my-skill
```

### testing-summary

Generate structured testing documentation for QA handover:

```
"Create test instructions for LSTOCK-469"
"Generate testing summary for the last commit"
```

## Hooks

| Hook | Trigger | Action |
|------|---------|--------|
| `safety-guards.sh` | PreToolUse (Bash) | Block dangerous commands |
| `post-edit-format.sh` | PostToolUse (Edit/Write) | Auto-lint and format |
| `ralph-stop.sh` | Stop | Manage autonomous loop |

## MCP Servers

This plugin includes pre-configured MCP servers:

| Server | Type | Purpose |
|--------|------|---------|
| playwright | stdio | Browser automation and testing |
| spec-workflow | stdio | Spec creation and task management |
| linear-server | SSE | Linear issue tracking integration |
| context7 | stdio | Up-to-date library documentation |
| figma | HTTP | Figma design integration |

## Requirements

### Core Plugin
- Claude Code
- Git

### Optional (for specific commands)
- `glab` CLI - GitLab commands
- `gh` CLI - GitHub commands
- `coderabbit` CLI - Code review
- Linear MCP server - Spec creation
- spec-workflow MCP server - Task management

## Directory Structure

```
josephanson-tools/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── .mcp.json
├── commands/
│   ├── commit.md
│   ├── create-mr.md
│   ├── create-pr.md
│   ├── coderabbit.md
│   ├── resolve-pipeline.md
│   ├── resolve-code-review.md
│   ├── create-spec.md
│   ├── complete-spec.md
│   ├── ralph-loop.md
│   └── cancel-ralph.md
├── agents/
│   ├── commit-agent.md
│   ├── merge-request-agent.md
│   ├── code-reviewer.md
│   ├── technical-analyst.md
│   └── qa-tester.md
├── skills/
│   └── skill-creator/
├── hooks/
│   ├── hooks.json
│   ├── safety-guards.sh
│   ├── ralph-stop.sh
│   └── post-edit-format.sh
└── README.md
```

## Licence

Private - personal use only.
