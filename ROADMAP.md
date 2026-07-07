# Amanuensis Roadmap

Remaining work, in rough dependency order. Tasks plus short notes on what's done.
Project overview, architecture, and current status live elsewhere.

Several milestones edit the canonical step list (`templates/pipeline-state.md`); they
are sequenced, not parallel, so it is never edited by two at once.

---

## M11 — Agent-addressable review: anti-AI slice

Second of the four agent-addressable-review milestones (M10–M13). The shared design
and target grammar table governing all four live in the completed M10 section below;
the machine-readable contract is `agents/review-grammars.yaml`.

Retarget `anti-ai.md` to the structured contract, and simplify it under the review model's shift from human-edits-markdown to **AI-plus-human review** (owner direction, Sprint 16): conventions that existed to make hand-annotating markdown cheap — the per-category `BULK:` header, its per-scene `BULK eligibility:` declaration block, and bulk inheritance — are retired rather than migrated. Category-level review survives as **companion fan-out**: where the grammar declares a category fan-out-eligible, the human states one decision for the category and the companion writes it into every pending unit's `Decision:` field, each marked with an audit note. The artifact itself carries pure per-unit decisions: blank means pending in every family, with no exceptions.

Done when: anti-AI flagged instances carry `review-id` anchors and decision fields; blank `Decision:` means pending with no inheritance exception; a `BULK:` header, the old positional annotation format, and an anchorless pre-M11 report are all invalid inputs to `anti_ai_fix` (never silently empty, never silently tolerated); `anti_ai_fix` consumes structured per-entry decisions via the shared validator; fan-out eligibility and recommended defaults are single-sourced in `agents/review-grammars.yaml`; the companion offers category-level capture only for declared categories and writes only human-stated decisions, fanned per-unit with audit notes.

- [ ] M11.1 Retarget `anti_ai_report` output: `review-id` anchor plus blank decision fields per flagged instance; drop the `BULK eligibility:` block and the per-scene `### Summary` tally (the validator's ledger is the authoritative count); a clean scene records a single `No flags.` line; grammar referenced from `agents/review-grammars.yaml`, not restated.
- [ ] M11.2 Update `anti_ai_fix` to consume `Decision:` fields via the shared validator (per-unit pending gate; positional annotations and `BULK:` headers are invalid input; category fix rules and stale/override mechanics unchanged).
- [ ] M11.3 Flip anti-AI to `adopted` in `review-grammars.yaml` with `container_pattern` settled and artifact bulk support withdrawn (`bulk_supported: no`); add the fan-out declaration (eligible categories plus recommended defaults). The validator itself needs no change — verified at planning.
- [ ] M11.4 Companion support: category queues; fan-out capture per the grammar's declaration (one stated decision written into every pending unit of the category, each with an audit note); payload prompting on categories whose bare `FIX` has no fix rule.
- [ ] M11.5 Smoke coverage: fan-out round-trip with a per-entry exception and mixed pending counts, a stray `BULK:` header rejected as invalid; the existing anti-AI-format recipes updated to the structured format.

Notes: Sprint 16 plans M11 (see SPRINT.md). The milestone was reshaped at planning under an owner directive: the review process is now AI-plus-human — the companion captures and writes, the human decides — so conventions that existed to make human hand-editing of markdown cheap are retired when retiring them makes agent review simpler or more reliable. Header bulk was the largest: it was the design's only blank-means-decided exception and its only two-layer validation case, and the `BULK eligibility:` block was fake-dynamic (the report emitted the same fixed list every run, restating static knowledge the grammar file owns). Shared-design principles 5 and 7 in the M10 section were revised accordingly. Locked at planning (owner decisions): the bare-`FIX` fallback on categories with no bare-FIX rule stays fixer-level treat-as-`ESCALATE` — the validator stays category-agnostic, and the companion instead prompts for the needed instruction at capture time (rejected: per-category payload keys in the grammar YAML and validator); the companion writes only what the human states — a category fan-out is one human decision mechanically applied, marked per unit in `Decision-note:` (this supersedes the same session's earlier plan, where the companion would write `BULK:` headers); the progress ledger is unchanged — `inherited-by-bulk` now stays 0, since no adopted family grants artifact-level bulk. Verified at planning with the stock validator against a scratch grammar copy: the fan-out-shaped artifact yields the correct ledger; a pre-M11 positional report — including its `### Summary` heading — fails the plain `container_pattern` check as invalid, so the old format can never pass as zero-units/proceed; and a stray `BULK:` header is rejected through the existing no-bulk-support path. `scripts/validate-review-artifact.sh` therefore ships byte-for-byte unchanged this milestone.

