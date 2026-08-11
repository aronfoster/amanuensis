---
book_id: book1
edit_policy: editable
role: derived_state
---

# Objective Continuity — Book 1

<!--
ILLUSTRATIVE EXAMPLE — NOT REAL PROJECT CANON OR STATE.

This file is a worked demonstration input for the bounded relational review
(`agents/review-context.md`), realized in a `book`-project `continuity/book-N.md`
and mirroring the field shapes in `templates/continuity-book.md`. The brig
*Cormorant*, her crew (Fenn, Sable, Wick, Pell, Teague, Dorrin), the ports
(Kettle Cove, Saltford, the Teeth), the drafts (`draft-vNN.md`), and the story
positions are all invented to demonstrate the model. Nothing here is a real
character, a real project's state, or anything to reconcile against. See the
folder README at `examples/relational-review/README.md`.

Only `continuity_update` writes this file. Each entry carries `id` (durable,
file-scoped — co-01, co-02, …), `story-position` (canonical folder-style
`book1/chapterNN/sceneNN`, zero-padded so lexical order = chronological),
`committed-in` (the accepted draft), `evidence` (a RETRIEVABLE full
attempt-qualified draft path `plot/book1/chapterNN/drafts/attemptNN/draft-vNN.md#<scene>`
— never a bare basename — plus the storyboard block / canon file where they
apply), the fact-class value field(s), and `- **review:** unreviewed`.

Provenance note that this fixture turns on: chapter02 was re-drafted as
`attempt02`. `continuity_update` re-derived most chapter02 facts against the new
attempt — co-03 / co-04 / co-05 carry `attempt02` evidence — but the night-helm
role entry co-06 was left stamped against the OLD `attempt01/draft-v03.md`. A
maintained entry whose provenance resolves to a superseded (non-latest) attempt
is a STATE defect (superseded), not a trustworthy fact (`agents/review-context.md`).
That stale co-06 is what makes the roster finding a non-prose defect. See the
README.
-->

---

## Chronology / time anchors

<!-- Day count, date, season, elapsed-time claims. -->

### Day 1 of the crossing
- **id:** co-02
- **story-position:** book1/chapter01/scene01
- **committed-in:** draft-v02.md
- **evidence:** plot/book1/chapter01/drafts/attempt01/draft-v02.md#scene01
- **anchor:** Day 1 of the *Cormorant*'s crossing; she clears Kettle Cove on the morning tide.
- **notes:** Chronology *advances* at co-05 — not superseded. Each day-anchor is true at its own position. A later scene naming an *earlier* day, or claiming far more elapsed time than the anchors allow, is a contradiction, not an advance.
- **review:** unreviewed

### Day 12; storm off the Teeth
- **id:** co-05
- **story-position:** book1/chapter02/scene06
- **committed-in:** draft-v01.md
- **evidence:** plot/book1/chapter02/drafts/attempt02/draft-v01.md#scene06
- **anchor:** Day 12 of the crossing, at the close of chapter 2; a storm is running off the reef called the Teeth.
- **notes:** Advances co-02 by eleven days. Re-derived against chapter02's latest attempt (`attempt02`). Chapter 3 opens a day or two later — near Day 14, roughly a fortnight from Kettle Cove — so prose in chapter 3 claiming "the better part of a month" contradicts the maintained count.
- **review:** unreviewed

---

## Event staging

<!-- Canonical staging of named events, for recall/recap fidelity. -->

### The night the longboat was cut loose
- **id:** co-03
- **story-position:** book1/chapter02/scene04
- **committed-in:** draft-v01.md
- **evidence:** plot/book1/chapter02/drafts/attempt02/draft-v01.md#scene04, plot/book1/chapter02/storyboards/scene04-storyboard.md
- **staging:** In the reef-squall off the Teeth, bosun Pell cut the *Cormorant*'s towed longboat loose to save the stern from being pulled under. Present at the transom: Pell, first mate Sable, and Captain Fenn. The longboat was **lost**, and the spare water breaker lashed in it went with her. The boat was not recovered.
- **notes:** This is the canonical account a later recall or recap must not contradict — that the longboat was cut loose and lost, not hauled aboard, and the spare water lost with it. Re-derived against `attempt02`.
- **review:** unreviewed

### The victualling at Saltford
- **id:** co-04
- **story-position:** book1/chapter02/scene02
- **committed-in:** draft-v01.md
- **evidence:** plot/book1/chapter02/drafts/attempt02/draft-v01.md#scene02
- **staging:** At Saltford the harbor agent agreed to victual the *Cormorant* **on credit against the summer cargo** — no coin down. Fenn signed the agent's book; no silver changed hands. The account is open, to be settled when the cargo is sold.
- **notes:** The canonical terms a later summary, log entry, or quotation must not contradict — on credit, no coin down, the account still open. Re-derived against `attempt02`.
- **review:** unreviewed

---

## Role / assignment

<!-- Rank, title, post — "who stands the helm". -->

### Who stands the night helm
- **id:** co-06
- **story-position:** book1/chapter02/scene05
- **committed-in:** draft-v03.md
- **evidence:** plot/book1/chapter02/drafts/attempt01/draft-v03.md#scene05
- **assignment:** First mate Sable stands the *Cormorant*'s night helm as officer of the watch.
- **notes:** PROVENANCE IS STALE. This entry's `evidence` resolves to `chapter02/attempt01/draft-v03.md`, but chapter02's latest attempt is `attempt02` (see `plot/book1/chapter02/drafts/attempt02/`). The re-derivation that moved co-03 / co-04 / co-05 onto `attempt02` did not re-derive this role entry — it is stamped in a superseded (non-latest) attempt. Per `agents/review-context.md` it is a **state** defect (superseded), not a trustworthy fact, so a relational finding that leans on it is a state finding routed to `continuity_update` / `revise`, not a prose finding.
- **review:** unreviewed

---

## Superseded

<!--
Non-destruction invariant (DIEGETIC change only). No diegetic transitions in this
fixture — the maintained facts each stand at their own position. (The co-06
provenance problem is an ATTEMPT-staleness issue, not a diegetic supersession: it
is resolved by re-deriving co-06 from chapter02/attempt02 via continuity_update /
revise, not by adding a `## Superseded` transition here.)
-->

<!-- No diegetic transitions in this fixture. -->
