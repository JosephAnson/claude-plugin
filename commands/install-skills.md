---
description: Install all recommended skills via skills.sh
---

# Setup Skills

Install all recommended Claude Code skills via [skills.sh](https://skills.sh/).

## Instructions

First, present the full list of skills to install and use AskUserQuestion to ask the user if they want to proceed or remove any from the list.

Then run each confirmed command in sequence. Use `-y -g` flags to auto-confirm and install globally (user-level, not per-project):

### Individual Skills

```
npx skills add https://nordhealth.design -y -g

npx skills add pbakaus/impeccable -y -g
npx skills add https://github.com/anthropics/skills --skill skill-creator -y -g

npx skills add https://github.com/antfu/skills --skill vue -y -g
npx skills add https://github.com/antfu/skills --skill vueuse-functions -y -g
npx skills add https://github.com/antfu/skills --skill nuxt -y -g
npx skills add https://github.com/antfu/skills --skill vue-router-best-practices -y -g
npx skills add https://github.com/antfu-collective/eslint-vitest-rule-tester --skill eslint-vitest-rule-tester -y -g

npx skills add https://github.com/obra/superpowers --skill using-git-worktrees -y -g
npx skills add https://github.com/obra/superpowers --skill subagent-driven-development -y -g

npx skills add https://github.com/JosephAnson/claude-plugin --skill api-patterns -y -g
npx skills add https://github.com/JosephAnson/claude-plugin --skill chrome-cdp -y -g
npx skills add https://github.com/JosephAnson/claude-plugin --skill code-simplifier -y -g
npx skills add https://github.com/JosephAnson/claude-plugin --skill database -y -g
npx skills add https://github.com/JosephAnson/claude-plugin --skill team-conventions -y -g
npx skills add https://github.com/JosephAnson/claude-plugin --skill testing-summary -y -g
npx skills add https://github.com/JosephAnson/claude-plugin --skill testing -y -g
npx skills add https://github.com/JosephAnson/claude-plugin --skill feature-dev -y -g
npx skills add https://github.com/JosephAnson/claude-plugin --skill pr-review-toolkit -y -g

npx skills add https://github.com/affaan-m/everything-claude-code --skill api-design -y -g
npx skills add https://github.com/noartem/laravel-vue-skills --skill shadcn-vue -y -g
npx skills add https://github.com/existential-birds/beagle --skill tailwind-v4 -y -g
npx skills add https://github.com/harlan-zw/vue-ecosystem-skills --skill tanstack-vue-query-skilld -y -g
npx skills add https://github.com/wshobson/agents --skill typescript-advanced-types -y -g
npx skills add https://github.com/pproenca/dot-skills --skill zod -y -g
```

## Note

After installation, tell the user to restart Claude Code to activate the skills.
