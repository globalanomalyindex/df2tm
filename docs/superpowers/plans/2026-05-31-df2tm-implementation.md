# df2tm Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Prose-authoring tasks additionally use **superpowers:writing-skills** and **anthropic-skills:skill-creator**.

**Goal:** Build df2tm — a distributable Claude Code plugin that acts as an always-on, relevance-gated learning layer: it teaches the concepts behind Claude's work as it works, and remembers them across sessions.

**Architecture:** A plugin combining (1) a SessionStart **hook** that injects a lean operating directive + surfaces due reviews and seeds state on first run; (2) a **skill** (`skills/df2tm/SKILL.md` + references) holding the full teaching method, the curated toolkit, the ~170-principle tiered science library, and the learner-model format; (3) a single arg-routed **command** `/df2tm`; (4) **state** in `~/.claude/df2tm/` (learner model + per-project journals), seeded from `templates/`. Behavior is prose Claude follows; only the hook and validation are executable code.

**Tech Stack:** Markdown (skill + references + commands + docs), JSON (plugin manifest, marketplace, hooks config), Bash (SessionStart handler + validation), no runtime dependencies beyond `bash`, `date`, `grep`/`sed`/`awk`, and optionally `python3` (graceful fallback if absent).

**Source spec:** `docs/superpowers/specs/2026-05-31-df2tm-design.md`
**Principles source of truth:** `docs/superpowers/plans/2026-05-31-df2tm-principles-source.md`

---

## Build guardrails

- **Do not pollute the live environment.** All hook/state tests use a `DF2TM_STATE_DIR` override pointing at a temp dir — never let tests write to the real `~/.claude/df2tm` until the user installs. Do not edit the user's `~/.claude/CLAUDE.md` or `settings.json`; activation is via the plugin's own hook (installed when the user installs the plugin).
- **TDD altitude for prose.** Deterministic files (JSON/bash/templates/frontmatter) are shown in full here and verified by `tests/validate.sh`. Large prose files (SKILL.md body, toolkit, science library) are specified by exact structure + acceptance criteria and authored at execution via writing-skills/skill-creator — their "tests" are validation greps + subagent triggering scenarios (Task 11).
- **Commit after every task.**

---

## File Structure

```
df2tm/
├── .claude-plugin/
│   ├── plugin.json                     # Task 1 — plugin manifest
│   └── marketplace.json                # Task 1 — single-plugin marketplace (source ".")
├── hooks/
│   ├── hooks.json                      # Task 2 — SessionStart registration
│   └── handlers/session-start.sh       # Task 2 — seed + inject directive + due reviews
├── templates/
│   ├── learner-model.md                # Task 3 — seed learner model (machine-readable STATE block)
│   └── journal/.gitkeep                # Task 3 — seed journal dir
├── skills/df2tm/
│   ├── SKILL.md                        # Task 8 — the teaching METHOD (lean, <~700 words)
│   └── references/
│       ├── learner-model-format.md     # Task 4 — state schema + update protocol
│       ├── teaching-toolkit.md         # Task 6 — ~25 actionable techniques (full how-to)
│       └── science-library.md          # Task 7 — all ~170 principles, 3 tiers, concise
├── commands/
│   └── df2tm.md                        # Task 9 — single arg-routed command
├── tests/
│   ├── validate.sh                     # Task 5 — structural validation harness
│   └── triggering/                     # Task 11 — skill triggering/behavioral scenarios
│       ├── should-trigger.md
│       └── should-not-trigger.md
├── README.md                           # Task 10 — install + usage
└── docs/superpowers/                   # specs/ + plans/ (already committed)
```

Each file has one responsibility; the skill body stays lean and defers depth to `references/` (progressive disclosure).

---

## Task 1: Scaffold plugin + manifests

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Create the plugin manifest**

`.claude-plugin/plugin.json`:
```json
{
  "name": "df2tm",
  "description": "Don't Forget To Teach Me — an always-on, relevance-gated learning layer that teaches the concepts behind Claude's work as it works, and remembers them across sessions.",
  "version": "0.1.0",
  "author": { "name": "Christopher Robin Fiore" },
  "homepage": "https://github.com/globalanomalyindex/df2tm",
  "repository": "https://github.com/globalanomalyindex/df2tm",
  "license": "MIT",
  "keywords": ["learning", "teaching", "spaced-repetition", "active-recall", "education", "memory", "mentor", "metacognition"]
}
```

- [ ] **Step 2: Create the marketplace manifest**

