# Sprint 19 — Milestone 14: Temporal character state

This Sprint gives Amanuensis a **temporal model of character-relative state** — what a
character knew, suspected, believed incorrectly, remembered, and was prohibited from
knowing at any story position — and stops the one place the pipeline silently loses that
history: character knowledge. Today the `knowledge/` templates already carry most of the
right *shape* (current state, historical transitions, prospective reveal constraints) but
lack durable identity, draft provenance, and a canonical story-position reference, and —
more sharply — **nothing in the running pipeline ever fills them.** `character_extraction`
scaffolds empty `knowledge/book-N.md` files (`agents/steps/character-extraction.md:54`,
`:88`) that "the deferred scene-knowledge-update step" is supposed to populate, but that
step does not exist: the scene-knowledge-update is a documented workflow
(`agents/workflows.md:62-68`), not an orchestrator step, and the scaffolds stay empty.

The milestone does three things. It **defines the temporal character-state model** across
`knowledge/`, `timeline.md`, and `relationships.md` — ordering and attribution by a single
canonical story-position reference, a durable per-entry id, a draft-provenance stamp, an
explicit current / historical-transition / prospective-constraint distinction, and a hard
**non-destruction invariant** (a later update never erases the ability to reconstruct an
earlier state) — and keeps it all human-readable Markdown, adding **no** parallel
authoritative state system. It **builds and wires a running `scene_knowledge_update`
step** — the sole writer of `knowledge/` — that reads the scene's storyboard knowledge
deltas, confirms them against the accepted draft, and **reconciles** them into the
knowledge files: appending new entries and recording corrections as transitions, never
overwriting accumulated knowledge. And it **demonstrates** point-in-time reconstruction
for a character whose knowledge changes more than once (suspicion → incorrect belief →
correction, under an active reveal constraint), plus a runnable smoke recipe.

Two owner decisions from planning shape the step (both starred in Conventions). The step is
**capture-style but not human-gated**: it writes knowledge directly, `review_required:
false`, the way the capture subsystem writes provenance-stamped inventions
(`agents/capture/capture-agent.md`) — "reviewable" here means *legible, provenance-stamped,
and non-destructive* (a human **can** audit it and reconstruct history), **not** that a
human must approve each write before the pipeline proceeds. And the reviewable-change format
is deliberately kept **off** the review-grammar / validator machinery
(`agents/review-grammars.yaml`, `scripts/validate-review-artifact.sh`): agent-addressable,
countable review of character-state changes is M16's job (Bounded relational review), not
M14's. This Sprint touches none of the four review families, the validator, or the review
companion.

## Background — what is and isn't wrong today

Established by inspection during planning, with file:line cites; tasks should not re-derive
this.

- **The knowledge template already has the right three-way shape, but no identity or
  provenance.** `templates/knowledge-book.md` sections are `## Knows` / `## Suspects` /
  `## Believes incorrectly` (current state, `:9-42`), `## Must not know yet` (prospective
  reveal constraints, `:46-51`), and `## Lost or superseded` (historical transitions,
  `:54-62`). So M14.3's current / historical / prospective distinction is *substantially
  present already*. What is missing: a **durable per-entry id** (entries are keyed only by a
  human `### [Short label]` heading, which is not stable under rewording), a **draft
  provenance stamp** (entries cite a scene via `learned:`/`basis:` but never the draft that
  committed the fact), a **basis type** to represent "remembered" vs "was told" (the
  done-when names "remembered" as a first-class axis; the template has no way to say a fact
  is held by direct experience of a prior scene), and a canonical story-position format
  (below).
- **The story-position reference is inconsistent across the repo.** The knowledge template
  uses `learned: [xx-yy]`, documented as "book-chapter, scene number"
  (`templates/knowledge-book.md:4`, `:15`, `:27`, `:39`, `:60`) — the numeric-prefix style
  (`01-01`) that `agents/project-layouts.md:11` **explicitly deprecated** in favor of folder
  structure. The scene-knowledge-delta already uses the folder-style form
  `[from <book-id>/<chapter-id>/<scene-id>]` (`agents/workflows.md:42-46`). Storyboards key
  scenes by `scene_ref` path (`agents/storyboard-schema.md:38`). Three formats, no single
  canonical one; the temporal model needs exactly one.
