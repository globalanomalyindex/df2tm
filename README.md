# df2tm — Don't Forget To Teach Me

**df2tm** is an always-on, relevance-gated learning layer for Claude Code. As Claude does real work on your actual projects, it teaches the concepts behind the work — woven inline, right when they matter — and remembers what you know across sessions. You get Claude's full execution speed and grow your own understanding at the same time, instead of just delegating. df2tm teaches on two axes: the **domain concept** live in the code (language features, algorithms, architectural trade-offs) and the **AI-direction axis** — how to steer Claude more precisely next time, so you become a sharper director with every session.

---

## How it works

A **SessionStart hook** fires at the start of every session. It reads your learner model, surfaces any concepts due for spaced-repetition review, and injects a lean operating directive — all before you type your first message. No setup per-project; it's always there.

During work, df2tm gates every potential aside through a four-part relevance check (load-bearing, forward-useful, novel-enough, budget-allows) before teaching anything. When an aside passes, it appears inline marked with **🎓** — skimmable at zero cost to the work. The default intensity is **ambient**: sparse, high-value only. Silence is always correct when nothing clears the gate.

Your learner model lives in `~/.claude/df2tm/learner-model.md`. Every concept Claude teaches is recorded with a grasp level (`new → shaky → solid`) and a spaced-repetition due date. Future sessions surface due concepts at startup and weave in recall checks when those concepts reappear in real work.

---

## Install

```
/plugin marketplace add globalanomalyindex/df2tm
/plugin install df2tm@df2tm
```

Installing wires the SessionStart hook and seeds `~/.claude/df2tm/` on the first session. The state directory is created automatically; no manual setup required.

For local development, you can install directly from a local checkout:

```
/plugin marketplace add /path/to/df2tm
/plugin install df2tm@df2tm
```

---

## Steering

Say any of these naturally — no slash command needed:

| Phrase | Effect |
|---|---|
| `teach me more` | Raise intensity one level |
| `teach me less` | Lower intensity one level |
| `df2tm off` / `just do it` | Set silent; persists across sessions |
| `df2tm on` | Restore ambient (or your last active level) |
| `why did you do that` | Explain the reasoning behind the last decision |
| `quiz me` | Active-recall session on due concepts |
| `debrief` | Structured recap of the session's key concepts + 2–3 recall questions |
| `I already know this` | Mark the current concept permanently retired; never re-taught |

Explicit steering always wins over auto-calibration. df2tm also auto-calibrates: engaging with asides (follow-up questions, answering recall prompts) nudges intensity up; ignoring them nudges it down. Any calibration change is explained, never silent.

---

## Commands

`/df2tm` gives you direct control:

| Command | What it does |
|---|---|
| `/df2tm` or `/df2tm status` | Report current intensity, concepts tracked, number due today, and the next few due |
| `/df2tm on` / `/df2tm off` | Toggle teaching on or off |
| `/df2tm intensity <level>` | Set intensity explicitly: `silent`, `ambient`, `active`, or `socratic` |
| `/df2tm known <topic>` | Mark a topic as already known — it will never be re-taught |
| `/df2tm quiz` | Run an active-recall session |
| `/df2tm debrief` | Structured recap with recall questions for the current task |

**Intensities:**

| Level | Behavior |
|---|---|
| `silent` | No teaching; journals silently so nothing is lost |
| `ambient` | **Default** — sparse, woven inline, high-value concepts only |
| `active` | More frequent; adds occasional callouts and recall checks |
| `socratic` | Pauses for you to predict or recall before revealing |

---

## State & privacy

All state is local on your machine. Nothing is sent anywhere.

| File | Contents |
|---|---|
| `~/.claude/df2tm/learner-model.md` | Preferences, intensity, and one line per tracked concept |
| `~/.claude/df2tm/journal/<project>.md` | One-line journal entry per concept per project, by date |

To relocate state (e.g. to a synced folder), set `DF2TM_STATE_DIR` in your environment before starting Claude Code:

```bash
export DF2TM_STATE_DIR="$HOME/Dropbox/.claude/df2tm"
```

To reset all learning history, delete the directory:

```bash
rm -rf ~/.claude/df2tm
```

The state directory is re-seeded automatically on the next session start.

---

## Uninstall

```
/plugin uninstall df2tm@df2tm
```

Optionally remove your learner model and journals:

```bash
rm -rf ~/.claude/df2tm
```

---

## The science

df2tm's teaching method draws on approximately 170 learning-science principles spanning evidence-based techniques, cognitive effects, and neural mechanisms — see [`skills/df2tm/references/science-library.md`](skills/df2tm/references/science-library.md).

---

## License

MIT — see [plugin.json](.claude-plugin/plugin.json).
