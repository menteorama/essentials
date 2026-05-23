---
name: optimize
version: 1.0.0
description: |
  Skill router and context optimizer for Claude Code. Analyzes your installed
  skills, maps them to task types, and generates a CLAUDE.md rule that loads
  only the right skills per task. Proven to improve session quality by 50+
  points vs loading everything. Run /optimize to audit and tune your setup.
triggers:
  - optimize my setup
  - skill audit
  - too many skills
  - context optimization
  - which skills should I use
---

# /optimize — Skill Router & Context Optimizer

> Based on Meta-Harness research (Stanford IRIS Lab adaptation). Targeted skill
> loading beats trigger-based activation by +51 points in benchmarks.

## The Problem

Claude Code loads skills via triggers — mention a keyword and a skill activates.
With many skills installed, sessions get bloated with irrelevant context. More
skills ≠ better results. In benchmarks:

| Strategy | Score |
|----------|-------|
| Task-routed (targeted) | **81.0** |
| Minimal (3 skills) | 53.4 |
| Trigger-based (all loaded) | 29.8 |
| Kitchen sink (force all) | 23.3 |

**Loading 3-4 targeted skills per task type beats loading 16 via triggers.**

## What /optimize Does

### Step 1 — Inventory

Scan the user's installed skills:

```bash
ls ~/.claude/skills/*/SKILL.md 2>/dev/null
```

Also check for plugin-installed skills:

```bash
ls ~/.claude/plugins/*/skills/*/SKILL.md 2>/dev/null
```

Count total skills. Read each SKILL.md's `name` and `description` fields.

### Step 2 — Classify

Map each installed skill to one or more task types:

| Task Type | Signal Words in Description |
|-----------|---------------------------|
| build | code, build, develop, implement, create, component, feature |
| debug | debug, fix, investigate, diagnose, error, issue, troubleshoot |
| deploy | deploy, ship, release, publish, CI/CD, infrastructure |
| audit | audit, security, review, scan, vulnerability, compliance |
| design | design, UI, UX, visual, layout, brand, styling, component |
| strategy | strategy, plan, marketing, business, growth, positioning |
| memory | memory, context, knowledge, documentation, notes |

If a skill's description matches multiple types, include it in all matching types.

### Step 3 — Build Routing Table

For each task type, select the top 3-4 most relevant skills. Prioritize:
1. Skills whose description is a strong match (multiple signal words)
2. Skills with narrower scope (specialists > generalists)
3. Safety skills (careful, watchmen) for destructive task types (deploy, build)

### Step 4 — Generate Rule

Output a CLAUDE.md rule block the user can paste:

```markdown
## Rule: Skill Routing
Load skills by task type — don't load everything:

| Task | Skills |
|------|--------|
| build | [skill-a], [skill-b], [skill-c] |
| debug | [skill-d], [skill-e] |
| deploy | [skill-f], [skill-g] |
| audit | [skill-h], [skill-i] |
| design | [skill-j], [skill-k] |
| strategy | [skill-l], [skill-m] |

Always load: [most-general-skill].
Max 4 skills per session.
```

### Step 5 — Report

Print a summary:

```
OPTIMIZE REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Skills installed:    [N]
Task types covered:  [N]/7
Recommended per task: 2-4 (avg [N])
Context reduction:   ~[X]% fewer tokens vs loading all

ACTION: Paste the rule above into your CLAUDE.md
        (usually at ~/.claude/CLAUDE.md)
```

### Step 6 — Warnings

Flag issues:
- **No safety skill**: If no skill handles destructive command protection, recommend installing `careful`
- **Overloaded type**: If a task type has 6+ matching skills, recommend pruning
- **Uncovered type**: If a task type has 0 skills, note the gap
- **Too few skills**: If total < 3, note that routing provides less benefit

## Why This Works

The model (Claude) is frozen. The only variable is **what context gets loaded**.
Loading irrelevant skills wastes the context window on instructions Claude won't
use, displacing the actual code and conversation that matters.

Task routing = right context at the right time = better outcomes.

## References

- Meta-Harness framework: adapted from Stanford IRIS Lab (arxiv 2603.28052)
- Benchmark data: 4 baselines × 30 tasks, validated on 10 held-out tasks
- Production result: Rule 8 deployed to Menteorama Studio CLAUDE.md (2026-05-23)
