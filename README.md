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

## Overview

Browse `commands/`, `skills/`, and `hooks/` directories for available functionality. Each command/skill contains its own documentation.

## Safety Features

Hooks in `hooks/` provide safety guardrails — blocking dangerous shell commands and auto-formatting edited files.

## Licence

Private - personal use only.
