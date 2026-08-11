# Review-context strategy

This doc single-sources the **review-context strategy**: what context a review needs, the minimum
valid context per review class, how a relational review names and retrieves its referents, the
precedence order that resolves a conflict, the defect taxonomy that routes remediation, and how the
whole scheme scales from a short story to a series. It states these once, authoritatively; the
retrofitted steps reference it rather than restating them.

It is distinct from the two existing review docs. `agents/review-grammars.yaml` owns the
review-artifact **format** (the unit/anchor/`review-id`/`Decision:` scheme) and
`agents/review-validation.md` owns **how to run the checker**. This doc owns **what context a
review needs**. No temporal-state rule, freshness predicate, or grammar token set is restated here —
each cites its single source.

## Classification and minimum context

A review is classified by the **defect it checks** — not by the files it happens to open, and not by
convenience. Three classes, each with a minimum valid context below which the check cannot be
trusted:

- **local** — block/scene-local surface or structural checks (a figure inventory, an AI-tell scan, a
  Must-Contain presence check). Minimum context: **the block/scene**. A local check is legitimately
  context-free and may stay block/scene-scoped.
- **bounded-window** — whole-chapter prose-quality checks evaluated over a span (register, voice, POV,
  pacing across a chapter). Minimum context: **the current chapter**.
- **relational** — prose checked against facts established **elsewhere**: continuity,
  character-knowledge, reveal-timing, chronology, recollection, quotation, summary, and recap
  fidelity. Minimum context: the **maintained state** (`continuity/`, `characters/<id>/knowledge/`,
  `reveals.md`) **plus targeted retrieval** of the named source evidence the prose invokes, tiered by
  check type. The tiers are stated once in `NOTES.md:74-79`: intra-chapter continuity → the whole
  current chapter; cross-chapter / cross-book → maintained state + targeted retrieval, **never** a
  full re-read; canon → the block's `canon_active` first, escalating to *named* canon files only when
  it is insufficient; concealment-from-characters → the relevant character `knowledge/` file.

A relational check **cannot** be done block-locally or in scene-blind shards: the failure classes it
catches are cross-scene by construction, so partitioning them by block makes every such contradiction
structurally invisible (`NOTES.md:42-46`, `:95-97`).

## The audit

Every current review step, its class, and a one-line justification:

| Review step | Class | Justification |
|---|---|---|
| `anti_ai_report` | local | context-free by design (`agents/steps/anti-ai-report.md:29`) |
| `metaphor_identify` | local | figures only; "Do not read canon files, the scene list, or any other file" (`agents/steps/metaphor-identify.md` Inputs) |
| `prose_pass` | bounded-window | storyboards + `voice.md` for register, not diffed (`agents/steps/prose-pass.md:52-53`) |
| `compliance_report` | relational | reads prose against `continuity/` + `knowledge/` + canon (retrofit, M16.3/M16.6) |
| `storyboard_review` | mixed — reveal-setup **relational**; takeaway-support + takeaway/concealment **bounded-window** | reveal-setup reasons across chapters against `reveals.md` (retrofit); the other two checks stay within the storyboard set |

A review's class is set by the **defect it checks**, not by convenience — a local check may stay
block/scene-local, a relational check may not.

## Referent identification and targeted retrieval

A relational review does not scan the corpus. It **names** the specific things the prose invokes, then
fetches only what those names require.

- **Naming the referent.** Referential prose is detectable and self-describing. A recap, quotation, or
  recollection **names its referent** — the earlier event, line, or scene it recalls. A continuity
  claim **names its fact-class and subject** — a chronology anchor for a named day, a possession for a
  named holder, a role at a named post, a location for a named party. A reveal or a
  takeaway-depends-on-prior-understanding beat names the reveal it builds toward. That naming is
  exactly what tells the review which referent to fetch.
- **Targeted retrieval.** Having named the referents, the review obtains **only** the maintained-state
  entries and named source evidence needed to judge them — the specific `continuity/` / `knowledge/` /
  `reveals.md` entries, the named canon file, or the specific prior scene — never a full re-read. The
  cost is O(facts + back-references), not O(corpus).

