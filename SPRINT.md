# Sprint 21 — Milestone 16: Bounded relational review

This Sprint makes Amanuensis's **relational reviews** — continuity, character-knowledge, reveal-timing,
recalled-event-staging, and recap-fidelity checks — work correctly when the full prose corpus cannot fit
in one model context. It is the review layer M14 and M15 were built to enable: M14 gave every character a
maintained, story-positioned **knowledge state**; M15 gave the story a maintained, evidence-stamped
**objective continuity state**; M16 teaches the reviews to **read prose against that maintained state plus
targeted retrieval of named source evidence** — cost O(facts + back-references), not O(corpus) — so a
review of one bounded prose unit can catch a contradiction whose evidence lives in this chapter, an
earlier chapter, or an earlier book, without loading the whole series.

The gap this closes is documented in `NOTES.md`. A `compliance_report` run on `the-course-he-kept`
evaluated per scene, in parallel, and reported all 40 blocks clean; a second, global pass found **8 real
violations across 6 blocks** — elapsed-time claims that contradict a day-count timeline, a moon-phase
regression across a time skip, a remembered scene whose staging contradicts the scene that delivered it, a
testimony-and-decode recap that contradicts the scenes that produced it, and an officer put at the helm
against the ship's roster (`NOTES.md:24-46`). Every one was already provable from the declared inputs; the
limiter was **not** input scope but two instructions: block-local framing ("each block's `canon_active`
contains everything needed; do not read other files") and evaluation partitioning (splitting the analysis
per scene makes every cross-scene contradiction structurally invisible, `NOTES.md:38-50`). The reusable
lesson is narrower and deeper than "declare more inputs": the failing checks are **relational** (prose vs.
facts established elsewhere), and relational checks cannot be done block-locally or in scene-blind shards —
they must check prose against distilled maintained state + targeted retrieval, tiered by check type
(`NOTES.md:52-79`).

The milestone does four things. It **defines the model** (M16.1, M16.4, M16.5, M16.7, M16.8) — the
local / bounded-window / relational classification, the minimum-valid-context strategy per class, how a
review identifies its referents and retrieves only what it needs, the precedence order among storyboard,
maintained state, canon, and prose, the prose-vs-storyboard-vs-state-vs-canon-vs-missing-context defect
taxonomy, and the project-scale gradation — single-sourced in a new `agents/review-context.md`. It
**audits** every review step (M16.2) and records each one's class. It **removes the structural blindness**
(M16.3, M16.6) by retrofitting the two relational reviews: `compliance_report` becomes the bounded
relational review that reads prose against `continuity/` + `knowledge/` + canon, and `storyboard_review`'s
reveal-setup check reasons across chapters against a new **story-level reveals ledger** (`reveals.md`).
Both carry relational findings on the **existing per-block review-unit scheme** — the anchor is the
reviewed prose location, the referent is cited in the finding, and a report-level `## Context consulted`
section declares what was read. It closes with a **worked demonstration** (M16.9) against the `NOTES.md`
failure set and a smoke recipe.

Two owner decisions from planning shape the Sprint (both starred in Conventions). (1) M16 is realized by
**retrofitting `compliance_report`** into the bounded relational review — reading prose against the M14/M15
maintained state plus targeted retrieval — **not** by building a new `continuity_report`/`continuity_fix`
review family, and **not** definitional-only. Relational findings stay on the existing per-block review-unit
scheme, so `agents/review-grammars.yaml` and `scripts/validate-review-artifact.sh` change **additively at
most** (M16 is permitted to touch them, unlike M15, but the design does not need to). This realizes the
Deferred "continuity review step" *inside* `compliance_report`, not as a separate step. (2) Reveal-timing is
carried the **broad** way: **also retrofit `storyboard_review`** to reason across chapters against a new
**story-level reveals ledger** — a human-authored planning artifact (`reveals.md`, `role: planning`, no
pipeline writer), realizing the Deferred "story-level reveals ledger with buildup" item. This Sprint adds
**no new pipeline step** and makes **no recipe change** — both retrofit targets are already in the recipe.

## Background — what is and isn't wrong today

Established by inspection during planning, with file:line cites; tasks should not re-derive this.

- **The maintained state the reviews must consult now exists — M16 is the consumer M14/M15 anticipated.**
  M14 built `characters/<id>/knowledge/` with a story-positioned temporal model (durable `id`,
  `story-position`, `committed-in`, non-destruction transitions — `agents/characters.md`'s Temporal
  character-state model). M15 built `continuity/` (the objective-fact state — chronology, event-staging,
  location, possession, physical-condition, role, open-thread — with a retrievable `evidence:` pointer per
  fact, `agents/continuity.md`). Both M15's planning addendum and the M15 SPRINT explicitly named "the
  bounded relational continuity *review* that reads prose against this state" as **M16** (`ROADMAP.md` M15
  Notes; `SPRINT.md`-Sprint-20 "Out of scope"). This Sprint is that review.
- **`compliance_report` is already a relational review whose framing hides relational defects.** It runs
  three checks — Must-Contain (`must_preserve`, `character_state_out`), Must-Not-Contain
  (`concealment_from_reader`, `concealment_from_characters`), and Canon (`canon_active`) —
  (`agents/steps/compliance-report.md:95-117`). Two of those are relational: `concealment_from_characters`
  is a character-knowledge check, and Canon is a fact-consistency check. But the step is told **"Do not read
  any other files. In particular, do not consult source canon files: each block's `canon_active` field is
  supposed to contain everything needed"** (`:33`, echoed `:115`, `:153`), and **"Work block by block. Do not
  collapse findings across blocks"** (`:93`). Those are exactly the block-local framing and evaluation
  partitioning `NOTES.md:38-50` identifies as the limiter. The `NOTES.md` worked example *is* a
  `compliance_report` run; retrofitting this step is the milestone's core.
