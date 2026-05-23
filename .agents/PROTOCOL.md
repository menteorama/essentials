# Menteorama Essentials — Agent Protocol

> **Repo:** github.com/menteorama/essentials (PUBLIC)
> **Visibility:** This is a PUBLIC repo. Never commit secrets, internal URLs, or client data.

## Tri-Brain Roles

| Agent | Role |
|-------|------|
| Claude | Architect — designs skills, writes hooks, crafts README/marketing |
| Codex | Executor — tests hooks in isolation, validates regex patterns, batch operations |
| Gemini | Validator — reviews hook security, audits for false positives/negatives, QA |

## Communication

All agents communicate through `.agents/HANDOFF.md`. Read it before any work.

## Rules

1. **PUBLIC REPO** — no internal project names, no API keys, no menteorama-specific paths in code
2. Skills must work universally — no assumptions about user's directory structure
3. Hook scripts use `${CLAUDE_SKILL_DIR}` for paths (plugin standard)
4. All hooks return JSON: `{"permissionDecision": "allow"}` or `{"permissionDecision": "ask", "message": "..."}`
5. Hooks are advisory ("ask") not blocking ("deny") — user always has final say
6. README serves as marketing funnel — changes must preserve the Brain Kit CTA
7. Test every regex pattern against both positive and negative cases
8. Log all actions to `.agents/LOG.md`