`.claude-plugin/marketplace.json`:
```json
{
  "$schema": "https://json.schemastore.org/claude-code-marketplace.json",
  "name": "df2tm",
  "version": "0.1.0",
  "description": "Don't Forget To Teach Me — learning layer for Claude Code.",
  "owner": {
    "name": "Christopher Robin Fiore",
    "email": "134718004+globalanomalyindex@users.noreply.github.com"
  },
  "plugins": [
    {
      "name": "df2tm",
      "source": ".",
      "category": "learning",
      "version": "0.1.0",
      "description": "Always-on, relevance-gated learning layer: teaches the concepts behind Claude's work and remembers them across sessions."
    }
  ]
}
```

- [ ] **Step 3: Verify both JSON files parse**

Run:
```bash
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  python3 -c "import json,sys; json.load(open('$f')); print('OK $f')" || echo "FAIL $f"
done
```
Expected: `OK .claude-plugin/plugin.json` and `OK .claude-plugin/marketplace.json`.

- [ ] **Step 4: Commit**
```bash
git add .claude-plugin/
git commit -m "feat(df2tm): scaffold plugin and marketplace manifests"
```

---

## Task 2: SessionStart hook (activation + due reviews + first-run seeding)

**Files:**
- Create: `hooks/hooks.json`
- Create: `hooks/handlers/session-start.sh`

- [ ] **Step 1: Register the hook**

`hooks/hooks.json`:
```json
{
  "description": "df2tm always-on learning layer: seeds state, injects the operating directive, and surfaces due reviews at session start.",
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/handlers/session-start.sh",
            "async": false
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2: Write the handler**

`hooks/handlers/session-start.sh`:
```bash
#!/usr/bin/env bash
# df2tm SessionStart hook.
# Seeds state on first run, then prints a lean operating directive plus any
# concepts due for review as additionalContext. MUST always exit 0 with valid JSON.

set -u

STATE_DIR="${DF2TM_STATE_DIR:-$HOME/.claude/df2tm}"
MODEL="$STATE_DIR/learner-model.md"
TPL_DIR="${CLAUDE_PLUGIN_ROOT:-.}/templates"
TODAY="$(date +%F)"

# --- First-run seeding (best effort; never fail the session) ---
if [ ! -d "$STATE_DIR" ]; then
  mkdir -p "$STATE_DIR/journal" 2>/dev/null || true
  if [ -f "$TPL_DIR/learner-model.md" ] && [ ! -f "$MODEL" ]; then
    cp "$TPL_DIR/learner-model.md" "$MODEL" 2>/dev/null || true
  fi
fi

# --- Read intensity + due concepts defensively ---
INTENSITY="ambient"
DUE=""
DUE_COUNT=0
if [ -f "$MODEL" ]; then
  i="$(grep -m1 '^intensity:' "$MODEL" 2>/dev/null | sed 's/^intensity:[[:space:]]*//')"
  [ -n "${i:-}" ] && INTENSITY="$i"
  while IFS= read -r line; do
    status="$(printf '%s' "$line" | grep -oE 'active|muted|known' | tail -1)"
    [ "$status" = "muted" ] && continue
    [ "$status" = "known" ] && continue
    slug="$(printf '%s' "$line" | sed 's/^concept:[[:space:]]*//; s/[[:space:]]*|.*$//')"
    due="$(printf '%s' "$line" | grep -oE 'due:[0-9-]+' | sed 's/due://')"
    if [ -n "${due:-}" ] && [[ ! "$due" > "$TODAY" ]]; then
      DUE="${DUE:+$DUE, }$slug"
      DUE_COUNT=$((DUE_COUNT + 1))
    fi
  done < <(grep '^concept:' "$MODEL" 2>/dev/null || true)
fi

# --- Build the lean directive ---
DIRECTIVE="df2tm is active (intensity: ${INTENSITY}). As you do real work, weave in brief, skimmable teaching about concepts that are load-bearing and forward-useful for THIS work, following your df2tm skill: default woven-inline, escalate only when a concept is pivotal or the user engages, and stay silent when nothing is worth teaching. Mark teaching asides distinctly (a 🎓 lead-in) so they are skippable. Record worth-remembering concepts to ${MODEL} plus a one-line journal entry under ${STATE_DIR}/journal/. Steering phrases the user may use: 'teach me more/less', 'df2tm off/on', 'just do it', 'quiz me', 'why did you do that', 'debrief', 'I already know this'. Concepts due for review now (${DUE_COUNT}): ${DUE:-none}. Read the df2tm skill and its references when you need the full method, the toolkit, or the science library."

