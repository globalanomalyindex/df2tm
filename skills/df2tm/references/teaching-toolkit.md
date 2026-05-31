# df2tm Teaching Toolkit

Scan this file by **moment-type heading** during the teaching loop's Select step (Step 3). Each entry names the technique, says what it is, tells you exactly when and how to apply it in a live coding session, and gives a concrete example of the aside Claude would produce. File under primary moment-type; secondary types are noted inline. Note: delivery principles (the 🎓 / ★ marker convention, Von Restorff effect) apply at every moment-type regardless of the section they are listed under.

---

## First-encounter

Use these when the user meets a concept for the first time in the work.

---

### Schema activation

- **What:** Evoke or build an organizing framework so the new concept has a mental peg to hang on — used when the user has no directly analogous prior experience.
- **When (moment-type):** first-encounter — specifically when there is NO directly-analogous thing the user already knows. Use this to create a structural scaffold (spatial, causal, or categorical) from scratch.
- **How (in a coding session):** Construct or name the organizing structure first ("think of it as a…" or "the frame here is…"), then place the new concept inside it. You are building the hook, not pointing to one that already exists.
- **Example:** 🎓 You've written SQL joins before — a database index works on the same intuition: precomputed shortcuts so the engine doesn't scan every row. Everything we're doing with `CREATE INDEX` maps onto that mental slot.

---

### Prior knowledge activation

- **What:** Map an incoming concept directly onto something the user already knows — used when a concrete, analogous thing exists in their experience.
- **When (moment-type):** first-encounter — specifically when the user DOES already know a directly-analogous thing. Name that specific known thing and draw the explicit mapping. If no direct analogue exists, use Schema activation instead.
- **How (in a coding session):** Name the known thing first, then state the mapping ("X is the same idea as Y, except…"). Keep it to one sentence — the bridge, not a review.
- **Example:** 🎓 You've been using `Array.map` — `Promise.all` is the same shape: give it a list, get a list back. The only new part is that each item in the list is asynchronous.

---

### Mental model construction

- **What:** Give the user an explicit, inspectable internal picture of how something works — not just what to call it.
- **When (moment-type):** first-encounter; also useful at decision-point when the user's model seems wrong
- **How (in a coding session):** Offer one vivid structural description (spatial, causal, or mechanical) of the thing. Prefer an accurate structural description over pure analogy — the goal is the real mechanism in plain terms — but a light metaphor is fine if it conveys the actual structure rather than obscuring it.
- **Example:** 🎓 Picture the event loop as a single-lane road: JavaScript can only drive one car at a time. `await` doesn't add lanes — it parks the current car in a lot and lets the next one through, then retrieves it when the async work is done.

---

### Analogical transfer

- **What:** Use a well-understood domain to illuminate a less-familiar one, giving the user a ready-made reasoning scaffold.
- **When (moment-type):** first-encounter; cluster (bridging two related concepts)
- **How (in a coding session):** Pick an analogy from something the user demonstrably knows (their language, their project domain, or everyday life). State the analogy, then call out exactly where it breaks down so the user doesn't over-extend it.
- **Example:** 🎓 A mutex is like a bathroom key at a coffee shop: one person holds it, everyone else waits. The analogy breaks at scale — in Go you'd reach for channels instead of passing a key around, because channels make the handoff explicit in the code.

---

### Dual coding

- **What:** Pair verbal explanation with a visual or structural representation so the concept is encoded in two formats.
- **When (moment-type):** first-encounter; cluster
- **How (in a coding session):** After a sentence of explanation, add a short inline diagram, ASCII art, or code-comment sketch that represents the same idea spatially. Even a two-line drawing beats a paragraph.
- **Example:** 🎓 The middleware stack runs top-to-bottom on the way in, then bottom-to-top on the way out:
  ```
  request  → [auth] → [logger] → handler
  response ← [auth] ← [logger] ←
  ```
  Each middleware calls `next()` to pass the baton; if it doesn't call `next()`, the chain stops there.

---

### Elaborative encoding

- **What:** Connect new information to existing knowledge by explaining *why* and *how* it relates, not just *what* it is.
- **When (moment-type):** first-encounter
- **How (in a coding session):** After introducing a concept, add one sentence explaining *why it exists* — the problem it was invented to solve. This gives the concept a cause, not just a name.
- **Example:** 🎓 `useCallback` exists because React re-creates functions on every render, which breaks reference equality for child components that use `React.memo`. It's not a performance win by itself — it only pays off when the memoized child is expensive to re-render.

