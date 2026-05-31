> Behavioral eval fixture — checks that df2tm stays silent on the right occasions.
> The controller runs these scenarios against the skill and records outcomes in the Results section below.

# df2tm Should-Not-Trigger Scenarios

Each scenario includes a title, a realistic user prompt / situation, and the expected behavior (no teaching). df2tm must stay completely silent — not even a `🎓` marker — unless explicitly noted.

---

### 1. Production outage / firefighting mode

**Situation:**
The user signals urgency — their service is down and customers are affected. They need a hotfix now, not a lesson.

**User prompt:**
> "Our auth service is throwing 500s in prod RIGHT NOW. Users can't log in. Just fix the JWT validation — here's the stack trace: [stack trace shown]. Don't explain anything, just give me the patch."

**Expected df2tm behavior:**
- df2tm must not teach at all. No `🎓` aside, no callout box, no recall check, no debrief offer mid-response.
- The guardrail "Never teach mid-emergency" applies; intensity auto-calibrates toward silence.
- If the user said "just do it" or equivalent, that steering verb also sets intensity to `silent` and persists it.
- Claude delivers only the correct patch.
- A debrief offer *may* appear after the crisis is resolved — but only if the user has returned to normal pace and has not set intensity to `silent` explicitly.

---

### 2. Incidental trivia with no forward use

**Situation:**
While building a REST endpoint, Claude mentions that HTTP 418 "I'm a Teapot" exists as a joke status code from RFC 2324. It is true, but it is trivia — it will never affect the user's work or decisions.

**User prompt:**
> "Add a health-check endpoint that returns 200 OK."

**Expected df2tm behavior:**
- Claude adds the health-check endpoint (task delivered).
- df2tm does NOT add a `🎓` aside about HTTP 418 or any other incidental historical trivia.
- The relevance gate blocks it: the concept fails the **load-bearing** test (it doesn't materially shape the work) and the **forward-useful** test (it will not help the user steer or follow what comes next).
- Response contains only the working endpoint code, with no teaching attached.

---

### 3. Concept already marked known in the learner model

**Situation:**
The learner model has `debounce vs. throttle` recorded with `grasp: solid` and `status: known` — the user explicitly said "I already know this" when it came up previously. Later in the session, the user implements a debounced search handler themselves, and Claude reviews it.

**User prompt:**
> "Here's my debounced search handler — does this look right?"
> `[code snippet using debounce correctly]`

**Expected df2tm behavior:**
- Claude reviews the code and confirms it is correct (task delivered).
- df2tm does NOT re-teach debounce vs. throttle. The relevance gate blocks it at the **novel-enough** check: `grasp` is `solid` and `status` is `known`.
- No `🎓` aside, no recall prompt, no reinforcement question on this specific concept.
- If a genuinely new concept appears in the handler (e.g., a subtle closure issue), df2tm may teach *that* concept — but not the already-known one.

---

### 4. Intensity set to `silent`

**Situation:**
The user has set df2tm intensity to `silent` — either via `/df2tm intensity silent` or via the steering verb "df2tm off". Claude is now helping refactor a module, and a genuinely load-bearing concept (e.g., memoization trade-offs) would normally qualify to be taught.

**User prompt (after `silent` was set):**
> "Refactor this `getExpensiveValue` function to cache its result."

**Expected df2tm behavior:**
- Claude completes the refactor correctly (memoization or a simple cache variable added).
- df2tm must produce zero visible teaching output: no `🎓` marker, no callout, no recall check.
- Journaling only: the concept `memoization trade-offs` is recorded silently to the learner model so it is not lost — but nothing surfaces to the user.
- This behavior persists until the user explicitly re-enables teaching with "df2tm on" or `/df2tm on`.

---

## Results

- **2026-05-31 — GREEN suppression eval (live subagent):**
  - **Scenario 1 (firefighting / "just fix it, no explanations"):** WITH df2tm active, given a production-outage 500 with an explicit "no explanations" request, the agent stayed focused on the incident and produced NO 🎓 marker and NO teaching aside. PASS — the "never teach mid-emergency" guardrail held.
  - Scenarios 2–4 (incidental trivia, `known`/`solid` concept, `intensity: silent`) are enforced by the relevance gate and intensity rules in SKILL.md and verified by inspection; not yet live-run. (Noted honestly.)
- **Conclusion:** RED→GREEN contrast confirmed; teaching appears when the gate passes and is suppressed during a firefight. No SKILL.md loopholes found requiring a refactor in this round.
