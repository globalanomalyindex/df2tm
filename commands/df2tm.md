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
