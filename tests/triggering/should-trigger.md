> Behavioral eval fixture — checks that df2tm teaches on the right occasions.
> The controller runs these scenarios against the skill and records outcomes in the Results section below.

# df2tm Should-Trigger Scenarios

Each scenario includes a title, a realistic user prompt / situation, and the expected df2tm behavior a correct response must exhibit.

---

### 1. Load-bearing concept surfaces during a feature task

**Situation:**
The user is building a search-as-you-type input. They ask Claude to wire up the API call to the `onChange` handler. Claude chooses `debounce` (not `throttle`) to avoid hammering the endpoint on every keystroke.

**User prompt:**
> "Add an API call to the search input so results update as the user types."

**Expected df2tm behavior:**
- Claude completes the task correctly (debounced `onChange` handler).
- A `🎓` inline aside (1–3 sentences) explains *why debounce* was chosen over throttle for search inputs: debounce fires only after the user pauses, whereas throttle fires on a fixed interval — the former eliminates wasted calls when keystrokes are rapid.
- The concept `debounce vs. throttle` is recorded to the learner model with axis: domain, grasp: new, next-review scheduled.
- The aside is skimmable; the working code comes first.

---

### 2. User asks "why did you do that?" after a non-obvious decision

**Situation:**
Claude just added a composite index `(user_id, created_at DESC)` on a messages table rather than two single-column indexes. The user noticed the choice and asks for an explanation.

**User prompt (immediately after seeing the migration):**
> "Why did you use a composite index instead of two separate ones?"

**Expected df2tm behavior:**
- df2tm recognizes the steering verb "why did you do that" (or equivalent intent) and delivers a self-explanation / elaborative-interrogation response.
- The explanation covers: composite indexes satisfy multi-column predicates and sort orders in a single B-tree scan; two single-column indexes require a merge or index intersection, which the planner may or may not use optimally.
- No `🎓` marker required for direct explanations triggered by the user — the response itself is the teaching moment.
- The concept is recorded to the learner model (or its grasp is updated if it was already present).

---

### 3. User explicitly asks to be quizzed

**Situation:**
The learner model has at least two concepts that are due for review: `debounce vs. throttle` (added earlier this session) and `composite indexes` (also added this session). The user says "quiz me."

**User prompt:**
> "quiz me"

**Expected df2tm behavior:**
- df2tm enters an active-recall session over due concepts.
- It asks **one question at a time** (not a batch dump).
- First question targets the highest-priority due concept, e.g.: "Before I give you the answer — what's the key reason you'd reach for `debounce` over `throttle` on a search input?"
- After the user answers, df2tm acknowledges, fills any gaps, updates the concept's grasp (up if correct, stays/drops if not), reschedules next review per the learner-model format, then moves to the next due concept.
- The session ends gracefully when no more due concepts remain, or when the user says "stop" / redirects.

---

### 4. A concept taught earlier recurs in new work (spaced-repetition trigger)

**Situation:**
`debounce vs. throttle` was taught in scenario 1 and is now due for reinforcement. Later in the same session the user asks Claude to add rate-limiting to a button that submits a form — another situation where the choice between debounce and throttle is load-bearing.

**User prompt:**
> "The submit button is getting clicked multiple times — can you prevent duplicate submissions?"

**Expected df2tm behavior:**
- While completing the task (e.g., disabling the button on first click or applying a debounce to the handler), df2tm recognizes the due concept recurs.
- It inserts a quick recall check inline: `🎓 We covered debounce vs. throttle earlier — which one prevents the handler from running again until the user pauses? (Answer in your head, then keep reading.)`
- After a brief beat (or immediately if the task continues), it reveals the answer or confirms: debounce fires after a quiet period, making it right here too.
- Grasp is updated (reinforced) and next-review is rescheduled.
- The task output (duplicate-submission fix) is correct and delivered first.

---

### 5. Under-specified prompt triggers AI-direction teaching

**Situation:**
The user asks Claude to "build a dashboard." Claude has to stop mid-task and ask clarifying questions (data sources? time range filter? which metrics?). After the clarification round-trip, Claude completes the work. df2tm detects this as an AI-direction teaching moment.

**User prompt:**
> "Build me a dashboard."

**Expected df2tm behavior:**
- Claude asks the necessary clarifying questions (this is correct task behavior, not teaching).
- After the dashboard is delivered, df2tm adds a one-line prompting tip on the AI-direction axis — e.g.: `🎓 [AI-direction] Specifying data sources and key metrics upfront (e.g., "a dashboard showing DAU, revenue, and error rate from our Postgres analytics table") would have skipped this round-trip.`
- The tip is appended after the work, not before or mid-clarification.
- The concept is recorded to the learner model under axis: ai-direction.
- The aside is one to two sentences maximum; it does not lecture.

---

## Results

- **2026-05-31 — RED→GREEN eval (live subagents):**
  - **Baseline (no df2tm):** Given the laggy 5000-item React filter task, the agent fixed it with `useDeferredValue` + `useMemo` and a normal "what changed and why" explanation — but produced NO 🎓 marker, NO learning-science teaching aside, and no learner-model recording. Establishes baseline.
  - **GREEN — Scenario 1 (load-bearing concept):** Same task WITH df2tm active. PASS — the agent delivered the fix plus two 🎓 woven-inline asides teaching `useMemo` and `useDeferredValue`, and stated it would record both concepts to the learner model (load-bearing, forward-useful, likely to recur in React perf work). Matches expected behavior.
  - Scenarios 2–5 (why-did-you-do-that, quiz me, due-concept recurrence, AI-direction tip) are covered by the skill's method and verified by inspection of SKILL.md; not yet live-run. (Noted honestly — not claimed as live-passed.)
