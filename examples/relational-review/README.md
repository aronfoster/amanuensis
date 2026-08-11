# Bounded-relational-review fixture — the *Cormorant* crossing

> **ILLUSTRATIVE EXAMPLE — NOT REAL PROJECT CANON OR STATE.**
> Per the Amanuensis Repository Boundary rule (`AGENTS.md`), prose, maintained
> state, storyboards, and reveal plans live in this tooling repo *only* as
> clearly-marked examples. The brig *Cormorant*, her crew (Fenn, Sable, Wick,
> Pell, Teague, Dorrin), the ports (Kettle Cove, Saltford, the Teeth), the
> drafts (`draft-vNN.md`), and the story positions here are all invented to
> demonstrate the bounded relational review. Nothing in this folder is a real
> character, a real project's state, or anything to reconcile against — do not
> treat it as canon and do not copy it into a story repo as fixtures for a real
> project. (The *Cormorant*'s crew is a **distinct** set from the *Meridian*'s in
> `examples/continuity/` — the two fixtures do not share a world.)

## What this folder shows

A worked demonstration of the **bounded relational review** — the retrofitted
`compliance_report` and `storyboard_review` reading drafted prose (and storyboard
plans) against **maintained state plus targeted retrieval**, per
`agents/review-context.md`. It is a `book`-project fixture (`agents/project-layouts.md`)
whose chapter 3, scene 2 draft carries the `NOTES.md:24-46` failure set, and it
catches every one as a **per-block relational finding with a cited referent and a
defect-type label**, backed by a report-level **`## Context consulted`** record.

The maintained state the review reads:

- `continuity/book-1.md` — the objective-continuity state
  (`templates/continuity-book.md` shape), with a full attempt-qualified
  `evidence:` path on every entry. Five entries carry the findings: two chronology
  anchors (co-02, co-05), two event-staging facts (co-03, co-04), and one role
  assignment (co-06).
- `characters/wick/knowledge/book-1.md` — navigator Wick's knowledge state
  (`templates/knowledge-book.md` shape), with a full attempt-qualified
  `committed-in:` path on every entry. The load-bearing entry is kn-02, his false
  belief that the short manifest is an honest error.
- `reveals.md` — the project-root, human-authored reveals ledger
  (`templates/reveals.md` shape), with **block-qualified** positions. rv-01 is the
  reveal a storyboard block discloses early.

The prose and plans under review:

- `plot/book1/chapter03/storyboards/scene01-storyboard.md`,
  `scene02-storyboard.md` — the storyboard blocks. Scene 2's blocks drive the
  compliance findings; scene 1's block 003 carries the premature-disclosure
  storyboard defect.
- `plot/book1/chapter03/drafts/attempt01/draft-v02.md` — the **accepted draft**,
  carrying the five prose contradictions.