A maintained-state entry is used **only when its currency can be unambiguously resolved** by its full
attempt-qualified provenance: its `story-position` for point-in-time reconstruction, and its full
attempt-qualified draft path for freshness. An entry whose currency **cannot** be unambiguously
resolved is treated as **missing-context** (ambiguous — surface as an open question); an entry stamped
in a **superseded (non-latest) attempt** is treated as a **state** defect (superseded). Neither is
silently trusted — a false-fresh entry must never quietly produce a relational finding. The freshness
model itself is not restated here: it lives in `agents/characters.md` ("## Temporal character-state
model", "Freshness is derived, never stored") and `agents/continuity.md` ("## Freshness").

## Precedence

Three orders govern a relational review. They are stated once here (the source is `NOTES.md:82-87`
plus `agents/continuity.md`); a review does not invent a fourth.

- **Review tiebreak over DERIVED state** — what the reviewed prose should match on a
  continuity/knowledge fact: **the storyboard block's deliberate intent > the distilled
  continuity/knowledge state > raw canon/prose**. Broader context **supplements, never overrides** the
  block — reaching into raw source without a tiebreaker manufactures false positives wherever a
  storyboard deliberately diverged. This holds because `continuity/` and `knowledge/` are **derived**
  from prose, so a storyboard may legitimately outrank them.
- **Reveal-timing carve-out** — `reveals.md` is a **human-authored plan/spec, not derived state**, so
  for reveal-timing checks it is the **controlling authority and outranks storyboard intent**:
  **canon > reveal plan (`reveals.md`) > storyboard > prose**. Consequence: a storyboard block that
  discloses a ledger secret before its `concealed-until:` is a **storyboard defect** (the storyboard
  violates the reveal plan) — **never** a "ledger is wrong" defect, and the guard must not be talked
  out of the finding by relaxing the plan. A **reveals-ledger** defect is reserved for the plan being
  wrong on its own terms (internally inconsistent, or contradicting canon).
- **Authoring authority** — which artifact owns a fact: **canon > continuity** (`agents/continuity.md`).
  A prose-vs-canon contradiction is **surfaced, not absorbed**.

The first order tiebreaks *what the prose should match*; the third fixes *which artifact owns the
fact* underneath it (canon sits above continuity in both). The carve-out is the one place a
maintained-state artifact outranks a storyboard, and only because `reveals.md` is authored intent, not
a derivation.

## Defect taxonomy

A relational finding carries a **defect type** assigned by **which artifact is wrong under
precedence** — not "which artifact the prose disagrees with." Five labels, each routing remediation to
the artifact that owns the fix:

- **prose** — the prose is the wrong one. This includes the common case where the **storyboard intent
  and the maintained state agree** and only the prose diverges: that is a prose defect, and
  `compliance_fix` edits the prose.
- **storyboard** — the beat's own spec under-specifies or misstates the fact, **including a storyboard
  block that discloses a ledger secret before its `concealed-until:`** (it violates the
  higher-precedence reveal plan, per the carve-out above).
- **state** — a maintained-state entry itself is at fault: it is **derived-stale**, or (for the
  **derived** `continuity/` / `knowledge/` entries) it contradicts higher-precedence storyboard intent
  or canon. The **state** type spans all three maintained-state artifacts, each routing to its owner:
  `continuity/` → `continuity_update` / `revise` (or surface as an M15 continuity conflict);
  `characters/<id>/knowledge/` → `scene_knowledge_update` / `revise`; and the human-authored
  **`reveals.md`** → the human who maintains the ledger. For `reveals.md` the qualifier differs
  because the ledger *outranks* storyboards: a **reveals-ledger defect** is the plan being wrong on its
  own terms (internally inconsistent, or contradicting canon), **not** a storyboard disagreeing with it
  (that is a storyboard defect).
- **canon** — the settled **canon artifact itself** is at fault: internally contradictory, or a rule
  the prose exposes as needing revision — routed to the canon file / the human, never edited in prose.
  Prose that merely contradicts *valid* settled canon is **not** a canon defect but a **prose** defect
  (canon outranks, so the prose is the wrong one and `compliance_fix` corrects the prose to conform).
- **missing-context** — the fact needed to judge is absent from every consulted source (surface as an
  open question).

Because the label routes remediation, **`compliance_fix` routes on the label for every decision —
`FIX` included, not only `ESCALATE`** — so a mislabeled `FIX` cannot edit prose for a non-prose
defect: a prose `FIX` is applied to prose; a state / storyboard / canon / missing-context decision is
directed to its authoritative artifact and never silently applied to prose. `NOTES.md:108-111` is the
precedent ("Label storyboard-defect vs prose-defect ... so the fix step is pointed at the storyboard,
not the prose").

## Project-scale and type gradation

The relational review scales by tiering context to project type, never by reading more:

- **`short_story`** → whole-work context where practical (the whole draft is loadable).
- **`book`** → the whole current chapter + prior maintained state.
- **`series`** → maintained state + targeted retrieval, **never a full-corpus reread**.

New relational inputs are **`required: false` and project-type-aware**: prior-chapter material,
`continuity/`, and `reveals.md` exist meaningfully only for `book` / `series`, so a `short_story` must
not block on their absence (`NOTES.md:103-107`). This project-type-aware, targeted-retrieval bounding
is the mechanism that makes the review scale to a series.

## The finding contract

Relational findings stay **per-block review units**. The relational nature is carried by a **cited
referent** in the finding text and a report-level **`## Context consulted`** record — reproducibility
comes from *declaring* the consulted context, not from excluding it, and at series scale the consulted
set is a small named subset whose naming is what makes a bounded check auditable
(`NOTES.md:88-100`). The unit/anchor/`review-id`/`Decision:` scheme itself is not restated here — see
`agents/review-grammars.yaml`; no cross-block units are invented.

These surface forms are canonical (downstream files agree on them):

- A relational finding rides on the existing `^- ` violation line and appends a greppable trailing
  tag: `[defect: <type>] [ref: <referent>]`, where `<type>` ∈ {prose, storyboard, state, canon,
  missing-context} and `<referent>` is one of `continuity/book-N.md#co-NN`,
  `characters/<id>/knowledge/book-N.md#kn-NN`, `reveals.md#rv-NN`, or `canon/<file>` + a quote.
- Every relational report declares a report-level section headed exactly `## Context consulted`, a
  bulleted list naming the specific state entries / chapters / files actually read — e.g.
  `- continuity/book-1.md#co-03 (chronology anchor)`.

The M14/M15 temporal-state model (`agents/characters.md`, `agents/continuity.md`) and the worked
example that grounds this whole strategy (`NOTES.md:24-46`, `:82-100`) are referenced, not restated.
