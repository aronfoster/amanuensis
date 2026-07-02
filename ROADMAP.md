# Amanuensis Roadmap

Remaining work, in rough dependency order. Tasks plus short notes on what's done.
Project overview, architecture, and current status live elsewhere.

Several milestones edit the canonical step list (`templates/pipeline-state.md`); they
are sequenced, not parallel, so it is never edited by two at once.

---

## M7 — Selective step execution

Replace the linear `next-step` cursor model with explicit, selective step invocation.
The default pipeline remains a recommended recipe, but correctness is governed by
artifact preconditions, not by strict sequence position.

Done when: a human can invoke a specific step by `step_id`; the dispatcher validates
that the step's declared inputs exist and are usable; locally ordered pairs such as
`compliance_report -> compliance_fix` are enforced by artifact freshness rules rather
than by global pipeline position; `pipeline-state.md` no longer requires a single
`[>]` cursor to define what may run next; both hosts expose the same model.

* [ ] M7.1 Design note: define the selective execution model. Terms to settle:
  `runnable`, `blocked`, `stale`, `superseded`, `active`, `recommended next`,
  and `explicit override`.

* [ ] M7.2 Reframe `pipeline-state.md` from cursor state into recipe/status state.
  Remove the requirement that exactly one `[>]` marker controls execution. Preserve
  the default step order as the recommended happy path, not as the only legal path.

* [ ] M7.3 Expand the step workflow contract so each step declares machine-readable
  preconditions in addition to descriptive `inputs` / `outputs`. At minimum, distinguish:
  required files, optional files, prose-draft inputs, side-artifact inputs, and
  human-review-sensitive inputs.

* [ ] M7.4 Implement explicit step invocation in the dispatcher:
  `run_step <step_id>` or host-equivalent. The dispatcher resolves the requested
  workflow file, checks preconditions, then follows that step body in the same session.

* [ ] M7.5 Keep a convenience command for the recommended path:
  `next_recommended_step` or host-equivalent. This reads the recipe/status file and
  chooses the next incomplete recommended step, but it is layered on top of selective
  execution rather than being the core control model.

* [ ] M7.6 Generalize local ordering constraints. Report/fix and identify/apply pairs
  must be enforced by artifact stamps such as `Reviewed-draft:`, not by global adjacency
  in the step list. A fix/apply step may run only when its paired report artifact was
  produced against the current usable draft, unless the human explicitly overrides.

* [ ] M7.7 Update `orchestrator.md` to remove forward/back/redo language. The
  orchestrator should describe Amanuensis as running selected transformations against
  explicit artifacts, with judgment living in the human and the step bodies.

* [ ] M7.8 Host parity: expose the same selective invocation model in Claude Code and
  OpenCode. The names do not have to be identical, but the behavior and safety checks
  must match.

* [ ] M7.9 Smoke coverage: verify that the default recipe still runs in order; verify
  that a human can rerun a completed report step; verify that a fix step blocks on a
  stale report; verify that a non-dependent step can run out of recipe order when its
  inputs are valid.

Notes: This milestone deliberately does not change draft version lineage. For now,
`<latest-draft>` may remain the highest-numbered `draft-vNN.md` as defined by M4.
Non-destructive reruns, active draft heads, and superseded draft branches are deferred
to M8. The purpose of M7 is to decouple dispatcher control from strict linear cursor
movement without rewriting the draft manifest model in the same sprint.

Sprint 12 plans M7 (see SPRINT.md). Locked there: the state grammar becomes `[x]`/`[ ]`
only, with `[>]` retired but tolerated as a legacy synonym of `[ ]` (no migration, no
`check-pipeline-state.sh` change); recommended next = first non-`[x]` step. The command
surface adds `run-step` on both hosts and keeps `next-step` as a convenience layer over
the same procedure. The M7.1 design note lands inside `agents/orchestrator.md` as an
Execution model section (single-sourcing; a separate design doc was rejected).
Preconditions are an additive frontmatter block (`path`/`kind: source|prose_draft|side_artifact`/
`required`/`review_sensitive`); the dispatcher checks required-file existence only —
freshness and review checks stay in step bodies until M9.6. The adjacency invariant is
renamed the report→fix freshness invariant with mechanics unchanged.

---

## M8 — Active draft lineage

Replace highest-numbered draft resolution with an explicit active draft head in
`draft-manifest.md`, so arbitrary reruns can create new draft versions without deleting
or archiving prior work.