---

## M12 — Agent-addressable review: prose-pass slice

Retarget `prose-pass.md` findings to the structured contract: selective per-entry review, no bulk anywhere (the locked M5 convention stands).

Done when: each finding carries a `review-id` anchor and decision fields (the current `Annotation:` line is replaced by `Decision:` / `Decision-note:`); `KEEP` findings are non-actionable (emitted with `Decision: SKIP` or omitted from the actionable queue, per the grammar); non-`KEEP` findings require explicit review evidence; the validator rejects any bulk annotation; `prose_fix` consumes structured decisions.

- [ ] M12.1 Retarget `prose_pass` findings format: anchor plus decision fields; `KEEP` handling per grammar; the annotation-grammar section moves to a `review-grammars.yaml` reference.
- [ ] M12.2 Update `prose_fix` to consume `Decision:` fields via the shared validator.
- [ ] M12.3 Flip prose-pass to `adopted` in `review-grammars.yaml`; no-bulk enforced by the validator.
- [ ] M12.4 Companion support for small, high-value finding queues.
- [ ] M12.5 Smoke coverage: non-`KEEP` finding pending/decided flow; a bulk annotation rejected as invalid.

---

## M13 — Agent-addressable review: metaphor slice

Retarget `metaphors.md` to the structured contract and make rejection non-destructive: accepted, rejected, and unreviewed figures must be distinct, and every figurative decision stays in the audit record.

Done when: each metaphor entry carries a `review-id` anchor and decision fields with tokens `KEEP` / `REJECT` / `FLATTEN` / `REPLACE: <image>` / `WORKSHOP`, replacing the free-text `Human Assessment:` line and delete-as-rejection; bare `REPLACE` is invalid per the policy locked in M10.1; `metaphor_fix` generates variants only for `FLATTEN` / `REPLACE` / `WORKSHOP` and skips `KEEP` / `REJECT`; `metaphor_apply` treats a fully reviewed file of all `KEEP` / `REJECT` decisions as valid pass-through, not a nothing-to-do failure; pending entries block downstream.

- [ ] M13.1 Retarget `metaphor_identify` entry format: anchor plus decision fields; drop the `Human Assessment:` line.
- [ ] M13.2 Update `metaphor_fix` to consume `Decision:` tokens: bare `REPLACE` becomes invalid (the treat-as-`WORKSHOP` convenience in `agents/steps/metaphor-fix.md` is removed); `KEEP` / `REJECT` entries stay in the file untouched; deletion is no longer a decision signal.
- [ ] M13.3 Update `metaphor_apply` to consume selected variants under the structured contract, with all-`KEEP`/`REJECT` pass-through.
- [ ] M13.4 Flip metaphors to `adopted` in `review-grammars.yaml`.
- [ ] M13.5 Companion support for metaphor pacing, progress counts, and non-automated review (no auto-disposition from `CLEAN` / `REVIEW` / `BROKEN` flags).
- [ ] M13.6 Smoke coverage: non-destructive rejection, all-`KEEP`/`REJECT` pass-through, pending-entries block, bare-`REPLACE` rejection.

---

## M14 — Reverse ingestion: existing prose into Amanuensis

Ingest a finished work into Amanuensis artifacts (characters, scene-list, storyboards,
overview), chunked to fit context. Design-gated.

Done when: a single existing chapter or short story ingests into a valid project
structure that the forward pipeline's downstream steps can consume.