# --- Emit JSON safely (python3 if present, else a sed fallback) ---
json_escape() {
  if command -v python3 >/dev/null 2>&1; then
    printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
  else
    printf '"%s"' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  fi
}

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$(json_escape "$DIRECTIVE")"
exit 0
```

- [ ] **Step 3: Make it executable**
```bash
chmod +x hooks/handlers/session-start.sh
```

- [ ] **Step 4: Syntax-check and run against a temp state dir (no real state touched)**

Run:
```bash
bash -n hooks/handlers/session-start.sh && echo "SYNTAX OK"
TMP="$(mktemp -d)"
DF2TM_STATE_DIR="$TMP/df2tm" CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/handlers/session-start.sh | tee /tmp/df2tm_hook_out.json
python3 -c "import json; d=json.load(open('/tmp/df2tm_hook_out.json')); assert d['hookSpecificOutput']['hookEventName']=='SessionStart'; assert 'df2tm is active' in d['hookSpecificOutput']['additionalContext']; print('JSON OK')"
test -d "$TMP/df2tm/journal" && echo "SEED OK (journal dir created)"
rm -rf "$TMP"
```
Expected: `SYNTAX OK`, a one-line JSON object, `JSON OK`, `SEED OK (journal dir created)`. (Templates don't exist yet, so seeding the model file is skipped — that's fine; re-verified in Task 3.)

- [ ] **Step 5: Commit**
```bash
git add hooks/
git commit -m "feat(df2tm): add SessionStart hook for activation, seeding, and due reviews"
```

---

## Task 3: State templates

**Files:**
- Create: `templates/learner-model.md`
- Create: `templates/journal/.gitkeep`

- [ ] **Step 1: Create the learner-model seed**

`templates/learner-model.md`:
```markdown
# df2tm — Learner Model

df2tm's persistent memory of what you've been taught. df2tm reads and updates this
automatically; you may also edit it by hand. Format reference: the df2tm skill's
`references/learner-model-format.md`.

## Preferences
intensity: ambient
known-topics:
prioritized-topics:

## Concepts
<!--
One machine-readable line per tracked concept. EXACT format (the SessionStart hook
reads `intensity:` above and these `concept:` lines):

concept: <slug> | <domain|ai-direction> | <new|shaky|solid> | last:YYYY-MM-DD | due:YYYY-MM-DD | reviews:N | tags:comma,separated | <active|known|muted>

Example:
concept: encoding-specificity | domain | shaky | last:2026-05-24 | due:2026-05-31 | reviews:2 | tags:memory,recall | active
-->
```
(No seed concepts — a fresh learner starts empty; the hook handles "due: none".)

- [ ] **Step 2: Create the journal placeholder**
```bash
mkdir -p templates/journal && touch templates/journal/.gitkeep
```

- [ ] **Step 3: Verify the hook now seeds the model from the template**

Run:
```bash
TMP="$(mktemp -d)"
DF2TM_STATE_DIR="$TMP/df2tm" CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/handlers/session-start.sh >/dev/null
test -f "$TMP/df2tm/learner-model.md" && echo "MODEL SEEDED OK"
grep -q '^intensity: ambient' "$TMP/df2tm/learner-model.md" && echo "INTENSITY OK"
rm -rf "$TMP"
```
Expected: `MODEL SEEDED OK`, `INTENSITY OK`.

- [ ] **Step 4: Verify due-review parsing with a seeded past-due concept**

Run:
```bash
TMP="$(mktemp -d)"; mkdir -p "$TMP/df2tm/journal"
cp templates/learner-model.md "$TMP/df2tm/learner-model.md"
printf 'concept: test-slug | domain | shaky | last:2020-01-01 | due:2020-01-08 | reviews:1 | tags:x | active\n' >> "$TMP/df2tm/learner-model.md"
DF2TM_STATE_DIR="$TMP/df2tm" CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/handlers/session-start.sh \
 | python3 -c "import json,sys; c=json.load(sys.stdin)['hookSpecificOutput']['additionalContext']; assert 'test-slug' in c and 'review now (1)' in c, c; print('DUE PARSE OK')"
