---
name: feature-dev
description: Guided feature development with codebase understanding and architecture focus. Use when implementing new features to follow a systematic discovery, exploration, design, and implementation workflow.
---

# Feature Development

Systematic approach to implementing new features: understand the codebase deeply, identify and ask about all underspecified details, design elegant architectures, then implement.

## Core Principles

- **Ask clarifying questions**: Identify all ambiguities, edge cases, and underspecified behaviours. Ask specific, concrete questions rather than making assumptions. Wait for user answers before proceeding.
- **Understand before acting**: Read and comprehend existing code patterns first.
- **Simple and elegant**: Prioritise readable, maintainable, architecturally sound code.
- **Track progress**: Use TodoWrite throughout.

## Phase 1: Discovery

**Goal**: Understand what needs to be built.

1. Create todo list with all phases
2. If feature unclear, ask user for: what problem they're solving, what the feature should do, any constraints or requirements
3. Summarise understanding and confirm with user

## Phase 2: Codebase Exploration

**Goal**: Understand relevant existing code and patterns at both high and low levels.

1. Launch 2-3 code-explorer agents in parallel, each targeting a different aspect:
   - Similar features and their implementation
   - Architecture and abstractions for the feature area
   - UI patterns, testing approaches, or extension points
   - Each agent should return a list of 5-10 key files to read
2. Read all files identified by agents to build deep understanding
3. Present comprehensive summary of findings and patterns

## Phase 3: Clarifying Questions

**Goal**: Fill in gaps and resolve all ambiguities before designing.

**CRITICAL**: Do not skip this phase.

1. Review codebase findings and original feature request
2. Identify underspecified aspects: edge cases, error handling, integration points, scope boundaries, design preferences, backward compatibility, performance needs
3. Present all questions in a clear, organised list
4. Wait for answers before proceeding

## Phase 4: Architecture Design

**Goal**: Design implementation approaches with different trade-offs.

1. Launch 2-3 code-architect agents with different focuses: minimal changes, clean architecture, or pragmatic balance
2. Review approaches and form opinion on best fit
3. Present: brief summary of each approach, trade-offs comparison, your recommendation with reasoning
4. Ask user which approach they prefer

## Phase 5: Implementation

**Goal**: Build the feature.

**Do not start without user approval.**

1. Wait for explicit user approval
2. Read all relevant files identified in previous phases
3. Implement following chosen architecture
4. Follow codebase conventions strictly
5. Update todos as you progress

## Phase 6: Quality Review

**Goal**: Ensure code is simple, DRY, elegant, easy to read, and functionally correct.

1. Launch code-reviewer agents with different focuses: simplicity/DRY/elegance, bugs/functional correctness, project conventions/abstractions
2. Consolidate findings and identify highest severity issues
3. Present findings and ask what user wants to do (fix now, fix later, or proceed as-is)
4. Address issues based on user decision

## Phase 7: Summary

**Goal**: Document what was accomplished.

1. Mark all todos complete
2. Summarise: what was built, key decisions made, files modified, suggested next steps

## Agent Types

Full agent specifications are in the `agents/` folder. Summary:

- **code-explorer** — Traces execution paths, maps architecture layers, documents dependencies. See `agents/code-explorer.md`
- **code-architect** — Designs feature architectures with implementation blueprints. See `agents/code-architect.md`
- **code-reviewer** — Reviews code with confidence-based filtering (>= 80). See `agents/code-reviewer.md`
