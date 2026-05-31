# df2tm — "Don't Forget To Teach Me" — Design Spec

- **Date:** 2026-05-31
- **Status:** Approved (brainstorming complete) — ready for implementation planning
- **Author:** Chris Fiore (with Claude Code)
- **Artifact type:** Distributable Claude Code plugin

---

## 1. Overview & thesis

df2tm is an **always-on learning layer** for Claude Code. While Claude does real work on *any* project, df2tm selectively surfaces the concepts that are *load-bearing for the work in front of the user* — woven in lightly — and remembers them across sessions so they actually stick.

The core problem it solves: Claude Code does great work, but the user is left out of the loop and learns nothing. df2tm fuses *doing* and *learning* into one process, addressing a common fear about AI — **that it replaces our work instead of helping us improve ourselves.**

### Two goals (the success criteria)

1. **Trust through legibility.** By surfacing the *why* behind Claude's decisions, Claude's reasoning becomes inspectable. The user gets *justified* trust, not blind trust — and can catch a wrong assumption before it ships.
2. **Improvement, not replacement.** A persistent learner model plus spaced repetition means the user compounds knowledge instead of re-outsourcing it every time.

### Two teaching axes

- **Domain axis** — the concept live in the work (a language feature, an algorithm, an architectural trade-off, a tool).
- **AI-direction axis** *(distinctive)* — how to steer Claude better ("notice you had to specify X mid-task; leading with that next time saves a round-trip"). This turns the user into a sharper prompt-engineer/director.

### Design principle: relevance-gated and forward-looking

df2tm does **not** turn every session into a class. It teaches only concepts that are (a) live in the current work and (b) forward-useful — knowledge that helps the user understand Claude's work and direct the AI better as the work continues. Persistence exists to reinforce *those* concepts, not to log everything.

---

## 2. Non-goals (YAGNI)

- Not a general tutoring system or curriculum — it teaches only what the active work surfaces.
- Not a constant explainer — silence is the default when nothing is worth teaching.
- v1 does **not** target Windows hook scripts (bash `.sh` only; Windows is a future enhancement).
- v1 does **not** implement multi-machine state sync — state is local to one machine.
- df2tm never blocks, delays, or substitutes for doing the task correctly. Teaching is strictly additive.

---

## 3. Users & context

- **Primary user:** an individual developer using Claude Code across many projects who wants to learn while delegating.
- **Environment:** the user already runs the superpowers and ruflo plugins (both inject context at session start), so df2tm must be a **good citizen** with a lean session-start footprint.
- **Distribution intent:** packaged as a shareable plugin so others can install it.

---

## 4. Architecture — the plugin

df2tm ships as a distributable Claude Code plugin. Layout (grounded in real installed plugins such as `superpowers` and `learning-output-style`):

```
df2tm/                              # distributable repo (this project root)
├── .claude-plugin/
│   ├── plugin.json                 # manifest (name, version, author, homepage, repo, license, keywords)
│   └── marketplace.json            # makes it installable as its own marketplace (source: ".")
├── skills/df2tm/
│   ├── SKILL.md                    # the teaching METHOD (loaded on demand)
│   └── references/
│       ├── teaching-toolkit.md     # curated ~20-30 actionable techniques + coding examples
│       ├── science-library.md      # full ~150 principles, tiered
│       └── learner-model-format.md # state schema + update protocol
├── commands/
│   ├── df2tm.md                    # /df2tm — status & controls (on/off/intensity/mark-known)
│   ├── quiz.md                     # /df2tm quiz — active-recall session on due concepts
│   └── debrief.md                  # /df2tm debrief — structured end-of-task recap
├── hooks/
│   ├── hooks.json                  # SessionStart (+ SessionEnd)
│   └── handlers/
│       ├── session-start.sh        # inject lean directive + surface due reviews; seed state on first run
│       └── session-end.sh          # nudge a journal update
├── templates/                      # seed files copied to the state dir on first run
│   ├── learner-model.md
│   └── journal.md
└── README.md
```

### 4.1 Activation linchpin — SessionStart hook with lean injection

A **SessionStart hook** injects a *lean* operating directive every session (a dozen lines, not an essay), following the proven `learning-output-style` / `explanatory-output-style` pattern of emitting `hookSpecificOutput.additionalContext`. The directive states: df2tm is active; weave learning per the df2tm skill; concepts currently due for review: [list]; current intensity: [level]; recognized steering verbs: [...].

Depth lives in `SKILL.md` and loads only when Claude needs the full method or to update state. This keeps per-session context cheap while guaranteeing df2tm is *always considered* and that spaced-repetition reminders *actually fire* (the literal "don't forget").

**Hook contract:** the handler must never block or error the session — it always exits 0 and emits valid JSON, degrading gracefully if state is missing or unreadable.

### 4.2 State store — outside the plugin