rm -rf "$TMP"
```
Expected: `DUE PARSE OK`.

- [ ] **Step 5: Commit**
```bash
git add templates/
git commit -m "feat(df2tm): add learner-model and journal seed templates"
```

---

## Task 4: `references/learner-model-format.md`

**Files:**
- Create: `skills/df2tm/references/learner-model-format.md`

- [ ] **Step 1: Write the format reference**

Document, for a future Claude updating state, exactly:
- **Location:** `~/.claude/df2tm/learner-model.md` (override `DF2TM_STATE_DIR`); journals at `~/.claude/df2tm/journal/<project>.md`.
- **Preferences block:** `intensity:` (one of `silent|ambient|active|socratic`), `known-topics:` (comma list), `prioritized-topics:` (comma list).
- **Concept line grammar** (exact, matching the template and hook):
  `concept: <slug> | <domain|ai-direction> | <new|shaky|solid> | last:YYYY-MM-DD | due:YYYY-MM-DD | reviews:N | tags:comma,sep | <active|known|muted>`
- **Update protocol:** when teaching a worth-remembering concept → upsert its line (slug = kebab-case), set `grasp`, compute `due` from grasp (new→+1d, shaky→+3d, solid→+10d, expanding via the lag effect), bump `reviews`, set `last` = today. On a recall hit → raise grasp + widen interval; on a miss → lower grasp + shorten interval (hypercorrection). On "I already know this" → set `known`. On "mute" → `muted`.
- **Journal line format:** `- YYYY-MM-DD · <concept-slug> · <one-line what/why>`.
- **Editing by hand:** safe; keep one concept per line; dates as `YYYY-MM-DD`.
- **Concurrency note:** last-write-wins; keep edits minimal.

- [ ] **Step 2: Verify it documents every field the hook reads**

Run:
```bash
for kw in "intensity:" "concept:" "due:" "active|known|muted" "journal"; do
  grep -Eq "$kw" skills/df2tm/references/learner-model-format.md && echo "OK $kw" || echo "MISSING $kw"
done
```
Expected: all `OK`.

- [ ] **Step 3: Commit**
```bash
git add skills/df2tm/references/learner-model-format.md
git commit -m "docs(df2tm): document learner-model format and update protocol"
```

---

## Task 5: Validation harness

**Files:**
- Create: `tests/validate.sh`

- [ ] **Step 1: Write the validator**

`tests/validate.sh`:
```bash
#!/usr/bin/env bash
# Structural validation for the df2tm plugin. Exit non-zero on any failure.
set -u
cd "$(dirname "$0")/.." || exit 1
fail=0
say() { printf '%-44s %s\n' "$1" "$2"; }

# 1) JSON files parse
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json hooks/hooks.json; do
  if python3 -c "import json; json.load(open('$f'))" 2>/dev/null; then say "json:$f" "OK"; else say "json:$f" "FAIL"; fail=1; fi
done

# 2) Hook script: syntax, executable, valid JSON output, exit 0
if bash -n hooks/handlers/session-start.sh 2>/dev/null; then say "hook:syntax" "OK"; else say "hook:syntax" "FAIL"; fail=1; fi
[ -x hooks/handlers/session-start.sh ] && say "hook:executable" "OK" || { say "hook:executable" "FAIL"; fail=1; }
TMP="$(mktemp -d)"
if DF2TM_STATE_DIR="$TMP/df2tm" CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/handlers/session-start.sh \
   | python3 -c "import json,sys; json.load(sys.stdin)" 2>/dev/null; then say "hook:json-output" "OK"; else say "hook:json-output" "FAIL"; fail=1; fi
rm -rf "$TMP"

# 3) SKILL.md frontmatter has name + description, body is lean
if [ -f skills/df2tm/SKILL.md ]; then
  head -5 skills/df2tm/SKILL.md | grep -q '^name:' && say "skill:name" "OK" || { say "skill:name" "FAIL"; fail=1; }
  head -8 skills/df2tm/SKILL.md | grep -q '^description:' && say "skill:description" "OK" || { say "skill:description" "FAIL"; fail=1; }
  words=$(wc -w < skills/df2tm/SKILL.md); [ "$words" -lt 1200 ] && say "skill:words($words<1200)" "OK" || { say "skill:words($words)" "WARN"; }
else say "skill:exists" "PENDING"; fi

# 4) Command frontmatter
if [ -f commands/df2tm.md ]; then
  head -6 commands/df2tm.md | grep -q '^description:' && say "cmd:description" "OK" || { say "cmd:description" "FAIL"; fail=1; }
else say "cmd:exists" "PENDING"; fi

# 5) Science library has all three tiers
if [ -f skills/df2tm/references/science-library.md ]; then
  for t in "Tier 1" "Tier 2" "Tier 3"; do
    grep -q "$t" skills/df2tm/references/science-library.md && say "lib:$t" "OK" || { say "lib:$t" "FAIL"; fail=1; }
  done
fi

