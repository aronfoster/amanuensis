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

- [ ] M1.1 Propagate the `anti_ai_report`/`anti_ai_fix` split into
  `examples/smoke/pipeline-state.md`, the `orchestrator.md` state example, and any
  README references still showing monolithic `anti_ai`.
- [ ] M1.2 Make `templates/pipeline-state.md` canonical; point `orchestrator.md` at it
  rather than re-listing; add a check that the smoke fixture's step set matches.
- [ ] M1.3 Replace any other hard-coded step lists (README, `workflows.md`, adapter
  template) with references.

Notes: —

---

## M2 — Drafting artifact cleanup

Delete per-scene fragments after assembly; align the step body with the OpenCode
coordinator.

Done when: a drafting run leaves `draft.md` and `notes.md` only; `sceneNN.md` /
`sceneNN-notes.md` removed; `drafting.md` frontmatter no longer lists them as durable
outputs.

- [ ] M2.1 Add post-assembly deletion of `sceneNN.md` / `sceneNN-notes.md` to
  `drafting.md`, mirroring `opencode/agents/chapter-coordinator.md`.
- [ ] M2.2 Reconcile `drafting.md` frontmatter: drop the per-scene fragments from
  durable outputs or mark them transient.
- [ ] M2.3 Document the audit-record vs transient-fragment distinction (persist
  `reviewer-actions.md`, `metaphors.md`, `anti-ai.md`, `notes.md`; delete scene fragments).

Notes: —

---

## M3 — Bounded canon invention

Replace the blanket "do not invent canon" with one bounded rule; resolve the
`orchestrator.md` TODO.

Done when: a single statement of the rule exists and is referenced from the step
bodies; the contradictory TODO is gone.

- [ ] M3.1 Write the rule (in `canon.md` or `update-rules.md`): invent only when canon
  and plan are silent, it cannot contradict existing canon, it fits genre/register/period,
  and it is not load-bearing for reveal timing or character knowledge; otherwise record an
  open question.
- [ ] M3.2 Reference it from `drafting.md`, `scene-generation.md`,
  `character-extraction.md`, `storyboarding.md`, `update-rules.md`; keep the hard
  prohibition for reveal- and knowledge-load-bearing facts.
- [ ] M3.3 Resolve the `orchestrator.md` invention TODO.

Notes: —

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
  or an attempt-level manifest).
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
