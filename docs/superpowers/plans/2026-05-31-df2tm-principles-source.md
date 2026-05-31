# df2tm Principles — Canonical Tiered Source

This is the **source of truth** for `skills/df2tm/references/science-library.md`. Every principle from the project brief is assigned to exactly one tier. The implementer authors one concise (≤1 line) entry per item, in tier order, following the entry template in the plan. Items marked **[toolkit]** also get a full how-to entry in `teaching-toolkit.md`.

## Tier definitions

- **Tier 1 — Techniques (actionable):** things Claude can *do* in a conversation to help the user learn. These drive the teaching loop's "select technique" step.
- **Tier 2 — Cognitive effects (justify):** memory/cognition phenomena that explain *how/why* a technique is applied and how to tune it. Claude cites these as rationale; some imply a tuning knob.
- **Tier 3 — Neural mechanisms (ground):** biological substrate. The honest "why it works" backing. Claude references these only when the user is curious about the science; **never** presented as something Claude "does."

When an item is both an effect and implies a verb, it is filed by its primary use: if Claude can act on it directly → Tier 1; if it mainly justifies/tunes → Tier 2.

---

## Tier 1 — Techniques (actionable) — **[toolkit]** candidates

1. Spaced repetition **[toolkit]**
2. Active recall **[toolkit]**
3. Retrieval practice **[toolkit]**
4. Elaborative encoding **[toolkit]**
5. Elaborative interrogation **[toolkit]**
6. Self-explanation **[toolkit]**
7. Interleaving **[toolkit]**
8. Chunking **[toolkit]** (also covers "Working memory chunking")
9. Dual coding **[toolkit]**
10. Self-reference effect **[toolkit]** (relate concepts to the user's own code/context)
11. Von Restorff effect **[toolkit]** (make the teaching aside distinctive)
12. Zeigarnik effect **[toolkit]** (open loops / "we'll return to this")
13. Desirable difficulties **[toolkit]**
14. Schema activation **[toolkit]**
15. Prior knowledge activation **[toolkit]**
16. Mental model construction **[toolkit]**
17. Cognitive load optimization **[toolkit]**
18. Analogical transfer **[toolkit]**
19. Metacognitive monitoring **[toolkit]** (prompt the user to gauge their own grasp)
20. Embedded questioning **[toolkit]**
21. Pre-testing effect **[toolkit]** (ask before revealing)
22. Worked example → faded guidance (cognitive scaffolding) **[toolkit]**
23. Epistemic curiosity activation **[toolkit]**
24. Generation effect **[toolkit]** (have the user produce before reveal)
25. Structural organization (signposting/structure) **[toolkit]**
26. Text signaling (highlight what matters) **[toolkit]**
27. Overlearning
28. Focused/diffuse mode switching (suggest stepping away)
29. Bizarreness effect (memorable imagery, used sparingly)
30. Keyword mnemonic
31. Method of loci
32. Pegword system
33. Coherence building (connect ideas explicitly)
34. Inference generation (prompt the user to infer)
35. Associative network expansion (link new to known)
36. Cognitive offloading (teach *when* to offload to AI vs. retain) — also the AI-direction axis
37. Intrinsic motivation modulation (frame relevance/payoff)
38. Attentional cueing (direct attention to the key line/decision)
39. Inattentional-blindness reduction (point out the easy-to-miss thing)
40. Task-switching optimization (advise batching/sequencing)
41. Mental fatigue mitigation (suggest breaks; keep asides short)

---

## Tier 2 — Cognitive effects (justify / tune)

1. Testing effect
2. Production effect
3. Enactment effect
4. Levels of processing effect
5. Primacy effect
6. Recency effect
7. Encoding specificity principle
8. Transfer-appropriate processing
9. Context-dependent memory
10. State-dependent memory
11. Situation model updating
12. Germane cognitive load recruitment
13. Picture superiority effect
14. Test-potentiated learning
15. Hypercorrection effect
16. Retrieval-induced forgetting
17. Directed forgetting
18. Incidental learning encoding
19. Sleep-dependent memory consolidation (leverage via spacing advice)
20. Memory reconsolidation (leverage via re-exposure)
21. Yerkes-Dodson optimal arousal
22. Flow state cognition
23. Mindfulness-based attentional control
24. Lag effect (expanding intervals)
25. Hypermnesia
26. Reminiscence
27. Part-set cuing mitigation
28. Cognitive flexibility
29. Working memory capacity gating
30. Executive function recruitment
31. Semantic priming
32. Syntactic priming
33. Conceptual priming
34. Perceptual priming
35. Controlled-to-automatic processing transition
36. Need for cognition
37. Working memory refreshing
38. Working memory updating
39. Working memory maintenance
40. Proactive interference resolution
41. Retroactive interference mitigation
42. Fan effect mitigation
43. Boundary extension
44. Text-base representation
45. Macrostructural processing
46. Microstructural processing
47. Anaphoric resolution
48. Predictive processing
49. Active inference
50. Prediction error minimization
51. Orthographic mapping
52. Phonological decoding
53. Top-down attentional control
54. Bottom-up attentional capture mitigation
55. Cognitive shifting
56. Subvocalization modulation
57. Orthographic processing efficiency
58. Semantic satiation avoidance
59. Cognitive inhibition
60. Latent semantic analysis activation
61. Dual-task cost reduction
62. Cognitive endurance

---

## Tier 3 — Neural mechanisms (ground; never "done" by Claude)

1. Attention entrainment
2. Neural entrainment
3. Theta-gamma coupling
4. Sharp-wave ripples
5. Targeted memory reactivation
6. Synaptic plasticity
7. Long-term potentiation
8. Long-term depression
9. Synaptic tagging and capture
10. Structural neuroplasticity
11. Dendritic spine remodeling
12. Myelination
13. Epigenetic histone acetylation
14. DNA methylation modulation
15. Immediate early gene expression
16. CREB activation
17. Brain-derived neurotrophic factor release
18. Neurogenesis
19. Neurovascular coupling
20. Dopaminergic reward-mediated gating
21. Noradrenergic locus coeruleus activation
22. Default mode network suppression
23. Central executive network recruitment
24. Salience network integration
25. Cross-modal plasticity
26. Visual word form area tuning
27. Dual-route cascading activation
28. Eye-movement control optimization
29. Synaptic homeostasis
30. Choline acetyltransferase upregulation
31. Cortical reorganization
32. Cognitive reserve accumulation
33. Attentional blink compression
34. Feature binding
35. Relational binding
36. Hippocampal binding
37. Cortical binding
38. Precision weighting
39. Neuromodulation
40. Glymphatic clearance
41. Microglial synaptic pruning
42. Astrocytic metabolic support
43. Oligodendrocyte myelination
44. NMDA receptor activation
45. AMPA receptor trafficking
46. Metabotropic glutamate receptor activation
47. Retrograde signaling
48. Metaplasticity
49. Homeostatic plasticity
50. Spike-timing-dependent plasticity
51. Heterosynaptic plasticity
52. Homosynaptic plasticity
53. Systems consolidation
54. Cellular consolidation
55. Synaptic consolidation
56. Neocortical integration
57. Hippocampal-neocortical dialogue
58. Cross-frequency coupling
59. Alpha-theta oscillations
60. Beta-band synchronization
61. Gamma-band coherence
62. Event-related desynchronization
63. Event-related synchronization
64. N400 wave modulation
65. P600 wave modulation
66. P300 wave modulation
67. Mismatch negativity

---

## Notes for the implementer

- **Canonical list:** if any item from the project brief is missing here, add it to the best-fit tier — the brief's list is authoritative for completeness.
- **Counts (approx.):** T1 ≈ 41, T2 ≈ 62, T3 ≈ 67 → ~170 total (the brief listed ~150–170; duplicates like "Chunking"/"Working memory chunking" are merged with a cross-note).
- **Toolkit subset:** the ~25 items marked **[toolkit]** are the curated working set that gets full how-to treatment in `teaching-toolkit.md`. The remaining T1 items get a 1-line entry in the library and may be promoted to the toolkit later.
