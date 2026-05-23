#!/usr/bin/env bash
# Destructive command guardrail — checks Bash tool input for dangerous patterns
# Part of menteorama-essentials plugin
# Returns JSON with permissionDecision: "allow" or "ask"

set -euo pipefail

# Read the command from tool input (passed via stdin as JSON)
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | grep -o '"command":"[^"]*"' | sed 's/"command":"//;s/"$//' || echo "")

# If we can't parse the command, allow it
if [ -z "$COMMAND" ]; then
  echo '{"permissionDecision":"allow"}'
  exit 0
fi

# Safe exceptions — build artifacts and caches that are always OK to delete
SAFE_PATTERNS=(
  "node_modules"
  ".next"
  "dist"
  "__pycache__"
  ".cache"
  "build"
  ".turbo"
  "coverage"
  ".wrangler"
  ".vercel"
  ".output"
)

for safe in "${SAFE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -q "rm.*$safe"; then
    echo '{"permissionDecision":"allow"}'
    exit 0
  fi
done

warn() {
  local msg="${1//\"/\\\"}"
  echo "{\"permissionDecision\":\"ask\",\"message\":\"WARNING: $msg\\n\\nCommand: $COMMAND\\n\\nProceed anyway?\"}"
  exit 0
}

# ── Recursive delete ────────────────────────────────────────────────────
if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|--recursive|-rf|-fr)\s'; then
  warn "DESTRUCTIVE: recursive delete detected (rm -rf). This permanently removes files."
fi

# rm -rf targeting root, home, or system directories
CMD_NOQUOTE=$(echo "$COMMAND" | tr -d "'\"")
if echo "$CMD_NOQUOTE" | grep -qE 'rm\s+(-[a-zA-Z]+\s+)*-?[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*\s+(/(\s|$)|~|\$HOME|\.\./\.\.)'; then
  warn "CRITICAL: recursive delete targeting /, ~, \$HOME, or parent traversal. Extremely dangerous."
fi

# ── SQL destruction ─────────────────────────────────────────────────────
if echo "$COMMAND" | grep -qiE '(DROP\s+(TABLE|DATABASE|SCHEMA)|TRUNCATE\s|DELETE\s+FROM.*WHERE\s+1|DELETE\s+FROM\s+[a-z]+\s*;)'; then
  warn "DESTRUCTIVE: SQL data destruction detected (DROP/TRUNCATE/mass DELETE). Data cannot be recovered."
fi

# DELETE FROM without WHERE clause
if echo "$COMMAND" | grep -qiE 'DELETE\s+FROM\s+[a-zA-Z_]+' && ! echo "$COMMAND" | grep -qiE 'WHERE'; then
  warn "DESTRUCTIVE: DELETE FROM without a WHERE clause. This deletes ALL rows."
fi

# ── Git history rewriting ───────────────────────────────────────────────
if echo "$COMMAND" | grep -qE 'git\s+push\s+(-[a-zA-Z]*f|--force)' && ! echo "$COMMAND" | grep -qE '\-\-force-with-lease'; then
  warn "DESTRUCTIVE: force push detected. This rewrites remote history. Use --force-with-lease if you must."
fi

if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  warn "DESTRUCTIVE: git reset --hard detected. Uncommitted changes will be permanently lost."
fi

if echo "$COMMAND" | grep -qE 'git\s+(checkout|restore)\s+\.'; then
  warn "DESTRUCTIVE: git checkout/restore . detected. All uncommitted changes will be discarded."
fi

if echo "$COMMAND" | grep -qE 'git\s+clean\s+-[a-zA-Z]*f'; then
  warn "DESTRUCTIVE: git clean -f permanently deletes untracked files."
fi

# ── Production infrastructure ───────────────────────────────────────────
if echo "$COMMAND" | grep -qE 'wrangler\s+d1\s+(delete|execute.*DROP)'; then
  warn "DESTRUCTIVE: Cloudflare D1 destruction detected. Production database at risk."
fi

if echo "$COMMAND" | grep -qE 'wrangler\s+(delete|secret\s+delete)'; then
  warn "DESTRUCTIVE: Cloudflare resource deletion detected. Production services may go down."
fi

# Docker destruction
if echo "$COMMAND" | grep -qE 'docker\s+(rm\s+-f|system\s+prune|volume\s+rm)'; then
  warn "DESTRUCTIVE: Docker resource removal detected. Running containers/volumes at risk."
fi

# Supabase destruction
if echo "$COMMAND" | grep -qE 'supabase\s+(db\s+reset|projects\s+delete)'; then
  warn "DESTRUCTIVE: Supabase destruction detected. Database or project will be wiped."
fi

# ── Dangerous system commands ───────────────────────────────────────────
# curl/wget piped to shell
if echo "$COMMAND" | grep -qE '(curl|wget)\s.*\|\s*(sudo\s+)?(bash|sh|zsh)'; then
  warn "DANGEROUS: piping downloaded content directly to a shell. Inspect the script first."
fi

# chmod 777
if echo "$COMMAND" | grep -qE 'chmod\s+([^ ]+\s+)*0?777\s' || echo "$COMMAND" | grep -qE 'chmod\s+([^ ]+\s+)*a\+rwx'; then
  warn "DANGEROUS: chmod 777/a+rwx grants everyone full access. Use restrictive permissions."
fi

# Accidental package publishing
if echo "$COMMAND" | grep -qE '(npm|yarn|pnpm|bun)\s+publish' && ! echo "$COMMAND" | grep -qE '\-\-dry-run'; then
  warn "DANGEROUS: package publish detected. Publishing should be done manually or in CI, not via Claude."
fi

# ── Secrets in commands ─────────────────────────────────────────────────
# API keys and tokens passed directly in commands
if echo "$COMMAND" | grep -qE '(AKIA[0-9A-Z]{16})'; then
  warn "SECRET DETECTED: AWS access key found in command. Use environment variables instead."
fi

if echo "$COMMAND" | grep -qE '(ghp_[a-zA-Z0-9]{36}|gho_[a-zA-Z0-9]{36}|ghs_[a-zA-Z0-9]{36}|ghr_[a-zA-Z0-9]{36})'; then
  warn "SECRET DETECTED: GitHub token found in command. Use environment variables instead."
fi

if echo "$COMMAND" | grep -qE 'sk-[a-zA-Z0-9]{20,}'; then
  warn "SECRET DETECTED: API key (sk-*) found in command. Use environment variables instead."
fi

if echo "$COMMAND" | grep -qE 'xox[bpas]-[a-zA-Z0-9-]+'; then
  warn "SECRET DETECTED: Slack token found in command. Use environment variables instead."
fi

# All checks passed
echo '{"permissionDecision":"allow"}'
