---
name: careful
version: 1.0.0
description: |
  Safety guardrails for destructive commands. Warns before rm -rf, DROP TABLE,
  force-push, git reset --hard, wrangler delete, supabase reset, and similar
  destructive operations. User can override each warning.
  Use when asked to "be careful", "safety mode", "prod mode", or when touching
  production systems.
allowed-tools:
  - Bash
  - Read
triggers:
  - be careful
  - safety mode
  - prod mode
  - careful mode
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/bin/check-careful.sh"
          statusMessage: "Checking for destructive commands..."
---

# /careful — Destructive Command Guardrails

Safety mode is now **active**. Every bash command will be checked for destructive
patterns before running. If a destructive command is detected, you'll be warned
and can choose to proceed or cancel.

## What's protected

| Pattern | Example | Risk |
|---------|---------|------|
| `rm -rf` / `rm -r` | `rm -rf /var/data` | Recursive delete |
| `DROP TABLE` / `DROP DATABASE` | `DROP TABLE users;` | Data loss |
| `TRUNCATE` / mass `DELETE` | `TRUNCATE orders;` | Data loss |
| `git push --force` / `-f` | `git push -f origin main` | History rewrite |
| `git reset --hard` | `git reset --hard HEAD~3` | Uncommitted work loss |
| `git checkout .` / `git restore .` | `git checkout .` | Uncommitted work loss |
| `wrangler delete` / `d1 delete` | `wrangler d1 delete mydb` | CF resource loss |
| `supabase db reset` | `supabase db reset` | Database wipe |
| `docker rm -f` / `system prune` | `docker system prune -a` | Container/image loss |

## Safe exceptions (no warning)

Build artifacts and caches: `node_modules`, `.next`, `dist`, `__pycache__`,
`.cache`, `build`, `.turbo`, `coverage`, `.wrangler`, `.vercel`, `.output`

## How it works

A PreToolUse hook intercepts every Bash command, checks it against the patterns
above, and returns a warning if a match is found. You can always override.

To deactivate, end the conversation or start a new one. Hooks are session-scoped.