Done when: `<latest-draft>` resolves to the manifest's active head rather than the
highest-numbered `draft-vNN.md`; rerunning a prose-advancing step can read an earlier
draft and produce a new active draft; superseded downstream drafts remain on disk but
are no longer considered active; stale side artifacts can identify which draft lineage
they belong to.

* [ ] M8.1 Design note: define active draft lineage. Terms to settle:
  `active_head`, `reads`, `produced_by`, `supersedes`, `superseded_by`,
  `lineage`, and `abandoned`.

* [ ] M8.2 Update `draft-manifest.md` schema so each prose-bearing draft version records:
  producing step, input draft(s), side artifacts consumed, timestamp, review gate if any,
  and whether it is the active head.

* [ ] M8.3 Change `<latest-draft>` resolution from highest-numbered draft to active
  manifest head. Keep draft filenames monotonic: reruns create the next `draft-vNN.md`
  rather than overwriting or reusing old numbers.

* [ ] M8.4 Define non-destructive rerun semantics. If a human reruns a prose-advancing
  step from an earlier draft, the new output becomes the active head and any previously
  active downstream drafts are marked superseded in the manifest, not deleted.

* [ ] M8.5 Update all prose-advancing steps to append manifest entries that preserve
  lineage. Steps must not infer active state from filenames alone.

* [ ] M8.6 Update all prose-reading/report steps to resolve the active head through the
  manifest before reading `<latest-draft>`.

* [ ] M8.7 Smoke coverage: create a linear draft chain, rerun a prose-advancing step from
  an earlier draft, verify the new draft becomes active, verify old downstream drafts
  remain on disk but are superseded, and verify report steps read the new active head.

Notes: This milestone replaces the archive-on-redo idea from the old M7. Amanuensis
does not move backward. It creates a new version from selected inputs and records which
draft lineage is now active.

---

## M9 — Stale artifacts and review gates

Make arbitrary step execution safe by tracking whether side artifacts are fresh,
stale, reviewed, pending review, superseded, or explicitly overridden.

Done when: side artifacts generated from prose identify the draft they reviewed;
fix/apply steps refuse stale artifacts by default; review-required artifacts carry
an explicit review status or equivalent human-acknowledgment marker; the dispatcher
and step bodies consistently block, warn, or proceed according to declared rules.

* [ ] M9.1 Design note: define side-artifact state. Terms to settle:
  `fresh`, `stale`, `review_pending`, `reviewed`, `override`, `discarded`,
  and `regenerated`.

* [ ] M9.2 Standardize freshness stamps for prose-derived side artifacts. Existing
  `Reviewed-draft:` behavior becomes the common pattern for reports, annotations,
  metaphor findings, anti-AI findings, and similar artifacts.

* [ ] M9.3 Standardize review markers for artifacts produced by `review_required: true`
  steps. Decide whether review state lives in the artifact itself, in a manifest, or
  in the recipe/status file.

* [ ] M9.4 Update fix/apply steps to check both freshness and review state before
  consuming side artifacts. On mismatch, append a clear blocker to `open-questions.md`
  and exit without modifying prose.

* [ ] M9.5 Define explicit override behavior. Overrides must be human-visible,
  source-specific, and recorded in the relevant artifact or manifest. No stale apply
  should happen silently.

* [ ] M9.6 Update the dispatcher to surface stale/review blockers before loading the
  requested step body when the precondition is machine-checkable.

* [ ] M9.7 Smoke coverage: verify stale report detection, reviewed-artifact detection,
  pending-review blocking or warning behavior, regeneration of a stale report against
  the active draft, and explicit override recording.

Notes: M9 generalizes the report→fix adjacency invariant into an artifact-freshness
model. The old adjacency rule remains valid as a special case, but the framework no
longer depends on global step order to protect fix/apply steps.

---

## M10 — Reverse ingestion: existing prose into Amanuensis

Ingest a finished work into Amanuensis artifacts (characters, scene-list, storyboards,
overview), chunked to fit context. Design-gated.

Done when: a single existing chapter or short story ingests into a valid project
structure that the forward pipeline's downstream steps can consume.

* [ ] M10.1 Design note (blocking): split reverse ingestion into smaller milestones.
  Candidate areas: prose chunking and source maps; character/entity extraction from
  prose; scene reconstruction; storyboard reconstruction; overview synthesis; canon
  reconciliation; reverse-to-forward bridge.
* [ ] M10.2+ Implementation tasks opened from the approved design note.

Notes: Formerly M8. This is intentionally tabled until selective execution and artifact
lineage are stable enough to support reverse-generated artifacts.