- **`storyboard_review`'s reveal-setup check is relational but hard-scoped to one chapter.** Check 2
  confirms that a block whose `reader_takeaway` depends on prior understanding (including every
  `beat_type: reveal`) has earlier setup and is not still under `concealment_from_reader` at that point
  (`agents/steps/storyboard-review.md:72-78`) — but **"This check is within-chapter only. Cross-chapter and
  story-level reveal tracking are deferred; do not reason about blocks outside the current chapter"** (`:78`,
  anti-pattern `:115`). Unlike `compliance_report`, this step had **no maintained state to consult** for
  cross-chapter reveals — which is why its scoping was a correct deferral, not a blindness bug, until this
  Sprint builds the reveals ledger it can consult.
- **Reveal timing is a distinct reader-comprehension axis, not covered by `knowledge/` or `continuity/`.**
  The storyboard schema is explicit: `reader_takeaway` (what the reader must understand) and `knowledge_delta`
  (what a *character* learns) are **different axes** — "a reader can grasp what no character knows, and a
  character can learn what the reader must not yet understand" (`agents/storyboard-schema.md:101-108`);
  `concealment_from_reader` "guards reveal timing and series-long canon integrity" (`:92-94`). So M14's
  `knowledge/` (character axis) and M15's `continuity/` (objective-fact axis) do **not** track reader-facing
  reveal buildup. A cross-chapter reveal-setup check needs its own maintained index — the reveals ledger.
- **The only reveal-timing home today is freeform, book-level, human-authored risk notes.** `agents/books.md:55`
  lists `continuity.md` as an optional book planning artifact and `:59-66` describes it as human notes on
  "fragile reveal timing," "dependencies across chapters," and "known consistency risks" — `role: planning`,
  book-scoped, freeform. M15 deliberately left it untouched and distinct from the derived `continuity/`
  folder. The reveals ledger is its structured, story-level, review-consumable evolution: it keeps
  `continuity.md` as-is (freeform book-level risk notes) and adds a distinct **story-level** `reveals.md`
  (structured, `id`-bearing, greppable) that `storyboard_review` can query.
- **The other three reviews are correctly local or bounded-window — the audit records them, unchanged.**
  `anti_ai_report` is **"context-free by design"** — surface and structural signals only, "no awareness of
  canon, storyboard requirements, or voice spec" (`agents/steps/anti-ai-report.md:23`,`:29`): **local**.
  `metaphor_identify` extracts figures and is told "Do not read canon files, the scene list, or any other
  file"; storyboards inform register only, "do not treat storyboard fields as specifications to diff against"
  (`agents/steps/metaphor-identify.md` Inputs): **local**. `prose_pass` judges prose quality with a
  density/clustering pass over spans and reads storyboards + `voice.md` "to judge whether the prose is
  serving the scene as designed," not diffed (`agents/steps/prose-pass.md:52-53`,`:208-227`):
  **bounded-window**. None has a relational responsibility; M16 changes none of them.
- **Findings must stay per-block review units; the relational nature is carried in cited referents and
  declared context.** `NOTES.md:98-100` and the M16 Notes require it: "Findings stay per-block review units.
  The relational nature is carried in the finding's cited referent, not by inventing cross-block units — the
  review-id/anchor scheme is preserved." The `compliance:` family grammar keys the container check on
  `### Block ` headings, the item line on `^- ` (`agents/review-grammars.yaml:141-145`), and a report-level
  section (like `### Summary`) is neither a `### Block ` container nor a `^- ` item — so a cited referent
  *inside* the violation line and a report-level `## Context consulted` section are **additive** and do not
  disturb the validator. M16 is permitted to change `review-grammars.yaml` /
  `scripts/validate-review-artifact.sh`, but the design is verified to need at most additive changes, gated
  on the updated `examples/review/reviewer-actions.md` fixture.
- **Precedence already has a stated answer — two orders that do not conflict.** For a *review tiebreak*
  (what the reviewed prose should match), `NOTES.md:82-87` fixes: **storyboard block intent > distilled
  canon/continuity state > raw source**; broader context *supplements, never overrides* the block, so
  reaching into raw canon without a tiebreaker "manufactures false positives wherever a storyboard
  deliberately diverged." For *authoring authority* (which artifact owns a fact), `agents/continuity.md`
  fixes canon > continuity, and a prose-vs-canon contradiction is surfaced, not absorbed. M16.5 states both
  and their relationship; it does not invent a new order.
- **`compliance_fix` already has the remediation hook the defect taxonomy needs.** It applies `FIX` units in
  prose and, for `ESCALATE` units, appends an `Escalated:` block naming a **"Suggested upstream target:
  storyboard block / canon file / open question"** (`agents/steps/compliance-fix.md:71-80`); it is told **"Do
  not read canon files during this step. If a fix requires canon clarification, the human should have marked
  it `ESCALATE`"** (`:51`). M16.7's defect-type labels direct exactly this routing — a state/storyboard/canon
  defect must not be "fixed" in prose — so the change is a strengthening of the existing `ESCALATE` target,
  not new machinery.
- **This Sprint adds no pipeline step, so the recipe and its consistency surfaces are untouched.** Unlike M14
  and M15, M16 retrofits **existing** steps (`compliance_report`, `storyboard_review`, `compliance_fix`),
  all already in both recipes (`templates/pipeline-state.md`, `examples/smoke/pipeline-state.md`). So the two
  step lists, both `scripts/check-pipeline-state.sh` modes (resolvable + `--exhaustive`), and the CI
  ordered-equality check (`.github/workflows/pipeline-state-check.yml`) require **no** change. `AGENTS.md`
  gains two support-doc catalog lines (`agents/review-context.md`, `agents/reveals.md`); the step catalog
  lines already exist (their one-line descriptions are refreshed). `install.sh` enumerates neither steps nor
  docs and stays unchanged.