The learner model and journal live in **`~/.claude/df2tm/`**, *not* inside the plugin folder (which is replaced on every update). State is cross-project and about the user, kept separate from Claude's per-project memory. On first run the session-start hook seeds the store from `templates/`.

---

## 5. The teaching loop (what Claude runs as it works)

1. **Detect** — note concepts genuinely present in the work as decisions get made.
2. **Gate** — teach only if *all* hold:
   - **Load-bearing** — materially shapes the work, not trivia.
   - **Forward-useful** — helps the user follow or steer what's coming.
   - **Novel-enough** — the learner model indicates the user doesn't already own it.
   - **Budget allows** — under the per-session frequency cap, intensity ≥ ambient, user not firefighting.
3. **Select technique** — match the moment (see toolkit):
   - *First encounter* → mental-model + analogy (elaborative encoding + dual coding).
   - *Decision with alternatives* → "why this over X?" (elaborative interrogation / self-explanation).
   - *Concept now due* → recall prompt (testing effect + spaced repetition; hypercorrection on misses).
   - *Related cluster* → interleaving / chunking.
   - *AI-direction moment* → name the prompting pattern.
4. **Deliver** — woven-inline by default, 1–3 sentences, clearly marked (Von Restorff) so it's skimmable. Escalate to a callout / debrief / Socratic prompt only when the concept is pivotal or the user is engaging.
5. **Record** — concepts clearing a higher "worth remembering" bar are written to the learner model with a review date; a one-line journal entry is always appended.
6. **Reinforce** — the session-start hook lists what's due; when a due concept *recurs in real work*, Claude does a quick recall check right there (encoding specificity), then updates grasp and reschedules.

---

## 6. Calibration

### Four intensities
`silent` (no teaching, but still journals so nothing is lost) → **`ambient` (DEFAULT: sparse, only high-value concepts)** → `active` (more frequent + occasional callouts and recall checks) → `socratic` (pauses for the user to predict/recall before revealing).

### Auto-calibration
The level nudges from user behavior — engaging (asking follow-ups, answering recall prompts) raises it; ignoring or saying "just do it" lowers it. Calibration is always **explained, never silently changed.**

### Steering verbs (override any time, persist to the learner model)
"teach me more / less," "df2tm off / on," "just do it," "quiz me," "why did you do that," "debrief," "I already know this" (marks a concept known so it is never re-taught). Explicit steering wins over auto-calibration.

---

## 7. Guardrails (do no harm)

- Never teach mid-emergency (debugging a production fire, user clearly rushed) — defer to a debrief offer.
- Teaching asides are always skimmable and visually distinct — ignoring them costs nothing about the work itself.
- A per-session frequency cap ensures it never becomes noise; when many concepts qualify, pick the highest-leverage and let the rest go (or batch into a debrief).
- Teaching never delays, blocks, or substitutes for doing the task correctly.
- Insights appear in the conversation only — never written into committed code or files.

### Marker convention (Von Restorff effect)
One consistent, skimmable marker distinguishes teaching from work narration: an inline `🎓` lead-in, and a `★ df2tm ───` box for callouts. Exact glyphs finalized at build time; the principle is *one consistent, scannable marker.*

---

## 8. Learner model & journal (`~/.claude/df2tm/`)

### `learner-model.md` — one entry per tracked concept
- concept name + 1-line gist
- axis (domain / ai-direction)
- first taught (date), times reviewed, last reviewed
- apparent grasp (new / shaky / solid)
- **next review due (date)** — interval widens as grasp solidifies (lag effect)
- tags (project, language, domain) for context-cued recall (encoding specificity)
- status (active / known / muted)

A header preference block stores: default intensity, known-topics-to-skip, prioritized topics.

### `journal/<project>.md` — append-only, skimmable
date · concept · one line of what was taught and why. This is the "lightweight journal" half — no scheduling engine.

### Forward-looking selection
The model flags concepts likely to *recur in the current project*, so Claude prioritizes teaching what will pay off as the work continues.

---

## 9. Principles handling — toolkit + science library

### `teaching-toolkit.md` — curated ~20–30 actionable techniques
Each entry: what it is (1 line) · when to use it in a coding session · a concrete coding-context example · the moment-type it fits. This is what Claude reaches for in loop step 3.

### `science-library.md` — all ~150 principles, three tiers (concise: 1 line each; toolkit entries get full treatment)
- **Tier 1 — Techniques** (actionable): active recall, spaced repetition, elaborative interrogation, dual coding, interleaving, chunking, generation effect, self-explanation, desirable difficulties, Von Restorff, Zeigarnik, analogical transfer, etc.
- **Tier 2 — Cognitive effects** (justify *how* a technique is applied): testing effect, levels of processing, encoding specificity, primacy/recency, cognitive load, schema activation, etc.
- **Tier 3 — Neural mechanisms** (the honest "why it works" backing, never pretended to be something Claude "does"): LTP, CREB, synaptic consolidation, theta-gamma coupling, glymphatic clearance, BDNF, etc.

