# Orchestrator

The orchestrator is how a project advances through the Amanuensis pipeline one step at a time. It is not an agent. It is a workflow definition plus a dispatcher convention. Any LLM agent host (Claude Code, OpenCode, etc.) can run it.

## Components

The orchestrator has three pieces:

1. **Step workflow files** — one markdown file per step, defining what that step does, what files it reads, what files it writes, and whether it requires human review. These live under `amanuensis/agents/steps/`, with one file per step. The file path for a step is derived from its `step_id` by replacing underscores with dashes: `step_id: metaphor_identify` resolves to `amanuensis/agents/steps/metaphor-identify.md`.
2. **State file** — `pipeline-state.md` at the project root. Tracks which step runs next and which steps are complete. Format defined below.
3. **Dispatcher** — a host-specific entry point (a Claude Code slash command, an OpenCode agent, or equivalent) that reads the state file, identifies the next step, and follows that step workflow's body in the same session. The step body advances the marker as its final action; the dispatcher then exits.

## Step workflow contract

Every step workflow file has frontmatter that declares the step's contract:

```yaml
---
step_id: metaphor_identify
review_required: true
inputs:
  - <chapter-folder>/drafts/<latest-attempt>/draft.md
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/metaphors.md
---
```

**`step_id`** is the canonical name of the step. Must match the corresponding entry in `pipeline-state.md` exactly. snake_case.

**`review_required`** indicates whether the human is expected to review the step's output before the next step runs. Nothing enforces this — on successful completion the step body advances the marker regardless. `review_required: true` is a signal to the human reading the state file that the next dispatcher invocation will assume the artifact has been reviewed. If the human invokes the dispatcher without reviewing, the next step runs against unreviewed output and the consequences are the human's problem.

**`inputs`** lists the files the step reads. Path conventions use `<chapter-folder>` and `<latest-attempt>` placeholders that the step body resolves based on project_type and current state. The list is descriptive; nothing enforces it. Its purpose is documentation and review.

**`outputs`** lists the files the step writes. Same conventions as inputs.

The body of a step workflow file describes what the step does. Existing step workflows in `agents/steps/` (storyboarding, drafting, compliance-report, etc.) are the model. Step bodies should:

- read only the declared inputs
- write only to the declared outputs
- treat the file system as the only state
- produce no notes or logs about what was done — the artifacts themselves are the record
- if blocked, write to the project's `open-questions.md` and exit. A missing detail is not automatically a block: under Rule 1 (`agents/update-rules.md`) a drafter may invent the permitted case — a non-load-bearing, non-conflicting, register-appropriate detail — rather than halting. Only when the missing fact is load-bearing for reveal timing or character knowledge, or would conflict with existing canon, does the step record an open question and exit instead of inventing.

## State file format

`pipeline-state.md` lives at the project root. The canonical example of both the file format and the default step sequence is `templates/pipeline-state.md` — see that file for a full, working specimen.

The frontmatter carries `project_type` (read by step workflows that need to resolve folder layout) and `last_updated` (updated by the dispatcher on every advance). No other fields are required at MVP. `project_type` is set in `amanuensis-project.yaml` at the project root; the template lives at `templates/amanuensis-project.yaml`.

The body contains a `## Steps` section listing each step on its own line with a marker: `[>]` is the next step the dispatcher will run, `[x]` is complete, and `[ ]` is pending. To redo a step, move the `[>]` marker up to that step and change downstream `[x]` markers back to `[ ]`.

The step list is the project's plan. It may differ between project types, or be customized per project. The dispatcher does not assume a fixed sequence — it reads whatever list is in the file.

## Dispatcher behavior

The dispatcher runs in the same host session as the step body. It is not a supervisor that spawns a subagent and then advances state on the subagent's behalf; it is a thin prompt that locates the right step workflow file and then becomes that step body for the rest of the session.

On invocation, the dispatcher:

1. Reads `pipeline-state.md`. Locates the `[>]` line.
2. Resolves the step workflow file path from `step_id` by replacing underscores with dashes: `amanuensis/agents/steps/<step-id-with-dashes>.md`. Example: `metaphor_identify` → `amanuensis/agents/steps/metaphor-identify.md`.
3. Loads the step workflow file. Treats its body as the agent's instructions for the remainder of the session.
4. Follows the step body in the same session. The step body reads `pipeline-state.md` frontmatter for `project_type` if it needs path resolution. Otherwise the step ignores the state file.
5. Exits when the step body exits.

Marker advancement is the step body's responsibility, not the dispatcher's. On successful completion, the step body's final action is to edit `pipeline-state.md`: flip the current `[>]` to `[x]`, flip the next `[ ]` to `[>]`, and update `last_updated` to the current ISO 8601 datetime with timezone offset. If the step body exits early — blocked, error, or otherwise incomplete — the marker stays on the current step and the next dispatcher invocation re-runs it.

The dispatcher does not:

- run multiple steps per invocation
- enforce `review_required` (the human's responsibility)
- track per-step notes or logs
- advance the marker on the step body's behalf
- handle errors beyond surfacing them and exiting cleanly

The fresh-invocation guarantee is honored by the human invoking the dispatcher in a fresh host session, not by host-side context isolation. A single `/next-step` invocation corresponds to a single step body run.

A blocked step writes its question to the project-root `open-questions.md` and exits without advancing the marker. The next dispatcher invocation re-runs the same step. The human resolves the blocker by editing files (including `open-questions.md`) before invoking the dispatcher again.

### Failure modes

The dispatcher stops and asks the human, in plain text, when any of the following hold. It does not guess, does not invent state, does not advance any marker, and does not attempt automatic recovery.

- `pipeline-state.md` is missing at the project root.
- `pipeline-state.md` is malformed: unparseable frontmatter, no step list, or a step list the dispatcher cannot read as a sequence of `[ ]`/`[>]`/`[x]` entries.
- No `[>]` marker is present (e.g., every step is `[x]`, or every step is `[ ]`, or the marker has been removed).
- The resolved step workflow file does not exist on disk at `amanuensis/agents/steps/<step-id-with-dashes>.md`.

In each case the dispatcher describes the problem to the human and exits. Recovery is the human's job: edit `pipeline-state.md`, restore the missing step file, or otherwise repair the state, then re-invoke the dispatcher.

## Re-running a step

The human edits `pipeline-state.md` directly:

- Move the `[>]` marker up to the step to redo.
- Change all downstream `[x]` markers back to `[ ]`.

The next dispatcher invocation runs from the new position. Any existing output files from the current step are overwritten.

## Path resolution by project type

See `agents/project-layouts.md`.

How a step knows which chapter is "the current chapter" for book and series projects is an open question deferred to the book/series rollout phase. For short_story projects there is only one chapter and the question doesn't arise.

TODO: this doesn't feel ideal but I should see it in practice before proposing a new solution

## What the orchestrator does not do

- It does not validate that human review has occurred.
- It does not detect upstream changes that should invalidate downstream artifacts.
- It does not enforce the step list — if the human deletes a step from `pipeline-state.md`, the dispatcher skips it.
- It does not coordinate concurrent work across multiple chapters or works.
- It does not produce reports or summaries of what it did.

These are intentional omissions. The orchestrator is mechanical. Judgment lives with the human and with the step bodies.
