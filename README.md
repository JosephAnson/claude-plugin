# josephanson-tools

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
/plugin install josephanson-tools@josephanson

# Optional: Install external plugins
/plugin install gemini-tools@josephanson
/plugin install headless@josephanson
/plugin install mobile@josephanson
```

## Commands

| Command | Description |
|---------|-------------|
| `/josephanson-tools:commit` | Create atomic conventional commits |
| `/josephanson-tools:create-mr` | Create GitLab merge request |
| `/josephanson-tools:create-pr` | Create GitHub pull request |
| `/josephanson-tools:coderabbit` | Run CodeRabbit CLI code review (requires coderabbit CLI) |
| `/josephanson-tools:resolve-pipeline` | Fix GitLab pipeline failures |
| `/josephanson-tools:resolve-code-review` | Address MR review comments |
| `/josephanson-tools:create-spec` | Create spec from Linear issue |
| `/josephanson-tools:complete-spec` | Implement spec with QA/review |
| `/josephanson-tools:ralph-loop` | Start autonomous development loop |
| `/josephanson-tools:cancel-ralph` | Cancel active Ralph loop |

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
/josephanson-tools:ralph-loop "Build a REST API for todos.
Requirements:
- CRUD endpoints
- Input validation
- Unit tests >80% coverage

Output <promise>COMPLETE</promise> when done." --max-iterations 25 --completion-promise "COMPLETE"
```

The loop continues until:
- Completion promise detected in files/git
- Maximum iterations reached
- Manually cancelled with `/josephanson-tools:cancel-ralph`

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

### skill-creator

Guide for creating Claude Code skills with validation and packaging:

```bash
# Initialise new skill
python skills/skill-creator/scripts/init_skill.py my-skill --path ./skills

# Package skill
python skills/skill-creator/scripts/package_skill.py ./skills/my-skill
```

## Hooks

| Hook | Trigger | Action |
|------|---------|--------|
| `safety-guards.sh` | PreToolUse (Bash) | Block dangerous commands |
| `post-edit-format.sh` | PostToolUse (Edit/Write) | Auto-lint and format |
| `ralph-stop.sh` | Stop | Manage autonomous loop |

## External Plugins (via Marketplace)

This marketplace also provides access to external plugins that stay automatically updated:

### ralph-wiggum (Official Anthropic)
The official Ralph Wiggum autonomous loop plugin from Anthropic.

```bash
/plugin install ralph-wiggum@josephanson
```

### gemini-tools
Visual analysis and UI/UX mockup generation via Gemini 3 Pro.

**Requirements:** `GEMINI_API_KEY`, `gemini-cli`, `pngpaste`

```bash
/plugin install gemini-tools@josephanson
```

### headless
Browser automation for testing and parity checks via Playwright.

```bash
/plugin install headless@josephanson
```

### mobile
Native mobile app testing via Appium for iOS and Android.

**Features:**
- Single app E2E validation
- iOS vs Android cross-platform parity checks
- Old vs new app version migration testing
- Supports native iOS/Android, React Native, Xamarin, Flutter
- Auto-starts Appium server locally (no global install needed)

**Requirements:** iOS Simulator and/or Android Emulator

```bash
/plugin install mobile@josephanson
```

**Usage:**
```bash
/mobile:test        # Single app E2E validation
/mobile:parity      # Cross-platform or version comparison
```

### code-review (Official Anthropic)
Advanced code review using 4 parallel agents with confidence scoring (80+ threshold). Uses CLAUDE.md compliance checking and git blame analysis.

```bash
/plugin install code-review@josephanson
```

**Usage:**
```bash
/code-review              # Review to terminal
/code-review --comment    # Post as PR comment
```

### pr-review-toolkit (Official Anthropic)
Comprehensive PR review with 6 specialised agents:

| Agent | Focus |
|-------|-------|
| comment-analyzer | Comment accuracy and documentation |
| pr-test-analyzer | Test coverage and quality |
| silent-failure-hunter | Error handling and silent failures |
| type-design-analyzer | Type design and invariants |
| code-reviewer | General code quality |
| code-simplifier | Code simplification |

```bash
/plugin install pr-review-toolkit@josephanson
```

**Usage:** Ask natural questions and the right agent triggers automatically:
- "Check if the tests cover all edge cases"
- "Review the error handling in the API client"
- "Simplify this code"

### feature-dev (Official Anthropic)
Structured 7-phase feature development workflow with specialised agents:

| Phase | Description |
|-------|-------------|
| 1. Discovery | Clarify requirements |
| 2. Exploration | Parallel code-explorer agents analyse codebase |
| 3. Questions | Identify edge cases and unknowns |
| 4. Architecture | Multiple code-architect approaches to choose from |
| 5. Implementation | Build with chosen architecture |
| 6. Review | Parallel code-reviewer agents check quality |
| 7. Summary | Document what was built |

```bash
/plugin install feature-dev@josephanson
```

**Usage:**
```bash
/feature-dev Add user authentication with OAuth
/feature-dev Add caching to API endpoints
```

### frontend-design (Official Anthropic)
Creates distinctive, production-grade frontend UIs with bold aesthetics that avoid the generic AI-generated look. Focuses on typography, animations, and intentional design choices.

```bash
/plugin install frontend-design@josephanson
```

**Features:**
- Bold colour palettes and intentional contrast
- Distinctive typography and spacing
- Meaningful animations and micro-interactions
- Avoids cookie-cutter patterns

## Code Review Options

This plugin provides multiple code review approaches:

| Approach | Command | How it works |
|----------|---------|--------------|
| **pr-review-toolkit** | 6 agents | Comprehensive: tests, errors, types, comments, simplification |
| **code-review** | `/code-review` | 4 parallel agents with 80+ confidence threshold |
| **CodeRabbit CLI** | `/josephanson-tools:coderabbit` | External CodeRabbit service via CLI |

**Recommended:** Install the official Anthropic plugins:
```bash
/plugin install code-review@josephanson
/plugin install pr-review-toolkit@josephanson
/plugin install feature-dev@josephanson
/plugin install frontend-design@josephanson
```

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

### External Plugins
- `gemini-cli` + `GEMINI_API_KEY` - Gemini tools
- Playwright - Headless browser

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