- **The reveals ledger has no derived writer, by design.** `storyboard_review` runs **pre-draft** — no
  committed prose exists yet (`agents/steps/storyboard-review.md:26`,`:33`) — and a reveal is **forward
  authorial intent** (a plan), not a fact derived from accepted prose the way `continuity/`/`knowledge/` are.
  A step that derived the ledger from storyboards, then reviewed those same storyboards against it, would be
  near-circular. So the ledger is **human-authored** (like `outline.md`, the storyboards themselves, and the
  freeform `continuity.md`), consumed read-only by `storyboard_review`. A *derived* reveals writer is a
  deferred follow-on.
- **"Which chapter is current" for book/series stays the deferred, worked-around question.** The
  orchestrator records chapter selection for book/series as an open TODO
  (`agents/orchestrator.md:146-148`). M16.9's demonstration is a hand-authored fixture (like
  `examples/character-state/` and `examples/continuity/`), reconstructed by reading the stamped state — it
  does not require the pipeline to resolve "current chapter."

## Definition of done

The Sprint is complete when:

1. ROADMAP.md tasks M16.1–M16.9 are checked; M17 is untouched. The M16 section Notes carry the Sprint-21
   planning addendum (already appended at planning). The Deferred "story-level reveals ledger with buildup"
   and "continuity review step" items are **removed** (each realized here), and any newly-surfaced follow-ups
   are added to the Deferred list; nothing else outside M16 changes.
2. **The review-context model is defined and single-sourced in a new `agents/review-context.md`** (parallel
   to `agents/continuity.md` and `agents/canon.md`), covering: the **local / bounded-window / relational**
   classification and the minimum-valid-context strategy per class (M16.1); the **audit** — a table naming
   every review step (`storyboard_review`, `compliance_report`, `prose_pass`, `metaphor_identify`,
   `anti_ai_report`) with its class and one-line justification (M16.2); the **referent-identification and
   targeted-retrieval** rule (how a review names the characters/events/facts/constraints/back-references it
   must check, then obtains only the maintained state and named source evidence needed — M16.4); the
   **precedence** rule (review tiebreak storyboard > distilled state > raw source, atop authoring-authority
   canon > continuity — M16.5); the **defect taxonomy** (prose / storyboard / state / canon / missing-context,
   each with which artifact owns the fix — M16.7); and the **project-scale/type gradation** (short_story
   whole-work; book whole-chapter + prior state; series maintained-state + targeted retrieval, never a
   full-corpus reread — M16.8). It states once that relational findings stay per-block review units carrying a
   cited referent + a declared `## Context consulted` record, and references (does not restate) the M14/M15
   temporal-state model and `NOTES.md`'s worked example.
3. **The story-level reveals ledger exists as a defined artifact.** A new `agents/reveals.md` (single source)
   defines the ledger: a **story-level, human-authored planning artifact** (`role: planning`, project-root
   `reveals.md`, **no pipeline writer**), distinct from the freeform book-level `continuity.md` risk notes
   (cross-referenced, not merged). Each entry carries `id` (`rv-NN`, minted once), the reveal content, a
   `lands:` story-position (canonical folder-style, book-qualified for series so one ledger spans books), an
   ordered `setup:` list of the buildup positions that establish it, and a `concealed-until:` position before
   which the reader must not learn it — reusing the M14/M15 `id`/`story-position` idiom (referenced, not
   restated). A new `templates/reveals.md` realizes the shape as legible Markdown. `reveals.md` appears in
   `agents/project-layouts.md` (all three project trees, with resolution rules) and in
   `templates/project-AGENTS.md` (Project Paths + Where To Look, adding `agents/review-context.md`,
   `agents/reveals.md`, and `reveals.md`).
4. **`compliance_report` is retrofitted into the bounded relational review** (M16.3, M16.6). Its block-local
   blindness is removed: the "Do not read any other files / do not consult source canon" rule
   (`agents/steps/compliance-report.md:33`,`:115`,`:153`) is reframed to the `agents/review-context.md`
   strategy, and the "Work block by block. Do not collapse findings across blocks" rule (`:93`) is scoped to
   *local* checks only, with **scene-blind sharding forbidden for relational checks**. It gains
   `required: false`, project-type-aware inputs — `continuity/` (M15), `characters/<id>/knowledge/` (M14), and
   named canon files — and: (a) consults the maintained state + targeted retrieval of named referents for its
   relational checks (canon consistency, `concealment_from_characters` vs. maintained knowledge, and the
   continuity fact-classes — chronology, event-staging, possession, role, location, physical-condition,
   open-thread — including recalled-event-staging and recap fidelity); (b) applies the precedence rule; (c)
   emits each relational finding as a per-block review unit **citing its conflicting/supporting referent**
   (`continuity/…#co-NN` / `knowledge/…#kn-NN` / a canon file + quote) and **labeling its defect type**; and
   (d) writes a report-level `## Context consulted` section naming the specific state entries / chapters /
   files read. The Must-Contain local checks and the existing anchor/`Decision:` review-unit scheme are
   preserved; `review_required: true` and the `reviewer-actions.md` output path are unchanged.
5. **`storyboard_review` reasons across chapters against the reveals ledger** (M16.3, M16.6). Its
   within-chapter-only scoping of the reveal-setup check (`agents/steps/storyboard-review.md:78`,`:115`) is
   replaced: it gains a `required: false` `reveals.md` input and, for each `beat_type: reveal` (or
   takeaway-depends-on-prior-understanding) block, checks setup against the ledger by **targeted lookup** of
   the reveal's `setup:` positions — never a full prior-storyboard rescan — and confirms nothing before
   `concealed-until:` discloses it. Findings cite the ledger entry (`reveals.md#rv-NN`) as the referent and
   declare context consulted; a ledger that under-specifies a reveal is labeled a **reveals-ledger defect**,
   not a storyboard defect. The step stays advisory / report-only (no fix step), and its within-chapter
   takeaway-support and takeaway/concealment checks are unchanged.
