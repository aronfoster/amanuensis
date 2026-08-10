---
step_id: continuity_update
review_required: false
inputs:
  - <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
  - <chapter-folder>/storyboards/*-storyboard.md
  - continuity/book-N.md
  - continuity/story.md
  - canon/**
outputs:
  - continuity/book-N.md
  - continuity/story.md
  - open-questions.md   # conditional: surfaced conflicts (a success-path write) and blocked-target open questions
  - pipeline-state.md
preconditions:
  - path: <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
    kind: prose_draft
    required: true
    review_sensitive: false
  - path: <chapter-folder>/storyboards/*-storyboard.md
    kind: source
    required: true
    review_sensitive: false
  - path: continuity/book-N.md
    kind: source
    required: false
    review_sensitive: false
  - path: canon/
    kind: source
    required: false
    review_sensitive: false
---

See `agents/orchestrator.md` for the step workflow contract.

# Continuity Update

## Purpose

Reconcile the **objective story continuity** the accepted chapter prose committed into the project's `continuity/` file. This step is the **sole writer of `continuity/`**: it reads the accepted prose, confirms each candidate objective fact against it, keeps only the load-bearing set, and reconciles that set non-destructively into the project-type target with a retrievable `evidence:` stamp on every entry. It writes `continuity/` and nothing else; `canon/`, `characters/`, `knowledge/`, and the drafts are other writers' — never this step's.

It runs at the **end** of the recipe, after `anti_ai_fix` and immediately **before** `scene_knowledge_update`, so it reads the *accepted* (final) chapter prose and records the objective facts first — then `scene_knowledge_update` can resolve a character's `truth:` reference to an already-recorded `co-NN` (`agents/steps/scene-knowledge-update.md`). Its writes are capture-style — legible, evidence-stamped, marked `unreviewed`, and non-destructive — but carry **no human gate** (`review_required: false`): applying a confirmed objective fact is mechanical enough that no approval blocks the pipeline. "Reviewable" here means the writes are legible, traceable, non-destructive, and any **conflict** is surfaced rather than silently resolved — a human *can* audit any `unreviewed` entry, reconstruct any earlier state, and resolve any surfaced conflict — **not** that each write is an anchored `- Decision:` review unit gated on approval (agent-addressable continuity review is M16).

The objective-continuity model these writes realize — the boundary (`continuity/` is the sole authority for maintained objective facts and never restates or overrides `canon/`), the granularity policy and the seven maintained fact-classes, the `evidence:` field, the diegetic-vs-authorial change distinction, and derived freshness — is defined once in `agents/continuity.md`. This step follows that model and does not restate it; the temporal idiom it reuses (`id`, `story-position`, `committed-in`, the non-destruction transition discipline) is defined in `agents/characters.md` (**## Temporal character-state model**). The field shapes are in `templates/continuity-book.md`.

## Inputs

- `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` — the accepted chapter prose, the source of record for what actually happened. Resolved at step start via the attempt manifest's `Active-head:` pointer per `agents/project-layouts.md`, not by highest-numbered draft. This step reads a draft but does not mint one.
- `<chapter-folder>/storyboards/*-storyboard.md` — the chapter's storyboard blocks. Their `## Canon active`, `## Must Preserve`, and staging direction (`agents/storyboard-schema.md`) name the canon mechanics, canon-mandated content, and staged events the prose was built to enact — the places maintained objective facts concentrate. They tell the step *what to check* against the prose; the prose, not the storyboard, is what is recorded.
- `continuity/book-N.md` (`book` / `series`) or `continuity/story.md` (`short_story`) — the continuity file this step reconciles into. Read to locate the reconcile target, respect its `edit_policy`, and match already-recorded entries by `id`. Not required to pre-exist: the step creates the project-type target if it is absent. The precondition names `continuity/book-N.md`; for `short_story` it resolves to `continuity/story.md`.
- `canon/` — relevant canon files, read for **conflict context** only: to tell whether a prose fact contradicts settled canon (which is surfaced as a conflict, never absorbed — canon outranks continuity, `agents/continuity.md`). `required: false`; the step never writes `canon/`.

## Behavior

Run in this order:

1. **Gather candidate objective facts from the accepted prose.** Read the accepted `<latest-draft>` (resolved via the manifest's active head) and collect the candidate objective facts it commits. Use the scene storyboards' `## Canon active`, `## Must Preserve`, and staging direction to know what to check — they name the canon mechanics operating in each beat, the canon-mandated content, and the staged events the prose was built to enact, which is where maintained objective facts concentrate.

2. **Confirm each candidate against the drafted prose.** Check that the prose actually committed the fact. The **drafted prose is what happened**; the storyboard is a forecast that drafting may have revised. If the prose committed something different from the storyboard, take **what the prose committed**; a fact the prose did **not** commit is not written at all. This mirrors `compliance_report`'s and `scene_knowledge_update`'s confirm-against-prose.

3. **Keep only the load-bearing set.** Apply `agents/continuity.md`'s granularity policy: maintain a fact **iff it is both relational** (its correctness depends on comparison across scenes — a later scene can agree or disagree with it) **and capable of a reader-visible contradiction** (getting it wrong later would be a mistake a reader could catch). Only the seven maintained fact-classes qualify — chronology / time anchors, event staging, location, possession, physical condition, role / assignment, open causal threads. A single-scene throwaway detail (relational to nothing, contradictable by nothing) stays in the prose and is not lifted here.

4. **Reconcile the confirmed load-bearing facts into the project-type target.** The target is `continuity/book-N.md` for `book` and `series` projects and `continuity/story.md` for `short_story` projects (create it if absent). Before writing, read the target's frontmatter `edit_policy` (Rule 7, `agents/update-rules.md:62-108`): a `locked` or `propose_only` target is **not** written — record an open question describing the fact, the target, and the routing decision, exactly as capture does for a blocked target. For a writable target:

   - A **new** fact appends a stamped entry to the right fact-class section, carrying `id` (the next unused `co-NN` for the file, minted once), `story-position` (canonical folder-style `<book-id>/<chapter-id>/<scene-id>`, reduced to `<scene-id>` for `short_story`), `committed-in: <latest-draft>`, `evidence:` (the **full attempt-qualified draft path** `<chapter-folder>/drafts/<attemptNN>/draft-vNN.md#<scene>`, plus the storyboard block and/or canon file where they apply — never a bare `draft-vNN.md` basename), the fact-class value field(s), and the marker `- **review:** unreviewed`.
   - A **changed** fact — a **diegetic** change to genuinely mutable, single-valued state, where the story advances and the fact changes *in the fiction* (a new holder takes the object; a new officer takes the post; a party moves to a new location) — appends a `## Superseded` transition that cites the **prior entry's** `id`, with `held` (from/to story positions), `committed-in`, `superseded-by` (the new entry's `id`), and `what changed`, **and** appends the new value as its **own** new stamped, `evidence:`-bearing entry in the appropriate fact-class section, naming the entry it supersedes. The superseded entry is **never** overwritten or deleted; it moves into `## Superseded`, keeping its `id`. This is the non-destruction invariant (`agents/continuity.md`, `agents/characters.md` **## Temporal character-state model**) and it is a hard rule of this step. (An **authorial** change — a human `revise` fixing what the fiction says — is *not* this step's: it is an in-place correction owned by `revise`, `agents/revision.md`.)

   **Additive facts are not superseded.** Not every advancing fact is a change to a single mutable value. A **chronology / time anchor** is additive — "Day 1 at scene01" and "Day 12 at scene10" are *both* permanently true, each at its own position — so an advancing anchor is recorded as a **new** entry (above), never a `## Superseded` transition over the earlier one; **event staging** is the same (each named event's staging is its own fact). A later scene naming an *earlier* time than a still-current anchor is not an advance but a **conflict** (below). Only single-valued mutable state — location, possession, physical condition, role/assignment — is superseded when it changes (`agents/continuity.md`, Chronology / time anchors).
   - A **conflict** — the prose contradicts a **still-current** maintained fact in a way that is **not** an intended change (a day count that regresses; a role or possession that collides with an unretired entry; a fact that contradicts settled canon) — is **surfaced to `open-questions.md`** naming **both sides**: the prior entry's `id` + value + `evidence`, and the prose position + a quote. The prior entry is left **in place**, and the conflicting value is **not** written as a fact. Conflict-surfacing is **non-blocking** (like capture): the step continues with the other facts and completes; the human resolves the conflict out-of-band. This is the concrete meaning of "surfaces conflicts rather than silently choosing a version." (An *intended* diegetic advance is not a conflict — it is the transition above.)

5. **Boundary.** The step writes `continuity/` **only** — never `canon/`, `characters/`, `knowledge/`, or the drafts. It respects each target's `edit_policy` (a `locked` / `propose_only` target → open question, no write, per step 4). It mints **no** draft and does **not** touch the attempt manifest's `Active-head:` (it is not a prose-advancing step; the lineage/supersession algorithm in `agents/project-layouts.md` does not run).

6. **Completion.** The step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.

## Freshness

Freshness of a continuity entry is a **derived predicate**, never a stored field and never swept — the M14 freshness rule (`agents/characters.md`, "Freshness is derived, never stored") applied to `continuity/`. A continuity entry is:

- **derived-stale** iff its `committed-in` draft is **outside the active head's lineage**; and
- **derived-unsupported** iff its `evidence:` pointer **no longer resolves in the active prose**.

Both are resolved against the manifest and prose identified by the entry's **full evidence path** — the specific `<chapter-folder>/drafts/<attemptNN>/draft-vNN.md` the `evidence:` field names, unambiguous across chapters *and* attempts. One `continuity/book-N.md` aggregates entries from every chapter and attempt of the book, whose `draft-vNN.md` basenames repeat; a bare basename names no single file and would **false-fresh on a collision** (the one failure a maintained-state artifact must never make). Both predicates are O(1) from facts already on disk (the entry's evidence path and that draft's manifest), written as no field, and maintained by no sweep over the continuity tree. This mirrors `agents/steps/scene-knowledge-update.md`'s Freshness section and the `Reviewed-draft:` predicate for prose-derived side artifacts (`agents/orchestrator.md`, **## Artifact state**).

**Prose axis only.** The draft is the one evidence source with a version model, so it is the one that defines derived freshness. A change to a **non-prose evidence source (storyboard, canon) or an earlier continuity entry** does **not** flip a derived bit — it is handled by **rerun-reconcile** (re-running `continuity_update` re-confirms each fact against the current prose and canon and surfaces any new contradiction as a conflict) and by M16 review, **not** by a stored dependency graph (which would be the O(artifacts) sweep the architecture rejects). Proactive / dispatcher-level detection of any of these is a deferred follow-on, exactly as dispatcher-level artifact staleness is (`agents/orchestrator.md`).

The full rule lives in `agents/continuity.md` (**## Freshness**); this step computes the predicate but does not restate the model. Correction of a stale or unsupported entry is the rerun-reconcile below.

## Idempotency / rerun

Re-running this step against the **current active head** appends only genuinely new facts, corrections, and newly-detected conflicts, and duplicates nothing. Before appending, match each confirmed fact against the file's existing entries by `id` and by `(story-position + fact)`: a fact already recorded against the current active head is **not** re-appended; a fact that has changed diegetically is recorded once as a `## Superseded` transition plus a new stamped entry, not re-appended on every run; and a still-standing conflict is re-surfaced but not duplicated. A rerun therefore **converges** — it never accumulates duplicate entries, duplicate transitions, or duplicate conflicts for the same committed fact. **Rebuild is this rerun-reconcile**: re-running against the current active head reconciles what the accepted prose committed, appends corrections as transitions, and re-surfaces conflicts — never silently rewriting an accumulated entry.

This is the append-only, non-destructive discipline `scene_knowledge_update` follows, not `character_extraction`'s overwrite-on-rerun: prior state always survives, and a rerun never overwrites or deletes an accumulated entry.

## Outputs

- `continuity/book-N.md` (`book` / `series`) or `continuity/story.md` (`short_story`) — the reconciled continuity file, created if absent. Confirmed new load-bearing facts appended as stamped, `evidence:`-bearing entries (`id`, `story-position`, `committed-in: <latest-draft>`, `evidence`, the fact-class value field(s), `- **review:** unreviewed`) in the appropriate fact-class section; confirmed diegetic changes appended as `## Superseded` transitions plus their new stamped entries. Pre-existing entries are never modified or removed. `canon/`, `characters/`, `knowledge/`, and the drafts are never written.
- `open-questions.md` (conditional) — a surfaced conflict (both sides named) or a blocked-target open question is appended here. A surfaced conflict is **non-blocking** and does not stop completion; a blocked target (missing/ambiguous inputs, or a `locked` / `propose_only` continuity target) stops completion (see Open questions handling).
- `pipeline-state.md` — this step's own line set to `[x]` and `last_updated` refreshed, as the completion action. No draft is minted; the manifest's `Active-head:` is untouched.

## Anti-Patterns

**Writing anything but `continuity/`.** This step is the sole writer of `continuity/` and writes *only* `continuity/`. `canon/`, `characters/`, `knowledge/`, and the drafts belong to other writers — touching them here is a boundary violation. It especially never restates or overrides `canon/`: a prose-vs-canon contradiction is surfaced as a conflict, not absorbed.

**Overwriting or deleting an accumulated entry.** A diegetic change is always a `## Superseded` transition plus a new stamped entry, never an in-place rewrite. Overwriting or deleting a prior entry destroys point-in-time reconstruction and breaks the non-destruction invariant. (In-place correction is `revise`'s authorial-change path, not this step's.)

**Recording an unconfirmed fact.** The storyboard is a forecast. If the drafted prose committed something different, take what the prose committed; if the prose committed nothing, do not record the fact at all. Recording a fact the prose did not enact writes an objective fact the fiction never established.

**Silently resolving a conflict.** A prose fact that contradicts a still-current maintained fact (and is not an intended diegetic advance) is surfaced to `open-questions.md` with both sides named and the prior entry left intact — never overwritten with the new value, never silently chosen. Silently choosing a version is exactly the failure this step is built to avoid.

**Lifting a throwaway detail.** Only the load-bearing set (relational **and** reader-visible-contradiction-capable; the seven classes) is maintained. Lifting a single-scene detail that is referenced nowhere else is noise.

**Using a bare `draft-vNN.md` basename in `evidence:`.** The pointer is the full attempt-qualified path `<chapter-folder>/drafts/<attemptNN>/draft-vNN.md#<scene>`. A bare basename repeats across chapters and attempts and would false-fresh on a collision.

**Re-appending an already-recorded fact.** A rerun matches existing entries by `id` / `(story-position + fact)` and appends only genuinely new facts, corrections, and conflicts. Re-appending a fact already recorded against the current active head inflates the file with duplicates.

**Writing into a locked or propose-only target.** A `locked` / `propose_only` continuity target is not written; record an open question instead (Rule 7). No silent write into an edit-policy-protected target, ever.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs — no resolvable `<latest-draft>`, no storyboard files, or a reconcile target whose `edit_policy` is `locked` / `propose_only` — append the blocker (or the recorded open question for the blocked target) to the project-root `open-questions.md` and exit **without** recording completion in `pipeline-state.md`. Do not fabricate facts the prose did not commit and do not write into a protected target. The next dispatcher invocation re-runs this step after the human resolves the blocker.

A **conflict** surfaced in step 4 is different: it is appended to `open-questions.md` **non-blockingly** — the step continues with the remaining facts and records completion normally. Surfacing a conflict does not stop the step; only a missing/ambiguous input or a blocked target does. On a successful run, the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
