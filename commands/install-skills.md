---
description: Install all recommended skills via skills.sh
---

# Setup Skills

Install all recommended Claude Code skills via [skills.sh](https://skills.sh/).

## Instructions

First, present the full list of skills to install and use AskUserQuestion to ask the user if they want to proceed or remove any from the list.

Then run each confirmed command in sequence:

### Individual Skills

```
npx skills add https://nordhealth.design

npx skills add https://github.com/anthropics/skills --skill frontend-design
npx skills add https://github.com/anthropics/skills --skill skill-creator

npx skills add https://github.com/antfu/skills --skill vue
npx skills add https://github.com/antfu/skills --skill vueuse-functions
npx skills add https://github.com/antfu/skills --skill nuxt
npx skills add https://github.com/antfu/skills --skill vue-router-best-practices
npx skills add https://github.com/antfu-collective/eslint-vitest-rule-tester --skill eslint-vitest-rule-tester

npx skills add https://github.com/obra/superpowers --skill using-git-worktrees
npx skills add https://github.com/obra/superpowers --skill subagent-driven-development

npx skills add https://github.com/JosephAnson/claude-plugin --skill api-patterns
npx skills add https://github.com/JosephAnson/claude-plugin --skill chrome-cdp
npx skills add https://github.com/JosephAnson/claude-plugin --skill database
npx skills add https://github.com/JosephAnson/claude-plugin --skill testing-summary
npx skills add https://github.com/JosephAnson/claude-plugin --skill testing
npx skills add https://github.com/JosephAnson/claude-plugin --skill code-simplifier
npx skills add https://github.com/JosephAnson/claude-plugin --skill feature-dev
npx skills add https://github.com/JosephAnson/claude-plugin --skill pr-review-toolkit

npx skills add https://github.com/affaan-m/everything-claude-code --skill api-design
npx skills add https://github.com/noartem/laravel-vue-skills --skill shadcn-vue
npx skills add https://github.com/existential-birds/beagle --skill tailwind-v4
npx skills add https://github.com/harlan-zw/vue-ecosystem-skills --skill tanstack-vue-query-skilld
npx skills add https://github.com/wshobson/agents --skill typescript-advanced-types
npx skills add https://github.com/pproenca/dot-skills --skill zod
```

## Note

After installation, tell the user to restart Claude Code to activate the skills.
