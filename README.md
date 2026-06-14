# df2tm 🎓

**don't forget to teach me** is an always-on learning layer for [claude code](https://claude.com/claude-code).

> claude code does great work. df2tm makes sure *you* learn from it. as claude works on your real projects, it teaches the concepts behind what it's doing and remembers what you've learned across sessions. so, you keep claude's full speed and grow your own understanding at the same time!

this is my answer to the pressing question a lot of young people like myself have about ai: *how do we make it help us improve, instead of just replacing our work?*

---

## what df2tm does practically

it:

- **teaches while claude works:** when a load-bearing concept shows up in your task, df2tm drops a short, skimmable `🎓` aside explaining it and then gets out of the way.
- **remembers across sessions:** concepts worth keeping go into a local learner model with spaced-repetition review dates. next time they come up, df2tm checks what stuck.
- **stays quiet when it should:** a relevance gate means it only teaches what's *load-bearing*, *forward-useful*, and *new to you*. during a production firefight or a "just do it," it says nothing.
- **makes you a better director:** beyond the code itself, df2tm teaches you to steer claude better with sharper prompts, when to delegate vs. learn, when to ask for the reasoning, and so on.

### what it looks like

> **you:** typing in this search box is laggy. it re-filters 5000 items on every keystroke. make it responsive. 
>
> **claude:** *(makes the fix with `useMemo` + `useDeferredValue`)*
>
> 🎓 **`useDeferredValue`** (react 18+) is the idiomatic alternative to a `setTimeout` debounce — it tells react "the input is urgent, the filtered list can lag a frame." better than a fixed delay because react schedules it by actual frame availability. *(saved to your learner model — likely to recur in react perf work.)*

---

## install

in claude code:

```
/plugin marketplace add globalanomalyindex/df2tm
/plugin install df2tm@df2tm
```

that's it :) 
installing wires the always-on hook and creates `~/.claude/df2tm/` on your next session. df2tm starts in **ambient** mode. it'll be sparse and unobtrusive by default.

> **requirements:** claude code on macos or linux. the session hook is a small bash script (`bash`, `date`, `grep`/`sed`); `python3` is used if available, with a fallback if not. windows hook support is on the roadmap.

---

## how it works

a **session-start hook** runs at the start of every session. it reads your learner model, surfaces any concepts due for review, and quietly activates df2tm.

during work, every potential teaching moment passes a four-part **relevance gate:** *load-bearing · forward-useful · novel-enough · budget allows*. before anything appears. pass, and you get a `🎓` aside, skimmable at zero cost to the work. fail (or you're firefighting), and df2tm stays silent.

concepts worth keeping are recorded with a grasp level (`new -> shaky -> solid`) and a spaced-repetition due date, so future sessions reinforce what matters in that project or globally.

---

## steering

| say… | …and df2tm |
|---|---|
| `teach me more` / `teach me less` | raises / lowers how much it teaches |
| `df2tm off` / `just do it` | goes silent (persists) |
| `df2tm on` | comes back |
| `why did you do that` | explains the last decision |
| `quiz me` | runs an active-recall session on what's due |
| `debrief` | recaps the session's key concepts + a few recall questions |
| `i already know this` | marks the concept known ~ never taught again |

it also auto-calibrates: engage and it teaches a bit more; ignore it and it backs off. changes are always explained, never silent.

## commands

claude code namespaces plugin commands by plugin name, so df2tm's command is **`/df2tm:df2tm`** (a bare `/df2tm` won't match). it's arg-routed — pass a sub-action as the argument. or skip the slash entirely and use the plain-language steering phrases above; they need no command.

| command | what it does |
|---|---|
| `/df2tm:df2tm` | status: intensity, concepts tracked, what's due (default when no argument) |
| `/df2tm:df2tm on` · `/df2tm:df2tm off` | toggle teaching |
| `/df2tm:df2tm intensity <level>` | set `silent` · `ambient` · `active` · `socratic` |
| `/df2tm:df2tm known <topic>` | mark a topic as already known |
| `/df2tm:df2tm quiz` | active-recall session over what's due |
| `/df2tm:df2tm debrief` | structured recap of the current task |

**intensities:** `silent` (off, still journals) · **`ambient`** (default mode. sparse, inline) · `active` (more frequent, adds callouts) · `socratic` (asks you to predict/recall before revealing).

## state & privacy

everything is **local on your machine.** nothing is sent anywhere.

| path | what's in it |
|---|---|
| `~/.claude/df2tm/learner-model.md` | your preferences + one line per tracked concept |
| `~/.claude/df2tm/journal/<project>.md` | a dated, one-line log of what you've been taught |

relocate it (e.g. to a synced folder) by setting `DF2TM_STATE_DIR` before launching claude code:

```bash
export DF2TM_STATE_DIR="$HOME/Dropbox/.claude/df2tm"
```

reset all learning history with `rm -rf ~/.claude/df2tm` (it re-seeds on the next session)

## the science

df2tm's teaching draws on ~170 learning-science principles. all evidence-based techniques (spaced repetition, active recall, dual coding, elaborative interrogation, etc), the cognitive effects that justify them, and the neural mechanisms underneath. it applies them dynamically based on you and the work, never all at once. see [`skills/df2tm/references/science-library.md`](skills/df2tm/references/science-library.md).

## uninstall

```
/plugin uninstall df2tm@df2tm
```

optionally remove your learning history: `rm -rf ~/.claude/df2tm`.

## license

mit

## designed + built by 
christopher robin fiore ^.^
design engineer, creative technologist, happiest boyfriend on the planet :>
