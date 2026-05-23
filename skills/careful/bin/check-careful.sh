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

# Dangerous patterns
WARNINGS=""

# Recursive delete
if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|--recursive|-rf|-fr)\s'; then
  WARNINGS="DESTRUCTIVE: recursive delete detected (rm -rf). This permanently removes files."
fi

# SQL destruction
if echo "$COMMAND" | grep -qiE '(DROP\s+(TABLE|DATABASE|SCHEMA)|TRUNCATE\s|DELETE\s+FROM.*WHERE\s+1|DELETE\s+FROM\s+[a-z]+\s*;)'; then
  WARNINGS="DESTRUCTIVE: SQL data destruction detected (DROP/TRUNCATE/mass DELETE). Data cannot be recovered."
fi

# Git history rewriting
if echo "$COMMAND" | grep -qE 'git\s+push\s+(-[a-zA-Z]*f|--force)'; then
  WARNINGS="DESTRUCTIVE: force push detected. This rewrites remote history and can destroy teammates work."
fi

if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  WARNINGS="DESTRUCTIVE: git reset --hard detected. Uncommitted changes will be permanently lost."
fi

if echo "$COMMAND" | grep -qE 'git\s+(checkout|restore)\s+\.'; then
  WARNINGS="DESTRUCTIVE: git checkout/restore . detected. All uncommitted changes will be discarded."
fi

# Production infrastructure
if echo "$COMMAND" | grep -qE 'wrangler\s+d1\s+(delete|execute.*DROP)'; then
  WARNINGS="DESTRUCTIVE: Cloudflare D1 destruction detected. Production database at risk."
fi

if echo "$COMMAND" | grep -qE 'wrangler\s+(delete|secret\s+delete)'; then
  WARNINGS="DESTRUCTIVE: Cloudflare resource deletion detected. Production services may go down."
fi

# Docker destruction
if echo "$COMMAND" | grep -qE 'docker\s+(rm\s+-f|system\s+prune|volume\s+rm)'; then
  WARNINGS="DESTRUCTIVE: Docker resource removal detected. Running containers/volumes at risk."
fi

# Supabase destruction
if echo "$COMMAND" | grep -qE 'supabase\s+(db\s+reset|projects\s+delete)'; then
  WARNINGS="DESTRUCTIVE: Supabase destruction detected. Database or project will be wiped."
fi

if [ -n "$WARNINGS" ]; then
  WARNINGS_ESCAPED=$(echo "$WARNINGS" | sed 's/"/\\"/g')
  echo "{\"permissionDecision\":\"ask\",\"message\":\"WARNING: $WARNINGS_ESCAPED\\n\\nCommand: $COMMAND\\n\\nProceed anyway?\"}"
else
  echo '{"permissionDecision":"allow"}'
fi