SKILL.md selection heuristic: default to Tier-1 techniques, justified by Tier-2, grounded in Tier-3 only when the user is curious about the science.

The full ~150-item list from the user's brief is the canonical source for `science-library.md`.

---

## 10. Commands (subcommands under `/df2tm`)

- **`/df2tm`** — show status (intensity, # concepts tracked, # due) and controls (on/off, set intensity, mark topics known).
- **`/df2tm quiz`** — run a focused active-recall session over due/selected concepts (testing effect on demand).
- **`/df2tm debrief`** — structured recap of the current task's key concepts + 2–3 recall questions (end-of-task consolidation on demand).

> **Routing note (resolve in implementation plan):** plugin command files map to command *names*, so the bare `commands/quiz.md` / `commands/debrief.md` layout would yield top-level `/quiz` and `/debrief`. To honor the "subcommands under `/df2tm`" decision, the plan must choose one of: (a) a `commands/df2tm/` subdirectory for namespaced commands (e.g. `/df2tm:quiz`), or (b) a single `commands/df2tm.md` that parses a subcommand argument (`/df2tm quiz`). The file tree in §4 is indicative, not final.

---

## 11. Data flow

1. **Session start** → hook reads `~/.claude/df2tm/learner-model.md`, computes due concepts, emits a lean directive + due list as `additionalContext`. First run: seeds state from `templates/`.
2. **During work** → Claude follows the teaching loop; the df2tm skill loads on demand for the full method and the toolkit/science-library references.
3. **On teaching a recordable concept** → Claude appends to `journal/<project>.md` and upserts the concept in `learner-model.md` with a next-review date.
4. **On a due concept recurring** → recall check → grasp + schedule updated in `learner-model.md`.
5. **Session end** → hook nudges a journal flush (best-effort).
6. **Commands** → operate directly on the state store and the current task context.

---

## 12. Error handling & edge cases

- **Missing state dir / first run** → hook seeds from `templates/`; if seeding fails, df2tm degrades to in-session-only and never errors the session.
- **Corrupt / unreadable `learner-model.md`** → df2tm continues without persistence, notes the issue, does not block work.
- **Hook robustness** → handlers always exit 0 and emit valid JSON; `additionalContext` kept short.
- **Concurrent sessions** → journal appends are safe; learner-model updates are last-write-wins for v1 (documented risk).
- **No git in the user's project** → df2tm has no git dependency.
- **Privacy** → all state is local under `~/.claude/df2tm/`; nothing leaves the machine. Journals may contain project concept names — local only.
- **No teaching leakage** → insights stay in conversation, never in committed artifacts.

---

## 13. Testing strategy

- **Skill triggering evals** (per skill-creator / writing-skills): scenarios that should and should not activate df2tm.
- **Behavioral scenarios:**
  - A teachable concept appears → woven-inline aside with marker is produced.
  - "just do it" → df2tm backs off and persists the lowered intensity.
  - A due concept recurs in real work → recall check fires; grasp/schedule update.
  - `/df2tm quiz` and `/df2tm debrief` produce the expected sessions.
  - First-run seeding creates `~/.claude/df2tm/` from templates.
- **Hook tests:** `session-start.sh` emits valid JSON, exits 0, lists due reviews; tolerates missing/corrupt state.
- **Calibration tests:** engagement raises level; disengagement lowers it; changes are explained.

---

## 14. Build & distribution notes

- Built using `superpowers:writing-skills` (for SKILL.md craft and skill-writing discipline) and `anthropic-skills:skill-creator` (for scaffolding and triggering evals).
- The plugin repo doubles as its own marketplace (`.claude-plugin/marketplace.json`, `source: "."`) so it can be installed via `/plugin marketplace add <repo>`.
- The state-file format is intentionally hook-friendly so the SessionStart reminder works reliably from day one.

---

## 15. Decisions log (from brainstorming)

| Decision | Choice |
|---|---|
| Teaching texture (default) | **Woven inline**, escalating to callout/debrief/Socratic when warranted |
| Memory model | **Persistent learner model + lightweight journal**, relevance-gated, forward-looking, includes AI-direction axis |
| Principles handling | **Curated toolkit (~20–30) + full ~150 science library** (neuro mechanisms as "why it works" backing) |
| Activation | **Always-on layer** via SessionStart hook (lean injection) + broad trigger; natural-language steering |
| Build target | **Full distributable plugin** (skill + commands + hooks + templates + manifest) |
| Default intensity | **Ambient** |
| Command shape | **Subcommands** under `/df2tm` (quiz, debrief) |
| Science-library depth (v1) | **All 150, concise** (1-line each in tiers; toolkit entries get full how-to) |

---

## 16. Open questions / future enhancements

- Windows hook support (`.cmd` wrapper like superpowers uses).
- Optional multi-machine state sync.
- Richer grasp model (confidence scoring) beyond new/shaky/solid.
- Concurrency-safe learner-model writes if multi-session use becomes common.
