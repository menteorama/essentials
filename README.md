# Menteorama Essentials

**6 free skills for Claude Code.** Safety guardrails, structured debugging, product stress-testing, skill optimization, code principles, and AI co-creation philosophy.

Built by [Menteorama Studio](https://studio.menteorama.co) — an AI integration studio that ships with Claude Code every day.

## Install

```bash
claude plugin marketplace add menteorama/essentials --sparse .claude-plugin
claude plugin install menteorama-essentials@menteorama-essentials
```

Two commands. Six skills, ready to use.

## What's Inside

### `/careful` — Safety Guardrails (v2.0)

Two hooks that protect you from three categories of disaster:

**Command protection** — Catches `rm -rf`, `DROP TABLE`, `git push --force`, `git reset --hard`, `git clean -f`, `curl | bash`, `chmod 777`, accidental `npm publish`, and more. Allows safe deletions (node_modules, .next, dist) automatically.

**File protection** — Warns before editing `.env` files, SSH keys, certificates, credentials, `.git/` internals, and anything in `secrets/` directories.

**Secrets detection** — Scans both commands and file content for AWS keys, GitHub tokens, API keys (sk-*), Slack tokens, private key blocks, and database connection strings with embedded passwords.

**How it works:** Two PreToolUse hooks — one for Bash commands, one for Write/Edit operations. No config needed — they just work.

### `/investigate` — Root Cause Debugging

A Staff Debugger protocol. Four phases: Investigate, Analyze, Hypothesize, Implement. The iron law: **no fixes without root cause.** Stops Claude from applying band-aids and forces it to actually understand what's broken before touching code.

**Trigger it:** "debug this", "why is this broken", "fix this bug"

### `/office-hours` — Product Idea Stress-Test

Six forcing questions that kill bad ideas before you waste months building them. Demand reality, status quo analysis, desperate specificity, narrowest wedge, unique observation, AI future-fit. Produces a BUILD / ITERATE / KILL verdict.

**Trigger it:** "I have an idea", "is this worth building", "office hours"

### `/code` — Technical Execution Principles

Architecture first, code second. Opinionated defaults. Error paths as first-class citizens. Premise challenges before implementation. Loads automatically when you ask Claude to build something.

**Trigger it:** "build this", "architect this", "how should I build"

### `/core` — AI Co-Creation Philosophy

Turns Claude from an assistant into a peer. Challenge premises, strategic depth first, ship with momentum, ground decisions in meaning. The operating system for thinking with AI, not just using it.

**Trigger it:** "think with me", "co-create", "second brain mode"

### `/optimize` — Skill Router & Context Optimizer

Analyzes your installed skills, maps them to 7 task types (build, debug, deploy, audit, design, strategy, memory), and generates a CLAUDE.md routing rule. Based on Meta-Harness research: **targeted skill loading beats trigger-based activation by +51 points** in benchmarks.

Loading 3-4 targeted skills per task type beats loading 16+ via triggers. Less context = better outcomes.

**Trigger it:** "optimize my setup", "skill audit", "too many skills"

## Why These 6?

We use 62 skills daily at Menteorama Studio. These are the six we couldn't work without — the ones that changed how we interact with Claude Code:

- **careful** saved us from a `DROP TABLE` in production
- **investigate** cut our debugging time in half
- **office-hours** killed 3 ideas that would have wasted months
- **code** eliminated "it depends" from Claude's vocabulary
- **core** turned Claude into a co-founder, not a code monkey
- **optimize** proved we were loading too many skills — and fixed it

## Want More?

These 6 skills are the free layer of the **[Menteorama Brain Kit](https://lab.menteorama.co)** — a complete Claude Code second brain with 62 skills across 9 categories:

| Category | Skills | Examples |
|----------|--------|----------|
| Marketing | 12 | SEO, content strategy, cold email, ad creative |
| Design | 4 | Brand systems, UI/UX, logo generation, slides |
| Strategy | 6 | Narrator (brand storytelling), pricing, launch |
| Sales | 5 | Funnels, proposals, enablement, RevOps |
| CRO | 7 | Signup flows, paywalls, popups, onboarding |
| Research | 3 | Customer research, competitor analysis |
| AI | 2 | AI-native SEO, token optimization |
| Development | 7 | Frontend design, Figma bridge, web audits |
| Methodology | 10 | Superpowers (agentic dev), Meta-Harness, GSD, retros |

**Install the full Brain Kit:**
```bash
/bin/bash -c "$(curl -fsSL https://lab.menteorama.co/install.sh)"
```

One command. No prerequisites. Works on Mac and Linux. Bilingual (Spanish/English).

## About

Menteorama Studio builds AI-powered tools for entrepreneurs, creators, and operators who think with AI, not just use it. We're based in Mexico and serve the Spanish-speaking market — 650M people with almost zero Claude Code adoption. Yet.

## License

MIT
