---
name: skill-creator
description: Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Claude's capabilities with specialised knowledge, workflows, or tool integrations.
---

# Skill Creator

This skill provides guidance for creating effective skills.

## About Skills

Skills are modular, self-contained packages that extend Claude's capabilities by providing specialised knowledge, workflows, and tools. Think of them as "onboarding guides" for specific domains or tasks—they transform Claude from a general-purpose agent into a specialised agent equipped with procedural knowledge that no model can fully possess.

### What Skills Provide

1. Specialised workflows - Multi-step procedures for specific domains
2. Tool integrations - Instructions for working with specific file formats or APIs
3. Domain expertise - Company-specific knowledge, schemas, business logic
4. Bundled resources - Scripts, references, and assets for complex and repetitive tasks

### Anatomy of a Skill

Every skill consists of a required SKILL.md file and optional bundled resources:

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata (required)
│   │   ├── name: (required)
│   │   └── description: (required)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/          - Executable code (Python/Bash/etc.)
    ├── references/       - Documentation intended to be loaded into context as needed
    └── assets/           - Files used in output (templates, icons, fonts, etc.)
```

#### SKILL.md (required)

**Metadata Quality:** The `name` and `description` in YAML frontmatter determine when Claude will use the skill. Be specific about what the skill does and when to use it. Use the third-person (e.g. "This skill should be used when..." instead of "Use this skill when...").

#### Bundled Resources (optional)

##### Scripts (`scripts/`)

Executable code (Python/Bash/etc.) for tasks that require deterministic reliability or are repeatedly rewritten.

- **When to include**: When the same code is being rewritten repeatedly or deterministic reliability is needed
- **Example**: `scripts/rotate_pdf.py` for PDF rotation tasks
- **Benefits**: Token efficient, deterministic, may be executed without loading into context

##### References (`references/`)

Documentation and reference material intended to be loaded as needed into context to inform Claude's process and thinking.

- **When to include**: For documentation that Claude should reference while working
- **Examples**: `references/api_docs.md` for API specifications
- **Best practice**: If files are large (>10k words), include grep search patterns in SKILL.md

##### Assets (`assets/`)

Files not intended to be loaded into context, but rather used within the output Claude produces.

- **When to include**: When the skill needs files that will be used in the final output
- **Examples**: `assets/logo.png` for brand assets, `assets/template.pptx` for templates

### Progressive Disclosure Design Principle

Skills use a three-level loading system to manage context efficiently:

1. **Metadata (name + description)** - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers (<5k words)
3. **Bundled resources** - As needed by Claude (Unlimited*)

*Unlimited because scripts can be executed without reading into context window.

## Skill Creation Process

To create a skill, follow the "Skill Creation Process" in order.

### Step 1: Understanding the Skill with Concrete Examples

To create an effective skill, clearly understand concrete examples of how the skill will be used. Ask questions like:

- "What functionality should the skill support?"
- "Can you give some examples of how this skill would be used?"
- "What would a user say that should trigger this skill?"

### Step 2: Planning the Reusable Skill Contents

Analyse each example by:
1. Considering how to execute on the example from scratch
2. Identifying what scripts, references, and assets would be helpful

### Step 3: Initialising the Skill

When creating a new skill from scratch, run the `init_skill.py` script:

```bash
scripts/init_skill.py <skill-name> --path <output-directory>
```

The script:
- Creates the skill directory at the specified path
- Generates a SKILL.md template with proper frontmatter and TODO placeholders
- Creates example resource directories: `scripts/`, `references/`, and `assets/`

### Step 4: Edit the Skill

**Writing Style:** Write the entire skill using **imperative/infinitive form** (verb-first instructions), not second person.

To complete SKILL.md, answer:
1. What is the purpose of the skill?
2. When should the skill be used?
3. How should Claude use the skill?

### Step 5: Packaging a Skill

Package into a distributable zip file:

```bash
scripts/package_skill.py <path/to/skill-folder> [output-directory]
```

The packaging script will:
1. **Validate** the skill automatically
2. **Package** the skill if validation passes

### Step 6: Iterate

After testing the skill, iterate based on feedback:
1. Use the skill on real tasks
2. Notice struggles or inefficiencies
3. Update SKILL.md or bundled resources
4. Test again