[ "$fail" -eq 0 ] && echo "ALL STRUCTURAL CHECKS PASSED" || echo "VALIDATION FAILED"
exit $fail
```
(Note: `PENDING`/`WARN` are non-fatal; only `FAIL` sets a non-zero exit. Files authored in later tasks flip `PENDING` → `OK`.)

- [ ] **Step 2: Run it (manifests + hook should pass now)**
```bash
chmod +x tests/validate.sh && ./tests/validate.sh
```
Expected: `json:*` OK, `hook:*` OK, `skill:exists PENDING`, `cmd:exists PENDING`, and a final `VALIDATION FAILED` is **not** expected — exit 0 because pending files aren't failures. Confirm `echo $?` is `0`.

- [ ] **Step 3: Commit**
```bash
git add tests/validate.sh
git commit -m "test(df2tm): add structural validation harness"
```

---

## Task 6: `references/teaching-toolkit.md` (curated ~25 techniques)

**Use:** superpowers:writing-skills + skill-creator writing style (imperative/infinitive).

**Files:**
- Create: `skills/df2tm/references/teaching-toolkit.md`

- [ ] **Step 1: Author the toolkit**

Source: the **[toolkit]**-marked items in `docs/superpowers/plans/2026-05-31-df2tm-principles-source.md` (Tier 1). For EACH (~25), write one entry with this exact shape:
```markdown
### <Technique name>
- **What:** <1 line>
- **When (moment-type):** <first-encounter | decision-point | recurrence/due | cluster | ai-direction | wrap-up>
- **How (in a coding session):** <1–2 lines of concrete instruction>
- **Example:** <one short, real coding-context example of the aside Claude would produce>
```
Group under the moment-types so step 3 of the teaching loop can scan by moment. Keep each example genuinely coding-flavored (not generic).

- [ ] **Step 2: Validate coverage + format**

Run:
```bash
n=$(grep -c '^### ' skills/df2tm/references/teaching-toolkit.md); echo "entries=$n"; [ "$n" -ge 20 ] && echo "COUNT OK"
for kw in '\*\*What:\*\*' '\*\*When' '\*\*How' '\*\*Example'; do grep -q "$kw" skills/df2tm/references/teaching-toolkit.md && echo "OK $kw" || echo "MISSING $kw"; done
```
Expected: `entries` ≥ 20, `COUNT OK`, all `OK`.

- [ ] **Step 3: Commit**
```bash
git add skills/df2tm/references/teaching-toolkit.md
git commit -m "docs(df2tm): add curated teaching toolkit (~25 actionable techniques)"
```

---

## Task 7: `references/science-library.md` (all ~170 principles, 3 tiers, concise)

**Files:**
- Create: `skills/df2tm/references/science-library.md`

- [ ] **Step 1: Author the library from the canonical source**

Source: `docs/superpowers/plans/2026-05-31-df2tm-principles-source.md`. Structure:
```markdown
# df2tm Science Library

How to use: default to Tier 1 techniques, justified by Tier 2, grounded in Tier 3
only when the user is curious about the science. Tier 3 is the honest biological
"why it works" — never describe it as something you literally do.

## Tier 1 — Techniques (actionable)
- **<Name>** — <≤1-line what it is / how it shows up in teaching>. [toolkit → see teaching-toolkit.md]
...

## Tier 2 — Cognitive effects (justify / tune)
- **<Name>** — <≤1-line: the effect and the knob it implies>.
...

## Tier 3 — Neural mechanisms (ground; not performed)
- **<Name>** — <≤1-line plain-language gloss of the mechanism>.
...
```
Author **one bullet per item in every tier**, preserving the source's tier assignment. Toolkit items get the `[toolkit → …]` cross-reference (no duplicated how-to). If any brief principle is missing from the source file, add it to the best-fit tier.

- [ ] **Step 2: Validate tiers present + entry count is in range**

Run:
```bash
for t in "Tier 1 — Techniques" "Tier 2 — Cognitive effects" "Tier 3 — Neural mechanisms"; do
  grep -q "$t" skills/df2tm/references/science-library.md && echo "OK $t" || echo "MISSING $t"
