# Orchestrator

The orchestrator is how a project runs Amanuensis pipeline steps, one step per invocation. It is not an agent. It is a workflow definition plus a dispatcher convention. Any LLM agent host (Claude Code, OpenCode, etc.) can run it.

## Components

The orchestrator has three pieces:

1. **Step workflow files** — one markdown file per step, defining what that step does, what files it reads, what files it writes, and whether it requires human review. These live under `amanuensis/agents/steps/`, with one file per step. The file path for a step is derived from its `step_id` by replacing underscores with dashes: `step_id: metaphor_identify` resolves to `amanuensis/agents/steps/metaphor-identify.md`.
2. **State file** — `pipeline-state.md` at the project root. The project's recipe (the recommended step order) and status record (which steps have completed at least once). Format defined below.
3. **Dispatcher** — a host-specific entry point (a Claude Code slash command, an OpenCode agent, or equivalent) that resolves the requested step — or the recommended next step — verifies its required preconditions resolve to existing files, and follows that step workflow's body in the same session. The step body records its own completion as its final action; the dispatcher then exits.

## Execution model

Correctness is governed by artifact preconditions, not by sequence position. The recipe order in `pipeline-state.md` is the recommended path, not the only legal one: any listed step whose required preconditions resolve to existing files may be invoked. The dispatcher checks existence only; judgment lives with the human and with the step bodies.

The terms this contract uses:

- **runnable** — every `required: true` precondition of the step resolves to at least one existing file.
- **blocked** — not runnable; at least one required precondition is missing. The dispatcher reports what's missing and stops without loading the step body.
- **stale** — a side artifact whose `Reviewed-draft:` stamp names a draft other than the current `<latest-draft>` (which resolves via the active head, so a stamp naming an abandoned draft is stale). Detected by the consuming step body at step start, not by the dispatcher (dispatcher-level staleness detection is M9.6).
- **superseded** — a draft carrying a `superseded_by:` stamp in the manifest, and any side artifact stamped against one.
- **active** — the draft named by the attempt manifest's `Active-head:` pointer — what `<latest-draft>` resolves to — and the side artifacts stamped against it.
- **active_head** — the manifest's top-of-file `Active-head: draft-vNN.md` pointer, the single source of "which draft is active"; full definition in `agents/project-layouts.md`.
- **lineage** — the `read_from` chain from a draft back to `draft-v01.md`; full definition in `agents/project-layouts.md`.
- **abandoned** — a draft that carries a `superseded_by` stamp and is not the active head, a derived predicate; full definition in `agents/project-layouts.md`.
- **recommended next** — the first non-`[x]` step in the recipe list.
- **explicit override** — a deliberate human instruction to proceed despite a stale or blocked condition, always human-visible and never assumed. The recording mechanism is deferred to M9.5; until then the existing path stands: the step blocks to `open-questions.md` and the human resolves it there.

## Step workflow contract

Every step workflow file has frontmatter that declares the step's contract:

```yaml
---
step_id: metaphor_identify
review_required: true
inputs:
  - <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/metaphors.md
---
```

**`step_id`** is the canonical name of the step. Must match the corresponding entry in `pipeline-state.md` exactly. snake_case.

**`review_required`** indicates whether the human is expected to review the step's output before a consuming step runs. Nothing enforces this — on successful completion the step body records its own completion regardless. `review_required: true` is a signal to the human reading the state file that a later dispatcher invocation consuming this output will assume the artifact has been reviewed. If the human invokes the dispatcher without reviewing, the consuming step runs against unreviewed output and the consequences are the human's problem.

**`inputs`** lists the files the step reads. Path conventions use `<chapter-folder>` and `<latest-attempt>` placeholders that the step body resolves based on project_type and current state. The list is descriptive; nothing enforces it. Its purpose is documentation and review.

**`outputs`** lists the files the step writes. Same conventions as inputs.

**`preconditions`** is the machine-readable block the dispatcher parses before loading the step body. It is additive: `inputs`/`outputs` remain descriptive lists. One entry per input, all keys explicit (no defaults — the block exists to be machine-read, so explicitness beats brevity):