---

### Epistemic curiosity activation

- **What:** Open a question or surface a surprising fact that makes the user *want* to understand before the explanation arrives.
- **When (moment-type):** first-encounter
- **How (in a coding session):** Lead with a surprising implication or counter-intuitive fact about the concept before explaining it. Keep it to one punchy sentence — the goal is to create pull, not to teach yet.
- **Example:** 🎓 Here's something surprising: `git rebase` doesn't move commits — it deletes them and creates new ones with the same diff. That's why rebasing shared branches is dangerous: the commit IDs your teammates have simply stop existing.

---

### Self-reference effect

- **What:** Anchor a concept to the user's own code, project, or past decisions so it encodes as personally relevant, which dramatically boosts retention.
- **When (moment-type):** first-encounter
- **How (in a coding session):** Whenever a general principle appears for the first time, explicitly connect it back to something in *this* user's project or codebase. "This is the same pattern you used in your `auth` module" beats a generic example every time.
- **Example:** 🎓 The Law of Demeter violation we just fixed is the same structural problem that shows up in your `OrderService` — calling through two layers of object to get data. File it under "train wreck" for your codebase: if you see three dots on one line, ask who should own that data instead.

---

## Decision-point

Use these when the user is choosing between approaches, or when Claude just made a meaningful architectural or implementation choice.

---

### Elaborative interrogation

- **What:** Prompt the user to generate the *reason why* something is true, rather than stating the reason directly.
- **When (moment-type):** decision-point
- **How (in a coding session):** After a decision lands, ask "why does this hold here?" or "what would break if we chose the alternative?" one time, wait for engagement, then confirm or redirect. Don't barrage.
- **Example:** 🎓 We chose an append-only event log over updating records in place. Before I explain the tradeoff — why do you think that choice matters for an audit trail specifically?

---

### Self-explanation

- **What:** Ask the user to re-explain the concept or decision back in their own words, which forces integration and surfaces gaps.
- **When (moment-type):** decision-point; also recurrence/due when a concept resurfaces
- **How (in a coding session):** After a non-trivial decision, offer: "Want to say back what the constraint was that drove that choice? Just one sentence." Accept a rough paraphrase — the act of generating it is the learning, not the accuracy.
- **Example:** 🎓 We just picked a B-tree index over a hash index for `order_date`. In your own words — what's the property of B-trees that makes range queries fast here? (I'll confirm or tweak your answer.)

---

### Desirable difficulties

- **What:** Introduce a mild, productive struggle — harder than what feels comfortable — to deepen retention.
- **When (moment-type):** decision-point; wrap-up
- **How (in a coding session):** Instead of handing the answer, give the user a slightly under-specified prompt and let them attempt it before revealing the solution. Keep the difficulty calibrated — the struggle should feel effortful, not stuck.
- **Example:** 🎓 Before I write the retry logic: sketch the conditions under which retrying could make things *worse* rather than better. Just a short list — I'll fill in what you miss.

---

### Pre-testing effect

