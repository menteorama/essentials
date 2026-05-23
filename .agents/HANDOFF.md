# Agent Handoff

> When handing work to the other agent, update this file.
> When receiving work, read this file FIRST.

## Active Handoff

**From:** claude
**To:** codex, gemini
**Time:** 2026-05-23
**Status:** ready

### What I Did

1. **Created menteorama/essentials** — public Claude Code plugin with 5 free skills
2. **Built careful v2.0** — upgraded from basic rm-rf check to full safety guardrails:
   - `check-careful.sh` — Bash interceptor: destructive commands, dangerous operations, secrets in commands
   - `check-files.sh` — Write/Edit interceptor: protected files, protected dirs, secrets in file content
3. **Wrote marketing README** — serves as storefront with Brain Kit funnel CTA
4. **Created launch content** — Reddit post + Twitter thread in `marketing/launch-posts.md`
5. **Published journal post** — studio.menteorama.co with bilingual content, fixed OG tags + social previews

### What You Need to Do

#### Codex (Executor)
1. **Test hook scripts** — Run `check-careful.sh` and `check-files.sh` with crafted JSON inputs to verify:
   - All destructive patterns trigger warnings (positive cases)
   - Safe operations pass through (negative cases — especially safe delete exceptions like node_modules)
   - Edge cases: commands with quotes, multi-line commands, mixed case SQL
   - Secrets detection: verify each pattern (AKIA, ghp_, sk-, xox, private key blocks, connection strings)
   - File protection: verify .env, .pem, .git/ paths trigger, normal files pass
2. **Create test harness** — A simple test script that pipes JSON to each hook and asserts output
3. **Verify plugin structure** — Ensure `claude plugin add menteorama/essentials` works from a clean install

#### Gemini (Validator)
1. **Security review of hook scripts** — Check for:
   - Regex bypass vectors (can a destructive command sneak past the patterns?)
   - False positives that would annoy users (legitimate commands incorrectly flagged)
   - JSON parsing robustness (what happens with malformed input?)
   - Shell injection risks in the hooks themselves
2. **README review** — Check for broken links, accuracy of claims, marketing tone
3. **Audit public repo** — Ensure no internal URLs, API keys, or menteorama-specific paths leaked

### Files Changed

| File | Change |
|------|--------|
| `skills/careful/SKILL.md` | Rewritten — v2.0 with 2 hooks, expanded docs |
| `skills/careful/bin/check-careful.sh` | Rewritten — destructive commands + secrets detection |
| `skills/careful/bin/check-files.sh` | NEW — file protection + secrets in content |
| `README.md` | Rewritten — marketing storefront with Brain Kit funnel |
| `marketing/launch-posts.md` | NEW — Reddit + Twitter launch content |

### Context You Need

- This is a **PUBLIC** repo. Every file is visible to the world.
- The hooks use JSON parsing via `grep -o` + `sed` — no jq dependency (keeps it zero-dep)
- Hook output format: `{"permissionDecision":"allow"}` or `{"permissionDecision":"ask","message":"..."}`
- The `warn()` function handles JSON escaping of double quotes in messages
- Safe exceptions list (node_modules, .next, etc.) is checked BEFORE destructive patterns
- `--force-with-lease` is explicitly allowed (only raw `--force` / `-f` triggers warning)

### Warnings

- **JSON parsing is fragile** — `grep -o` pattern matching on JSON fields. Works for Claude Code's tool input format but not a general JSON parser. Known limitation, acceptable for this use case.
- **No jq dependency** — intentional. Plugin must work on any Mac/Linux with just bash + coreutils.
- **Multi-line commands** — the hooks read `command` as a single string. Multi-line heredocs or scripts piped via bash may not be fully parsed.
- **Regex overlap** — some patterns (like `rm -rf`) have both a general check and a critical check (targeting / or ~). The critical check runs second but both can't fire (first match exits).

---

## Previous Handoffs

(No previous handoffs — this is the first)