```yaml
preconditions:
  - path: <chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md
    kind: side_artifact        # source | prose_draft | side_artifact
    required: true
    review_sensitive: true
```

- `kind: prose_draft` — a versioned draft resolved via `<latest-draft>`. `kind: side_artifact` — a report/annotation artifact produced by another step (carries or inherits a `Reviewed-draft:` stamp). `kind: source` — everything else the step reads (plans, scene lists, storyboards, canon, voice, config).
- `required: true` means the step cannot start safely without it. `required: false` marks conditional-use inputs (canonical example: `metaphor_fix` needs `voice.md` only when a `WORKSHOP` entry exists).
- `review_sensitive: true` marks inputs expected to carry human annotations/review before consumption.
- Existence semantics: a glob pattern resolves if at least one file matches; a `<latest-draft>` path resolves if at least one `draft-vNN.md` exists in the latest attempt. Placeholder resolution follows `agents/project-layouts.md` as today.

The body of a step workflow file describes what the step does. Existing step workflows in `agents/steps/` (storyboarding, drafting, compliance-report, etc.) are the model. Step bodies should:

- read only the declared inputs
- write only to the declared outputs
- treat the file system as the only state
- produce no notes or logs about what was done — the artifacts themselves are the record
- if blocked, write to the project's `open-questions.md` and exit without recording completion in `pipeline-state.md`. A missing detail is not automatically a block: under Rule 1 (`agents/update-rules.md`) a drafter may invent the permitted case — a non-load-bearing, non-conflicting, register-appropriate detail — rather than halting. Only when the missing fact is load-bearing for reveal timing or character knowledge, or would conflict with existing canon, does the step record an open question and exit instead of inventing.

## State file format

`pipeline-state.md` lives at the project root. The canonical example of both the file format and the default step recipe is `templates/pipeline-state.md` — see that file for a full, working specimen.

The frontmatter carries `project_type` (read by step workflows that need to resolve folder layout) and `last_updated` (updated by the step body as part of its completion action). No other fields are required at MVP. `project_type` is set in `amanuensis-project.yaml` at the project root; the template lives at `templates/amanuensis-project.yaml`.

The body contains a `## Steps` section listing each step on its own line with a checkbox: `[x]` means the step has completed at least once, `[ ]` means it has not. There is no cursor and no stored pointer. A `[>]` marker encountered in a pre-M7 state file is a deprecated legacy marker and is read as `[ ]`. The recommended next step is the first non-`[x]` step in the list, resolved at invocation time.

The step list is the project's recipe. It may differ between project types, or be customized per project. The dispatcher does not assume a fixed sequence — it reads whatever list is in the file.

## Dispatcher behavior

The dispatcher runs in the same host session as the step body. It is not a supervisor that spawns a subagent and then records state on the subagent's behalf; it is a thin prompt that locates the right step workflow file and then becomes that step body for the rest of the session.

The core operation is `run_step <step_id>`, which takes an optional read-from draft after the step_id: `run_step <step_id> from <draft-vNN>` (contract-level grammar; the host command is `run-step <step_id> from <draft-vNN>`). The read-from draft overrides which draft `<latest-draft>` resolves to for that one invocation and nothing else. On invocation, the dispatcher:

1. Reads `pipeline-state.md`. Confirms the requested `step_id` appears in the recipe list.
2. Resolves the step workflow file path from `step_id` by replacing underscores with dashes: `amanuensis/agents/steps/<step-id-with-dashes>.md`. Example: `metaphor_identify` → `amanuensis/agents/steps/metaphor-identify.md`.
3. If a read-from draft was given: confirms the step file's `preconditions:` block declares a `prose_draft` entry, and confirms the named draft exists as a `draft-vNN.md` file in the latest attempt. If either check fails, the dispatcher names the problem and stops (see Failure modes).
4. Parses the step file's `preconditions:` frontmatter block and verifies that every `required: true` entry resolves to at least one existing file. If any is missing, the dispatcher names the missing file(s) and stops without loading the step body. When a read-from draft was given, it substitutes for `<latest-draft>` in the `prose_draft` precondition check; without one, `<latest-draft>` resolves to the active head as normal (per `agents/project-layouts.md`).
5. Loads the step workflow file. Treats its body as the agent's instructions for the remainder of the session. When a read-from draft was given, the dispatcher passes it to the step body as the draft to read.
6. Follows the step body in the same session. The step body reads `pipeline-state.md` frontmatter for `project_type` if it needs path resolution. Otherwise the step ignores the state file until its completion action.
7. Exits when the step body exits.