- **`timeline.md` and `relationships.md` are freeform and have no template.** `agents/characters.md:29-45`
  describes them as a "chronological record" and "relationship dynamics" in prose bullets;
  `templates/` ships `profile.md` and `knowledge-book.md` only — no `timeline.md`, no
  `relationships.md`. M14.1 requires the temporal model to span all three files; two of the
  three have no structured home for it yet.
- **The scene-knowledge-update is a documented workflow, not a step — so the scaffolds are
  never filled.** `agents/workflows.md:62-68` ("Workflow: scene knowledge update") describes
  reading the storyboard deltas and applying them to `characters/<name>/knowledge/book_n.md`,
  but there is **no** `scene_knowledge_update` in `templates/pipeline-state.md:16-30` and no
  file under `agents/steps/`. `character_extraction` creates `knowledge/book-N.md` as "empty
  scaffolds ... Filled later by the scene knowledge update workflow"
  (`agents/steps/character-extraction.md:54`, `:88`), and `agents/characters.md:61` states
  knowledge items are written "only ... during the **scene knowledge update** workflow" —
  which nothing runs. The capture docs name it "**the deferred scene-knowledge-update
  step**" (`agents/capture/capture-agent.md:46`, `:84`; `agents/capture/README.md:31`). Net:
  in the live pipeline, character knowledge acquired during the story has no writer.
- **`knowledge/` is reserved for this step; capture must never write it.** The capture
  subsystem writes character `timeline.md` events and `profile.md` identity and
  `canon/generated/` world facts, and is **hard-barred from `knowledge/`**
  (`agents/capture/capture-agent.md:46`, `:84`, `:102`; `agents/capture/README.md:31`) —
  precisely because knowledge is reveal-timing-load-bearing and belongs to the
  scene-knowledge-update step. This Sprint fills that reserved slot; it does not widen
  capture.
- **short_story has no per-book knowledge file today.** `character_extraction` creates only
  `knowledge/baseline.md` for `short_story` and no `book-N.md`
  (`agents/steps/character-extraction.md:80`; layout `agents/project-layouts.md:100-138`).
  So for a short story, story-acquired knowledge currently has *nowhere structured to land*.
  The new step needs a project-type-aware target that includes `short_story`.