- `plot/book1/chapter03/drafts/attempt01/reviewer-actions.md` — the produced
  **compliance report**: five relational findings, a `### Summary`, and the
  `## Context consulted` record. It validates `proceed` (exit 0) — see
  [Validating the report](#validating-the-report).
- `plot/book1/chapter03/storyboards/storyboard-review.md` — the produced
  **storyboard-review** excerpt: the reveal-timing finding and its own
  `## Context consulted`.

### The five failures, and where each surfaces

The five `NOTES.md:24-46` failure types surface across the two review artifacts.
Four are `compliance_report` findings; one is a `storyboard_review` finding. A
fifth `compliance_report` finding — the ship's roster — is included to show a
**non-prose defect** and how `compliance_fix` routes it (it is also, verbatim,
one of `NOTES.md`'s original violations: "an officer put at the helm against the
ship's roster").

| # | Failure type | Review step | Defect | Cited referent |
| --- | --- | --- | --- | --- |
| 1 | Cross-scene chronology | `compliance_report` | prose | `continuity/book-1.md#co-05` |
| 2 | Character knowledge | `compliance_report` | prose | `characters/wick/knowledge/book-1.md#kn-02` |
| 3 | Recalled event staging | `compliance_report` | prose | `continuity/book-1.md#co-03` |
| 4 | Recap fidelity | `compliance_report` | prose | `continuity/book-1.md#co-04` |
| 5 | Reveal timing | `storyboard_review` | storyboard | `reveals.md#rv-01` |
| + | Role / roster (non-prose demo) | `compliance_report` | **state** | `continuity/book-1.md#co-06` |

Because this is a `book` project, story-positions are full folder-style
`book1/chapterNN/sceneNN` (zero-padded, so lexical order equals chronological
order), review-ids take the book form
`compliance:book1:chapter03:scene02:block-NNN-vKK`, and reveal-ledger positions
are book-qualified and **block-qualified** (`book1/chapterNN/sceneNN:block-NNN`).

## The four `compliance_report` findings

Each is a **per-block review unit** on the existing `compliance:` grammar: a
`<!-- review-id: ... -->` anchor, an `INCONSISTENT (...)` violation line carrying
the greppable ` [defect: <type>] [ref: <referent>]` tag, and blank/filled
`- Decision:` / `- Decision-note:` fields. (The `Decision:` fields are shown
**filled** here — a human reviewed the report — so the fix routing below can be
demonstrated; a freshly produced report leaves them blank.) The relational nature
rides in the **cited referent**, not in a new cross-block unit — the review-unit /
anchor scheme is unchanged (`agents/review-grammars.yaml`).

### 1 — Cross-scene chronology (block 002)

The prose says the crew is *"the better part of a month at sea"*. The maintained
day-count says otherwise: **co-02** fixes Day 1 at the Kettle Cove departure and
**co-05** fixes Day 12 at chapter 2's close, so chapter 3 stands near Day 14 —
roughly a fortnight, not a month.

```markdown
<!-- review-id: compliance:book1:chapter03:scene02:block-002-v01 -->
- INCONSISTENT (chronology): elapsed time — "the better part of a month at sea"
  contradicts the maintained day-count. co-02 fixes Day 1 at the Kettle Cove
  departure and co-05 fixes Day 12 at chapter 2's close, so this scene stands near
  Day 14 — roughly a fortnight, not a month. Prose: "the better part of a month at
  sea". [defect: prose] [ref: continuity/book-1.md#co-05]
  - Decision: FIX: change "the better part of a month at sea" to "near a fortnight at sea"
```

**Defect: prose.** The timeline is valid; the prose is the wrong one. Both
chronology anchors and the block's own `must_preserve` agree the elapsed time is
~a fortnight, and only the prose diverges — the taxonomy's plain **prose** case
(`agents/review-context.md`). `compliance_fix` edits the prose.

### 2 — Character knowledge (block 003)

The prose has Wick accuse Fenn: *"You altered the tally yourself, and you knew
it."* But at this story position Wick is **concealed from** the forgery. His
maintained state, **kn-02**, holds him believing the short count an honest
clerical error, and the storyboard block itself keeps the forgery from him
(`concealment_from_characters`). Only the prose gives him knowledge he does not
hold.

```markdown
<!-- review-id: compliance:book1:chapter03:scene02:block-003-v01 -->
- INCONSISTENT (character-knowledge): Wick — the prose has Wick accuse Fenn of
  deliberately altering the manifest, knowledge he is concealed from at this
  position. kn-02 holds him believing the short count an honest clerical error, and
  the storyboard block conceals the forgery from him; only the prose diverges.
  Prose: "You altered the tally yourself, and you knew it".
  [defect: prose] [ref: characters/wick/knowledge/book-1.md#kn-02]
  - Decision: FIX: have Wick press only on the short count as an error, not accuse Fenn of deliberate forgery
```

**Defect: prose.** Storyboard intent and maintained knowledge state agree that
Wick stays in the dark; the prose is the outlier. Under the review tiebreak
(**storyboard intent > distilled state > raw source**), the prose is what must
change.

### 3 — Recalled event staging (block 004)

Sable *recalls* the reef-squall: *"we got the boat back aboard before she took her
— the water with it."* The maintained event-staging fact **co-03** fixes the
opposite: Pell **cut the towed longboat loose** and it was **lost**, the spare
water breaker gone with it. A remembered scene whose staging contradicts the
maintained fact is a relational finding.

```markdown
<!-- review-id: compliance:book1:chapter03:scene02:block-004-v01 -->
- INCONSISTENT (event-staging): the lost longboat — Sable recalls the reef-squall
  as though the longboat was hauled back aboard and the water saved. co-03 fixes
  that Pell cut the towed longboat loose and it was lost, the spare water breaker
  gone with it, not recovered. Prose: "we got the boat back aboard before she took
  her — the water with it". [defect: prose] [ref: continuity/book-1.md#co-03]
  - Decision: FIX
```

**Defect: prose.** co-03 is valid maintained state (re-derived against chapter 2's
latest attempt, `attempt02`); the recollection is wrong.

### 4 — Recap fidelity (block 005)

Fenn dictates a log line: *"provisioned at Saltford, paid in silver, the account
closed."* That summary contradicts the scene that produced it: **co-04** fixes the
Saltford terms as **on credit against the summer cargo, no coin down, the account
still open.** A summary or quotation that contradicts the scenes behind it is a
recap-fidelity finding.

```markdown
<!-- review-id: compliance:book1:chapter03:scene02:block-005-v01 -->
- INCONSISTENT (recap-fidelity): the Saltford log line — Fenn's dictated log
  summarizes the Saltford victualling as paid in silver, the account closed. co-04
  fixes that Saltford victualled the ship on credit against the summer cargo, no
  coin down, the account still open. Prose: "provisioned at Saltford, paid in
  silver, the account closed". [defect: prose] [ref: continuity/book-1.md#co-04]
  - Decision: FIX
```

**Defect: prose.** co-04 is valid; the recap is the wrong one.

## The reveal-timing finding (`storyboard_review`)

Reveal timing is checked **pre-draft** by `storyboard_review` against
`reveals.md`, so it is not a compliance unit — it lives in
`plot/book1/chapter03/storyboards/storyboard-review.md`, an advisory report with
**no** anchors, decision fields, or draft stamp.

Scene 1's block 003 has a `## Reader takeaway` that **names the forgery outright**:
"Reader understands that Captain Fenn altered the manifest himself…". But rv-01's
`concealed-until:` is `book1/chapter04/scene02:block-005` — the reader must not
learn it until chapter 4. Block 003 sits at `book1/chapter03/scene01:block-003`, a
full book-position **before** the window closes, so it discloses the secret early.

```markdown
### Block 003
- PREMATURE (reveal): scene 1, Wick's suspicion — the block discloses reveal rv-01
  (Captain Fenn forged the *Cormorant*'s manifest) before its `concealed-until:`
  book1/chapter04/scene02:block-005. The block's `## Reader takeaway` names the
  forgery outright at book1/chapter03/scene01:block-003 — a full book-position early
  … [defect: storyboard] [ref: reveals.md#rv-01]
```

**Defect: storyboard.** By the **reveal-timing carve-out** — `reveals.md` is a
human-authored plan, not derived state, so it outranks storyboard intent:
**canon > `reveals.md` > storyboard > prose** — a storyboard block that discloses
a ledger secret before its `concealed-until:` is a **storyboard** defect. The
guard is *not* talked out of the finding by relaxing the plan; a "ledger is wrong"
(`state`) defect is reserved for the plan being internally inconsistent or
contradicting canon, which is not the case here.

Note the two forgery findings are **different axes**, deliberately: finding 2 is
about a *character* (Wick) knowing too much in the *prose*; this one is about the
*reader* learning too early in the *storyboard*. Reader comprehension and
character knowledge are separate axes (`agents/storyboard-schema.md`), caught by
different checks against different referents.

## The non-prose defect and its routing (block 006)

The prose stands **Teague** at the night helm as officer of the watch. The
maintained roster, **co-06**, says **Sable** stands the night helm. That looks
like a plain prose contradiction — but it is not, because **co-06 itself cannot be
trusted**.

Resolving co-06's provenance: its `evidence:` is
`plot/book1/chapter02/drafts/attempt01/draft-v03.md#scene05` — but chapter 2 was
re-drafted, and its **latest attempt is `attempt02`** (see
`plot/book1/chapter02/drafts/attempt02/`). `continuity_update` re-derived the
other chapter-2 facts onto `attempt02` (co-03 / co-04 / co-05 all cite it) but
left the role entry stamped against the old `attempt01`. Per
`agents/review-context.md`, a maintained entry **stamped in a superseded
(non-latest) attempt is a `state` defect (superseded)** — surfaced, never silently
trusted, so a false-fresh entry can never quietly produce a relational finding.

```markdown
<!-- review-id: compliance:book1:chapter03:scene02:block-006-v01 -->
- INCONSISTENT (role): the night helm — the prose stands Teague at the night helm
  as officer of the watch, against the maintained roster (co-06: Sable stands the
  night helm). But co-06's provenance resolves to chapter02/attempt01/draft-v03.md,
  a superseded attempt — chapter02's latest attempt is attempt02 — so the maintained
  role entry cannot be trusted as fresh: the entry itself is the problem, not the
  prose. Prose: "Teague took the night helm as officer of the watch".
  [defect: state] [ref: continuity/book-1.md#co-06]
  - Decision: ESCALATE
  - Decision-note: re-derive the night-helm role from chapter02/attempt02 (via continuity_update or revise) before judging the prose; do not edit prose on this unit.
```

**Defect: state.** Because the label — not the decision token — routes
remediation, `compliance_fix` **never edits prose for a state defect**, whether
the human recorded `ESCALATE` or `FIX`. It appends an `Escalated:` block routing
the unit to the artifact that owns the fix (`agents/steps/compliance-fix.md`, the
`Escalated:` upstream-target block; the `state` type routes `continuity/` →
`continuity_update` / `revise`):

```markdown
#### Escalated: night helm (review-id: compliance:book1:chapter03:scene02:block-006-v01)
- Reason: state defect — the maintained role referent co-06 is stamped in a superseded attempt (chapter02/attempt01) and cannot be judged against until re-derived; this is not a prose edit.
- Suggested upstream target: continuity_update / revise (continuity) — re-derive the night-helm role from chapter02/attempt02, then re-run the review.
```

So the fix does **not** rewrite "Teague" to "Sable" in the prose — which would
bake in a stale roster. It routes the problem to `continuity/`'s owner to
re-derive co-06 from the latest attempt; only then can the prose (Teague vs.
whoever the fresh roster names) be judged. This is the whole point of assigning
the defect type by **which artifact is wrong under precedence**, not by which
artifact the prose disagrees with.

## The report-level record (`## Context consulted`)

Reproducibility comes from **declaring** the consulted context, not from excluding
it. Every relational report ends with a `## Context consulted` section naming the
exact state entries and files the relational checks read — the canonical audit
surface (`agents/review-context.md`). The compliance report's record:

```markdown
## Context consulted

- continuity/book-1.md#co-02 (chronology — Day 1 departure anchor)
- continuity/book-1.md#co-05 (chronology — Day 12 anchor at chapter 2's close)
- continuity/book-1.md#co-03 (event staging — the longboat cut loose and lost)
- continuity/book-1.md#co-04 (event staging — the Saltford victualling terms)
- continuity/book-1.md#co-06 (role — night-helm assignment; provenance resolves to chapter02/attempt01, a superseded attempt)
- characters/wick/knowledge/book-1.md#kn-02 (concealment — what Wick believes about the short manifest at chapter03/scene02)
- plot/book1/chapter02/drafts/attempt02/draft-manifest.md (latest-attempt check that resolves co-06 as non-latest / superseded)
```

The storyboard-review report carries its own, naming the one ledger entry its
reveal check consulted:

```markdown
## Context consulted

- reveals.md#rv-01 (lands book1/chapter04/scene02:block-005; setup book1/chapter02/scene03:block-002, book1/chapter03/scene01:block-002; concealed-until book1/chapter04/scene02:block-005)
```

## The bounding cost — O(facts + back-references), not O(corpus)

The review **did not read the corpus.** It named the specific referents the prose
invoked and fetched only those. For chapter 3, scene 2 that named set was:

- **Seven maintained-state entries**, by id: `co-02`, `co-05`, `co-03`, `co-04`,
  `co-06` (continuity), `kn-02` (knowledge), and `rv-01` (the ledger, for the
  storyboard check).
- **One back-reference** resolved to judge provenance: chapter 2's latest-attempt
  manifest, `plot/book1/chapter02/drafts/attempt02/draft-manifest.md`, which
  decided co-06's freshness.

It did **not** re-read chapters 1 and 2, did not scan every prior storyboard block,
and did not load any canon file (no block's asserted world-fact required
escalating past its `canon_active`). The cost is **O(facts + back-references)** —
the seven named entries plus the one manifest lookup — not **O(corpus)**. That is
the mechanism that lets the same review scale from this book to a series: the
consulted set stays a small **named** subset, and naming it in `## Context
consulted` is exactly what makes the bounded check auditable and reproducible
(`agents/review-context.md`, `NOTES.md:88-100`).

## Validating the report

The compliance report is a real `compliance:`-family review artifact. From the
repo root:

```sh
sh scripts/validate-review-artifact.sh \
  examples/relational-review/plot/book1/chapter03/drafts/attempt01/reviewer-actions.md \
  agents/review-grammars.yaml
```

It reports `verdict: proceed (exit 0)` — total 5, decided 4, escalated 1, invalid
0 — because every unit carries a legal, filled `Decision:` (four `FIX`, one
`ESCALATE`) and every violation line is a well-formed, anchored review unit. The
five relational findings validate on the existing grammar with no structural or
grammar defects: the ` [defect: <type>] [ref: <referent>]` tag and the
`## Context consulted` section are additive and raise nothing. (Left blank, as a
freshly produced report would be, the same file validates `pending-remain`, exit
4 — the normal fresh-report state, not an error.) The storyboard-review report is
advisory and matches no review-grammar family, so it is not validated by the
script.
