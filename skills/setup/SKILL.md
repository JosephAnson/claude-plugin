---
name: setup
description: Install all recommended plugins and marketplaces. Use this when the user asks to setup plugins, install recommended plugins, or configure a new machine with all plugins.
---

# Setup Plugins

Display the commands needed to install all recommended Claude Code plugins.

**Note**: These commands must be run in your terminal, not through Claude's Bash tool (the `claude` CLI isn't available in that context).

## Commands to Run

### 1. Add Marketplaces

```bash
# Install marketplace
claude plugin marketplace add JosephAnson/claude-plugin
claude plugin marketplace add anthropics/claude-code
claude plugin marketplace add paddo/claude-tools

# Your custom plugin
claude plugin install ja@josephanson

# Anthropic plugins (from claude-code-plugins marketplace)
claude plugin install ralph-wiggum@claude-code-plugins
claude plugin install code-review@claude-code-plugins
claude plugin install pr-review-toolkit@claude-code-plugins
claude plugin install feature-dev@claude-code-plugins
claude plugin install frontend-design@claude-code-plugins

## Pando plugins
claude plugin install gemini-tools@paddo-tools
claude plugin install headless@paddo-tools
claude plugin install mobile@paddo-tools
```
