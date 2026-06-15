# Amanuensis Roadmap

Remaining work, in rough dependency order. Tasks plus short notes on what's done.
Project overview, architecture, and current status live elsewhere.

Several milestones edit the canonical step list (`templates/pipeline-state.md`); they
are sequenced, not parallel, so it is never edited by two at once.

---

## M1 — Pipeline step-list consistency

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

## M2 — Drafting artifact cleanup

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

## M3 — Bounded canon invention + capture

Replace the blanket "do not invent canon" with one bounded rule; resolve the
`orchestrator.md` TODO; add a coordinator-managed **capture agent** that records the
continuity-relevant inventions the rule permits into the right canonical files.

Done when: a single statement of the rule exists and is referenced from the step
bodies; the contradictory TODO is gone; the drafting coordinator dispatches a capture
agent that writes permitted inventions to `timeline.md` / `profile.md` / an
agent-generated `canon/` subfolder (never `knowledge/`), with annotated, edit-policy-
respecting, non-blocking writes, at parity on both hosts.

### The rule

- [x] M3.1 Write the rule (in `canon.md` or `update-rules.md`): invent only when canon
  and plan are silent, it cannot contradict existing canon, it fits genre/register/period,
  and it is not load-bearing for reveal timing or character knowledge; otherwise record an
  open question.
- [x] M3.2 Reference it from `drafting.md`, `scene-generation.md`,
  `character-extraction.md`, `storyboarding.md`, `update-rules.md`; keep the hard
  prohibition for reveal- and knowledge-load-bearing facts.
- [x] M3.3 Resolve the `orchestrator.md` invention TODO.

### The capture agent

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

## M4 — Versioned draft naming

Decouple prose-bearing draft filenames from the producing step so prose-chain reordering
is a `pipeline-state.md`-only edit. Prerequisite for M5 and M7.

Done when: prose-advancing steps read `<latest-draft>` and write the next version; report
steps read `<latest-draft>` and do not increment; provenance is recorded; side-artifacts
keep their step names; the report→fix adjacency invariant is documented.

- [ ] M4.1 Define `<latest-draft>` resolution (highest-numbered `draft-vNN.md` in the
  attempt), parallel to `<latest-attempt>`. Drafting produces `draft-v01.md`.
- [ ] M4.2 Convert prose-advancing steps (`drafting`, `compliance_fix`, `metaphor_apply`,
  `line_pass`, `anti_ai_fix`) to write `<next-draft>`; convert prose-reading steps
  (`compliance_report`, `prose_pass`, `metaphor_identify`, `metaphor_fix`,
  `anti_ai_report`) to read `<latest-draft>`.
- [ ] M4.3 Add provenance to each draft version (frontmatter stamp `produced_by` / `reads`,
  or an attempt-level manifest). This is also the "which draft did this come from" stamp that
  M3.7's capture annotations reference — define it so a captured invention can name its source
  draft version.
- [ ] M4.4 Document the report→fix adjacency invariant: no draft increment between a report
  and its paired fix.
- [ ] M4.5 Sweep the rename through docs that hard-code `draft.md` (`chapters.md`,
  `project-layouts.md`, schema examples) and the canonical state list.

Notes: side-artifacts (`reviewer-actions.md`, `metaphors.md`, `anti-ai.md`,
`prose-pass.md`) stay step-named; only prose-bearing files are versioned.

---

## M5 — Prose fix apply step

Close the prose-apply orphan: `prose_pass` recommendations get applied into the versioned
draft the metaphor stage reads. Depends on M4.

Done when: `prose_fix` reads annotated `prose-pass.md` + `<latest-draft>` and writes the
next draft version; `prose_pass` output carries an annotation grammar; the metaphor stage
consumes the prose-applied draft.

- [ ] M5.1 Add `FIX` / `FIX: <instruction>` / `SKIP` / `ESCALATE` annotation grammar (and
  optional per-category bulk headers) to `prose-pass.md`, keyed off the existing
  KEEP/TIGHTEN/FLATTEN/REWRITE labels.
- [ ] M5.2 Decide and record the apply strategy. Default candidate: chunked, like
  `line_pass` — REWRITE is paragraph-scale, TIGHTEN/FLATTEN local.
- [ ] M5.3 Write `agents/steps/prose-fix.md` (inputs: annotated `prose-pass.md`,
  `<latest-draft>`, voice; output: next draft version + apply log). `review_required: false`.
- [ ] M5.4 Insert `prose_fix` after `prose_pass` in the canonical step list.

Notes: with M4 done, the metaphor steps already read `<latest-draft>`, so no input
rewiring is needed.

---

## M6 — Storyboard reader-reveal coverage

Storyboards declare what the reader must understand, not only what is concealed; an
advisory review pass flags under-communication. Order-independent of M4/M5.

Done when: the schema has a reader-takeaway field; `storyboarding` populates it;
`storyboard_review` flags beats whose takeaway is unsupported or whose reveals lack prior
setup; it sits between storyboarding and drafting.

- [ ] M6.1 Add a reader-takeaway field to `storyboard-schema.md` (distinct from
  `concealment_from_reader` and `must_preserve`), held to the spec-not-prose discipline.
- [ ] M6.2 Update `storyboarding.md` to populate it; make an empty field a default-to-fill
  anti-pattern.
- [ ] M6.3 Write `agents/steps/storyboard-review.md` (advisory, report-only): check each
  beat's takeaway is carried and that dependent beats have prior setup.
- [ ] M6.4 Insert `storyboard_review` between `storyboarding` and `drafting` in the
  canonical list.

Notes: a `storyboard_review_fix` apply step and the cross-chapter reveals ledger are
deferred.

---

## M7 — Dispatcher rework: forward / back / redo with archiving

Replace linear `next-step` with directional control; redo archives prior draft versions
and surfaces downstream staleness. Design-gated. Builds on M4's version counter.

Done when: design note approved; human can advance, step back, and redo a specific step;
redo archives versions above the redone step and flags them stale; `orchestrator.md`
documents the model; both hosts at parity; the smoke fixture exercises a redo.

- [ ] M7.1 Design note (blocking). Resolve: skill granularity (one parameterized dispatcher
  vs per-step skills); backward semantics (marker-only vs restore archived versions);
  archive location vs the `attemptNN` convention (mid-pipeline redo must not re-run
  drafting); downstream-staleness rule (everything with version > N is stale — reset
  markers / archive / warn?); review-gate behavior under back and redo.
- [ ] M7.2 Update `orchestrator.md` to the directional model (absorbs the deferred
  pass-interaction question).
- [ ] M7.3 Implement per-step invocation.
- [ ] M7.4 Implement archive-on-redo over the version counter.
- [ ] M7.5 Host parity (`.claude` + `.opencode`).
- [ ] M7.6 Extend the smoke recipe: advance -> redo -> verify archive, on both hosts.

Notes: —

---

## M8 — Reverse ingestion: existing prose into Amanuensis

Ingest a finished work into Amanuensis artifacts (characters, scene-list, storyboards,
overview), chunked to fit context. Design-gated.

Done when: a single existing chapter or short story ingests into a valid project structure
that the forward pipeline's downstream steps can consume.

- [ ] M8.1 Design note (blocking): reverse pipeline steps (candidates: prose_chunking,
  character_extraction_from_prose, scene_reconstruction, storyboard_reconstruction,
  overview_synthesis); chunking strategy that preserves cross-chunk continuity;
  reconciliation against existing canon.
- [ ] M8.2+ Implementation tasks opened from the approved design note.

Notes: —

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