---

## Completed

### M1 — Pipeline step-list consistency

Make every step list agree with `agents/steps/` and single-source it.

Done when: all step lists match the step files; `orchestrator.md` references the
canonical list instead of duplicating it; the smoke fixture is checked against it.

- [x] M1.1 Propagate the `anti_ai_report`/`anti_ai_fix` split into
  `examples/smoke/pipeline-state.md`, the `orchestrator.md` state example, and any
  README references still showing monolithic `anti_ai`.
- [x] M1.2 Make `templates/pipeline-state.md` canonical; point `orchestrator.md` at it
  rather than re-listing; add a check that the smoke fixture's step set matches.
- [x] M1.3 Replace any other hard-coded step lists (README, `workflows.md`, adapter
  template) with references.

Notes: Also shipped a consumer-side validator — `scripts/check-pipeline-state.sh` plus
a CI workflow template (`templates/dispatcher/.github/workflows/pipeline-state-check.yml`)
installed by `install.sh` — so consuming projects' `pipeline-state.md` files are
checked against their installed Amanuensis step set on push and pull request.

---

### M2 — Drafting artifact cleanup

Delete per-scene fragments after assembly; align the step body with the OpenCode
coordinator.

Done when: a drafting run leaves `draft.md` and `notes.md` only; `sceneNN.md` /
`sceneNN-notes.md` removed; `drafting.md` frontmatter no longer lists them as durable
outputs.

- [x] M2.1 Add post-assembly deletion of `sceneNN.md` / `sceneNN-notes.md` to
  `drafting.md`, mirroring `opencode/agents/chapter-coordinator.md`.
- [x] M2.2 Reconcile `drafting.md` frontmatter: drop the per-scene fragments from
  durable outputs or mark them transient.
- [x] M2.3 Document the audit-record vs transient-fragment distinction (persist
  `reviewer-actions.md`, `metaphors.md`, `anti-ai.md`, `notes.md`; delete scene fragments).

Notes: The OpenCode coordinator (`chapter-coordinator.md`) was also pointed at the
shared persist-vs-delete rule in `chapters.md` for host parity.

---

### M3 — Bounded canon invention + capture

Replace the blanket "do not invent canon" with one bounded rule; resolve the
`orchestrator.md` TODO; add a coordinator-managed **capture agent** that records the
continuity-relevant inventions the rule permits into the right canonical files.

Done when: a single statement of the rule exists and is referenced from the step
bodies; the contradictory TODO is gone; the drafting coordinator dispatches a capture
agent that writes permitted inventions to `timeline.md` / `profile.md` / an
agent-generated `canon/` subfolder (never `knowledge/`), with annotated, edit-policy-
respecting, non-blocking writes, at parity on both hosts.

#### The rule

- [x] M3.1 Write the rule (in `canon.md` or `update-rules.md`): invent only when canon
  and plan are silent, it cannot contradict existing canon, it fits genre/register/period,
  and it is not load-bearing for reveal timing or character knowledge; otherwise record an
  open question.
- [x] M3.2 Reference it from `drafting.md`, `scene-generation.md`,
  `character-extraction.md`, `storyboarding.md`, `update-rules.md`; keep the hard
  prohibition for reveal- and knowledge-load-bearing facts.
- [x] M3.3 Resolve the `orchestrator.md` invention TODO.

#### The capture agent

A new subagent role dispatched by the drafting coordinator (and the OpenCode
`chapter-coordinator`), **not** a new pipeline step. The sandboxed scene-drafters stay
sandboxed — they only emit *recommendations*; the capture agent is the one role permitted
to write character and canon files.

- [x] M3.4 Recommendation hand-off. Define the schema a scene-drafter emits in its
  `sceneNN-notes.md` for each continuity-relevant invention: the invented fact, the target
  (`character_id`(s) or world-scope), the fact-type (`event` / `identity` / `world`), and the
  source scene+beat. Add a line to the `drafting.md` subagent prompt contract instructing
  subagents to record these (they still write nothing outside their notes/prose).
- [x] M3.5 Coordinator collection + dispatch. The coordinator gathers recommendations while
  assembling `notes.md` (drafting step 8) and dispatches the capture agent **before** the
  step-9 fragment deletion, so nothing is lost when `sceneNN-notes.md` is removed. Capture
  is gated like deletion: it runs only on a completed assembly, never on a failure/abandon
  path.