* [ ] M14.1 Design note (blocking): split reverse ingestion into smaller milestones.
  Candidate areas: prose chunking and source maps; character/entity extraction from
  prose; scene reconstruction; storyboard reconstruction; overview synthesis; canon
  reconciliation; reverse-to-forward bridge.
* [ ] M14.2+ Implementation tasks opened from the approved design note.

Notes: Formerly M8, then M11 (renumbered when the review milestones split into
M10–M13). This is intentionally tabled until selective execution and artifact
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

### M7 — Selective step execution

Replace the linear `next-step` cursor model with explicit, selective step invocation.
The default pipeline remains a recommended recipe, but correctness is governed by
artifact preconditions, not by strict sequence position.

Done when: a human can invoke a specific step by `step_id`; the dispatcher validates
that the step's declared inputs exist and are usable; locally ordered pairs such as
`compliance_report -> compliance_fix` are enforced by artifact freshness rules rather
than by global pipeline position; `pipeline-state.md` no longer requires a single
`[>]` cursor to define what may run next; both hosts expose the same model.

- [x] M7.1 Design note: define the selective execution model. Terms to settle:
  `runnable`, `blocked`, `stale`, `superseded`, `active`, `recommended next`,
  and `explicit override`.

- [x] M7.2 Reframe `pipeline-state.md` from cursor state into recipe/status state.
  Remove the requirement that exactly one `[>]` marker controls execution. Preserve
  the default step order as the recommended happy path, not as the only legal path.

- [x] M7.3 Expand the step workflow contract so each step declares machine-readable
  preconditions in addition to descriptive `inputs` / `outputs`. At minimum, distinguish:
  required files, optional files, prose-draft inputs, side-artifact inputs, and
  human-review-sensitive inputs.

- [x] M7.4 Implement explicit step invocation in the dispatcher:
  `run_step <step_id>` or host-equivalent. The dispatcher resolves the requested
  workflow file, checks preconditions, then follows that step body in the same session.

- [x] M7.5 Keep a convenience command for the recommended path:
  `next_recommended_step` or host-equivalent. This reads the recipe/status file and
  chooses the next incomplete recommended step, but it is layered on top of selective
  execution rather than being the core control model.

- [x] M7.6 Generalize local ordering constraints. Report/fix and identify/apply pairs
  must be enforced by artifact stamps such as `Reviewed-draft:`, not by global adjacency
  in the step list. A fix/apply step may run only when its paired report artifact was
  produced against the current usable draft, unless the human explicitly overrides.

- [x] M7.7 Update `orchestrator.md` to remove forward/back/redo language. The
  orchestrator should describe Amanuensis as running selected transformations against
  explicit artifacts, with judgment living in the human and the step bodies.

- [x] M7.8 Host parity: expose the same selective invocation model in Claude Code and
  OpenCode. The names do not have to be identical, but the behavior and safety checks
  must match.

- [x] M7.9 Smoke coverage: verify that the default recipe still runs in order; verify
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

### M8 — Active draft lineage

Replace highest-numbered draft resolution with an explicit active draft head in
`draft-manifest.md`, so arbitrary reruns can create new draft versions without deleting
or archiving prior work.

Done when: `<latest-draft>` resolves to the manifest's active head rather than the
highest-numbered `draft-vNN.md`; rerunning a prose-advancing step can read an earlier
draft and produce a new active draft; superseded downstream drafts remain on disk but
are no longer considered active; stale side artifacts can identify which draft lineage
they belong to.

- [x] M8.1 Design note: define active draft lineage. Terms to settle:
  `active_head`, `reads`, `produced_by`, `supersedes`, `superseded_by`,
  `lineage`, and `abandoned`.

- [x] M8.2 Update `draft-manifest.md` schema so each prose-bearing draft version records:
  producing step, input draft(s), side artifacts consumed, timestamp, review gate if any,
  and whether it is the active head.

