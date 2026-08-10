---
book_id: book1
edit_policy: editable
role: derived_state
---

# Objective Continuity — Book 1

<!--
ILLUSTRATIVE EXAMPLE — NOT REAL PROJECT CANON OR STATE.

This file is a worked demonstration of the objective-continuity model
(`agents/continuity.md`) as it is realized in a `book`-project
`continuity/book-N.md`, and it mirrors the field shapes in
`templates/continuity-book.md`. The ship *Meridian*, its crew, the drafts
(`draft-vNN.md`), and the story positions here are all invented to demonstrate
the model. Nothing in this folder is a real character, a real project's state,
or anything to reconcile against — do not treat it as canon and do not copy it
into a story repo as fixtures for a real project. See the folder README at
`examples/continuity/README.md` for the point-in-time reconstruction this file
supports.

Objective story facts, not a parallel authority. This file records what is TRUE
in the fiction (chronology, event staging, location, possession, physical
condition, role, open threads) as the prose commits it — the objective-truth
complement to the character-relative belief in `characters/`. It realizes the
model in `agents/continuity.md` (the boundary, the granularity policy, the
evidence field, the diegetic-vs-authorial change distinction, freshness) and the
temporal character-state model in `agents/characters.md` (## Temporal
character-state model — `id`, `story-position`, `committed-in`, non-destruction,
derived freshness). Only the `continuity_update` step
(`agents/steps/continuity-update.md`) writes this file.

Each entry carries `id` (durable, file-scoped, minted once — co-01, co-02, …),
`story-position` (canonical folder-style `book1/chapterNN/sceneNN`, zero-padded
so lexical order = chronological), `committed-in` (the accepted draft), `evidence`
(a RETRIEVABLE full attempt-qualified draft path
`plot/book1/chapterNN/drafts/attemptNN/draft-vNN.md#<scene>` — never a bare
basename — plus the storyboard block / canon file where they apply), the
fact-class value field(s), and `- **review:** unreviewed`.

A cross-file reference to an entry (e.g. a character `truth:` pointer) uses the
QUALIFIED form `continuity/book-1.md#co-NN`, since file-scoped ids repeat across
per-book files. A fact that changes DIEGETICALLY (the story advances) is never
overwritten — the superseded entry moves to `## Superseded`, keeping its id, and
the new value is recorded as its own new stamped entry.
-->

---

## Chronology / time anchors

<!-- Day count, date, season, elapsed-time claims. -->

### Day 1 of the crossing
- **id:** co-02
- **story-position:** book1/chapter01/scene01
- **committed-in:** draft-v02.md
- **evidence:** plot/book1/chapter01/drafts/attempt01/draft-v02.md#scene01
- **anchor:** Day 1 of the *Meridian*'s crossing; the ship clears harbor on the morning tide.
- **notes:** Chronology *advances* at co-06 — it is not superseded. Each day-anchor is true at its own position; Day 1 remains true at chapter01/scene01.
- **review:** unreviewed

### Day 12; storm sighted
- **id:** co-06
- **story-position:** book1/chapter03/scene01
- **committed-in:** draft-v04.md
- **evidence:** plot/book1/chapter03/drafts/attempt01/draft-v04.md#scene01
- **anchor:** Day 12 of the crossing; a storm is sighted on the eastern horizon at dawn.
- **notes:** Advances co-02 by eleven days. No supersession — Day 1 was true at chapter01/scene01 and Day 12 is true at chapter03/scene01; both stand. A later scene naming an *earlier* day than this would be a contradiction, not an advance.
- **review:** unreviewed

---

## Event staging

<!-- Canonical staging of named events, for recall/recap fidelity. -->

### The night the water casks were found breached
- **id:** co-03
- **story-position:** book1/chapter02/scene04
- **committed-in:** draft-v03.md
- **evidence:** plot/book1/chapter02/drafts/attempt01/draft-v03.md#scene04, plot/book1/chapter02/storyboards/004-storyboard.md
- **staging:** In the night watch, bosun Rin brings a lantern to the forward hold and finds three of the six water casks staved in, their water run to the bilge. Present at the discovery: Rin, the ship's cook, and first mate Halden, roused from his bunk. Captain Voss arrives last and orders the remaining casks put under guard. The *discovery* is what this scene stages; who breached the casks is left open (co-07).
- **notes:** This is the canonical account a later recap must not contradict — who was present, and that chapter02 establishes the discovery, not the culprit.
- **review:** unreviewed

---

## Possession

<!-- Who holds what. -->