- [x] M3.6 Capture agent definition + routing. Write the agent (a host doc under `agents/`
  plus an `opencode/agents/` counterpart). Routing:
  character `event` → `characters/<id>/timeline.md`; invented stable identity color →
  `characters/<id>/profile.md`; **never `knowledge/`** (reserved for the deferred
  scene-knowledge-update step and reveal-sensitive — `characters.md:61`); non-character /
  `world` facts → a new agent-generated subfolder under `canon/` (kept distinct from
  human-authored canon); a walk-on with no folder → create a `status: stub` folder per
  `characters.md` then write. Capture only records inventions the M3.1 rule permits;
  reveal-/knowledge-load-bearing facts are still recorded as open questions, never captured.
- [x] M3.7 Write discipline. Each write is annotated with source scene+beat, draft-version
  provenance (the M4.3 stamp — "which draft did this come from"), and an
  `invented, unreviewed` marker; respects the target file's `edit_policy` (no silent write
  to a locked / propose-only file — emit a proposal / log instead); and is non-blocking —
  a capture failure never blocks draft completion, it is logged in `notes.md`. Captured
  writes ride drafting's existing `review_required: true` gate.
- [x] M3.8 Host parity. Mirror the coordinator dispatch and the capture agent across the
  `.claude` drafting coordinator (`agents/steps/drafting.md`) and
  `opencode/agents/chapter-coordinator.md`.

Notes: knowledge/ is deliberately out of bounds for capture — it stays the sole province of
the deferred scene-knowledge-update step, which protects reveal timing. M3.7's provenance
annotation depends on M4.3's per-draft-version stamp. The agent-generated canon subfolder was
named `canon/generated/` (Sprint 8 Open decision 1); capture annotates source scene + beat +
attempt now and folds in the M4.3 draft-version stamp when M4 lands.

---

### M4 — Versioned draft naming

Decouple prose-bearing draft filenames from the producing step so prose-chain reordering
is a `pipeline-state.md`-only edit. Prerequisite for M5 and M7.

Done when: prose-advancing steps read `<latest-draft>` and write the next version; report
steps read `<latest-draft>` and do not increment; provenance is recorded; side-artifacts
keep their step names; the report→fix adjacency invariant is documented.

- [x] M4.1 Define `<latest-draft>` resolution (highest-numbered `draft-vNN.md` in the
  attempt), parallel to `<latest-attempt>`. Drafting produces `draft-v01.md`.
- [x] M4.2 Convert prose-advancing steps (`drafting`, `compliance_fix`,
  `metaphor_apply`, `line_pass`, `anti_ai_fix`) to write `<next-draft>`; convert prose-reading
  steps (`compliance_report`, `prose_pass`, `metaphor_identify`, `metaphor_fix`,
  `anti_ai_report`) to read `<latest-draft>`.
- [x] M4.3 Add provenance to each draft version (frontmatter stamp `produced_by` / `reads`,
  or an attempt-level manifest). This is also the "which draft did this come from" stamp that
  M3.7's capture annotations reference — define it so a captured invention can name its source
  draft version.
- [x] M4.4 Document the report→fix adjacency invariant: no draft increment between a report
  and its paired fix.
- [x] M4.5 Sweep the rename through docs that hard-code `draft.md` (`chapters.md`,
  `project-layouts.md`, schema examples) and the canonical state list.

Notes: side-artifacts (`reviewer-actions.md`, `metaphors.md`, `anti-ai.md`,
`prose-pass.md`) stay step-named; only prose-bearing files are versioned. Sprint 9 landed
provenance as an attempt-level `draft-manifest.md` (not per-draft frontmatter) because
drafting's prose-only invariant precludes in-file YAML in the draft files themselves; each
prose-advancing step appends a per-version entry to the manifest. `prose_fix` remains deferred
to M5; M4 only makes the versioned naming model ready for it.

---

### M5 — Prose fix apply step

Close the prose-apply orphan: `prose_pass` recommendations get applied into the versioned
draft the metaphor stage reads. Depends on M4.

Done when: `prose_fix` reads annotated `prose-pass.md` + `<latest-draft>` and writes the
next draft version; `prose_pass` output carries an annotation grammar; the metaphor stage
consumes the prose-applied draft.

- [x] M5.1 Add `FIX` / `FIX: <instruction>` / `SKIP` / `ESCALATE` per-entry annotation
  grammar to `prose-pass.md`, keyed off the existing KEEP/TIGHTEN/FLATTEN/REWRITE labels;
  `KEEP` needs no annotation and is treated as `SKIP`. No bulk headers (Sprint 10 locked
  decision — `prose_pass` is deliberately selective at 5-10 findings, so bulk-annotation
  surface would go unused).
