# Sprint 7 — Milestone 2: Drafting artifact cleanup

This Sprint makes a drafting run leave only durable artifacts behind. The
Claude-side step body (`agents/steps/drafting.md`) is brought to parity with the
OpenCode coordinator (`opencode/agents/chapter-coordinator.md`), which already
deletes the per-scene working files after assembly. After this Sprint, a completed
drafting attempt folder contains `draft.md` and `notes.md` only; the per-scene
`sceneNN.md` / `sceneNN-notes.md` fragments are deleted once their content has been
folded into those two combined files. The frontmatter and Outputs section of
`drafting.md` stop advertising the scene fragments as durable outputs, and a single
place in the docs (`agents/chapters.md`) records why some per-attempt files persist
as audit records while the scene fragments are transient.

This is a documentation/prose-contract milestone: every change edits a Markdown step
body or support doc. No code, no scripts, no schema changes. The step bodies are run
by an LLM coordinator, so "a run leaves draft.md and notes.md only" is enforced by
the instructions the coordinator follows, not by an executable test; acceptance is by
inspection of those instructions plus grep invariants on the frontmatter.

## Background — what is and isn't wrong today

Established by inspection during planning; tasks should not re-derive this:

- `opencode/agents/chapter-coordinator.md:35` is **already correct**: it instructs
  the coordinator to "Delete the scene-drafter's scene and notes files once their
  entire contents are in the chapter draft and notes files." This is the reference
  behavior the Claude-side step is being brought up to. Its only gap is that it does
  not point at the persist-vs-delete rationale; Task 3 adds a one-line pointer for
  host symmetry.
- `agents/steps/drafting.md` is the file that **lags**. Three things are wrong:
  - Frontmatter `outputs:` (lines 7–11) lists `scene01.md` and `scene01-notes.md`
    as durable outputs alongside `draft.md` and `notes.md`.
  - The Behavior section assembles `draft.md` (step 7, Assembly rules) and `notes.md`
    (step 8, Notes assembly) but **never deletes** the scene fragments afterward.
  - The Outputs section (lines 158–163) documents `sceneNN.md` / `sceneNN-notes.md`
    as outputs ("Working artifacts the coordinator reads during assembly").
- **Deletion is safe by construction.** `draft.md` already absorbs all scene prose
  (Assembly rules) and `notes.md` already absorbs every per-scene notes file, broken
  out by scene (Notes assembly). So by the time the fragments are deleted, their
  entire content is captured in a durable combined file. The deletion is gated on
  that capture — it is not unconditional.
- **Drafting is the only step that produces transient fragment files.** The other
  coordinator step, `metaphor_fix`, has its subagents append in place into
  `metaphors.md`; it writes no per-entry fragment files. So this milestone's cleanup
  is scoped entirely to the drafting step; no other step body produces orphan
  fragments to reconcile.
- `agents/chapters.md:57` already describes the per-attempt working artifacts under
  `drafts/attemptNN/` (reviewer reports, compliance and prose-pass outputs, metaphor
  working files, line-pass and anti-AI outputs). This is the natural and only home
  for the audit-record-vs-transient-fragment distinction (Task 2); no new doc is
  created.
- `agents/project-layouts.md` shows only `draft.md` in its folder trees, never the
  scene fragments, so it needs **no** edit. Verify, don't rewrite.

## Definition of done

The Sprint is complete when:

1. ROADMAP.md tasks M2.1, M2.2, and M2.3 are checked.
2. `agents/steps/drafting.md` frontmatter `outputs:` lists **only**
   `<chapter-folder>/drafts/<latest-attempt>/draft.md` and
   `<chapter-folder>/drafts/<latest-attempt>/notes.md`. The `scene01.md` and
   `scene01-notes.md` lines are gone.
3. `agents/steps/drafting.md` Behavior section contains an explicit post-assembly
   deletion step: after `draft.md` and `notes.md` are assembled, the coordinator
   deletes each `sceneNN.md` and `sceneNN-notes.md`, gated on its content already
   being captured in `draft.md` / `notes.md`. The deletion is suppressed on the
   failure paths (blocker recorded, assembly not completed).
