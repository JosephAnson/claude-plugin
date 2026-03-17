---
description: Install all recommended plugins and marketplaces
---

# Setup Plugins

Install all recommended Claude Code plugins and marketplaces. First, present the full list of plugins to install and use AskUserQuestion to ask the user if they want to proceed or remove any from the list.


## Instructions

Run each of these commands in sequence:

### Marketplaces

```
/plugin marketplace add JosephAnson/claude-plugin
```

### Plugins

```
/plugin install ja@josephanson
/plugin install ralph-loop@claude-plugins-official
/plugin install code-review@claude-plugins-official
/plugin install pr-review-toolkit@claude-plugins-official
/plugin install feature-dev@claude-plugins-official
```

## Note

After installation, tell the user to restart Claude Code to activate the plugins.