- [x] M8.3 Change `<latest-draft>` resolution from highest-numbered draft to active
  manifest head. Keep draft filenames monotonic: reruns create the next `draft-vNN.md`
  rather than overwriting or reusing old numbers.

- [x] M8.4 Define non-destructive rerun semantics. If a human reruns a prose-advancing
  step from an earlier draft, the new output becomes the active head and any previously
  active downstream drafts are marked superseded in the manifest, not deleted.

- [x] M8.5 Update all prose-advancing steps to append manifest entries that preserve
  lineage. Steps must not infer active state from filenames alone.

- [x] M8.6 Update all prose-reading/report steps to resolve the active head through the
  manifest before reading `<latest-draft>`.

- [x] M8.7 Smoke coverage: create a linear draft chain, rerun a prose-advancing step from
  an earlier draft, verify the new draft becomes active, verify old downstream drafts
  remain on disk but are superseded, and verify report steps read the new active head.

Notes: This milestone replaces the archive-on-redo idea from the old M7. Amanuensis
does not move backward. It creates a new version from selected inputs and records which
draft lineage is now active.

Sprint 13 plans M8 (see SPRINT.md). Locked there: the active head is a top-of-manifest
`Active-head: draft-vNN.md` pointer (parallel to the `Reviewed-draft:` stamp), and
`<latest-draft>` resolves to it — falling back to the highest-numbered draft when no
pointer exists, so existing projects need no migration. `<latest-draft>` (the read
pointer) and `<next-draft>` (highest existing draft number + 1, kept monotonic) decouple.
Branch selection is an owner decision: a read-from argument on `run-step`
(`run-step <step_id> from <draft-vNN>`) that overrides which draft `<latest-draft>`
resolves to for that one invocation; `next-step` never branches. On a branch (read-from ≠
active head) the prose-advancing step writes `<next-draft>`, repoints `Active-head`, and
stamps each displaced active-lineage draft `superseded_by: <next-draft>`; abandonment is
derived from that stamp, not a separate field, and a linear advance supersedes nothing.
The M8.1 design note and the lineage/supersession algorithm land in
`agents/project-layouts.md` (the doc that owns the manifest); `orchestrator.md`'s
Execution-model terms are updated to match and cross-reference it. The report→fix
freshness invariant keeps its filename-comparison mechanics unchanged — with active-head
resolution, a report stamped against an abandoned draft is correctly stale, and stamp
filename plus the manifest's `read_from` chain identifies which lineage a stale artifact
belongs to.

---

## M9 — Stale artifacts and review gates

Make arbitrary step execution safe by tracking whether side artifacts are fresh,
stale, reviewed, pending review, superseded, or explicitly overridden.

Done when: side artifacts generated from prose identify the draft they reviewed;
fix/apply steps refuse stale artifacts by default; review-required artifacts carry
an explicit review status or equivalent human-acknowledgment marker; the dispatcher
and step bodies consistently block, warn, or proceed according to declared rules.

* [x] M9.1 Design note: define side-artifact state. Terms to settle:
  `fresh`, `stale`, `review_pending`, `reviewed`, `override`, `discarded`,
  and `regenerated`.

* [x] M9.2 Standardize freshness stamps for prose-derived side artifacts. Existing
  `Reviewed-draft:` behavior becomes the common pattern for reports, annotations,
  metaphor findings, anti-AI findings, and similar artifacts.

* [x] M9.3 Standardize review markers for artifacts produced by `review_required: true`
  steps. Decide whether review state lives in the artifact itself, in a manifest, or
  in the recipe/status file.

* [x] M9.4 Update fix/apply steps to check both freshness and review state before
  consuming side artifacts. On mismatch, append a clear blocker to `open-questions.md`
  and exit without modifying prose.

* [x] M9.5 Define explicit override behavior. Overrides must be human-visible,
  source-specific, and recorded in the relevant artifact or manifest. No stale apply
  should happen silently.

* [ ] M9.6 Update the dispatcher to surface stale/review blockers before loading the
  requested step body when the precondition is machine-checkable. **Deferred out of
  Sprint 14** to a follow-on: the checks stay in the step bodies until the state model
  proves out (see the Sprint-14 note below and the Deferred list).