4. `agents/steps/drafting.md` Outputs section no longer presents the scene fragments
   as durable outputs; it documents `draft.md` and `notes.md` as the durable outputs
   and describes the scene fragments (in prose, not as an outputs entry) as transient
   working files created during the run and deleted after assembly.
5. `agents/chapters.md` records the audit-record-vs-transient-fragment distinction:
   `notes.md`, `reviewer-actions.md`, `metaphors.md`, and `anti-ai.md` persist as
   per-attempt records; the per-scene `sceneNN.md` / `sceneNN-notes.md` fragments are
   transient and deleted after assembly because their content is captured in the
   combined files.
6. `opencode/agents/chapter-coordinator.md` still instructs deletion and now points
   at the same persist-vs-delete distinction, so the two hosts describe the same
   contract. Its existing safety condition ("once their entire contents are in the
   chapter draft and notes files") is preserved.
7. A drafting attempt folder, after a run that follows the updated `drafting.md`,
   would contain `draft.md` and `notes.md` only — confirmed by reading the step body,
   since the step is LLM-run and has no executable harness.

## Conventions adopted by this Sprint

Locked at the start so individual tasks don't rediscover them.

**Durable vs transient.** A per-attempt file is **durable** (an audit record) if it
is the only place its content lives and a human or downstream step may need it later:
`draft.md`, `notes.md`, and the later-stage records `reviewer-actions.md`,
`metaphors.md`, `anti-ai.md`. A file is **transient** if its entire content is folded
into a durable combined file during the same step: the per-scene `sceneNN.md` and
`sceneNN-notes.md` fragments. Transient files are deleted after assembly; durable
files are never deleted by the step that writes them.

**Deletion is gated, not unconditional.** The coordinator deletes a scene fragment
only after confirming its content is present in the durable combined file
(`sceneNN.md` → `draft.md`, `sceneNN-notes.md` → `notes.md`). On any failure path —
a subagent reports a blocker, assembly does not complete, a scene file is missing —
the fragments are **not** deleted and the blocker is recorded in `notes.md`, matching
the step's existing failure handling. This preserves the working files for diagnosis
when a run cannot complete.

**`outputs:` means durable outputs.** Per `agents/orchestrator.md`, frontmatter is
descriptive, not enforced. This Sprint adopts the reading that `outputs:` lists the
**durable** artifacts a step leaves behind. Transient working files are described in
the body, not listed in `outputs:`. No new frontmatter field is introduced; the
orchestrator frontmatter contract is unchanged.

**Reference direction.** `opencode/agents/chapter-coordinator.md` is the behavioral
reference (it already deletes). `agents/steps/drafting.md` is brought up to it. The
OpenCode file changes only by gaining a pointer to the shared persist-vs-delete rule
(Task 3); its deletion instruction and safety condition are not rewritten.

**Single documentation home.** The persist-vs-delete distinction is documented once,
in `agents/chapters.md`, next to the existing per-attempt artifacts description. Step
bodies and the OpenCode coordinator may reference it but do not restate the full list.

**Scope.** This Sprint edits `agents/steps/drafting.md`, `agents/chapters.md`,
`opencode/agents/chapter-coordinator.md`, `ROADMAP.md`, and this Sprint file. It does
**not** change scene-drafter prompt files, `project-layouts.md`, any other step body,
the storyboard schema, or any script. No file is renamed.

---

## Tasks

### Task 1 — Delete scene fragments after assembly; reconcile `drafting.md` frontmatter and Outputs [ ]

**Goal.** Bring `agents/steps/drafting.md` to parity with the OpenCode coordinator:
the run deletes the per-scene fragments after assembly, and the file stops advertising
them as durable outputs. Closes **M2.1** and **M2.2**. All edits are within this one
file so a single developer owns it end to end.

**Requirements.**

- **Frontmatter (M2.2).** In the `outputs:` block, remove the
  `<chapter-folder>/drafts/<latest-attempt>/scene01.md` and
  `<chapter-folder>/drafts/<latest-attempt>/scene01-notes.md` lines. After the edit,
  `outputs:` lists exactly `draft.md` and `notes.md` (with their full
  `<chapter-folder>/drafts/<latest-attempt>/` paths). Do not add a new frontmatter
  key for the fragments — they are described in the body, not the frontmatter.
- **Behavior — add the deletion step (M2.1).** After the existing Notes-assembly step
  (currently step 8 in "Coordinator responsibilities"), add a step that deletes each
  `sceneNN.md` and `sceneNN-notes.md` from `<chapter-folder>/drafts/<latest-attempt>/`
  once its content is captured: the scene prose is in `draft.md` and the scene notes
  are in `notes.md`. Mirror the OpenCode wording — deletion happens "once their entire
  contents are in the chapter draft and notes files." State the gate explicitly so a
  reader cannot read it as an unconditional `rm`.
- **Behavior — guard the failure paths.** Make clear (in the new deletion step and/or
  the existing "Failure handling" / "Safety rules" subsections) that the fragments are
  **not** deleted when the run cannot complete assembly — e.g. a subagent reports a
  blocker, a scene file is missing, or assembly is abandoned. On those paths the
  fragments are preserved and the blocker is recorded in `notes.md`, consistent with
  the step's existing failure handling. The Open-questions exit path (no `draft.md`
  written) likewise performs no deletion.