6. **`compliance_fix` routes remediation by defect type** (M16.7). Its `ESCALATE` handling
   (`agents/steps/compliance-fix.md:71-80`) is extended so a finding labeled state / storyboard / canon /
   missing-context defect is directed to its authoritative artifact (the strengthened "Suggested upstream
   target") rather than edited in prose; a prose-defect `FIX` is applied as today. The step's per-unit gate,
   freshness check, validator call, and surgical-edit discipline are otherwise unchanged.
7. **The review-artifact grammar/validator change is additive and verified.** The updated
   `examples/review/reviewer-actions.md` fixture carries at least one relational finding (cited referent +
   defect-type label) and a `## Context consulted` section, and `scripts/validate-review-artifact.sh` run
   over it returns the expected ledger and exit 0 (or the fixture's documented state). `agents/review-grammars.yaml`
   and `scripts/validate-review-artifact.sh` are changed **only** if the run shows a structural conflict; any
   change is minimal and its rationale recorded. The three other family fixtures and their validator behavior
   are byte-for-byte unchanged.
8. **`agents/workflows.md` reflects the retrofit.** The freeform "continuity review" workflow
   (`agents/workflows.md` "Workflow: continuity review") is updated so its automated realization now points at
   the retrofitted `compliance_report` (the bounded relational review reading prose against `continuity/` +
   `knowledge/`), and a "reveals ledger" note is added near the storyboard-review workflow describing the
   human-authored `reveals.md` and its cross-chapter reveal-setup consumption. The book-level `continuity.md`
   risk-notes distinction (from M15) is preserved.
9. **`AGENTS.md` catalogs are updated.** The support-doc catalog gains `agents/review-context.md` and
   `agents/reveals.md` lines; the `compliance-report.md` and `storyboard-review.md` step-catalog descriptions
   are refreshed to name their relational-review role. No step file is added or removed; the recipe lists and
   both `check-pipeline-state.sh` modes are untouched.
10. **A worked demonstration is committed** under `examples/relational-review/` (clearly marked as an example
    per `AGENTS.md:22-26`, mirroring `examples/continuity/README.md`): a `book`-project fixture — maintained
    `continuity/` + `characters/<id>/knowledge/` state, a `reveals.md` ledger, storyboards, and an accepted
    draft — that exercises the `NOTES.md` failure set: **cross-scene chronology** (an elapsed-time claim vs. a
    day/anchor timeline), **character knowledge** (prose acting on knowledge a character was concealed from at
    that story position), **reveal timing** (a reveal landing before its ledger `setup:` / before
    `concealed-until:`), **recalled event staging** (a remembered scene whose staging contradicts the
    maintained fact), and **recap fidelity** (a summary/quotation that contradicts the scenes that produced
    it). The README shows, for each, the per-block review unit with its **cited referent** and **defect-type
    label**, the report-level `## Context consulted` record, and — for at least one non-prose defect — the
    `compliance_fix` routing to the authoritative artifact; and it states the bounding cost (facts +
    back-references consulted, not the corpus).
11. **Smoke coverage exists** in `examples/smoke/README.md`: at least one recipe that hand-authors the
    maintained state (`continuity/`, a `knowledge/` file), storyboards, and an accepted draft, runs the
    retrofitted `compliance_report`, and confirms a relational finding is produced with a cited referent and a
    `## Context consulted` section, and that `validate-review-artifact.sh` accepts the report; the recipe
    enumeration, layout/untracked notes, and reset procedure are updated for the new recipe number and paths;
    existing recipes (1–22) stay byte-for-byte untouched.
12. **Verification passes.** `git diff --stat` against the captured Sprint-start SHA shows **no** changes to
    the three local/bounded-window review steps (`agents/steps/anti-ai-report.md`,
    `agents/steps/metaphor-identify.md`, `agents/steps/prose-pass.md`) or their fix/apply steps beyond nothing;
    **no** changes to the recipe lists, either CI workflow yml, `install.sh`, or the dispatcher command/agent
    files; and the review-grammar/validator either unchanged or changed only additively per item 7. Both
    `check-pipeline-state.sh` modes pass; the two step lists stay ordered-equal. Greps confirm the sweep:
    `git grep -ln "review-context\|reveals.md\|reveals ledger"` lists at least the two new support docs, the
    template, the two retrofitted steps, `agents/project-layouts.md`, `templates/project-AGENTS.md`, and
    `AGENTS.md`; `git grep -n "do not read other files\|within-chapter only"` shows the block-local /
    within-chapter blindness instructions retired from the two retrofitted steps.

## Conventions adopted by this Sprint

Locked at planning (the two starred items are owner decisions from this Sprint's planning session); tasks
don't rediscover them.

- **★ M16 is realized by retrofitting `compliance_report` into the bounded relational review — not a new
  review family, not definitional-only.** The owner chose to make the existing compliance review read prose
  against the M14/M15 maintained state + targeted retrieval, carrying relational findings on the existing
  per-block review-unit scheme. Rationale: the `NOTES.md` worked example *is* a `compliance_report` run whose
  8 violations were all provable from declared inputs — the fix is reframing its block-local / scene-blind
  instructions, not adding a step; and the M16 Notes require the review-unit/anchor scheme be preserved. This
  realizes the Deferred "continuity review step" *inside* `compliance_report`. Rejected: a new
  `continuity_report`/`continuity_fix` family on the validator machinery — heaviest, adds a parallel review
  artifact the M16 Notes say to avoid, overlaps M17 timing. Rejected: definitional-only (model + audit + strip
  instructions, defer the wiring and demo) — leaves the relational review defined-but-not-working, the exact
  gap M14/M15 were built to let M16 close.
- **★ Reveal-timing is carried broadly: also retrofit `storyboard_review` against a new story-level reveals
  ledger.** The owner chose the broad reveal-timing option over carrying reveal-timing solely through
  `compliance_report`'s knowledge-state check. So this Sprint builds a **story-level reveals ledger**
  (`reveals.md`) and teaches `storyboard_review`'s reveal-setup check to reason across chapters against it,
  realizing the Deferred "story-level reveals ledger with buildup" item. Rationale: reveal timing is a
  reader-comprehension axis that neither `knowledge/` nor `continuity/` tracks
  (`agents/storyboard-schema.md:101-108`), so cross-chapter reveal-setup checking needs its own maintained
  index. Rejected: leave `storyboard_review` within-chapter and carry reveal-timing only via
  `compliance_report` × `knowledge/` — narrower, and leaves the within-chapter blindness (`:78`) unaddressed.
- **The reveals ledger is a human-authored, story-level planning artifact with no pipeline writer.**
  `storyboard_review` is pre-draft (no committed prose) and a reveal is forward authorial intent, so there is
  nothing accepted to derive from and a derived writer that reads the same storyboards it feeds would be
  near-circular. The ledger is therefore human-authored — like `outline.md`, the storyboards, and the freeform
  `continuity.md` — and consumed read-only. It lives at project root as **`reveals.md`** (story-level: one
  ledger per work, spanning books in a series via book-qualified `story-position`s), `role: planning`, and is
  kept **distinct** from the book-level freeform `continuity.md` risk notes (`agents/books.md:59-66`), which
  stay as-is and are cross-referenced. Rejected: a derived `reveals_update` writer step (near-circular,
  heavier, no accepted-prose basis pre-draft) — recorded as a deferred follow-on. Rejected: evolve the
  book-level `continuity.md` (book-scoped and freeform; conflates human risk notes with a structured
  review-consumable index — the same collision M15 avoided for `continuity/`).
- **The model single-sources in a new `agents/review-context.md`; the ledger schema in a new `agents/reveals.md`.**
  Two new support docs parallel to `agents/continuity.md` — one holds the review-context *strategy* (the
  classification, minimum-context-per-class, retrieval, precedence, defect taxonomy, scale gradation, and the
  audit table), the other the reveals *artifact schema*. They are distinct from the two existing review docs:
  `agents/review-grammars.yaml` owns the review-artifact *format* and `agents/review-validation.md` owns *how
  to run the checker*; `agents/review-context.md` owns *what context a review needs*. No temporal-state rule
  or grammar token set is restated — each cites its single source.
- **The audit (M16.2) records three reviews unchanged and two retrofitted.** `anti_ai_report` — **local**
  ("context-free by design," `agents/steps/anti-ai-report.md:29`). `metaphor_identify` — **local** ("Do not
  read canon files, the scene list, or any other file"). `prose_pass` — **bounded-window** (storyboards +
  voice for register, not diffed, `agents/steps/prose-pass.md:52-53`). `compliance_report` — **relational**
  (retrofit). `storyboard_review`'s reveal-setup check — **relational** (retrofit); its takeaway-support and
  takeaway/concealment checks are bounded-window and unchanged. A review's class is set by the **defect it
  checks**, not by convenience: a local check may stay block/scene-local, a relational check may not.
- **Relational findings stay per-block review units; the relational nature is the cited referent + declared
  context.** A cross-scene finding is anchored to the reviewed prose block (its own review unit under the
  existing grammar) and **cites the conflicting/supporting referent** in the finding text
  (`continuity/…#co-NN` / `knowledge/…#kn-NN` / `reveals.md#rv-NN` / a canon file + quote); the report
  declares a report-level `## Context consulted` record of the specific state entries / chapters / files read
  (`NOTES.md:88-100`). Reproducibility comes from **declaring** the consulted context, not from excluding it;
  at series scale the consulted set is a small named subset, and naming it is what makes a bounded check
  auditable. The anchor/`review-id`/`Decision:` scheme is preserved; no cross-block units are invented.
- **Precedence: two orders, stated once, non-conflicting (M16.5).** For a *review tiebreak* — what the
  reviewed prose should match — **the storyboard block's deliberate intent > the distilled continuity/knowledge
  state > raw canon/prose**; broader context supplements, never overrides the block, so raw source without a
  tiebreaker cannot manufacture a false positive where a storyboard deliberately diverged (`NOTES.md:82-87`).
  For *authoring authority* — which artifact owns a fact — **canon > continuity** (`agents/continuity.md`), and
  a prose-vs-canon contradiction is surfaced, not absorbed. The review tiebreak sits atop the authoring order
  and does not change it. Rejected: "`canon_active` is authoritative, ignore everything else" (the current
  block-local rule — manufactures false positives on deliberate divergence and hides cross-scene defects);
  rejected: raw source always wins (overrides deliberate storyboard intent).
- **Scope is tiered by check type; new inputs are `required: false` and project-type-aware.** Intra-chapter
  continuity → the whole current chapter (bounded); cross-chapter / cross-book → maintained state + targeted
  retrieval of named referents, **never** a full re-read; canon → block `canon_active` first, escalate to
  *named* canon files only when it is insufficient or the prose asserts a checkable fact it doesn't cover;
  concealment-from-characters → the relevant character `knowledge/` file (`NOTES.md:74-79`). Prior-chapter
  material, `continuity/`, and `reveals.md` exist meaningfully only for `book`/`series`, so a `short_story`
  must not block on their absence — every new input is `required: false` (`NOTES.md:103-107`). This is the
  bounding mechanism that makes the review scale to a series.
- **Defect type routes remediation (M16.7).** A relational finding is labeled **prose** (the prose is wrong —
  `compliance_fix` edits it), **storyboard** (the beat's own spec under-specifies or misstates the fact —
  route to the storyboard), **state** (the maintained `continuity/`/`knowledge/` entry is the authority the
  prose contradicts — route there, or surface as an M15 continuity conflict), **canon** (settled canon is
  contradicted — route to canon), or **missing-context** (the fact needed to judge is absent from every
  consulted source — surface as an open question). `compliance_fix` directs a non-prose defect to its
  authoritative artifact via the strengthened `ESCALATE` "Suggested upstream target"
  (`agents/steps/compliance-fix.md:71-80`), never a prose edit. `NOTES.md:108-111` is the precedent ("Label
  storyboard-defect vs prose-defect ... so the fix step is pointed at the storyboard, not the prose").
- **Scene-blind sharding is forbidden for relational checks; parallelism is preserved where it is safe.**
  Splitting one chapter's continuity/recap/timeline check into scene-blind shards makes every cross-scene
  contradiction structurally invisible (`NOTES.md:42-46`,`:95-97`). Relational checks evaluate the chapter as
  a whole (against maintained state + targeted retrieval); the local Must-Contain checks may still be
  block-scoped. Parallelism is acceptable *across* independent facts or *across* chapters, never by splitting
  one chapter's continuity into scene-blind shards.
- **The review-artifact change is additive; the validator is touched only if forced.** The cited referent
  rides inside the existing `^- ` violation line; the defect-type is a label on that line; `## Context
  consulted` is a report-level section (neither a `### Block ` container nor a `^- ` item). So
  `agents/review-grammars.yaml` and `scripts/validate-review-artifact.sh` need no change — verified by running
  the validator over the updated `examples/review/reviewer-actions.md` fixture. M16 *may* change them (unlike
  M15), but only if that run shows a structural conflict, and then minimally with recorded rationale.
- **No new pipeline step; no recipe change.** M16 retrofits existing, already-listed steps. The recipe lists,
  both `check-pipeline-state.sh` modes, and CI ordered-equality are untouched. The sprint's catalog additions
  are two support docs and one template.

---

## Tasks

Wave order: **Task 1** defines the model and the reveals-ledger artifact — every downstream file cites it —
and lands first. **Task 2** retrofits the two relational reviews and the fix-routing against Task 1's model
and ledger. **Task 3** demonstrates, smoke-tests, verifies, and closes out, last. The tasks are largely
sequential (Task 2 cites `agents/review-context.md` and consumes the `reveals.md` shape Task 1 defines; Task 3
depends on both), so run them in order rather than in parallel. Capture the Sprint-start SHA
(`git rev-parse HEAD`) before the first commit; the untouched-surface diffs anchor there, not `origin/main`
(`AGENTS.md:6`).

### Task 1 — The review-context model, the audit, and the reveals-ledger artifact

- [ ] Todo

**Goal.** Define the local/bounded-window/relational classification, the minimum-context strategy, the
referent-identification and retrieval rule, the precedence order, the defect taxonomy, and the project-scale
gradation once, authoritatively, in a new `agents/review-context.md`; record the audit of every review step;
and realize the story-level reveals ledger as a defined, human-readable artifact. Closes **M16.1**, **M16.2**,
**M16.4**, **M16.5**, **M16.7**, **M16.8** (definitional), and the artifact half of the reveal-timing work.

**Requirements.**

- Create `agents/review-context.md` (parallel to `agents/continuity.md`, `agents/canon.md`), stating once:
  - **The classification and minimum-context strategy (M16.1).** Local (block/scene-local surface or
    structural checks), bounded-window (whole-chapter prose-quality checks over spans), relational (prose vs.
    facts established elsewhere — continuity, character-knowledge, reveal-timing, chronology, recollection,
    quotation, summary, recap fidelity). For each class, the minimum valid context: local → the block/scene;
    bounded-window → the current chapter; relational → maintained state (`continuity/`, `knowledge/`,
    `reveals.md`) + targeted retrieval of named source evidence, tiered by check type (`NOTES.md:74-79`).
  - **The audit (M16.2)** as a table: each review step (`storyboard_review`, `compliance_report`, `prose_pass`,
    `metaphor_identify`, `anti_ai_report`) → its class → a one-line justification with a cite. Record
    `anti_ai_report`/`metaphor_identify` local, `prose_pass` bounded-window,
    `compliance_report` relational, `storyboard_review` mixed (reveal-setup relational; the other two checks
    bounded-window).
  - **Referent identification + targeted retrieval (M16.4):** how a relational review names the
    characters/events/facts/constraints/back-references the prose invokes (a recap/quotation/recollection names
    its referent; a continuity claim names its fact-class and subject), then obtains only the maintained-state
    entries and named source evidence needed — never a corpus scan.
  - **Precedence (M16.5):** the review tiebreak (storyboard intent > distilled state > raw source; supplements
    never overrides — `NOTES.md:82-87`) and the authoring-authority order (canon > continuity —
    `agents/continuity.md`), and how they relate.
  - **The defect taxonomy (M16.7):** prose / storyboard / state / canon / missing-context, each with the
    artifact that owns the fix, per Conventions.
  - **The project-scale/type gradation (M16.8):** short_story whole-work; book whole-chapter + prior state;
    series maintained-state + targeted retrieval, never full-corpus; new inputs `required: false` and
    project-type-aware.
  - **The finding contract:** relational findings stay per-block review units with a cited referent, and every
    relational report declares `## Context consulted` (M16.6). Reference `agents/review-grammars.yaml` for the
    unit/anchor scheme; do not restate token sets.
- Create `agents/reveals.md` (single source) defining the story-level reveals ledger per Definition-of-done
  item 3: a `role: planning`, human-authored, project-root `reveals.md` with `id` (`rv-NN`), reveal content,
  `lands:`, ordered `setup:` positions, and `concealed-until:` — reusing the M14/M15 `id`/`story-position`
  idiom (reference `agents/characters.md`'s temporal model; do not restate it). State once that it is distinct
  from the book-level freeform `continuity.md` risk notes (`agents/books.md:59-66`), has **no pipeline writer**,
  and is consumed read-only by `storyboard_review`.
- Create `templates/reveals.md` realizing the entry shape as legible Markdown (frontmatter `role: planning`,
  a short "forward reveal plan, not derived state" note, and structured `rv-NN` entries). Model tone/structure
  on `templates/continuity-book.md`.
- Add `reveals.md` to `agents/project-layouts.md` (all three trees, with resolution rules — story-level, one
  per work) and to `templates/project-AGENTS.md` (Project Paths + Where To Look, adding
  `agents/review-context.md`, `agents/reveals.md`, and `reveals.md`).
- Do not edit any step file, `pipeline-state.md`, the review grammar/validator, or `agents/workflows.md` in
  this task.

**Done when.** `agents/review-context.md` defines the classification, strategy, audit, retrieval, precedence,
defect taxonomy, scale gradation, and finding contract in one place; `agents/reveals.md` + `templates/reveals.md`
realize the ledger reusing the M14/M15 idiom with no writer and no parallel temporal model; `reveals.md`,
`agents/review-context.md`, and `agents/reveals.md` appear in the layouts and the adapter; no rule is restated
per file.

---

### Task 2 — Retrofit the two relational reviews and the fix routing

- [ ] Todo

**Goal.** Reframe `compliance_report` into the bounded relational review reading prose against `continuity/` +
`knowledge/` + canon with precedence, cited referents, declared context, and defect labels; teach
`storyboard_review`'s reveal-setup check to reason across chapters against `reveals.md`; route
`compliance_fix` remediation by defect type; keep the change additive to the review-artifact grammar. Closes
**M16.3**, **M16.6**, and the retrofit half of **M16.7**.

**Requirements.**

- **Retrofit `agents/steps/compliance-report.md`** per Definition-of-done item 4:
  - Remove the block-local blindness: reframe `:33`/`:115`/`:153` ("do not read any other files / do not
    consult source canon") to the `agents/review-context.md` retrieval strategy — `canon_active` first,
    escalate to *named* canon only when insufficient or the prose asserts a checkable fact it doesn't cover;
    consult `continuity/` and `knowledge/` for relational checks. Scope the "work block by block; do not
    collapse findings across blocks" rule (`:93`) to *local* checks; **forbid scene-blind sharding for
    relational checks** (evaluate the chapter as a whole against maintained state).
  - Add `required: false`, project-type-aware `preconditions`/`inputs`: `continuity/` (`kind: source`),
    `characters/<id>/knowledge/` (`kind: source`), named canon files (`kind: source`) — per the step-workflow
    contract (`agents/orchestrator.md:35-79`).
  - Add the relational checks against maintained state + targeted retrieval: canon consistency,
    `concealment_from_characters` vs. maintained knowledge state (character-knowledge / reveal-timing), and the
    continuity fact-classes (chronology, event-staging, location, possession, physical-condition, role,
    open-thread — covering recalled-event-staging and recap fidelity). Apply the precedence rule.
  - Emit each relational finding as a per-block review unit **citing its referent** in the violation line
    (`continuity/…#co-NN` / `knowledge/…#kn-NN` / canon file + quote) and **labeling its defect type**; keep
    the existing anchor/`review-id`/`Decision:` scheme (`agents/review-grammars.yaml` `compliance:` family) and
    the Must-Contain local checks. Add a report-level `## Context consulted` section naming the state entries /
    chapters / files read.
  - Leave `review_required: true`, the `reviewer-actions.md` output path, and the `Reviewed-draft:` freshness
    stamp unchanged.
- **Retrofit `agents/steps/storyboard-review.md`** per Definition-of-done item 5: replace the
  within-chapter-only scoping of the reveal-setup check (`:78`,`:115`) with a `required: false` `reveals.md`
  input and cross-chapter checking by **targeted lookup** of each reveal's `setup:` positions (never a full
  prior-storyboard rescan), confirming nothing before `concealed-until:` discloses it. Cite the ledger entry
  (`reveals.md#rv-NN`) and declare context consulted; label a under-specified ledger a **reveals-ledger
  defect**. Keep the takeaway-support and takeaway/concealment checks and the advisory/report-only nature
  unchanged.
- **Route `agents/steps/compliance-fix.md` by defect type** per Definition-of-done item 6: extend the
  `ESCALATE` handling (`:71-80`) so a state/storyboard/canon/missing-context defect is directed to its
  authoritative artifact (the strengthened "Suggested upstream target"), while a prose-defect `FIX` is applied
  as today. Leave the per-unit gate, freshness check, validator call, and surgical discipline unchanged.
- **Keep the grammar/validator change additive** per Definition-of-done item 7: update
  `examples/review/reviewer-actions.md` with a relational finding (cited referent + defect label) and a
  `## Context consulted` section, run `scripts/validate-review-artifact.sh` over it, and confirm exit 0 / the
  documented ledger. Change `agents/review-grammars.yaml` / `scripts/validate-review-artifact.sh` only if the
  run shows a structural conflict; record any change's rationale.
- **Update `agents/workflows.md`** per Definition-of-done item 8: point the "continuity review" workflow's
  automated realization at the retrofitted `compliance_report`, and add a "reveals ledger" note near the
  storyboard-review workflow. Preserve the book-level `continuity.md` risk-notes distinction.
- **Refresh the `AGENTS.md` catalogs** per Definition-of-done item 9: add the two support-doc lines; refresh
  the `compliance-report.md` / `storyboard-review.md` step descriptions. Add no step; change no recipe.

**Done when.** `compliance_report` reads prose against `continuity/` + `knowledge/` + named canon via targeted
retrieval with precedence, emits per-block relational findings citing referents and defect types, and declares
`## Context consulted`; `storyboard_review` checks cross-chapter reveal setup against `reveals.md` by targeted
lookup; `compliance_fix` routes non-prose defects to their authoritative artifact; the validator accepts the
updated fixture with at most additive grammar changes; `agents/workflows.md` and the `AGENTS.md` catalogs
reflect the retrofit; the three local/bounded-window reviews and the recipe/CI surfaces are untouched.

---

### Task 3 — Demonstration, smoke coverage, verification, and close-out

- [ ] Todo

**Goal.** Prove the bounded relational review against the `NOTES.md` failure set end-to-end, give it a
runnable smoke recipe, run the verification sweep, and close the milestone. Closes **M16.9** and the residual
of **M16**.

**Requirements.**

- Commit the worked demonstration under `examples/relational-review/` per Definition-of-done item 10, clearly
  marked as an example (mirror `examples/continuity/README.md`'s header): a `book`-project fixture with
  maintained `continuity/` + `characters/<id>/knowledge/` state, a `reveals.md` ledger, storyboards, and an
  accepted draft, exercising **cross-scene chronology**, **character knowledge**, **reveal timing**, **recalled
  event staging**, and **recap fidelity** (the `NOTES.md:24-46` set). The README shows, per failure, the
  per-block review unit with its **cited referent** and **defect-type label**, the report-level `## Context
  consulted` record, and — for at least one non-prose defect — the `compliance_fix` routing; and it states the
  bounding cost (facts + back-references consulted, not the corpus).
- Add the smoke recipe(s) to `examples/smoke/README.md` per Definition-of-done item 11, modeled on the
  existing hand-authored-input recipes (Recipe 22's shape): hand-author `continuity/`, a `knowledge/` file,
  storyboards, and an accepted draft; run the retrofitted `compliance_report`; confirm a relational finding
  with a cited referent + `## Context consulted` section, and that `validate-review-artifact.sh` accepts the
  report. Update the recipe enumeration, the layout/untracked notes, and the reset procedure for the new
  recipe number and paths; confirm the reset removes them. Existing recipes (1–22) stay byte-for-byte
  untouched.
- Run the full verification sweep per Definition-of-done item 12: both `check-pipeline-state.sh` modes; the
  two step lists ordered-equal; the untouched-surface `git diff --stat` against the captured Sprint-start SHA
  (no changes to the three local/bounded-window review steps, the recipe lists, either CI workflow yml,
  `install.sh`, or the dispatcher files; the grammar/validator unchanged or additive-only per item 7); and the
  greps (item 12).
- Cross-file consistency read: `agents/review-context.md`, `agents/reveals.md`, `templates/reveals.md`, the two
  retrofitted steps, `compliance_fix`, `agents/workflows.md`, the layouts, and the adapter agree on the
  classification, the precedence order, the referent-citation and `## Context consulted` forms, the defect
  taxonomy, the reveals-ledger `rv-NN`/`lands`/`setup`/`concealed-until` shape, and the tiered scope — no
  drift, no restated model or grammar; the demonstration and smoke fixtures match the template shapes and the
  `compliance:` family grammar.
- Update `ROADMAP.md`: check M16.1–M16.9 only after Tasks 1–2 pass verification; **remove** the "story-level
  reveals ledger with buildup" and "continuity review step" Deferred items (realized here); add any
  newly-surfaced follow-up to the Deferred list. Check this SPRINT.md's per-task boxes (Tasks 1–3) only after
  their acceptance conditions hold.

**Done when.** The demonstration catches all five `NOTES.md` failure types as per-block relational findings
with cited referents, defect labels, and a `## Context consulted` record, and shows one non-prose defect
routed to its authoritative artifact; the smoke recipe runs and the reset covers it; all script runs, the
ordered-equality check, the untouched-surface diff, and the greps return the expected results; ROADMAP
M16.1–M16.9, the removed Deferred items, and the SPRINT task boxes reflect completed work.

---

## Out of scope for this Sprint

- **A new review family / the validator machinery beyond additive.** No `continuity_report`/`continuity_fix`
  or other fifth family; `agents/review-grammars.yaml`, `scripts/validate-review-artifact.sh`,
  `agents/review-validation.md`, and the `amanuensis-review` companion are unchanged except at most additively
  (item 7). Relational findings ride the existing `compliance:` review units. The owner's retrofit decision is
  the reason.
- **The three local / bounded-window reviews.** `anti_ai_report`, `metaphor_identify`, and `prose_pass` (and
  their fix/apply steps) are byte-for-byte unchanged — the audit records them local / bounded-window, needing
  no relational context. Touching them is out of scope.
- **A derived writer for the reveals ledger.** `reveals.md` is human-authored planning with no pipeline
  writer this Sprint (pre-draft, forward-intent, near-circular to derive). A derived `reveals_update` step is
  a deferred follow-on (added to ROADMAP Deferred).
- **A `storyboard_review_fix` apply step.** `storyboard_review` stays advisory / report-only; the human revises
  storyboards by hand. The paired fix step remains the Deferred item it is today.
- **Cross-book `truth:` reference resolution and the knowledge-step write path.** M16's bounded review *reads*
  across books via maintained state + targeted retrieval, but resolving `scene_knowledge_update`'s cross-book
  `truth: continuity/book-M.md#co-NN` write remains the Deferred series-only refinement (`ROADMAP.md` Deferred);
  this Sprint changes no knowledge-step write behavior.
- **The book-level freeform `continuity.md` and the derived `continuity/`/`knowledge/` writers.** `continuity.md`
  risk notes (`agents/books.md:59-66`) stay freeform, book-level, distinct from `reveals.md`; the M15
  `continuity_update` and M14 `scene_knowledge_update` writers are unchanged (M16 is their *reader*, not their
  writer).
- **Dispatcher-level scope/context enforcement.** The retrieval and precedence live in the step bodies and
  `agents/review-context.md`; lifting any of it into the dispatcher is a deferred follow-on, exactly as
  dispatcher-level artifact staleness is (`agents/orchestrator.md:187`).
- **"Which chapter is current" for book/series.** The orchestrator TODO (`agents/orchestrator.md:146-148`) is
  unchanged; the demonstration is hand-authored, as `examples/character-state/` and `examples/continuity/` are.
- **`install.sh`, the CI workflow ymls, the recipe lists, and the dispatcher command/agent files.** Unchanged —
  M16 adds no step and no recipe line, and nothing here enumerates the retrofitted steps' behavior.
