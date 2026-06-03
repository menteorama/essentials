# Launch Posts — Menteorama Essentials

## Reddit Post (r/ClaudeAI)

**Title:** I made 5 free skills for Claude Code that changed how I work — safety guardrails, a debugging protocol, and a product stress-test

**Body:**

I run a small AI studio and Claude Code is my main tool. After months of daily use I noticed three patterns:

1. Claude would occasionally run destructive commands (rm -rf, DROP TABLE, force push) without hesitation. I lost a staging database once.
2. When debugging, Claude would guess-and-patch instead of finding the root cause. I'd end up with 4 "fixes" that created 3 new bugs.
3. I kept building features nobody asked for because Claude validated every idea I threw at it.

So I built skills to fix each one. Then I added two more for code quality and co-creation philosophy. Packaged them as a free plugin.

**What's in it:**

`/careful` — A hook that intercepts Bash commands before execution. If Claude is about to run `rm -rf`, `DROP TABLE`, `git push --force`, or `git reset --hard`, it warns you first. Safe deletions (node_modules, .next, dist) pass through automatically. This one has saved me multiple times.

`/investigate` — A 4-phase debugging protocol: Investigate > Analyze > Hypothesize > Implement. The iron law is "no fixes without root cause." Claude has to write a bug report before touching code and a root cause report after. It completely changed how Claude debugs — it actually reads the code now instead of guessing.

`/office-hours` — 6 forcing questions that stress-test product ideas. Demand reality, status quo analysis, desperate specificity, narrowest wedge, unique observation, AI future-fit. Produces a BUILD / ITERATE / KILL verdict. It killed 3 of my ideas. They deserved it.

`/code` — Architecture first, code second. Opinionated defaults. Error paths as first-class citizens. Makes Claude challenge the premise before building.

`/core` — Turns Claude from an assistant into a thinking partner. Challenge premises, strategic depth, no sycophancy. The "think with me, not for me" operating system.

**Install:**

```
claude plugin add menteorama/essentials
```

Repo: github.com/menteorama/essentials

MIT licensed. All 5 skills are plain markdown files — you can read exactly what they do before installing.

I use 43 skills daily but these 5 are the ones I'd never remove. If there's interest I'll write up how each one works in detail.

---

## Twitter/X Thread

**Tweet 1 (hook):**

Claude Code nearly dropped my staging database last month.

Now it asks permission first.

I built 5 free skills that fix the worst habits of AI coding assistants. Thread:

**Tweet 2 (careful):**

Skill 1: /careful

A hook that catches destructive commands before Claude runs them.

rm -rf? Warned.
DROP TABLE? Warned.
git push --force? Warned.
git reset --hard? Warned.

Safe stuff like deleting node_modules passes through automatically.

This one skill has saved me more than once.

**Tweet 3 (investigate):**

Skill 2: /investigate

Claude's default debugging: guess, patch, hope.

This skill forces a 4-phase protocol:
- Investigate (gather evidence)
- Analyze (narrow the search)
- Hypothesize (test theories)
- Implement (fix with confidence)

Iron law: no fixes without root cause.

Before/after is night and day.

**Tweet 4 (office-hours):**

Skill 3: /office-hours

I used to brainstorm with Claude and it validated every bad idea.

Now it asks 6 uncomfortable questions:
- Who is ALREADY paying for this?
- What do they do TODAY without you?
- Name ONE person who'd be devastated without it

It killed 3 of my ideas. They deserved it.

**Tweet 5 (code + core):**

Skill 4: /code — Architecture first. Opinionated defaults. Error paths before happy paths. No "it depends."

Skill 5: /core — Turns Claude from assistant to peer. Challenges premises. No sycophancy. "Think with me, not for me."

**Tweet 6 (install):**

All free. All MIT. All plain markdown — you can read every line before installing.

```
claude plugin add menteorama/essentials
```

github.com/menteorama/essentials

I use 43 skills daily. These 5 are the ones I'd never remove.

**Tweet 7 (CTA):**

If you want the full set (43 skills across marketing, design, strategy, sales, CRO, dev, and methodology):

lab.menteorama.co

One terminal command. No prerequisites. Works on Mac and Linux. Bilingual (Spanish/English).

Built for entrepreneurs and creators who think with AI, not just use it.