done
n=$(grep -c '^- \*\*' skills/df2tm/references/science-library.md); echo "entries=$n"; [ "$n" -ge 150 ] && echo "COUNT OK" || echo "COUNT LOW"
```
Expected: three `OK`, `entries` ≥ 150, `COUNT OK`.

- [ ] **Step 3: Commit**
```bash
git add skills/df2tm/references/science-library.md
git commit -m "docs(df2tm): add tiered science library covering all ~170 principles"
```

---

## Task 8: `skills/df2tm/SKILL.md` (the core method, lean)

**Use:** superpowers:writing-skills (CSO description rules) + skill-creator (imperative style, progressive disclosure).

**Files:**
- Create: `skills/df2tm/SKILL.md`

- [ ] **Step 1: Write the frontmatter EXACTLY (description = when-to-use only, no workflow summary)**
```markdown
---
name: df2tm
description: Use when df2tm is active and the user is doing real work where a load-bearing concept could be taught, when the user asks to understand why something was done, wants to be quizzed or debriefed, adjusts teaching intensity, or uses steering phrases like "teach me", "quiz me", "df2tm off", or "I already know this".
---
```

- [ ] **Step 2: Write the body (target < 700 words; defer depth to references)**

Required sections, in order:
1. **Overview** — what df2tm is + core principle (relevance-gated, forward-looking; teach so the user trusts and can steer the work). 2–3 sentences.
2. **The teaching loop** — the 6 steps from spec §5 (Detect → Gate → Select → Deliver → Record → Reinforce), one line each. For "Select", say: pick from `references/teaching-toolkit.md` by moment-type. For "Record", point to `references/learner-model-format.md`.
3. **The relevance gate** — the four conditions (load-bearing, forward-useful, novel-enough, budget allows). Small inline flowchart ONLY here (the one non-obvious decision: teach vs stay silent).
4. **Calibration & steering** — the four intensities (default ambient), auto-calibration is explained-not-silent, and the steering-verb table.
5. **Guardrails** — never teach mid-emergency; asides skimmable + `🎓` marker (Von Restorff); per-session frequency cap; teaching never delays/blocks/replaces the work; insights stay in chat, never in committed files.
6. **Two axes** — domain + ai-direction (one line each).
7. **Commands** — one line: `/df2tm` controls + `quiz`/`debrief` subactions (see `commands/df2tm.md`).
8. **References** — bulleted pointers (REQUIRED markers, NO `@`): `references/teaching-toolkit.md`, `references/science-library.md`, `references/learner-model-format.md`.

Keep it imperative and scannable. Do NOT restate the science library or toolkit inline.

- [ ] **Step 3: Validate frontmatter + leanness + reference links**

Run:
```bash
head -4 skills/df2tm/SKILL.md | grep -q '^name: df2tm' && echo "NAME OK"
grep -q '^description: Use when' skills/df2tm/SKILL.md && echo "DESC OK"
python3 - <<'PY'
import re,io
t=open('skills/df2tm/SKILL.md').read()
fm=t.split('---',2)[1]
assert len(fm)<=1024, "frontmatter too long"
# description must NOT summarize workflow: ban tell-tale process verbs in the description line
desc=[l for l in fm.splitlines() if l.startswith('description:')][0].lower()
for bad in ['first','then','step','detect','record','reinforce']:
    assert bad not in desc, f"description summarizes workflow ('{bad}')"
print("FRONTMATTER OK")
PY
w=$(wc -w < skills/df2tm/SKILL.md); echo "words=$w"; [ "$w" -lt 900 ] && echo "LEAN OK" || echo "TOO LONG"
for r in teaching-toolkit science-library learner-model-format; do grep -q "$r" skills/df2tm/SKILL.md && echo "ref:$r OK" || echo "ref:$r MISSING"; done
```
Expected: `NAME OK`, `DESC OK`, `FRONTMATTER OK`, `words` < 900 → `LEAN OK`, all `ref:* OK`.

- [ ] **Step 4: Run the structural validator (skill checks now flip to OK)**
```bash
./tests/validate.sh; echo "exit=$?"
```
Expected: `skill:name OK`, `skill:description OK`, `lib:Tier * OK`, `exit=0`.

- [ ] **Step 5: Commit**
```bash
git add skills/df2tm/SKILL.md
git commit -m "feat(df2tm): add core teaching-method skill (SKILL.md)"
```

---

## Task 9: `/df2tm` command (single, arg-routed)

**Files:**
- Create: `commands/df2tm.md`

- [ ] **Step 1: Write the command**

`commands/df2tm.md`:
```markdown
---
description: Control df2tm and run learning actions — status, on/off, intensity, mark-known, quiz, debrief.
argument-hint: "[status | on | off | intensity <silent|ambient|active|socratic> | known <topic> | quiz | debrief]"
allowed-tools: Read, Write, Edit
---

# /df2tm $ARGUMENTS

Load the df2tm skill if it is not already loaded, then interpret `$ARGUMENTS`
(default to `status` when empty). Operate on `~/.claude/df2tm/learner-model.md`
(honor `DF2TM_STATE_DIR` if set). Keep all edits minimal and human-readable.