* [x] M9.7 Smoke coverage: verify stale report detection, reviewed-artifact detection,
  pending-review blocking or warning behavior, regeneration of a stale report against
  the active draft, and explicit override recording.

Notes: M9 generalizes the report→fix adjacency invariant into an artifact-freshness
model. The old adjacency rule remains valid as a special case, but the framework no
longer depends on global step order to protect fix/apply steps.

Sprint 14 plans M9 (see SPRINT.md). Locked there: staleness is a **derived predicate**
(`Reviewed-draft:` stamp = manifest `Active-head:` → fresh, else stale), computed by the
consuming step at step start and never stored or swept — no update walks every artifact
(the owner decision; it applies M8's derived-`abandoned` precedent to the whole model).
Review is **surfaced, not enforced**: `review_sensitive`/`review_gate` remain the
declaration, annotation is the review evidence for the four reports, consumption emits a
non-blocking notice, and the only hard review block is the pre-existing unannotated-report
path. The design note lands in `agents/orchestrator.md` (which owns the freshness invariant
and execution-model vocabulary), generalizing the report→fix invariant into a single
**Artifact state** section that keeps the invariant verbatim as its named special case and
adds the terms `fresh`/`review_pending`/`reviewed`/`override`/`discarded`/`regenerated`.
No new frontmatter or manifest field: override is recorded in the consuming step's apply
log; `discarded`/`regenerated` name behavior that already ships. The one new step-body
behavior is an explicit recorded-override branch in the four fix/apply steps. M9.6
(dispatcher lift) is deferred so the model proves out in step bodies first; Sprint 14
delivers M9.1–M9.5 and M9.7.

---

## M10 — Agent-addressable review: shared contract + compliance slice

### Goal

First of four milestones (M10–M13) delivering **agent-addressable human review**: the four human-gated review artifact families are retargeted from human-only markdown to structured markdown an agent can address, count, and validate, and an agent-assisted **review companion** makes working through them fast, auditable, resumable, and visibly finite.

The companion is **not** a checker, fixer, or decider. It is the human-decision capture layer and progress ledger over structured review artifacts. Most review decisions are irreducibly human; the problem is that the work is not ergonomic or visibly finite. The value is not that the agent decides more — it is that the human decides faster, safer, and with visible progress toward done:

```text
identify/report → human decision capture + progress ledger → fix/apply
```

M10 lands the shared contract — grammar file, validator script, fixtures, companion skill — and migrates the crispest artifact family (compliance) end-to-end. M11 (anti-AI), M12 (prose pass), and M13 (metaphors) migrate the remaining families against that proven contract, one milestone per sprint. Each slice is a big-bang migration for its family: once a family is migrated, its old human-only annotation format is an invalid input and no compatibility path is kept.

Done when: `agents/review-grammars.yaml`, `scripts/validate-review-artifact.sh`, and `agents/review-validation.md` exist as the single-source contract covering all four families; the compliance family round-trips — `compliance_report` emits structured review items, the human (companion-assisted) records decisions into explicit fields by `review-id`, and `compliance_fix` consumes those decisions via the shared validator; progress counts are accurate; and a human can stop mid-review and later resume from accurate remaining counts.

### Shared design (governs M10–M13)

1. **Human decisions remain human.** The companion may recommend actions, explain tradeoffs, and batch presentation. It must not silently make editorial decisions except where the artifact grammar explicitly permits mechanical bulk handling.
2. **The report/identify step surfaces findings; the companion captures decisions; the fix/apply step changes prose.** The companion never becomes the checker or the fixer.
3. **A field is a promise; a position is only a hope.** Every review item carries an embedded HTML-comment anchor (`<!-- review-id: ... -->`) plus explicit `- Decision:` / `- Decision-note:` fields. No positional annotation conventions ("insert below the flag line").
4. **Progress must be countable.** Blank decision fields mean pending; filled decision fields mean adjudicated. Accepted and unreviewed items must never look identical at the review-unit level.
5. **Category-level decisions are capture behavior, not artifact grammar.** *(Revised in Sprint 16 planning; formerly header bulk, anti-AI only.)* Where the grammar declares a category fan-out-eligible, the human may state one decision for the whole category and the companion writes it into every pending unit's `Decision:` field, each marked with an audit note. The artifact carries no bulk grammar: blank means pending in every family with no exceptions, and a `BULK:` header is invalid input.
6. **Grammars are artifact-specific and single-sourced** in `agents/review-grammars.yaml`. The parser, validator, companion, and fix/apply steps consume the same contract; step docs reference it rather than restating token sets in prose.
7. **Fan-out eligibility is static and single-sourced in the grammar file.** *(Revised in Sprint 16 planning; formerly a static-grammar/dynamic-report-declaration split.)* The per-report `BULK eligibility:` declaration was retired with the header grammar: the report emitted the same fixed list every run, restating static knowledge the grammar file owns. No family currently defines per-report review permissions.
8. **Structured markdown remains the primary artifact** — readable, hand-editable, Git-diff-friendly. No JSON sidecars as source of truth.
9. **IDs are stable within a reviewed-draft epoch, not across regenerations.** A `review-id` only needs to be stable for the report generated against its `Reviewed-draft:` stamp; regeneration discards prior findings (existing contract) and may regenerate IDs.

Target grammar per artifact — the full machine-readable definition lives in `agents/review-grammars.yaml` once M10.1 lands; this table is the summary:

| Artifact              | Producer            | Consumer                         | Review Unit                                                          | Legal Decisions                                                                                                                          | Blank Means                                         | Bulk Legal?                                                                                     | Notes                                                                                                                                        |
| --------------------- | ------------------- | -------------------------------- | -------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- | ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `reviewer-actions.md` | `compliance_report` | `compliance_fix`                 | Per violation                                                        | `FIX`, `FIX: <instruction>`, `SKIP`, `ESCALATE`                                                                                          | Pending / review evidence missing                   | No generic bulk                                                                                 | Crispest grammar; migrated first (M10). `CLEAN` blocks require no action and are not review units.                                           |
| `prose-pass.md`       | `prose_pass`        | `prose_fix`                      | Per finding                                                          | `FIX`, `FIX: <instruction>`, `SKIP`, `ESCALATE`                                                                                          | Pending for non-`KEEP` findings                     | No                                                                                              | `KEEP` recommendations are treated as `SKIP`; actionable non-`KEEP` findings require explicit per-entry decisions. Migrated in M12.          |
| `anti-ai.md`          | `anti_ai_report`    | `anti_ai_fix`                    | Per flagged instance                                                  | `FIX`, `FIX: <instruction>`, `SKIP`, `ESCALATE`                                                                                          | Pending                                             | No — category fan-out is companion capture, not artifact grammar (revised Sprint 16)            | Fan-out-eligible categories and recommended defaults are declared in the grammar file; a `BULK:` header is invalid input. Migrated in M11.   |
| `metaphors.md`        | `metaphor_identify` | `metaphor_fix`, `metaphor_apply` | Per metaphor entry                                                   | `KEEP`, `REJECT`, `FLATTEN`, `REPLACE: <image>`, `WORKSHOP`                                                                              | Pending                                             | No                                                                                              | Replaces delete-as-rejection with `Decision: REJECT` so the file remains an audit record and progress is countable. Migrated in M13.         |

Freshness, review, and override stay governed by `agents/orchestrator.md`'s Artifact-state contract; M10–M13 change none of its mechanics. For a migrated family, the structured decision fields *are* the review evidence: a blank `Decision:` is `review_pending`, and override remains stale-axis-only and anchor-gated.

### Tasks

- [x] M10.1 `agents/review-grammars.yaml`: machine-readable grammar definitions for all four families — per artifact: producer/consumer steps, artifact path pattern, review item shape, anchor pattern, legal decision tokens, payload requirements, blank-means semantics, bulk rules (static support + dynamic declaration requirement + header grammar), progress-counting rules, what constitutes review evidence, and what state lets the consumer proceed — with a per-family adoption marker (compliance `adopted` in M10; the other three defined here but `pending` until their milestone). Locks the bare-`REPLACE` policy: `REPLACE` requires a non-empty image payload; bare `REPLACE` is invalid and `WORKSHOP` is the ask-for-candidates path.
- [x] M10.2 `scripts/validate-review-artifact.sh` + `agents/review-validation.md`: a read-only validator script (parse review units; validate state, structure, and grammar with token lists read from `review-grammars.yaml`, never hardcoded; print the progress ledger — total / pending / decided / inherited-by-bulk / skipped / escalated / invalid / stale; exit with a distinct proceed / pending / invalid / stale code) plus the thin interpretation contract the companion and fix/apply steps of migrated families follow — when to run the script, how to act on its output, and what remains agentic judgment.
- [x] M10.3 Fixture examples of all four target formats under `examples/review/`, exercising each grammar's distinctive cases (compliance CLEAN vs violation; anti-AI bulk and non-bulk categories; prose-pass KEEP handling; metaphor decision tokens).
- [x] M10.4 Retarget `compliance_report` to emit structured review items: a `review-id` anchor plus `Decision:` / `Decision-note:` fields per violation; `CLEAN` blocks are not review units and carry no anchor or fields.
- [x] M10.5 Retarget `compliance_fix` to consume explicit `Decision:` fields via the shared validator (blank decision = `review_pending`; positional annotations are no longer valid input; stale/override behavior unchanged).
- [x] M10.6 `amanuensis-review` Claude Code skill, installed by `install.sh` into consuming projects: identify artifact, load grammar, validate, show progress counts, present pending units as a queue, explain legal decisions, capture and write decisions by `review-id`, support pacing controls. Compliance support in this milestone.
- [x] M10.7 Smoke coverage: compliance round-trip (structured report → decisions → fix consumes), blank-decision `review_pending` block, progress counts, resume mid-review; existing compliance-format recipes updated to the structured format.

Notes: Sprint 15 plans M10 (see SPRINT.md). Locked there: the validator is a **deterministic script** (`scripts/validate-review-artifact.sh`) with a thin agentic interpretation contract (`agents/review-validation.md`) — an agentic prose procedure was chosen first and flipped after discussion (owner decision: the ledger counts and the proceed/block verdict are the two things that must never be wrong, and LLM counting is the design's weakest point; strictness is a feature since `invalid` is a reported state and the companion writes canonical format; the grammar YAML stays the single source — the script reads its token lists from it; the agentic fallback is on the Deferred list if the script proves too rigid). The companion ships as a **Claude Code skill**, not a host command pair (owner decision: conversational activation wins over host parity; OpenCode parity is on the Deferred list). The roadmap was restructured to one milestone per sprint (owner decision), splitting the former monolithic M10 into M10–M13 and renumbering reverse ingestion to M14. Shipped in Sprint 15 as planned, with one addition found in verification: the validator detects a pre-M10 positional report (violation blocks with no anchors) as structurally invalid via per-family container-pattern keys in `review-grammars.yaml`, so an old-format report can never pass as zero-units/proceed.

---

## Deferred

- dispatcher-level staleness/review lift (M9.6) — surface stale/review blockers before
  loading the step body; deferred out of Sprint 14 until the step-body state model proves out
- OpenCode parity for the `amanuensis-review` companion skill — M10.6 ships Claude Code
  only (owner decision, Sprint 15); revisit once the skill's contract is stable
- consumer-side CI lift for review-artifact validation — wire
  `scripts/validate-review-artifact.sh` into the installed CI workflow once the
  compliance slice proves out (M10 ships it agent-run only)
- agentic fallback for review-artifact validation — if the strict script proves too
  rigid against hand-edited artifacts in practice, front it with an agent-followed
  procedure (Sprint 15 chose the script; owner decision)
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