- **Outputs section.** Rewrite the Outputs list so `draft.md` and `notes.md` are the
  durable outputs. Remove the `sceneNN.md` and `sceneNN-notes.md` bullets as durable
  outputs; instead add a short prose line (in the Outputs section or the deletion
  step) noting they are transient working files written by subagents during the run
  and deleted after assembly, so they are not part of the durable output set. Do not
  delete the Behavior-section references to subagents *writing* `sceneNN.md` /
  `sceneNN-notes.md` (steps 5–6 and the subagent contract) — those files are still
  created transiently; only their status as durable outputs changes.
- Keep all other prose intact: scene grouping, subagent contract, assembly rules,
  notes assembly format, out-of-scope, and open-questions handling are unchanged.

**Done when.** `drafting.md` frontmatter `outputs:` names only `draft.md` and
`notes.md`; the Behavior section has an explicit, capture-gated deletion step for the
scene fragments with the failure paths excluded; and the Outputs section presents
`draft.md` / `notes.md` as durable while describing the fragments as transient.

---

### Task 2 — Document the audit-record vs transient-fragment distinction in `chapters.md` [ ]

**Goal.** Record, in one place, why some per-attempt files persist and the scene
fragments do not. Closes **M2.3**.

**Requirements.**

- Edit `agents/chapters.md`, at or near the existing per-attempt artifacts
  description (the `draft.md` section, around line 57, which already enumerates the
  working files under `drafts/attemptNN/`). Add a short, clearly-scoped passage that:
  - States that some per-attempt files are **durable audit records** kept for human
    review and downstream steps: `notes.md` (the run record), and the later-stage
    review/report files `reviewer-actions.md`, `metaphors.md`, and `anti-ai.md`,
    alongside the prose `draft.md`.
  - States that the per-scene `sceneNN.md` / `sceneNN-notes.md` fragments are
    **transient**: their entire content is folded into `draft.md` and `notes.md`
    during the drafting step, and they are deleted after assembly. The general rule:
    a working file is deletable once its content is captured in a durable combined
    artifact.
- Keep it brief and consistent with the file's existing tone — a few sentences or a
  short list, not a new top-level section unless that reads more naturally. Do not
  restate the drafting step's full behavior; this is the rationale, the step body is
  the procedure.
- Do not edit `project-layouts.md` (its trees show only `draft.md` and are correct).

**Done when.** `agents/chapters.md` names the persisted set (`notes.md`,
`reviewer-actions.md`, `metaphors.md`, `anti-ai.md`, plus `draft.md`) as durable
records and the scene fragments as transient-deleted-after-assembly, with the
capture-based rule stated once.

---

### Task 3 — Point the OpenCode coordinator at the shared rule [ ]