- **status** — report current `intensity`, number of concepts tracked, number due for review today, and the next few due. Perform no other work.
- **on** / **off** — `off` sets `intensity: silent`; `on` restores `intensity: ambient` (or the last non-silent level if recorded). Confirm the change.
- **intensity <silent|ambient|active|socratic>** — set the `intensity:` preference; confirm and state in one line what changes.
- **known <topic>** — mark matching concept line(s) `known` so they are never re-taught; if none match, append `<topic>` to `known-topics:`.
- **quiz** — run an active-recall session over due (or named) concepts: ask one question at a time, wait for the answer, then give feedback (apply the hypercorrection effect on misses). Update each concept's `grasp` and `due` per `references/learner-model-format.md`. Follow the quiz protocol in the df2tm skill.
- **debrief** — produce a structured recap of the current task's key concepts plus 2–3 recall questions, then upsert those concepts. Follow the debrief protocol in the df2tm skill.
```

- [ ] **Step 2: Validate**
```bash
head -5 commands/df2tm.md | grep -q '^description:' && echo "DESC OK"
grep -q '\$ARGUMENTS' commands/df2tm.md && echo "ARGS OK"
for sub in status on off intensity known quiz debrief; do grep -q "\*\*$sub" commands/df2tm.md && echo "sub:$sub OK" || echo "sub:$sub MISSING"; done
```
Expected: `DESC OK`, `ARGS OK`, all `sub:* OK`.

- [ ] **Step 3: Commit**
```bash
git add commands/df2tm.md
git commit -m "feat(df2tm): add arg-routed /df2tm command (status/on/off/intensity/known/quiz/debrief)"
```

---

## Task 10: README

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write the README**

Cover: one-paragraph pitch (the two goals + "improve yourself, don't just delegate"); **Install** (`/plugin marketplace add globalanomalyindex/df2tm` then `/plugin install df2tm@df2tm`, or local path during dev); **How it works** (always-on SessionStart layer, ambient by default); **Steering** (the verb list); **Commands** (`/df2tm`, `quiz`, `debrief`); **State & privacy** (everything in `~/.claude/df2tm/`, local only; how to relocate via `DF2TM_STATE_DIR`; how to reset); **Uninstall**; a one-line nod to the science behind it (link `skills/df2tm/references/science-library.md`).

- [ ] **Step 2: Validate key sections present**
```bash
for s in Install Steering Commands Privacy; do grep -qi "$s" README.md && echo "OK $s" || echo "MISSING $s"; done
```
Expected: all `OK`.

- [ ] **Step 3: Commit**
```bash
git add README.md
git commit -m "docs(df2tm): add README with install, usage, and privacy"
```

---

## Task 11: Skill triggering + behavioral evals (writing-skills TDD)

**Use:** superpowers:writing-skills (RED → GREEN → REFACTOR with subagents).

**Files:**
- Create: `tests/triggering/should-trigger.md`
- Create: `tests/triggering/should-not-trigger.md`

- [ ] **Step 1: Write scenarios**

`should-trigger.md` — situations where df2tm SHOULD teach/activate (one per bullet, each a realistic prompt + the expected df2tm behavior):
- A normal feature task that surfaces a load-bearing concept (e.g., choosing a debounce vs throttle) → a `🎓` woven-inline aside appears, concept recorded.
- "why did you do that?" → a self-explanation/elaborative-interrogation response.
- "quiz me" → an active-recall session over due concepts.
- A concept previously taught (seeded `due` today) recurs → a recall check fires.
- An obvious AI-direction moment (user gave an under-specified prompt) → a one-line prompting tip.

`should-not-trigger.md` — situations where df2tm should STAY SILENT or back off:
- User is firefighting a production outage / says "just do it" → no teaching.
- Pure trivia with no forward use → no aside.
- A concept the learner-model marks `known` → not re-taught.
- `intensity: silent` → no teaching (journaling only).

- [ ] **Step 2: RED — baseline without the skill**

For 3–4 scenarios, dispatch a subagent **without** loading the df2tm skill (plain task prompt). Record verbatim: does it teach? skimmably? record state? Capture the gaps. (This is the "watch it fail" step.)

- [ ] **Step 3: GREEN — with the skill**

Re-run the same scenarios with the df2tm SessionStart directive + skill available. Verify: teaches only when gated true, uses the `🎓` marker, stays silent on the should-not cases, respects `known`/`silent`. Document results inline in the scenario files under a `## Results` heading.

- [ ] **Step 4: REFACTOR — close loopholes**