- [x] M5.2 Record the apply strategy in `agents/steps/prose-fix.md`: surgical per-entry
  (Sprint 10 locked decision). Locate quote → apply local edit → copy rest verbatim,
  matching `compliance_fix` / `anti_ai_fix` / `metaphor_apply`. Bare `FIX` on `REWRITE` is
  generative — the fixer produces a new sentence/paragraph in-voice using `voice.md` as
  system message and the target paragraph plus one paragraph either side as read-only
  context. Chunked-like-`line_pass` was considered and rejected: `prose_pass` is
  deliberately selective, so a whole-chapter chunk pass would reprocess mostly untouched
  prose.
- [x] M5.3 Write `agents/steps/prose-fix.md` (inputs: annotated `prose-pass.md`,
  `<latest-draft>`, `voice.md`; outputs: `<next-draft>` + appended `prose-pass.md` apply
  log + appended `draft-manifest.md` entry). `review_required: false`. Follows the
  report→fix adjacency invariant via the `Reviewed-draft:` stamp `prose_pass` already
  writes.
- [x] M5.4 Insert `prose_fix` after `prose_pass` in the canonical step list
  (`templates/pipeline-state.md` and `examples/smoke/pipeline-state.md`); the pipeline
  check (`scripts/check-pipeline-state.sh`) must pass.

Notes: with M4 done, the metaphor steps already read `<latest-draft>`, so no input
rewiring is needed. Sprint 10 retires the "Manual prose-edit handoff" procedure in
`agents/chapters.md` and the "advisory only until M5" language in `prose-pass.md` /
`AGENTS.md`; `prose_pass → prose_fix` joins the report→fix invariant list in
`agents/orchestrator.md`. Storyboards and canon are deliberately *not* read by `prose_fix`
(matches `metaphor_apply` / `anti_ai_fix`) — `prose_pass` already reviewed the prose
against the storyboard and voice, and `prose_fix` applies the reviewed judgments without
re-evaluating them.

---

### M6 — Storyboard reader-reveal coverage

Storyboards declare what the reader must understand, not only what is concealed; an
advisory review pass flags under-communication. Order-independent of M4/M5.

Done when: the schema has a reader-takeaway field; `storyboarding` populates it;
`storyboard_review` flags beats whose takeaway is unsupported or whose reveals lack prior
setup; it sits between storyboarding and drafting.

- [x] M6.1 Add a reader-takeaway field to `storyboard-schema.md` (distinct from
  `concealment_from_reader` and `must_preserve`), held to the spec-not-prose discipline.
- [x] M6.2 Update `storyboarding.md` to populate it; make an empty field a default-to-fill
  anti-pattern.
- [x] M6.3 Write `agents/steps/storyboard-review.md` (advisory, report-only): check each
  beat's takeaway is carried and that dependent beats have prior setup.
- [x] M6.4 Insert `storyboard_review` between `storyboarding` and `drafting` in the
  canonical list.

Notes: a `storyboard_review_fix` apply step and the cross-chapter reveals ledger are
deferred. Sprint 11 plans M6 (see SPRINT.md). Locked there: the new field is
`reader_takeaway`, a default-to-fill markdown section (not frontmatter) that states what
the *reader* must understand by a beat's end — distinct from `concealment_from_reader` (its
inverse) and `knowledge_delta` (character knowledge). `storyboard_review` is advisory-only —
a report with no annotation grammar and no paired fix step (the deferred `storyboard_review_fix`
would add the grammar later, mirroring how `prose_pass`'s grammar landed with `prose_fix`); it
runs before drafting so it carries no `Reviewed-draft:` stamp and sits outside the report→fix
invariant. It runs three checks: takeaway-supported, reveal-has-prior-setup (within-chapter
only), and a takeaway/concealment contradiction guard. Reveal dependencies are inferred from
`beat_type`/`reader_takeaway`/`concealment_from_reader` plus `scene-list.md` ordering — no new
dependency field is added.

---

## Deferred

- storyboard_review_fix apply step (after M6 proves out)
- story-level reveals ledger with buildup (couples to continuity review; matters for book/series)
- continuity review step
- scene knowledge update step
- post-chapter update step
- chapter selection for book/series ("which chapter is current?")
- pre-writing pipeline (vague idea -> plan)
- multi-host beyond Claude Code / OpenCode
- per-attempt comparison tooling (revisit after M7's archive model)
- multi-work concurrency