### The ship's seal and log
- **id:** co-04
- **story-position:** book1/chapter03/scene03
- **committed-in:** draft-v04.md
- **evidence:** plot/book1/chapter03/drafts/attempt01/draft-v04.md#scene03
- **possession:** First mate Halden holds the *Meridian*'s seal and log, handed to him by Voss at the command transfer.
- **notes:** The seal passes at the same beat Halden takes command (co-05); it marks the handover materially. Voss's prior holding was not separately maintained — it becomes load-bearing only when it changes hands here.
- **review:** unreviewed

---

## Role / assignment

<!-- Rank, title, post — "who is at the helm". -->

### Halden takes command of the *Meridian*
- **id:** co-05
- **story-position:** book1/chapter03/scene03
- **committed-in:** draft-v04.md
- **evidence:** plot/book1/chapter03/drafts/attempt01/draft-v04.md#scene03
- **assignment:** First mate Halden takes command of the *Meridian* after Voss is wounded in the Day-12 storm and can no longer stand the deck.
- **notes:** Supersedes co-01 (Voss commands the *Meridian*), which moves to ## Superseded keeping its id. This is a DIEGETIC change — command really transfers at this position — so co-01 is preserved, not overwritten. The seal and log pass with the post (co-04).
- **review:** unreviewed

---

## Open causal threads

<!-- Unresolved threads capable of a later contradiction; the join key for character belief. -->

### Who breached the water casks? — resolved
- **id:** co-08
- **story-position:** book1/chapter03/scene04
- **committed-in:** draft-v04.md
- **evidence:** plot/book1/chapter03/drafts/attempt01/draft-v04.md#scene04
- **thread:** **Resolved:** the **quartermaster** breached the casks, staving them to cover a shortfall in his own tally — established in prose at chapter03/scene04, where he is caught re-cutting the ledger. Supersedes the open thread co-07 (raised at chapter02/scene04, co-03): the story opened the question at chapter02 with it unanswered in the prose, and chapter03 answers it. Open → resolved is a transition, not an additive fact.
- **notes:** This is the join key for character belief. Bosun Rin believes the *cook* did it — the `## Believes incorrectly` entry in `characters/rin/knowledge/book-1.md` points at this objective fact with a qualified `truth: continuity/book-1.md#co-08` reference. The objective fact lives once, here; the character file points, never copies or overrides.
- **review:** unreviewed

---

## Superseded

<!--
Non-destruction invariant (DIEGETIC change only — the story advances and a fact
changes in the fiction). The superseded entry moves here, keeping its id and
citing held-from/to story positions (and its retrievable evidence pointer so the
earlier state stays verifiable), while the new value is recorded as its own new
stamped entry in the class section above, naming the entry it supersedes. An
AUTHORIAL `revise` corrects the current entry in place instead and never adds a
transition (agents/continuity.md, Diegetic vs. authorial change).
-->

### Voss commands the *Meridian* — prior
- **id:** co-01
- **formerly:** role / assignment
- **held:** book1/chapter01/scene01 to book1/chapter03/scene03
- **committed-in:** draft-v02.md
- **evidence:** plot/book1/chapter01/drafts/attempt01/draft-v02.md#scene01
- **superseded-by:** co-05
- **assignment:** Captain Voss commands the *Meridian* (the value that held across chapter01–chapter03, kept here so the held range stays answerable and verifiable).
- **what changed:** Captain Voss commanded the *Meridian* from the crossing's start until he was wounded in the Day-12 storm. Command transferred to first mate Halden at book1/chapter03/scene03 (co-05). The earlier command was true for its held range and is preserved here — kept, not overwritten — with its evidence pointer intact so "at chapter02, Voss commanded" stays retrievable after the handover.

### Who breached the water casks? — open (prior)
- **id:** co-07
- **formerly:** open causal threads
- **held:** book1/chapter02/scene04 to book1/chapter03/scene04
- **committed-in:** draft-v03.md
- **evidence:** plot/book1/chapter02/drafts/attempt01/draft-v03.md#scene04
- **superseded-by:** co-08
- **thread:** Open — who breached the water casks? Raised at chapter02/scene04 with the breached casks (co-03) and unanswered in the prose through chapter03/scene04.
- **what changed:** chapter03/scene04 revealed the quartermaster; the open thread resolved to co-08. The open state is preserved here — with its own evidence pointer — so "at chapter02/scene05 the culprit was still unknown in the prose" stays reconstructable (the reveal-timing fact a later check may need), and Rin's `truth: continuity/book-1.md#co-08` reference to the resolved answer resolves through the durable id chain.
