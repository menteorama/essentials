# Menteorama Essentials — Agent Context

> **Repo:** github.com/menteorama/essentials (PUBLIC)
> **Stack:** Bash scripts (hooks), Markdown (skills), JSON (plugin config)
> **Deploy:** N/A — distributed as Claude Code plugin (`claude plugin add menteorama/essentials`)
> **Live:** https://github.com/menteorama/essentials

## What This Is

A free Claude Code plugin with 5 skills. It's the top of the marketing funnel:
```
Free plugin (5 skills) → README → Brain Kit CTA (43 skills) → lab.menteorama.co/install.sh
```

## Architecture

```
.claude-plugin/
  plugin.json          # Plugin manifest — name, version, description
  marketplace.json     # Marketplace metadata (if/when Claude marketplace launches)
skills/
  careful/             # v2.0 — safety guardrails (2 PreToolUse hooks)
    SKILL.md           # Skill definition with hook config
    bin/
      check-careful.sh # Hook: intercepts Bash for destructive commands + secrets
      check-files.sh   # Hook: intercepts Write/Edit for protected files + secrets in content
  investigate/         # Root cause debugging protocol
    SKILL.md
  office-hours/        # Product idea stress-test (6 forcing questions)
    SKILL.md
  code/                # Technical execution principles
    SKILL.md
  core/                # AI co-creation philosophy
    SKILL.md
marketing/
  launch-posts.md      # Reddit + Twitter/X launch content (ready to post)
README.md              # Marketing-optimized — serves as storefront
```

## Skills Overview

| Skill | Type | Hooks | Version |
|-------|------|-------|---------|
| careful | Safety guardrails | 2 PreToolUse (Bash, Write/Edit) | 2.0.0 |
| investigate | Debugging protocol | None (prompt-only) | 1.0.0 |
| office-hours | Idea stress-test | None (prompt-only) | 1.0.0 |
| code | Code principles | None (prompt-only) | 1.0.0 |
| core | Co-creation philosophy | None (prompt-only) | 1.0.0 |

## careful v2.0 — Hook Architecture

### check-careful.sh (Bash interceptor)
- Reads tool input JSON from stdin
- Extracts `command` field
- Safe exceptions: node_modules, .next, dist, __pycache__, .cache, build, .turbo, coverage, .wrangler, .vercel, .output
- Destructive patterns: rm -rf, rm targeting /, ~, $HOME, DROP/TRUNCATE/DELETE, force push (except --force-with-lease), git reset --hard, git checkout/restore ., git clean -f, wrangler delete, docker rm -f/prune, supabase db reset
- Dangerous patterns: curl|bash, chmod 777/a+rwx, npm/yarn/pnpm publish (except --dry-run)
- Secrets: AWS keys (AKIA*), GitHub tokens (ghp_/gho_/ghs_/ghr_), API keys (sk-*), Slack tokens (xox*)

### check-files.sh (Write/Edit interceptor)
- Reads tool input JSON from stdin
- Extracts `file_path`, `content`, `new_string` fields
- Protected files: .env*, *.pem/*.key/*.crt/*.p12/*.pfx, SSH keys, credentials.json, service-account*.json, .npmrc, .pypirc
- Protected dirs: .git/*, secrets/*, private/*
- Secrets in content: same patterns as check-careful.sh + private key blocks + DB connection strings with passwords

## What NOT to Touch

- Plugin manifest (`.claude-plugin/plugin.json`) — only update version on releases
- README.md Brain Kit CTA section — this is the funnel endpoint
- The "ask" pattern — hooks must NEVER use "deny", always "ask"

## Current State

- v2.0 deployed (commit 2c6e0e2) — careful upgraded with secrets scanning + file protection
- README updated for v2.0
- Marketing content ready in `marketing/launch-posts.md` (not yet posted)
- Journal post live at studio.menteorama.co/en/journal/5-skills-that-changed-how-we-use-claude-code
