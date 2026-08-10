---
book_id: <book-id>
edit_policy: editable | careful_edit | propose_only | locked
role: derived_state
---

# Objective Continuity — Book [N]

<!--
Objective story facts, not a parallel authority. This file records what is TRUE in the fiction
(chronology, event staging, location, possession, physical condition, role, open threads) as the
prose commits it — the objective-truth complement to the character-relative belief in
`characters/`. It realizes the model in `agents/continuity.md` (the boundary, the granularity
policy, the evidence field, the diegetic-vs-authorial change distinction, freshness) and the
temporal character-state model in `agents/characters.md` (## Temporal character-state model — `id`,
`story-position`, `committed-in`, non-destruction, derived freshness). See those for the rules;
this template shows the shapes.

For `short_story` the file is `continuity/story.md` (no `book_id`); for `book`/`series` it is
`continuity/book-N.md`, one per book.

Only the `continuity_update` step (`agents/steps/continuity-update.md`) writes this file. It
maintains only the LOAD-BEARING set (a fact that is both relational and reader-visible-contradiction
-capable; single-scene throwaway detail stays in prose — `agents/continuity.md`).

Each entry carries:
- `id:` — durable, file-scoped, minted once, never changed (co-01, co-02, …).
- `story-position:` — where the fact is established, canonical folder-style
  `<book-id>/<chapter-id>/<scene-id>` (short_story: `<scene-id>`).
- `committed-in:` — the accepted draft that committed the fact (draft-vNN.md).
- `evidence:` — a RETRIEVABLE pointer to the supporting accepted artifact: the FULL
  attempt-qualified draft path `<chapter-folder>/drafts/<attemptNN>/draft-vNN.md#<scene>` (never a
  bare `draft-vNN.md` basename — it must name one specific draft across chapters AND attempts), plus
  the storyboard block / canon file where they apply. This is the objective counterpart to
  knowledge's `basis:`.
- `- **review:** unreviewed` — the review marker (the writes are legible and human-reviewable, not
  gated review units).

A cross-file reference to an entry (e.g. a character `truth:` pointer) uses the QUALIFIED form
`continuity/book-N.md#co-NN`, since file-scoped ids repeat across per-book files.

Non-destruction (see agents/characters.md / agents/continuity.md): a fact that changes DIEGETICALLY
(the story advances) is never overwritten — move the superseded entry to `## Superseded`, keeping
its id, and record the new value as its own new stamped entry in the appropriate class section. An
AUTHORIAL `revise` corrects the current entry in place instead (no transition).
-->

---

## Chronology / time anchors

<!-- Day count, date, season, elapsed-time claims. -->

### [Short label, e.g. "Day count at ch2 open"]
- **id:** co-01
- **story-position:** book1/chapter02/scene01
- **committed-in:** draft-v03.md
- **evidence:** plot/book1/chapter02/drafts/attempt01/draft-v03.md#scene01
- **anchor:** [The time fact, precisely — e.g. "Day 3 of the voyage; late autumn."]
- **notes:** [Optional. Cross-references, caveats, downstream implications.]
- **review:** unreviewed

---

## Event staging

<!-- Canonical staging of named events, for recall/recap fidelity. -->

### [Short label, e.g. "The harbor ambush"]
- **id:** co-02
- **story-position:** book1/chapter02/scene04
- **committed-in:** draft-v03.md
- **evidence:** plot/book1/chapter02/drafts/attempt01/draft-v03.md#scene04, storyboards/scene04.md
- **staging:** [Who was present, what happened, in what order — the canonical account a later recap
  must not contradict.]
- **notes:** —
- **review:** unreviewed

---

## Location

<!-- Where an entity or party is. -->

### [Short label, e.g. "The party's position after the ambush"]
- **id:** co-03
- **story-position:** book1/chapter02/scene05
- **committed-in:** draft-v03.md
- **evidence:** plot/book1/chapter02/drafts/attempt01/draft-v03.md#scene05
- **location:** [Which entity/party, and where they are.]
- **notes:** —
- **review:** unreviewed

---

## Possession

<!-- Who holds what. -->

### [Short label, e.g. "The signet ring"]
- **id:** co-04
- **story-position:** book1/chapter03/scene02
- **committed-in:** draft-v05.md
- **evidence:** plot/book1/chapter03/drafts/attempt01/draft-v05.md#scene02
- **possession:** [Who holds what — e.g. "Corvin holds the signet ring."]
- **notes:** —
- **review:** unreviewed

---

## Physical condition

<!-- Injuries, states of persons or objects. -->

### [Short label, e.g. "The captain's wound"]
- **id:** co-05
- **story-position:** book1/chapter03/scene04
- **committed-in:** draft-v05.md
- **evidence:** plot/book1/chapter03/drafts/attempt01/draft-v05.md#scene04
- **condition:** [The state of a person or object — e.g. "The captain's left arm is broken."]
- **notes:** —
- **review:** unreviewed

---

## Role / assignment

<!-- Rank, title, post — "who is at the helm". -->

### [Short label, e.g. "Who is at the helm"]
- **id:** co-06
- **story-position:** book1/chapter03/scene04
- **committed-in:** draft-v05.md
- **evidence:** plot/book1/chapter03/drafts/attempt01/draft-v05.md#scene04, canon/world/ranks.md
- **assignment:** [Who holds what post — e.g. "Halden is acting helmsman."]
- **notes:** —
- **review:** unreviewed

---

## Open causal threads

<!-- Unresolved threads capable of a later contradiction; the join key for character belief. -->

### [Short label, e.g. "Who set the harbor fire?"]
- **id:** co-07
- **story-position:** book1/chapter02/scene04
- **committed-in:** draft-v03.md
- **evidence:** plot/book1/chapter02/drafts/attempt01/draft-v03.md#scene04
- **thread:** [The unresolved question and its current objective status — e.g. "Arsonist unknown to
  the party; objectively it was the harbormaster (co-11)."]
- **notes:** [A character may answer this thread wrongly — a `## Believes incorrectly` knowledge
  entry may point here with a qualified `continuity/book-N.md#co-07` `truth:` reference.]
- **review:** unreviewed

---

## Superseded

<!--
Non-destruction invariant (DIEGETIC change only — the story advances and a fact changes in the
fiction). Move the superseded entry here, keeping its id and citing held-from/to story positions,
and record the new value as its own new stamped entry in the class section above, naming the entry
it supersedes. An AUTHORIAL `revise` corrects the current entry in place instead and never adds a
transition (agents/continuity.md, Diegetic vs. authorial change).
-->

### [Short label, e.g. "Who is at the helm — prior"]
- **id:** co-06
- **formerly:** role / assignment
- **held:** book1/chapter03/scene04 to book1/chapter05/scene02
- **committed-in:** draft-v12.md
- **superseded-by:** co-14
- **what changed:** [Brief explanation — e.g. "The captain resumes the helm once his arm heals; the
  acting assignment ends."]
