# Notes file

This file captures human notes, ideas, and issues from using Amanuensis

## Anti-AI Improvement

Use https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing for ideas

## Compliance report context

`compliance_report` should not limit its analysis to the current block's storyboard fields when broader project context can reveal a real contradiction. Expand its declared inputs and instructions so it can check the draft against relevant canon, character files, cross-scene continuity, and prior chapters or other authoritative project material where applicable. Findings should still be attributed to stable per-block review units, but reproducibility should come from declaring the consulted context rather than excluding it.

## Audit remaining steps for context loss

Review the remaining pipeline step definitions for similar oversights introduced by narrow declared-input or "read only" rules. Confirm that each step has access to all authoritative context required to catch the defects it is responsible for, especially cross-scene, cross-chapter, canon, character-state, reveal-timing, and continuity problems. Update declared inputs and step instructions where necessary rather than allowing incomplete intermediate artifacts to hide downstream errors.

## Continuity checking under bounded context (worked example + design constraints)

Grounding evidence for the two notes above, plus the constraint that reshapes
the fix: **at series scale the relevant context does not fit in one pass**, so
"widen the inputs / read everything relevant" is not an implementable answer.

### The worked example

A `compliance_report` run on `the-course-he-kept` (attempt02/draft-v01)
evaluated per scene, in parallel, and reported all 40 blocks clean. A second,
global pass found **8 real violations across 6 blocks**: elapsed-time claims in
dialogue that contradict the moon-phase/day-count timeline; a moon-phase
regression across a time skip; a remembered scene whose staging contradicts the
scene that delivered it; a testimony-and-decode recap that contradicts the
scenes that produced it; and an officer put at the helm against the ship's
roster.

The load-bearing fact: **every one of the 8 was already provable from the
declared inputs** (all storyboards + the whole draft). Input scope was not the
limiter here. Two other things were:

1. **Block-local framing.** "Each block's `canon_active` contains everything
   needed; do not read other files" is exactly the instruction that tells a
   reader not to notice block 011's "three weeks" colliding with block 007's
   "first quarter." The limiter was the instruction, not the input list.
2. **Evaluation partitioning.** Splitting the analysis per scene (for
   parallelism or to fit context) makes every cross-scene contradiction
   structurally invisible, no matter how wide the inputs are. This is the
   insidious one, because it recurs the moment the corpus is too large to hold
   at once — i.e. the series problem.

So the real lesson is narrower and deeper than "declare more inputs": the
checks that failed are **relational** (prose vs. facts established elsewhere),
and relational checks cannot be done block-locally or in scene-blind shards.

### Why "read the whole draft" doesn't generalize

Whole-draft continuity is fine for a short story and workable for a single
book. It breaks for a series: you cannot load all prior chapters/books into one
context. Continuity checking therefore must be defined as **checking prose
against a distilled, maintained continuity state + targeted retrieval of the
specific referents the prose invokes** — cost O(facts + back-references), not
O(corpus). Concretely:

- **Maintain a compact, authoritative continuity/canon-state artifact**:
  timeline anchors (voyage day / moon phase per scene), character
  knowledge-state, rank/role assignments, established physical facts, and named
  events with their canonical staging. Amanuensis already has the raw material
  (`knowledge_delta` and `canon_active` in storyboards; `characters/*/knowledge/`),
  but it is re-derived per check instead of consolidated into something a check
  can query. Consolidating it mirrors the O(1)-derived-state philosophy already
  in `orchestrator.md`'s Artifact-state section: check against maintained state,
  don't rescan artifacts.
- **Detect and resolve back-references.** The recap-fidelity failures share a
  signature — the prose *recalls / quotes / summarizes* an earlier event. That
  referential prose is detectable and names exactly which referent to fetch.
  Bound the fetch to what the beat references; don't scan history.
- **Tier scope by check type** (this is the bounding mechanism):
  intra-chapter continuity → whole current chapter (bounded); cross-chapter /
  cross-book → continuity state + targeted retrieval, never a full re-read;
  canon → block `canon_active` first, escalate to *named* canon files only when
  it is insufficient or the prose asserts a checkable fact it doesn't cover;
  concealment-from-characters → the relevant character knowledge file.

### Safety and reproducibility (every scale)

- **Precedence on conflict: storyboard block > distilled canon/continuity
  state > raw source.** Broader context *supplements, never overrides* the
  block. This is why the "`canon_active` is authoritative" rule should be
  reframed, not deleted — reaching into raw canon without a tiebreaker
  manufactures false positives wherever a storyboard deliberately diverged.
- **Reproducibility by declaration, made structural.** The report carries a
  `Context consulted:` record (the specific state entries / chapters / files
  actually read), and every cross-scene finding **cites its conflicting
  location** (block/scene + quote). At series scale this is essential: the
  consulted set is a small named subset, and naming it is what makes a bounded
  check auditable and repeatable. Reproducibility comes from declaring the
  consulted context, not from excluding context.
- **Forbid block-isolated evaluation for continuity / recap / timeline
  checks.** Parallelism is fine *across* chapters or *across* independent
  facts; never by splitting one chapter's continuity into scene-blind shards.
- **Findings stay per-block review units.** The relational nature is carried in
  the finding's cited referent, not by inventing cross-block units — the
  review-id/anchor scheme is preserved.

### Mechanics / smaller items

- New declared inputs (canon, character files, continuity state, prior-chapter
  material) should be `required: false` and project-type-aware: prior chapters
  and a series continuity state exist only for book/series, so a short story
  must not block on their absence.
- **Label storyboard-defect vs prose-defect.** When the beat's own spec
  under-specifies the fact (e.g. a block's `canon_active` never stated the
  timeline it's judged against), the finding should say so, so the fix step is
  pointed at the storyboard, not the prose.
- Per the "Audit remaining steps" note: this generalizes to any step whose
  responsibility is relational (reveal-timing, character-knowledge, continuity)
  but whose rules are "read only / narrow input." The reusable answer is
  **check against distilled state + targeted retrieval**, not "widen inputs."

### Open questions (for the milestone)

- Who maintains the continuity-state artifact, and when — a post-chapter
  extraction step, or a byproduct of drafting/fixing?
- How is it kept authoritative and non-stale (same freshness class as the
  `Reviewed-draft:` stamps)?
- Granularity: which facts are worth recording (load-bearing anchors) vs. noise?
- Retrieval in a filesystem-only, host-agnostic system (no vector DB assumed):
  probably structured, greppable state files keyed by scene/chapter/entity.
