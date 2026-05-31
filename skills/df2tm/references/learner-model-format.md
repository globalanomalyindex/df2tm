# df2tm — Learner Model Format Reference

> This is an operational reference for Claude instances reading or updating df2tm state.
> For the teaching method and science, read the df2tm skill itself.

---

## 1. File Locations

| File | Path |
|------|------|
| Learner model | `~/.claude/df2tm/learner-model.md` |
| Journal (per project) | `~/.claude/df2tm/journal/<project>.md` |

Override the base directory by setting `DF2TM_STATE_DIR` in the environment.
The SessionStart hook seeds `learner-model.md` from `templates/learner-model.md` on first run.

---

## 2. Preferences Block

Located under the `## Preferences` heading. The SessionStart hook reads `intensity:` with
`grep -m1 '^intensity:'`; update it in-place when the user steers.

```
intensity: ambient
known-topics:
prioritized-topics:
```

| Field | Values | Meaning |
|-------|--------|---------|
| `intensity:` | `silent \| ambient \| active \| socratic` | Teaching density for this user |
| `known-topics:` | comma-separated slugs or labels | Subjects to skip entirely |
| `prioritized-topics:` | comma-separated slugs or labels | Subjects to surface first |

---

## 3. Concept Line Grammar

One line per tracked concept, under the `## Concepts` heading.
The SessionStart hook reads these with `grep '^concept:'`.

**Exact format (pipe-delimited, no optional fields):**

```
concept: <slug> | <domain|ai-direction> | <new|shaky|solid> | last:YYYY-MM-DD | due:YYYY-MM-DD | reviews:N | tags:comma,sep | <active|known|muted>
```

**Example:**
```
concept: encoding-specificity | domain | shaky | last:2026-05-24 | due:2026-05-31 | reviews:2 | tags:memory,recall | active
```

### Field definitions

| Position | Field | Format | Notes |
|----------|-------|--------|-------|
| 1 | `slug` | kebab-case | Stable identifier; never rename after creation |
| 2 | concept type | `domain` or `ai-direction` | `domain` = general CS/ML; `ai-direction` = Claude-specific behaviour |
| 3 | grasp | `new \| shaky \| solid` | User's current understanding level |
| 4 | `last:` | `YYYY-MM-DD` | Date this concept was last taught or reviewed |
| 5 | `due:` | `YYYY-MM-DD` | Next review date; hook flags concept when `due ≤ today` |
| 6 | `reviews:` | integer `N` | Cumulative review count (starts at 0, bump on each upsert) |
| 7 | `tags:` | comma-separated strings | Topic labels; no spaces around commas |
| 8 | status | `active \| known \| muted` | Hook skips `known` and `muted` lines entirely |

All eight fields are required; preserve the `|` separators and single-space padding.

---

## 4. Update Protocol

### To record a concept for the first time

Append a new `concept:` line with grasp=`new` (or `shaky` if the user clearly already half-knew it), reviews=`1`, last=today, due=today + 1 day (or today + 3 days if grasp=`shaky`).

### Interval table (grasp-driven; deterministic)

The review interval is a function of `grasp` alone — no multipliers, no per-review growth:

| Grasp | due = today + … |
|-------|-----------------|
| `new` | today + 1 day |
| `shaky` | today + 3 days |
| `solid` | today + 10 days |

Intervals widen through **grasp promotion**, not a per-review multiplier. `reviews` is a stat
counter only — it is NOT part of the interval formula.

### To upsert after teaching or reviewing

1. Find the existing line by `slug`.
2. Set `last:` to today.
3. Increment `reviews:` by 1.
4. Update `grasp` and recompute `due` per the rules below.

### On a recall hit (user remembers correctly)

Promote grasp one step (`new`→`shaky`→`solid`). Set `due` from the new higher grasp's interval.
Set `last`=today; increment `reviews`. A concept at `solid` that is recalled correctly again
may be graduated to status `known` (mastered) at your discretion.

### On a recall miss (user fails to recall)

Demote grasp one step (`solid`→`shaky`→`new`). Set `due` to the shorter interval for the new
lower grasp (hypercorrection: schedule sooner, not later). Set `last`=today; increment `reviews`.

### Worked example

A concept recorded as `new` today → `due` tomorrow. Recalled correctly next session → promote
to `shaky`, `due` in 3 days. Recalled correctly again → promote to `solid`, `due` in 10 days.
Missed → demote to `shaky`, `due` in 3 days.

### On "I already know this"

Set status to `known`. **`known`** means the user has asserted mastery — the concept is
permanently retired and will never be re-taught or surfaced again. The SessionStart hook
skips all `known` lines.

### On user muting a concept

Set status to `muted`. **`muted`** means the user has silenced this concept for now — it will
not be surfaced in future sessions, but may be revisited later (e.g. by changing status back to
`active`). The SessionStart hook also skips all `muted` lines.

---

## 5. Journal Line Format

To append a journal entry, add one line to `~/.claude/df2tm/journal/<project>.md`:

```
- YYYY-MM-DD · <concept-slug> · <one-line what/why>
```

The separator is a middle dot `·` (U+00B7), not a period or bullet point.
Use the current project name (or `global`) as the filename stem. Create the file if absent.

---

## 6. Editing by Hand

The format is designed to be hand-editable:

- One `concept:` line per concept; no multi-line entries.
- Dates must be `YYYY-MM-DD`; no other formats are parsed.
- Blank lines and comment lines (HTML comments or `#`) are ignored by the hook.
- Reordering lines is safe.

---

## 7. Concurrency

Multiple simultaneous Claude sessions write the same file. The hook is read-only at session
start; writes happen inline during the session. Strategy: last-write-wins. To minimise
conflict surface, update only the specific `concept:` line(s) touched in the current session
rather than rewriting the whole file.