**Goal.** Keep the two hosts describing the same contract without rewriting the
OpenCode coordinator's already-correct deletion instruction.

**Requirements.**

- In `opencode/agents/chapter-coordinator.md`, preserve the existing deletion bullet
  and its safety condition ("Delete the scene-drafter's scene and notes files once
  their entire contents are in the chapter draft and notes files").
- Add a brief pointer making the persist-vs-delete intent explicit and consistent
  with Task 2: the scene and notes fragments are transient and deleted after
  assembly, while the chapter draft and run notes (and later review/report files)
  persist. A one-line reference to the distinction documented in the Amanuensis
  `chapters.md` (reached via the project's workflow paths, the same way this file
  already references `update-rules.md` / `agentic-drafting.md`) is sufficient — do not
  inline the full persist list into this host file.
- Make no other behavioral change to the coordinator (scene grouping, attempt-folder
  creation, dispatch, assembly, the `wc` word-count report all stay).

**Done when.** `chapter-coordinator.md` still instructs gated deletion and now points
at the shared persist-vs-delete distinction, matching the Claude-side step and
`chapters.md`.

---

### Task 4 — Verification sweep, ROADMAP, closeout [ ]

**Goal.** Confirm the milestone's "done when" holds, update the catalogs, and check
the boxes. Depends on Tasks 1–3.

**Requirements.**

- **Frontmatter invariant.** Confirm `agents/steps/drafting.md`'s `outputs:` block
  contains no `scene` line (e.g. `git grep -n "scene01" -- agents/steps/drafting.md`
  returns only legitimate Behavior/contract references to subagents writing or the
  coordinator deleting `sceneNN.md` / `sceneNN-notes.md`, and **nothing** inside the
  frontmatter `outputs:` block). Read the frontmatter by eye to confirm only
  `draft.md` and `notes.md` remain.
- **Behavioral read-through.** Read the updated `drafting.md` Behavior and Outputs
  sections and confirm a faithful run would leave `draft.md` and `notes.md` only, with
  deletion gated on capture and suppressed on failure paths. This is the acceptance
  for an LLM-run step — there is no executable harness.
- **Host parity check.** Confirm `drafting.md`, `chapter-coordinator.md`, and
  `chapters.md` agree: same deletion behavior, same safety condition, same
  persist-vs-delete framing, no contradiction.
- **Sweep.** `git grep -n "scene01\|scene02\|sceneNN" -- '*.md'` across the repo;
  confirm no remaining file lists the scene fragments as durable outputs or as
  expected persisted artifacts. Background says drafting.md is the only such file; if
  the sweep turns up another (it shouldn't), reconcile it the same way. Record what
  the sweep found in the commit message.
- **ROADMAP.md.** Check M2.1, M2.2, and M2.3. Optionally add a one-line Note that the
  OpenCode coordinator was also pointed at the shared rule for host parity. Do not
  edit other milestones.
- **Sprint file.** Mark each completed task in this file as `[x]`.

**Done when.** The frontmatter invariant holds, the step body reads as
draft.md-and-notes.md-only with gated deletion, the three files agree, ROADMAP
M2.1–M2.3 are checked, and all Sprint tasks are checked.

---

## Out of scope for this Sprint

- Any change to scene-drafter prompt files (`opencode/agents/scene-drafter.md`,
  `scene-drafter-opus.md`). They still write `sceneNN.md` / `sceneNN-notes.md`; only
  the coordinator's post-assembly handling of those files changes.
- Versioned draft naming (`draft-vNN.md`) and the prose-chain rework — that is
  Milestone 4. This Sprint keeps the single `draft.md` per attempt.
- Editing `project-layouts.md` or the folder-tree examples (they already show only
  `draft.md`).
- Adding an executable check that a run left only `draft.md` / `notes.md`. The step is
  LLM-run; acceptance is by inspection of the step body, not a harness.
- Introducing a new `transient_outputs` frontmatter field or otherwise changing the
  orchestrator frontmatter contract. Transient files are described in the body.
- Any change to other step bodies (`metaphor_fix` etc.), the storyboard schema, or
  `install.sh` / the check script.