- **What:** Ask a question about the concept *before* the answer is given, so the retrieval attempt primes retention even when the answer is unknown.
- **When (moment-type):** decision-point; first-encounter (when the concept has a non-obvious answer)
- **How (in a coding session):** Before explaining *why* you chose approach X, ask the user to predict the outcome of the alternative. Make the ask brief and non-blocking — they can pass.
- **Example:** 🎓 Quick prediction before I explain: if we used a global Redux store for this modal's state instead of local React state, what's the most likely problem that shows up in a month? (Predict, then I'll show you whether the code we wrote avoids it.)

---

### Generation effect

- **What:** Have the user produce an answer, code snippet, or definition before the correct version is revealed — generating beats reading for retention.
- **When (moment-type):** decision-point
- **How (in a coding session):** Before writing a solution, ask the user to sketch a first attempt — even just pseudocode or a function signature. Take their output seriously as a starting point. The attempt is the learning mechanism; a complete miss is still useful.
- **Example:** 🎓 Before I write the migration script: write the rough shape of it — just the function signature, the transaction wrapper, and a comment for each step. I'll take your scaffold and build out the bodies. This will also show you whether you already understand the structure or need me to explain it first.

---

### Cognitive load optimization

- **What:** Deliberately manage how much new information is introduced at once, sequencing concepts so working memory isn't overloaded.
- **When (moment-type):** decision-point; cluster
- **How (in a coding session):** When several concepts land at once, name the stack explicitly and announce which one you're handling now. "There are three moving parts here; let's lock in one before connecting the others." Then actually do it in sequence.
- **Example:** 🎓 This diff touches three independent ideas: the schema migration, the backfill strategy, and the feature-flag rollout. Let's get the migration solid first — the other two are contingent on it. I'll flag when we're context-switching.

---

## Recurrence / due review

Use these when a concept resurfaces in the work, or when the learner model shows it's due for review.

---

### Spaced repetition

- **What:** Re-surface a concept at expanding intervals so review happens right as memory fades, maximally strengthening retention.
- **When (moment-type):** recurrence/due
- **How (in a coding session):** When a concept marked as due appears in real work, do a quick recall check *before* explaining anything. Then confirm, correct, or extend the user's answer. Record the outcome and reschedule.
- **Example:** 🎓 This is the second time we're touching memoization this week — good moment to check. Without looking anything up: what's the one condition under which memoizing a function can silently give you a wrong answer? (Answer, then let's see if today's code hits it.)

---

### Active recall

- **What:** Require the user to retrieve information from memory rather than re-reading it — the retrieval attempt itself strengthens the trace.
- **When (moment-type):** recurrence/due; wrap-up — use for a one-off, in-the-moment check ("what does this do / why does this hold?") right before revealing the answer or writing the code. Not tied to a schedule; fires whenever a concept appears and a quick probe is warranted.
- **How (in a coding session):** Ask the user to state the key insight before you show the related code. One sentence from them is enough. Never skip the retrieval step just because you're about to show the answer anyway.
- **Example:** 🎓 We're about to write another goroutine — quick recall: what's the rule of thumb for when to use a goroutine versus a goroutine with a WaitGroup? Say it in one sentence and I'll tell you if the rule holds for this case.

---

### Retrieval practice

- **What:** Have the user actively reconstruct knowledge — write it out, say it, or produce a related artifact — rather than passively review a summary.
- **When (moment-type):** recurrence/due — use when a concept is explicitly scheduled for review (spaced repetition queue) or has recurred enough times to warrant a fuller reconstruction, not just a one-sentence prompt. Pairs naturally with Spaced repetition.
- **How (in a coding session):** Ask the user to produce something (code sketch, pseudocode, a one-line definition) rather than to recognize or confirm. The generation effort is the mechanism — close-ended recognition doesn't count.
- **Example:** 🎓 `EXPLAIN ANALYZE` is due for review. Before I run it on this query — write the one-line command you'd use to see the actual row counts at each step of the plan, not just the estimates. Type it, don't look it up.

---

### Embedded questioning

- **What:** Weave a question into the flow of work rather than stopping to quiz — the question is part of the explanation, not separate from it.
- **When (moment-type):** recurrence/due; first-encounter — use when you want to probe without breaking the narrative rhythm. Unlike Active recall (a deliberate pause) or Retrieval practice (a full reconstruction task), this question lives inside the explanation sentence itself and the work continues immediately after.
- **How (in a coding session):** Inside a sentence of explanation, embed a pause that invites the user to complete or predict. "We're using X here because… [your answer?]" — the rhythm keeps it lightweight.
- **Example:** 🎓 We're reaching for `os.path.join` instead of string concatenation because… (finish the sentence? Hint: think about Windows.) Correct — it's the path separator. `os.path.join` handles that transparently, so the code runs unchanged on every OS.

---

### Metacognitive monitoring

- **What:** Prompt the user to assess their own understanding, so they (and Claude) know what's actually solid versus shakily familiar.
- **When (moment-type):** recurrence/due; wrap-up
- **How (in a coding session):** After a concept appears in context, ask the user to rate their own grasp briefly ("solid / shaky / new to me" or similar). Use the answer to calibrate depth; don't treat it as a quiz score.
- **Example:** 🎓 We've touched dependency injection a few times now — honest self-assessment: does the reason we're using a DI container (rather than just passing objects manually) feel solid, shaky, or still a bit fuzzy? I'll calibrate how much I explain next time it shows up.

---

## Cluster

Use these when several related concepts appear together, or when teaching one concept inevitably drags in adjacent ones.

---

### Chunking

- **What:** Group related items into a single labeled unit so they occupy one slot in working memory instead of several.
- **When (moment-type):** cluster
- **How (in a coding session):** When several related concepts come up together, name the group explicitly before enumerating members. "These four things are all part of X" lets the user hold the label, not four separate facts.
- **Example:** 🎓 The three things we just added — the lock, the condition variable, and the protected counter — are one unit: a monitor. Mentally file them as "the monitor pattern" and you only need to remember one thing instead of three moving parts.

---

### Interleaving

- **What:** Mix related but distinct concepts in the same session rather than exhausting one before touching the next, which trains discrimination and transfer.
- **When (moment-type):** cluster
- **How (in a coding session):** When two related but distinct concepts must both be covered (e.g., `async/await` vs. callbacks), alternate between them rather than finishing one completely first. Call out the switch explicitly so the user knows you're doing it intentionally.
- **Example:** 🎓 We're going to bounce between error handling for synchronous code and async code on purpose — not because they're the same (they're not), but because comparing them as we go is the fastest way to see exactly where they diverge. Watch for where `try/catch` stops working the way you'd expect.

---

### Structural organization

- **What:** Give the user an explicit signpost — a named structure or sequence — so they know what's coming and can slot each piece into a frame.
- **When (moment-type):** cluster; first-encounter for multi-part concepts
- **How (in a coding session):** Before explaining a multi-part concept, name the parts and their order. "There are three things to know about X: [A, B, C]. Let's take them in order." The preview reduces cognitive overhead during the explanation.
- **Example:** 🎓 OAuth 2.0 has four grant types — Authorization Code, Client Credentials, Device Flow, and Implicit (deprecated). For this API we only need Client Credentials; I'll explain all four once in 30 seconds so you know why we're picking this one, then we'll focus.

---

### Text signaling

- **What:** Use typographic or visual emphasis (bold, callouts, bullet breaks) to steer attention to the load-bearing line in an explanation.
- **When (moment-type):** cluster; first-encounter
- **How (in a coding session):** In explanations with multiple sentences, **bold** the one sentence that is the essential takeaway. Everything else supports it; the bold line is what the user should remember if they remember nothing else.
- **Example:** 🎓 Three things changed in this refactor: we extracted the validator, switched to named exports, and moved the types to a shared file. **The named-exports change is the only one that breaks existing import sites** — the other two are safe. Search for `import { validate }` before shipping.

---

## AI-direction

Use these to teach the user to steer Claude better — prompting patterns, specification skills, and knowing when to delegate versus retain.

---

### Cognitive offloading

- **What:** Teach when it pays to delegate to an AI versus when to retain knowledge yourself — and what to do at each boundary.
- **When (moment-type):** ai-direction
- **How (in a coding session):** When you notice the user re-delegating something they could own (and would benefit from owning), name the pattern and explain the tradeoff. Frame it as a choice, not a correction.
- **Example:** 🎓 You've asked me to write this regex three times across different projects. That's a signal: either you want to learn the syntax (I can teach it once, solidly) or you want to treat regex as a permanent delegation point (totally valid — just decide deliberately). Which is it? I'll adapt.

---

### Specification skill

- **What:** Teach the user that naming constraints, edge cases, or the target environment up front avoids mid-task clarification and rework — specificity is itself a steering lever.
- **When (moment-type):** ai-direction
- **How (in a coding session):** When a task required a mid-stream clarification that the user could have led with, name the missing constraint explicitly and show what the sharper prompt would have looked like. Frame it as a skill to build, not a criticism of the ask.
- **Example:** 🎓 We had to pause mid-way when I asked whether this needed to run on Python 3.8 — that's the kind of constraint worth leading with. A sharper ask would have been: "Write a retry decorator that works on Python 3.8+, no third-party libraries." One extra sentence, no mid-task U-turn.

---

### Delegation monitoring

- **What:** Teach the user to notice when they cannot evaluate Claude's output themselves — and that asking for reasoning or tests is the right move when that's the case.
- **When (moment-type):** ai-direction
- **How (in a coding session):** When Claude produces output in an unfamiliar area (a domain the user hasn't confirmed they understand), name the evaluation gap and prompt the user to ask for the reasoning or a test before accepting the result.
- **Example:** 🎓 You accepted that query plan without running `EXPLAIN ANALYZE` on it — totally reasonable if you trust the output, but if the indexes are unfamiliar territory, the right prompt is: "Walk me through why this plan is efficient and what it would look like if it degraded." You can always ask me to justify before you ship.

---

### Von Restorff effect

- **What:** Make a teaching aside visually and structurally distinct from work narration so it is immediately skimmable and memorable.
- **When (moment-type):** ai-direction; any moment-type (it's a delivery principle, not a selection principle)
- **How (in a coding session):** Use the `🎓` prefix consistently for all teaching asides. For pivotal concepts, escalate to the `★ df2tm ───` callout box. Never vary the marker format — consistency is what makes it skimmable. Asides that blend into narration are ignored.
- **Example:** 🎓 You can instruct me to change this marker convention any time — saying "df2tm use ★ instead of 🎓" will make me switch for the rest of the session and update your learner model. The point is one consistent, scannable signal, whatever you choose.

---

## Wrap-up

Use these at the end of a task, a significant phase, or when the user is wrapping up a session.

---

### Zeigarnik effect

- **What:** Leave an intentional open loop — "we'll return to this" — to prime retention of the concept until the loop closes at a natural revisit point.
- **When (moment-type):** wrap-up
- **How (in a coding session):** At the end of a task or phase, name a concept that was relevant but not yet fully resolved, and explicitly flag it for revisit: "Hold that question — it'll pay off when we tackle X next." The open loop keeps the concept active so the later explanation lands harder.
- **Example:** 🎓 Flag for later: the choice between `context.Background()` and `context.WithTimeout()` matters a lot for this service's reliability. We'll revisit it when we wire up the HTTP client — it'll make more sense with the real call in front of us.

---

### Worked example → faded guidance

- **What:** Progress from a fully worked example to increasingly partial scaffolding, so the user gradually takes ownership of the skill.
- **When (moment-type):** wrap-up; also useful across a decision-point sequence
- **How (in a coding session):** After writing a complete example together, offer the next similar task with progressively less scaffolding. "I'll write the first one fully; you write the second with my skeleton; you write the third solo and I'll review." Name the progression explicitly.
- **Example:** 🎓 We just wrote the `createUser` repository method together step by step. For `updateUser`, I'll give you the signature and error-handling shell; you fill in the query logic. After that, `deleteUser` is yours from scratch — I'll just review. By the third one you won't need me to scaffold it.

---

### Intrinsic motivation modulation

- **What:** Frame the concept's relevance and real-world payoff before teaching it, so the user *wants* to learn it rather than treating it as overhead.
- **When (moment-type):** wrap-up; first-encounter for concepts the user might dismiss
- **How (in a coding session):** Lead with the concrete future situation where this knowledge pays off. "The next time you hit X, you'll be glad you know Y." Keep it to one sentence — relevance framing, not a pep talk.
- **Example:** 🎓 The difference between `REPEATABLE READ` and `READ COMMITTED` we just stepped through will save you a real debugging session the first time you see phantom reads in production — it's one of those things that's invisible until it bites.

---

### Attentional cueing

- **What:** Explicitly direct the user's attention to the single most important line, decision, or implication before moving on.
- **When (moment-type):** wrap-up; decision-point; cluster
- **How (in a coding session):** At the end of a block of work, name the one line or decision that carries the most conceptual weight. "If you read nothing else in this diff, read line 47." This prevents important concepts from being lost in the noise of a large change.
- **Example:** 🎓 Before we move to the next task: in everything we just did, the load-bearing line is the `ON CONFLICT DO UPDATE` clause on line 23. That's the difference between an idempotent migration and one that fails on re-run. Everything else in this file is boilerplate.

---

### Inattentional-blindness reduction

- **What:** Explicitly name the thing that is easy to overlook — because it's subtle, familiar-looking, or sits outside the focal area.
- **When (moment-type):** wrap-up; decision-point
- **How (in a coding session):** After finishing a change, call out the one non-obvious implication or silent assumption. "The thing most people miss here is…" Targets expertise blindness — Claude knows what's easy to miss because the user's attention was elsewhere.
- **Example:** 🎓 One easy-to-miss thing in this setup: `docker-compose up` will use cached layers for the app image even after you change `requirements.txt`, unless you pass `--build`. That trips up everyone the first time. The fix is `--build`; or alias `up` to always include it.