- **Two strong precedents already exist for provenance and freshness — reuse them, don't
  reinvent.** (1) Capture stamps every write with source **scene + beat + attempt** and an
  **`invented, unreviewed`** marker so a human can find and confirm it
  (`agents/capture/capture-agent.md:54-59`). (2) The Artifact-state contract models a
  prose-derived side artifact's freshness as a **derived predicate**: a `Reviewed-draft:
  draft-vNN.md` stamp is `fresh` iff it equals the active head, `stale` otherwise, computed
  O(1) from two facts on disk, never stored or swept (`agents/orchestrator.md:150-181`).
  NOTES.md's open questions for this milestone explicitly ask to keep character state "the
  same freshness class as the `Reviewed-draft:` stamps" (`NOTES.md:119-123`). M14.2 and
  M14.6 are these two precedents applied to character knowledge.
- **Durable review-ids exist, but only in the review-artifact system.** The `<!-- review-id:
  ... -->` anchor convention lives in `agents/review-grammars.yaml` and the four report/fix
  step families; it is **not** used in character files. M14.2's durable id is therefore a
  new, character-local identity scheme, not an extension of review-ids (which this Sprint
  leaves untouched — see Out of scope).
- **Adding a step has three hard consistency surfaces.** (a) `scripts/check-pipeline-state.sh`
  runs in resolvable mode (every listed step resolves to a file) and `--exhaustive` mode
  (every step file appears in the list). (b) The repo CI enforces **ordered-equality** of the
  step lists in `templates/pipeline-state.md` and `examples/smoke/pipeline-state.md` — the new
  line must sit at the **same position** in both (`.github/workflows/pipeline-state-check.yml:24-34`).
  (c) `AGENTS.md:63-77` catalogs every step file and needs a new catalog line. `install.sh`
  does **not** enumerate steps and stays unchanged; neither CI workflow yml lists step names,
  so they pass automatically once the two lists and the step file agree.
- **Downstream consumers read knowledge as inputs and must keep working.** `scene_generation`
  reads `knowledge/baseline.md` (`agents/steps/scene-generation.md:7`, `:43`) and
  `storyboarding` reads `knowledge/*.md` (`agents/steps/storyboarding.md:8`, `:48`), both to
  plan reveals/concealments against current knowledge. The temporal model is **additive** —
  it adds ids, a provenance stamp, a story-position field, and transitions, and keeps the
  current-state sections (`## Knows` etc.) legible exactly as before — so these consumers
  need no change this Sprint (they read current state as they do today).

## Definition of done

The Sprint is complete when:

1. ROADMAP.md tasks M14.1–M14.7 are checked; M15–M17 are untouched. The M14 section body,
   done-when, and Notes carry the Sprint-19 planning addendum (the locked decisions below),
   and nothing outside M14 changes.
2. **The temporal character-state model is defined and single-sourced in
   `agents/characters.md`**, spanning `knowledge/`, `timeline.md`, and `relationships.md`,
   and covering: the canonical story-position reference; the durable per-entry id; the
   draft-provenance stamp; the current / historical-transition / prospective-constraint
   distinction; the basis type (including "remembered"); and the non-destruction invariant.
   It states once, authoritatively, that the character Markdown files remain the sole
   authority for character-relative state — **no** parallel index, database, or derived
   state file is introduced.
3. **`templates/knowledge-book.md` is evolved** to the model: each entry carries a durable
   `id`, a `story-position` in the canonical format (replacing the deprecated `xx-yy`
   `learned:`/`basis:` scheme, which is removed), a `committed-in: draft-vNN.md` provenance
   stamp, and a `basis` field (`witnessed` | `told` | `inferred`) that lets "remembered" be
   represented; the `## Lost or superseded` transition entry gains the same id/provenance so
   a correction cites the entry it supersedes; the human `### [Short label]` heading stays as
   a readable label. The file stays valid human-readable Markdown.
4. **`templates/timeline.md` and `templates/relationships.md` are created**, each applying the
   temporal model at the altitude that fits it: ordered, story-position-attributed,
   id-bearing entries; relationship *dynamics* carry the current / superseded distinction
   (a fractured loyalty supersedes a prior one, non-destructively); timeline events are the
   inherently-chronological record. Both are human-readable Markdown and declare that they
   are not a parallel authority — they describe character-relative truth, deferring objective
   facts to canon/continuity (the M15 boundary).
5. **A new step `agents/steps/scene-knowledge-update.md` exists and is wired.** It is the sole
   writer of `knowledge/`; it reads the scene's storyboard knowledge deltas plus the accepted
   `<latest-draft>`, confirms each delta against the drafted prose, and **reconciles** it into
   the project-type-appropriate knowledge file: a new fact appends a stamped entry; a changed
   fact appends a `## Lost or superseded` transition and records the corrected state — it
   **never** overwrites or deletes an accumulated entry. It writes directly with
   `review_required: false` (no human gate) and stamps every write with story-position +
   `committed-in` draft + an `unreviewed` marker (capture's provenance idiom,
   `agents/capture/capture-agent.md:54-59`). It touches **only** `knowledge/`; `timeline.md`
   and `relationships.md` get the model/templates but no automated writer this Sprint.
6. **The step is added to both recipes at the same position** — appended after `anti_ai_fix`
   in `templates/pipeline-state.md` and `examples/smoke/pipeline-state.md` — so both
   `check-pipeline-state.sh` modes pass and the CI ordered-equality check passes. `AGENTS.md`'s
   step catalog (`:63-77`) gains a `scene-knowledge-update.md` line.
7. **Freshness and correction behavior is defined** (M14.6): a knowledge entry's `committed-in`
   stamp makes it a **derived-stale** predicate — an entry committed from a draft no longer in
   the active head's lineage is stale, computed O(1) from the entry stamp and the manifest,
   mirroring the `Reviewed-draft:` contract (`agents/orchestrator.md:150-181`) rather than
   storing a field or sweeping. The correction behavior is the step's rerun-reconcile:
   re-running `scene_knowledge_update` against the current active head appends corrections as
   transitions and never silently rewrites; the step's idempotency section states this
   explicitly (contrast `character_extraction`'s overwrite-on-rerun,
   `agents/steps/character-extraction.md:74-76`). Where this rule needs a home beyond the step,
   it lives in `agents/characters.md` and references the orchestrator contract; the
   orchestrator's Artifact-state section is left byte-for-byte or gains at most a one-line
   cross-reference.
8. **The `deferred` framing is retired everywhere it appears.** `agents/characters.md:61`,
   `agents/steps/character-extraction.md:54`/`:88`/`:80`, `agents/capture/capture-agent.md:46`/`:84`,
   and `agents/capture/README.md:31` are updated to name the real `scene_knowledge_update`
   step instead of "the deferred scene-knowledge-update step/workflow"; the capture hard-line
   ("never `knowledge/`") is preserved, now pointing at a step that exists.
9. **The scene-knowledge-update workflow entry is updated** (`agents/workflows.md:62-68`) to
   reference the automated step and its reconciling, non-destructive, provenance-stamped
   behavior, keeping the folder-style delta format it already uses (`:42-46`) aligned with the
   canonical story-position reference.
10. **A worked demonstration is committed** under `examples/character-state/` (a clearly-marked
    example, per the `AGENTS.md` repository-boundary rule): an example character folder whose
    knowledge changes more than once — a suspicion that becomes an incorrect belief that is
    later corrected — under an active `## Must not know yet` reveal constraint, plus a README
    that reconstructs the character's state at two different story positions from the
    ids/stamps/transitions alone, showing the earlier state survives the later correction.
11. **Smoke coverage exists** for the step in `examples/smoke/README.md`: at least one recipe
    that hand-authors a character `knowledge/` file, a scene storyboard carrying a knowledge
    delta, and an accepted draft, runs `scene_knowledge_update`, and confirms a
    provenance-stamped non-destructive append; and a second run against a corrected fact that
    confirms a transition is appended rather than the prior entry overwritten. The recipe
    enumeration, layout/untracked notes, and reset procedure are updated for the new recipe(s)
    and any new untracked paths; existing recipes are byte-for-byte untouched.
12. **Verification passes.** `sh scripts/check-pipeline-state.sh --exhaustive
    templates/pipeline-state.md agents/steps` and `sh scripts/check-pipeline-state.sh
    examples/smoke/pipeline-state.md agents/steps` both succeed; the two step lists are
    ordered-equal; `git diff --stat` against the Sprint start SHA (`eb11589`, captured before
    the first commit) shows **no** changes to `scripts/validate-review-artifact.sh`,
    `agents/review-grammars.yaml`, `agents/review-validation.md`, any of the four review-family
    step files, the review companion skill, `install.sh`, either CI workflow yml, or the
    dispatcher command/agent files. Greps confirm the sweep: `git grep -n "deferred
    scene-knowledge-update"` returns no hits; `git grep -ln "scene_knowledge_update\|scene-knowledge-update"`
    lists the step file, both pipeline-state files, `AGENTS.md`, `agents/characters.md`,
    `agents/workflows.md`, the capture docs, and `character-extraction.md`; `git grep -n
    "xx-yy" templates/knowledge-book.md` returns no hits.

## Conventions adopted by this Sprint

Locked at planning (the two starred items are owner decisions from this Sprint's planning
session); tasks don't rediscover them.

- **★ The `scene_knowledge_update` step is built and wired this Sprint — it is not deferred.**
  The owner chose to build the running step now (over defining the model and leaving the step
  for M15/M16). So `agents/steps/scene-knowledge-update.md` is created, added to both recipes,
  and cataloged in `AGENTS.md`; the pipeline gains its first writer of `knowledge/`, and the
  empty-scaffold gap closes. Rejected alternative: model-and-templates only, step stays
  deferred — cleaner and smaller, but leaves `knowledge/book-N.md` permanently unfilled and
  postpones the milestone's one load-bearing capability.
- **★ Capture-style writes, but no human gate: `review_required: false`.** The step writes
  knowledge directly, the way capture writes inventions — provenance-stamped, non-destructive,
  marked `unreviewed` — but does **not** block downstream steps on human approval. The owner's
  rationale: applying a confirmed scene delta to a knowledge file is mechanical enough that the
  agent can do it without a human double-check. "Reviewable" in M14.5 therefore means the
  writes are **legible, traceable, and non-destructive** (a human *can* audit them and
  reconstruct any earlier state), **not** that a human must approve each one. This is safe re:
  reveal timing (Rule 2, `agents/update-rules.md:29-37`): the step records what a character
  learned *from committed prose that already happened*, so it is recording history, never
  forecasting a premature reveal; the prospective `## Must not know yet` constraints are
  authored by planning, and the step does not write them. Rejected: `review_required: true`
  (capture's gate) — the owner judged the write mechanical and the gate unnecessary friction.
- **The reviewable-change format stays off the validator / review-grammar machinery.**
  Character-state changes are **not** modeled as anchored `- Decision:` review units, and this
  Sprint does not touch `agents/review-grammars.yaml`, `scripts/validate-review-artifact.sh`,
  `agents/review-validation.md`, or the review companion. Agent-addressable, countable review
  of character-state changes is M16's job (Bounded relational review), and the objective
  continuity-update *reviewable* workflow is M15.5. Keeping M14 off that machinery avoids
  building review infrastructure the later milestones are chartered to design. Rejected:
  report/fix split via the validator — much heavier and a direct overlap with M15/M16.
- **The canonical story-position reference is folder-style `<book-id>/<chapter-id>/<scene-id>`,
  book-id omitted for `short_story`.** This adopts the form the knowledge-delta already uses
  (`agents/workflows.md:42-46`) and the folder convention that `agents/project-layouts.md:11`
  established, and **retires** the deprecated `xx-yy` numeric-prefix form in
  `templates/knowledge-book.md`. For `short_story` (no chapter subdivision, one chapter) a
  position reduces to `<scene-id>`. One format, ordered lexically by book → chapter → scene,
  used everywhere a character-state entry cites where a change occurred. Rejected: keep `xx-yy`
  (deprecated, and inconsistent with the delta the step reads).
- **Durable identity is a visible `id` field, not an HTML-comment anchor.** Each entry carries
  a stable `id` (e.g. `kn-01`, scoped to the character's knowledge file) as a normal structured
  field, minted once and never changed — later steps and transitions cite it. It stays a
  visible, human-readable field because the entry is already a structured unit with a `###`
  label, so the review-artifact system's "a position is only a hope" concern (which drove the
  `<!-- review-id -->` anchors) does not apply, and M14.4 demands human-readable Markdown.
  Rejected: reuse the `<!-- review-id -->` anchor convention — consistent with the review
  system but adds invisible markup to files a human reads directly, and couples character state
  to a grammar M14 is deliberately staying off.
- **Non-destruction is a hard invariant, realized by transitions.** A later change never
  deletes or overwrites the prior state: a correction moves the superseded belief into `##
  Lost or superseded` with its `id`, its held-from/held-to story positions, and what changed,
  and records the new state as its own stamped entry. This is the same append-don't-destroy
  discipline the draft-lineage model uses (superseded drafts stay on disk, unmodified —
  `agents/project-layouts.md:79`). It is what makes point-in-time reconstruction (M14.7)
  possible and what "not silently rewriting accumulated knowledge" (M14.5) concretely means.
- **Freshness is a derived predicate over the `committed-in` stamp, not a stored field.**
  Mirroring the Artifact-state contract (`agents/orchestrator.md:150-181`): an entry is
  derived-stale iff its `committed-in: draft-vNN.md` names a draft outside the active head's
  lineage, computed O(1) from the entry and the attempt manifest; no field is stored and no
  sweep walks the knowledge tree. Correction is the step's rerun-reconcile. Dispatcher-level
  detection of character-state staleness is **out of scope** — a deferred follow-on, exactly as
  dispatcher-level artifact staleness is (`agents/orchestrator.md:187`).
- **The step writes `knowledge/` only; `timeline.md` and `relationships.md` are
  model-and-template only this Sprint.** The knowledge delta is the mechanical, reliable input
  the step confirms and applies. Relationship shifts and timeline events are less mechanically
  derivable from the storyboard, `timeline.md` already has a writer (capture, for invented
  events), and adding a second automated writer per file invites conflicts. So the two files
  get the temporal model and templates (M14.1/M14.4) but keep their existing human/post-chapter
  update path (`agents/workflows.md:83-90`); an automated writer for them, if wanted, is later
  work.
- **short_story acquired knowledge lands in `knowledge/story.md`.** `short_story` has no
  `book-N.md` (`agents/steps/character-extraction.md:80`); the step creates and writes
  `knowledge/story.md` for facts acquired during the story, parallel to `book-N.md` for
  book/series. `baseline.md` stays pre-story only. The step creates the target file if absent.
- **The step runs at the end of the recipe, after `anti_ai_fix`.** It consumes the *accepted*
  (final) chapter prose and produces character state that feeds the *next* chapter's planning
  (`scene_generation`/`storyboarding` read `knowledge/`), matching the post-chapter-update
  ordering (`agents/workflows.md:83-90`). Rejected: placing it right after `compliance_fix`
  (where the storyboard-mandated facts are settled and the later passes are wording-only) — a
  defensible alternative, but end-of-recipe is the most literal reading of "accepted prose" and
  keeps the step reading one settled draft.

---

## Tasks

Wave order: **Task 1** settles the model and the templates/guidance — every downstream file
cites it — and lands first. **Task 2** builds and wires the step and defines its
provenance/freshness/correction behavior against Task 1's model. **Task 3** demonstrates,
smoke-tests, verifies, and closes out, last. The tasks are largely sequential (Task 2 writes to
`agents/characters.md`'s step-reference and freshness sections that Task 1 establishes; Task 3
depends on both), so run them in order rather than in parallel.

### Task 1 — The temporal model, the evolved knowledge template, and the timeline/relationships templates

- [ ] Todo

**Goal.** Define the temporal character-state model once, authoritatively, in
`agents/characters.md`, and realize it in the three templates as human-readable Markdown with
no parallel state system. Closes **M14.1**, **M14.2**, **M14.3**, **M14.4**.

**Requirements.**

- In `agents/characters.md`: state the temporal model spanning `knowledge/`, `timeline.md`, and
  `relationships.md` — the canonical story-position reference (folder-style
  `<book-id>/<chapter-id>/<scene-id>`, book-id omitted for `short_story`, per Conventions); the
  durable visible `id` (minted once, stable, character-file-scoped); the `committed-in:
  draft-vNN.md` provenance stamp; the current / historical-transition / prospective-constraint
  distinction (map it to the sections that already exist in the knowledge template); the `basis`
  type (`witnessed` | `told` | `inferred`) and how "remembered" is expressed (a fact `witnessed`
  at its source scene); and the **non-destruction invariant** (a later update never erases an
  earlier reconstructable state; corrections become transitions). State once that the character
  Markdown files remain the sole authority for character-relative state — no parallel
  index/DB/derived-state file — and that objective facts are deferred to canon/continuity (the
  M15 boundary), so a character file records what a character *believes*, not what is *true*.
- Evolve `templates/knowledge-book.md` per Definition-of-done item 3: add `id`, `story-position`
  (canonical format), `committed-in`, and `basis` fields to the `Knows` / `Suspects` /
  `Believes incorrectly` entry shapes; **remove** the deprecated `learned: [xx-yy]` /
  `basis: [xx-yy]` scheme and the `:4` note that defines `xx-yy`; give `## Lost or superseded`
  entries the same `id` (citing the entry they supersede) plus held-from/held-to story positions
  and `committed-in`; keep the `### [Short label]` heading as a readable label and `## Must not
  know yet` as the prospective-constraint section. Keep it valid, legible Markdown.
- Create `templates/timeline.md` and `templates/relationships.md` per Definition-of-done item 4:
  ordered, story-position-attributed, `id`-bearing entries; `relationships.md` carries current
  dynamics plus a superseded/transition section (a changed loyalty supersedes non-destructively,
  citing the prior entry's `id`); `timeline.md` is the chronological event record with the same
  attribution. Each opens with a short note that it is character-relative truth, not a parallel
  authority, deferring objective facts to canon/continuity. Model tone and structure on
  `templates/knowledge-book.md` and `templates/profile.md`.
- Do not touch the step files, `pipeline-state.md`, or the review-artifact system in this task.

**Done when.** `agents/characters.md` defines the full temporal model in one place; the three
templates realize it as human-readable Markdown; `xx-yy` is gone from `knowledge-book.md`; no
parallel state system is introduced; the story-position, id, provenance, basis, and
non-destruction rules are stated once and referenced, not restated per file.

---

### Task 2 — The `scene_knowledge_update` step: wired, provenance-stamped, non-destructive

- [ ] Todo

**Goal.** Build the sole writer of `knowledge/`, wire it into the pipeline, and define its
provenance, freshness, and correction behavior against Task 1's model. Closes **M14.5** and
**M14.6**.

**Requirements.**

- Create `agents/steps/scene-knowledge-update.md` with the standard step frontmatter
  (`step_id: scene_knowledge_update`, `review_required: false`, `inputs`/`outputs`,
  `preconditions`), modeling structure on an existing step (e.g.
  `agents/steps/compliance-report.md`) and following the step-workflow contract
  (`agents/orchestrator.md:35-79`). Inputs: the scene's storyboard blocks carrying the knowledge
  deltas (`kind: source`, required), the accepted `<latest-draft>` (`kind: prose_draft`,
  required), and the character `knowledge/` files it reconciles (`kind: source`, required:
  false — the step creates missing targets). Behavior: for each character's scene knowledge
  delta, **confirm** it against the drafted prose (correct the delta to what the prose actually
  committed), then **reconcile** into the project-type target — `knowledge/book-N.md` for
  book/series, `knowledge/story.md` for `short_story` (create if absent; `baseline.md` stays
  pre-story). A new fact appends a stamped entry (`id`, `story-position`, `committed-in:
  <latest-draft>`, `basis`, an `unreviewed` marker); a changed fact appends a `## Lost or
  superseded` transition citing the prior entry's `id` and records the corrected state — the step
  **never** overwrites or deletes an accumulated entry. It writes `knowledge/` only (never
  `timeline.md`/`relationships.md`/`profile.md`/canon — those are capture's or human's), respects
  each target's `edit_policy` (Rule 7, `agents/update-rules.md:62-108`), and records its own
  completion in `pipeline-state.md` as its final action.
- Define freshness and correction in the step body (and, where it generalizes, in
  `agents/characters.md`): a knowledge entry is **derived-stale** iff its `committed-in` names a
  draft outside the active head's lineage — computed O(1) from the entry stamp and the attempt
  manifest's `Active-head:`/`read_from` chain (`agents/project-layouts.md:81-98`), mirroring the
  `Reviewed-draft:` predicate (`agents/orchestrator.md:150-181`), never stored, never swept. An
  **idempotency / rerun** section states the reconcile behavior explicitly: re-running the step
  against the current active head appends corrections as transitions and duplicates nothing
  (match existing entries by `id` / story-position + fact), in contrast to
  `character_extraction`'s overwrite-on-rerun (`agents/steps/character-extraction.md:74-76`).
  Dispatcher-level staleness detection stays out of scope (deferred, per
  `agents/orchestrator.md:187`).
- Wire it: append `- [ ] scene_knowledge_update` after `anti_ai_fix` in **both**
  `templates/pipeline-state.md` and `examples/smoke/pipeline-state.md` (same position — CI
  enforces ordered-equality). Add a `scene-knowledge-update.md` catalog line to `AGENTS.md:63-77`.
  Run both `check-pipeline-state.sh` modes and confirm they pass.
- Retire the `deferred` framing (Definition-of-done item 8) and update the workflow entry
  (item 9): point `agents/characters.md:61`, `character-extraction.md:54`/`:88`/`:80`,
  `agents/capture/capture-agent.md:46`/`:84`, `agents/capture/README.md:31`, and
  `agents/workflows.md:62-68` at the real step and its reconciling, non-destructive,
  provenance-stamped, `review_required: false` behavior; preserve capture's "never `knowledge/`"
  hard line, now pointing at a step that exists. Leave the orchestrator's Artifact-state section
  byte-for-byte, or add at most a one-line cross-reference that character-state entries follow the
  same derived-freshness contract.

**Done when.** The step exists, is the sole `knowledge/` writer, reconciles deltas
non-destructively with provenance stamps and `review_required: false`, targets the right file per
project type, and defines its freshness/correction behavior; both recipes carry the step at the
same position; both `check-pipeline-state.sh` modes and the CI ordered-equality check pass; every
`deferred scene-knowledge-update` reference is retired; the untouched-surface diff (item 12) holds.

---

### Task 3 — Demonstration, smoke coverage, verification, and close-out

- [ ] Todo

**Goal.** Prove point-in-time reconstruction end-to-end, give the step a runnable smoke recipe,
run the verification sweep, and close the milestone. Closes **M14.7** and the residual of **M14**.

**Requirements.**

- Commit the worked demonstration under `examples/character-state/` (Definition-of-done item 10),
  clearly marked as an example per the `AGENTS.md` repository-boundary rule: an example character
  `knowledge/` file whose entries evolve across scenes — a **suspicion** that hardens into an
  **incorrect belief** that is later **corrected** (the correction recorded as a `## Lost or
  superseded` transition, not an overwrite), all under an active `## Must not know yet` reveal
  constraint — plus a README that reconstructs the character's state at **two** story positions
  from the ids/stamps/transitions alone and shows the earlier state survives the later correction.
- Add the smoke recipe(s) to `examples/smoke/README.md` (Definition-of-done item 11), modeled on
  the existing hand-authored-input recipes (the draft/report fixtures under
  `plot/drafts/attempt01/`, untracked): hand-author a character `knowledge/story.md` (short_story
  fixture), a scene storyboard carrying a knowledge delta, and an accepted draft; run
  `scene_knowledge_update` and confirm a provenance-stamped non-destructive append; then a second
  run against a corrected fact confirming a transition is appended, not an overwrite. Update the
  recipe enumeration paragraph (`:9`), the layout/untracked notes (`:28-29`), and the reset
  procedure to cover the new recipe number(s) and any new untracked paths; confirm the reset
  removes them. Existing recipes (1–20) stay byte-for-byte untouched.
- Run the full verification sweep (Definition-of-done items 6, 7, 12): both
  `check-pipeline-state.sh` modes; the two step lists ordered-equal; the untouched-surface
  `git diff --stat` against `eb11589` (no changes to the validator, review grammar/validation,
  the four review families, the review companion, `install.sh`, either CI workflow yml, or the
  dispatcher files); and the greps (`deferred scene-knowledge-update` → none;
  `scene_knowledge_update`/`scene-knowledge-update` → the expected file set; `xx-yy` gone from
  `knowledge-book.md`).
- Cross-file consistency read: the step, the three templates, `agents/characters.md`,
  `agents/workflows.md`, the capture docs, and `character-extraction.md` agree on the
  story-position format, the id/provenance fields, the non-destruction invariant, and the
  freshness rule — no drift, no restated model, no surviving `xx-yy`, no surviving `deferred`
  reference; the demonstration and smoke fixtures match the evolved template shapes.
- Update `ROADMAP.md`: check M14.1–M14.7 only after Tasks 1–2 pass verification; add the Sprint-19
  planning addendum to the M14 Notes (the starred owner decisions and the locked conventions) so
  the roadmap stays the plan of record. Check this SPRINT.md's per-task boxes (Tasks 1–3) only
  after their acceptance conditions hold.

**Done when.** The demonstration reconstructs a twice-changed character's state at two positions
with the earlier state intact; the smoke recipe(s) run and the reset covers them; all script runs,
the ordered-equality check, the untouched-surface diff, and the greps return the expected results;
ROADMAP M14.1–M14.7 and the SPRINT task boxes reflect completed work.

---

## Out of scope for this Sprint

- **The review-grammar / validator machinery.** `agents/review-grammars.yaml`,
  `scripts/validate-review-artifact.sh`, `agents/review-validation.md`, the four review-family
  step files, and the `amanuensis-review` companion skill are byte-for-byte unchanged.
  Character-state changes are not modeled as `- Decision:` review units; agent-addressable,
  countable review of them is **M16** (Bounded relational review). The owner's capture-style /
  no-gate / no-validator decision is the reason.
- **Objective continuity state (M15).** The character files record character-*relative* truth
  (what a character believes), never objective fact. The boundary — which class of fact each home
  owns — is **M15.1**; the objective *reviewable* continuity-update workflow is **M15.5**. This
  Sprint states the boundary only enough to keep character files from claiming objective
  authority, and does not build any continuity state.
- **Bounded relational review (M16).** Using maintained character state plus targeted retrieval to
  catch cross-scene/-chapter/-book contradictions is M16. This Sprint produces the maintained state
  and its provenance/ids/freshness so M16 can consume it; it does not add or change any relational
  review.
- **An automated writer for `timeline.md` or `relationships.md`.** They get the temporal model and
  templates (M14.1/M14.4) but keep their existing human/post-chapter update path
  (`agents/workflows.md:83-90`). `timeline.md` already has a writer (capture, for invented events);
  a second automated writer per file is later work.
- **Widening the capture subsystem.** Capture stays hard-barred from `knowledge/`
  (`agents/capture/capture-agent.md:46`); only its "deferred" pointer is updated to name the real
  step. Its routing to `timeline.md`/`profile.md`/`canon/generated/` is unchanged.
- **Dispatcher-level freshness/override for character state.** Detection stays in step bodies as a
  derived predicate; lifting it into the dispatcher is a deferred follow-on, exactly as it is for
  artifact staleness (`agents/orchestrator.md:187`).
- **Downstream consumer changes.** `scene_generation` and `storyboarding` read `knowledge/` as they
  do today; the temporal model is additive and leaves the current-state sections legible, so their
  step files are unchanged.
- **`install.sh`, the CI workflow ymls, and the dispatcher command/agent files.** Unchanged —
  adding a step touches only the two `pipeline-state.md` lists, the step file, and the `AGENTS.md`
  catalog; nothing enumerates step names in those files.
