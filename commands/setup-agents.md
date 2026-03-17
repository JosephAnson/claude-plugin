---
description: Setup .agents/ directory with MCP config and command prompts via symlinks
---

# Setup Agents

Symlink MCP config and commands (as prompts) into `.agents/` for tools like Codex CLI.

## Usage

```bash
/ja:setup-agents
```

## Workflow

### 1. Resolve Plugin Path

Find this plugin's install location. The plugin directory contains `commands/` and `.mcp.json`.

Look for it at:
- The directory this command file lives in (go up one level from `commands/`)
- `~/.claude/plugins/ja@josephanson/`
- Or ask the user if not found

Store as `PLUGIN_DIR`.

### 2. Symlink MCP Config

```bash
mkdir -p .agents
ln -sf "$PLUGIN_DIR/.mcp.json" ".agents/.mcp.json"
```

### 3. Symlink Commands as Prompts

Codex has no commands concept — make commands available as prompt files:

```bash
mkdir -p .agents/prompts

for cmd in "$PLUGIN_DIR"/commands/*.md; do
  name=$(basename "$cmd")
  ln -sf "$cmd" ".agents/prompts/$name"
done
```

### 4. Report

List all symlinks created and confirm setup is complete.

Remind user to add `.agents/` to `.gitignore` if they don't want to commit the symlinks.

## Notes

- Symlinks are idempotent — safe to run multiple times
- Uses `-sf` flag to overwrite existing symlinks
- Won't overwrite non-symlink files (warns instead)
