---
name: careful
version: 2.0.0
description: |
  Safety guardrails for destructive commands, secrets detection, and file
  protection. Warns before rm -rf, DROP TABLE, force-push, git reset --hard,
  curl|bash, package publish, chmod 777, and similar destructive operations.
  Detects secrets (API keys, tokens, private keys, connection strings) in
  commands and file content. Blocks edits to .env, .pem, .key, SSH keys,
  and credentials files. User can override each warning.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
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
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/bin/check-files.sh"
          statusMessage: "Checking for protected files and secrets..."
---

# /careful — Destructive Command Guardrails

Safety mode is now **active**. Every bash command is checked for destructive
patterns, and every file write is checked for secrets and protected paths.
If something dangerous is detected, you'll be warned and can choose to proceed
or cancel.

## Command protection

| Pattern | Example | Risk |
|---------|---------|------|
| `rm -rf` / `rm -r` | `rm -rf /var/data` | Recursive delete |
| `rm -rf /` / `~` / `$HOME` | `rm -rf /` | System destruction |
| `DROP TABLE` / `DROP DATABASE` | `DROP TABLE users;` | Data loss |
| `TRUNCATE` / mass `DELETE` | `TRUNCATE orders;` | Data loss |
| `DELETE FROM` without `WHERE` | `DELETE FROM users;` | Full table wipe |
| `git push --force` / `-f` | `git push -f origin main` | History rewrite |
| `git reset --hard` | `git reset --hard HEAD~3` | Uncommitted work loss |
| `git checkout .` / `git restore .` | `git checkout .` | Uncommitted work loss |
| `git clean -f` | `git clean -fd` | Untracked file loss |
| `curl \| bash` | `curl url \| bash` | Remote code execution |
| `chmod 777` / `a+rwx` | `chmod 777 /app` | World-writable files |
| `npm publish` / `gem push` | `npm publish` | Accidental publish |
| `wrangler delete` / `d1 delete` | `wrangler d1 delete mydb` | CF resource loss |
| `supabase db reset` | `supabase db reset` | Database wipe |
| `docker rm -f` / `system prune` | `docker system prune -a` | Container/image loss |

## File protection

| Pattern | Example | Risk |
|---------|---------|------|
| `.env` / `.env.*` | `.env.production` | Secrets exposure |
| `*.pem` / `*.key` / `*.crt` | `server.key` | Crypto material |
| SSH keys | `id_rsa`, `id_ed25519` | Auth keys |
| `credentials.json` | GCP service account | Service secrets |
| `.npmrc` / `.pypirc` | Registry auth | Auth tokens |
| `.git/*` | `.git/config` | Repo corruption |
| `secrets/*` / `private/*` | `secrets/api.json` | Secret directories |

## Secrets detection

Scans both commands and file content for:

- **AWS keys** — `AKIA` prefix access keys
- **GitHub tokens** — `ghp_`, `gho_`, `ghs_`, `ghr_` prefixes
- **API keys** — `sk-*` pattern (OpenAI, Stripe, Anthropic)
- **Slack tokens** — `xox` prefixes
- **Private keys** — `BEGIN PRIVATE KEY` blocks
- **Connection strings** — `postgres://user:pass@host` patterns

## Safe exceptions (no warning)

Build artifacts and caches: `node_modules`, `.next`, `dist`, `__pycache__`,
`.cache`, `build`, `.turbo`, `coverage`, `.wrangler`, `.vercel`, `.output`

## How it works

Two PreToolUse hooks:
1. **check-careful.sh** — intercepts Bash commands for destructive patterns and secrets
2. **check-files.sh** — intercepts Write/Edit for protected files and secrets in content

All warnings are advisory — you can always override. To deactivate, end the
conversation or start a new one.