`next_recommended_step` is a convenience layer over the same machinery: it resolves the first non-`[x]` step in the recipe list, reports which step it selected, and then proceeds identically to `run_step` for that step_id — same precondition checks, same failure modes, one step per invocation. It never accepts a read-from argument: it is the linear convenience layer and always advances from the active head.

Recording completion is the step body's responsibility, not the dispatcher's. On successful completion, the step body's final action is to edit `pipeline-state.md`: set its own step line to `[x]` — a no-op if the line is already `[x]`; reruns don't move anything — and update `last_updated` to the current ISO 8601 datetime with timezone offset. For a prose-advancing step, the final action also repoints the manifest's `Active-head` to the draft it just wrote and, on a branch — when the draft it read is not the current active head — stamps the displaced drafts `superseded_by`, per the lineage and supersession algorithm in `agents/project-layouts.md`. On a blocked exit — blocked, error, or otherwise incomplete — the step body touches `pipeline-state.md` not at all.

The dispatcher does not:

- run multiple steps per invocation
- enforce `review_required` (the human's responsibility)
- track per-step notes or logs
- record completion on the step body's behalf
- handle errors beyond surfacing them and exiting cleanly

The fresh-invocation guarantee is honored by the human invoking the dispatcher in a fresh host session, not by host-side context isolation. A single dispatcher invocation — `run-step` or `next-step` — corresponds to a single step body run.

A blocked step writes its question to the project-root `open-questions.md` and exits without recording completion. A later invocation of `run_step` for that step_id re-runs it. The human resolves the blocker by editing files (including `open-questions.md`) before invoking the dispatcher again.

### Failure modes

The dispatcher stops and asks the human, in plain text, when any of the following hold. It does not guess, does not invent state, does not touch `pipeline-state.md`, and does not attempt automatic recovery.

- `pipeline-state.md` is missing at the project root.
- `pipeline-state.md` is malformed: unparseable frontmatter, no step list, or a step list the dispatcher cannot read as a sequence of checkbox entries per the state file format above.
- The requested `step_id` does not appear in the recipe list. The dispatcher does not guess and does not run unlisted steps: the human either mistyped or needs to add the step line to the recipe first.
- The resolved step workflow file does not exist on disk at `amanuensis/agents/steps/<step-id-with-dashes>.md`.
- A `required: true` precondition does not resolve to any existing file. The dispatcher names the missing file(s) and stops without loading the step body.
- A read-from draft does not resolve to an existing `draft-vNN.md` in the latest attempt. The dispatcher names the missing draft and stops without loading the step body.
- A read-from argument is passed to a step that declares no `prose_draft` precondition. This is a usage error — the step reads no draft, so the override is meaningless. The dispatcher names the problem and stops without loading the step body.
- The recipe is complete: `next_recommended_step` finds every step `[x]`. The dispatcher reports the recipe complete and stops.

In each case the dispatcher describes the problem to the human and exits. Recovery is the human's job: edit `pipeline-state.md`, restore the missing step file, produce the missing input (typically by running the step that emits it), or otherwise repair the state, then re-invoke the dispatcher.

## Re-running a step

To rerun any step — completed or not — invoke `run_step` with its step_id. Completed steps stay `[x]`: the completion action is a no-op on an already-checked line, and downstream checkboxes are never rewound. Checkbox state records history (completed at least once), not validity; artifact freshness stamps (`Reviewed-draft:`, per the invariant below) are what protect downstream consumers from consuming superseded output. Any existing output files from the rerun step are overwritten — except versioned drafts: a prose-advancing rerun writes `<next-draft>` (a new file) rather than overwriting.

A rerun is a branch exactly when the draft the step reads is not the current active head — that is, when a read-from draft (`run_step <step_id> from <draft-vNN>`) names an earlier draft. On a branch, the prose-advancing step's completion action repoints `Active-head` to the new draft and stamps the displaced drafts `superseded_by`, per the algorithm in `agents/project-layouts.md`. A rerun from the active head (or with no read-from argument) is a linear advance and supersedes nothing.

## Path resolution by project type

See `agents/project-layouts.md`.

How a step knows which chapter is "the current chapter" for book and series projects is an open question deferred to the book/series rollout phase. For short_story projects there is only one chapter and the question doesn't arise.

TODO: this doesn't feel ideal but I should see it in practice before proposing a new solution

## Report→fix freshness invariant

(Formerly the report→fix adjacency invariant.)

A fix/apply step may consume its paired report only when that report was produced against the current `<latest-draft>`, human override excepted. Each prose-advancing fix/apply step verifies this at step start by comparing the paired side artifact's `Reviewed-draft:` stamp against the current `<latest-draft>`. On mismatch the fix/apply step appends a stale-report blocker to the project-root `open-questions.md` and exits without recording completion in `pipeline-state.md`.

`<latest-draft>` now resolves via the manifest's active head (`agents/project-layouts.md`), so a report stamped against an abandoned draft fails the filename comparison and is correctly detected as stale; the invariant's mechanics are otherwise unchanged. A stale artifact's lineage is identifiable from its `Reviewed-draft:` filename plus the manifest's `read_from` chain.

The pairs governed by this invariant in the current pipeline:

- `compliance_report` → `compliance_fix`, stamped in `reviewer-actions.md`.
- `prose_pass` → `prose_fix`, stamped in `prose-pass.md`.
- `metaphor_identify` / `metaphor_fix` → `metaphor_apply`, stamped in `metaphors.md`.
- `anti_ai_report` → `anti_ai_fix`, stamped in `anti-ai.md`.

The stamp is written by the report-emitting step the first time it creates its side artifact (`compliance_report`, `prose_pass`, `metaphor_identify`, `anti_ai_report`). On a rerun against an unchanged `<latest-draft>` the stamp is preserved and the step continues normally. On a rerun against a different `<latest-draft>` — the recovery path for a stale-report blocker — the report-emitting step **overwrites** its side artifact and writes a fresh top-of-file stamp matching the new `<latest-draft>`; the previous run's findings against the superseded draft are discarded, because their prose anchors no longer apply. `metaphor_fix` is not a report-emitting step: it preserves whatever stamp it inherits from `metaphor_identify` and never refreshes it. The paired fix/apply step reads the top-of-file stamp at step start.

`prose_pass` records a `Reviewed-draft:` stamp in `prose-pass.md`, and `prose_fix` is its paired prose-advancing consumer, so the stamp is load-bearing (`prose_fix` checks it at step start to detect stale annotations). `line_pass` is a prose-advancing step with no upstream report, so the invariant does not apply to it.

The stale-report exit is a human decision point, not an automatic recovery. The fix/apply step appends a blocker to `open-questions.md` recording the stamped draft, the current `<latest-draft>`, and which step produced the newer draft. The human then decides between rerunning the report-emitting step (which overwrites the side artifact as described above), rolling the draft back to the stamped version, or accepting a stale apply with an explicit override. The fix/apply step does not silently apply old annotations to a newer draft.

## What the orchestrator does not do

- It does check that every `required: true` precondition of the selected step resolves to an existing file at dispatch — and, when a read-from draft is given, that the named draft exists in the latest attempt and the step declares a `prose_draft` precondition. That is the extent of its validation.
- It does not validate that human review has occurred.
- It does not detect staleness at the dispatcher level, and it does not record overrides. Upstream changes that should invalidate downstream artifacts are detected by the consuming step bodies via `Reviewed-draft:` stamps; lifting machine-checkable staleness and override recording into the dispatcher is M9.5/M9.6.
- It does not enforce the recipe as the only order — the recipe is the recommended path, and any listed step whose required preconditions exist may be invoked.
- It does not coordinate concurrent work across multiple chapters or works.
- It does not produce reports or summaries of what it did.

These are intentional omissions. The orchestrator is mechanical. Judgment lives with the human and with the step bodies.
