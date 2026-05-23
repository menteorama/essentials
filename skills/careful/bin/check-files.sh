#!/usr/bin/env bash
# File protection guardrail — blocks Write/Edit to sensitive files
# Part of menteorama-essentials plugin
# Returns JSON with permissionDecision: "allow" or "ask"

set -euo pipefail
export LC_ALL=C

extract_json_string() {
  local field="$1"
  printf '%s' "$INPUT" | FIELD="$field" perl -0ne '
    my $field = $ENV{FIELD};
    if (/"\Q$field\E"\s*:\s*"((?:\\.|[^"\\])*)"/s) {
      my $value = $1;
      $value =~ s/\\n/\n/g;
      $value =~ s/\\r/\r/g;
      $value =~ s/\\t/\t/g;
      $value =~ s/\\"/"/g;
      $value =~ s/\\\\/\\/g;
      print $value;
    }
  '
}

INPUT=$(cat)

# Try to extract file_path from tool input
FILE_PATH=$(extract_json_string "file_path")

# If we can't parse the file path, allow it
if [ -z "$FILE_PATH" ]; then
  echo '{"permissionDecision":"allow"}'
  exit 0
fi

BASENAME=$(basename -- "$FILE_PATH")
BASENAME_LC=$(echo "$BASENAME" | tr '[:upper:]' '[:lower:]')
PATH_LC=$(echo "$FILE_PATH" | tr '[:upper:]' '[:lower:]')

warn() {
  local msg="${1//\"/\\\"}"
  echo "{\"permissionDecision\":\"ask\",\"message\":\"WARNING: $msg\\n\\nFile: $FILE_PATH\\n\\nProceed anyway?\"}"
  exit 0
}

# ── Protected file patterns ─────────────────────────────────────────────
# Environment files
case "$BASENAME_LC" in
  .env|.env.*)
    warn "PROTECTED FILE: .env files contain secrets. Editing may expose credentials." ;;
  *.pem|*.key|*.crt|*.p12|*.pfx)
    warn "PROTECTED FILE: certificate/key file detected. These contain cryptographic material." ;;
  id_rsa|id_ed25519|id_ecdsa|*.pub)
    warn "PROTECTED FILE: SSH key detected. Modifying SSH keys can lock you out." ;;
  credentials.json|service-account*.json)
    warn "PROTECTED FILE: credentials file detected. This contains service account secrets." ;;
  .npmrc|.pypirc)
    warn "PROTECTED FILE: package registry config may contain auth tokens." ;;
esac

# ── Protected directories ───────────────────────────────────────────────
case "$PATH_LC" in
  .git/*|*/.git/*)
    warn "PROTECTED PATH: editing files inside .git/ can corrupt the repository." ;;
  secrets/*|*/secrets/*|private/*|*/private/*)
    warn "PROTECTED PATH: this file is inside a secrets/private directory." ;;
esac

# ── Secrets in file content ─────────────────────────────────────────────
# Check new_string (Edit) or content (Write) for embedded secrets
CONTENT=$(extract_json_string "content")
NEW_STRING=$(extract_json_string "new_string")
CHECK_TEXT="$CONTENT$NEW_STRING"

if [ -n "$CHECK_TEXT" ]; then
  # AWS access keys
  if echo "$CHECK_TEXT" | grep -qE 'AKIA[0-9A-Z]{16}'; then
    warn "SECRET IN CONTENT: AWS access key detected. Use environment variables instead."
  fi

  # GitHub tokens
  if echo "$CHECK_TEXT" | grep -qE '(ghp_|gho_|ghs_|ghr_)[a-zA-Z0-9]{36}'; then
    warn "SECRET IN CONTENT: GitHub token detected. Use environment variables instead."
  fi

  # API keys (sk-*)
  if echo "$CHECK_TEXT" | grep -qE 'sk-[a-zA-Z0-9]{20,}'; then
    warn "SECRET IN CONTENT: API key (sk-*) detected. Use environment variables instead."
  fi

  # Slack tokens
  if echo "$CHECK_TEXT" | grep -qE 'xox[bpas]-[a-zA-Z0-9-]+'; then
    warn "SECRET IN CONTENT: Slack token detected. Use environment variables instead."
  fi

  # Private key blocks
  if echo "$CHECK_TEXT" | grep -qE 'BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY'; then
    warn "SECRET IN CONTENT: private key block detected. Never commit private keys."
  fi

  # Connection strings with passwords
  if echo "$CHECK_TEXT" | grep -qE '(mysql|postgres|postgresql|mongodb|redis)://[^:]+:[^@]+@'; then
    warn "SECRET IN CONTENT: database connection string with embedded password detected."
  fi
fi

# All checks passed
echo '{"permissionDecision":"allow"}'