If a should-not case taught anyway, or a should case stayed silent, add an explicit counter to `SKILL.md` (e.g., a Red-Flags line or a sharper gate condition), then re-run that scenario. Repeat until all pass. Commit any SKILL.md changes with a `fix(df2tm): close <loophole>` message.

- [ ] **Step 5: Commit**
```bash
git add tests/triggering/ skills/df2tm/SKILL.md
git commit -m "test(df2tm): add triggering/behavioral evals and close loopholes found"
```

---

## Task 12: End-to-end validation + packaging readiness

- [ ] **Step 1: Full structural pass**
```bash
./tests/validate.sh; echo "exit=$?"
```
Expected: every line `OK` (no `FAIL`, no `PENDING`), `ALL STRUCTURAL CHECKS PASSED`, `exit=0`.

- [ ] **Step 2: Simulated cold-start integration test (temp state, no real env touched)**
```bash
TMP="$(mktemp -d)"
out=$(DF2TM_STATE_DIR="$TMP/df2tm" CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/handlers/session-start.sh)
echo "$out" | python3 -c "import json,sys; c=json.load(sys.stdin)['hookSpecificOutput']['additionalContext']; assert 'df2tm is active' in c and 'due for review' in c.lower() or 'review now' in c; print('COLD START OK')"
test -f "$TMP/df2tm/learner-model.md" && echo "STATE SEEDED OK"
rm -rf "$TMP"
```
Expected: `COLD START OK`, `STATE SEEDED OK`.

- [ ] **Step 3: Optional skill validation via skill-creator**

If `anthropic-skills:skill-creator`'s `quick_validate.py` is available, run it on `skills/df2tm`; otherwise rely on `tests/validate.sh`. Record which was used.

- [ ] **Step 4: Final commit + tag**
```bash
git add -A
git commit -m "chore(df2tm): v0.1.0 — end-to-end validation green" || echo "nothing to commit"
git tag v0.1.0
```

- [ ] **Step 5: Hand the user install instructions (do NOT auto-install)**

Print, for the user to run themselves when ready:
```
/plugin marketplace add <path-or-globalanomalyindex/df2tm>
/plugin install df2tm@df2tm
```
Note that installing wires the SessionStart hook and seeds `~/.claude/df2tm/`.

---

## Self-Review (plan vs. spec)

**Spec coverage:**
- Thesis, two goals, two axes → SKILL.md §1/§6 (Task 8). ✓
- Plugin architecture/layout → Tasks 1–3, 8–10 (File Structure). ✓
- SessionStart lean-injection activation + due reviews + first-run seeding → Task 2. ✓
- State at `~/.claude/df2tm/` (model + journal), outside plugin → Tasks 2–4. ✓
- Teaching loop, relevance gate → SKILL.md §2/§3 (Task 8). ✓
- Calibration (4 intensities, default ambient), steering verbs → SKILL.md §4 + command (Tasks 8–9). ✓
- Guardrails + Von Restorff marker → SKILL.md §5 (Task 8) + hook directive (Task 2). ✓
- Learner model + journal schema → Tasks 3–4. ✓
- Toolkit (~25) + science library (all ~170, 3 tiers) → Tasks 6–7 + principles-source. ✓
- Commands `/df2tm` + quiz + debrief (subcommand routing resolved = single arg-routed command) → Task 9. ✓
- Data flow, error handling (hook never fails, defensive parse, privacy) → Task 2 + validator. ✓
- Testing (triggering + behavioral + structural) → Tasks 5, 11, 12. ✓

**Known deviations from spec (intentional):**
- **SessionEnd journal nudge dropped from v1.** Spec §4/§11 mention it; a SessionEnd hook cannot prompt the model after the turn ends, so journaling is driven by the skill *during* the session (Task 8 §2 "Record", Task 4 protocol). Recorded as a future enhancement (spec §16 spirit). The hook surface is SessionStart-only, matching the proven learning-output-style pattern.
- **Marker glyph fixed to `🎓`** (spec left exact glyph to build time). Resolved here for consistency across hook directive + SKILL.md.

**Placeholder scan:** none — deterministic files are shown in full; prose tasks specify exact structure + acceptance greps + source. No "TBD"/"handle edge cases"/"write tests for the above".

**Type/format consistency:** the concept-line grammar is identical in the template (Task 3), the hook parser (Task 2), the format reference (Task 4), and the command (Task 9): `concept: <slug> | <axis> | <grasp> | last:DATE | due:DATE | reviews:N | tags:.. | <status>`. `intensity:` values `silent|ambient|active|socratic` are identical across hook, template, SKILL.md, and command. Marker `🎓` identical in hook + SKILL.md.
