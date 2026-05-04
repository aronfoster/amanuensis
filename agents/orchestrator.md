# Orchestrator

The orchestrator is how a project advances through the Amanuensis pipeline one step at a time. It is not an agent. It is a workflow definition plus a dispatcher convention. Any LLM agent host (Claude Code, OpenCode, etc.) can run it.

## Components

The orchestrator has three pieces:

1. **Step workflow files** — one markdown file per step, defining what that step does, what files it reads, what files it writes, and whether it requires human review. These live under `amanuensis/agents/` (existing workflow files) and `amanuensis/agents/steps/` (new workflow files added in roadmap Phase 3, or wherever Phase 1 settles the convention).
2. **State file** — `pipeline-state.md` at the project root. Tracks which step runs next and which steps are complete. Format defined below.
3. **Dispatcher** — a host-specific entry point (a Claude Code slash command, an OpenCode agent, or equivalent) that reads the state file, identifies the next step, runs that step's workflow as a fresh agent invocation, advances the marker, and exits.

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

**`review_required`** indicates whether the human is expected to review the step's output before the next step runs. The dispatcher does not enforce this — it always advances the marker after a step body completes. `review_required: true` is a signal to the human reading the state file that the next dispatcher invocation will assume the artifact has been reviewed. If the human invokes the dispatcher without reviewing, the next step runs against unreviewed output, and the consequences are the human's problem.

**`inputs`** lists the files the step reads. Path conventions use `<chapter-folder>` and `<latest-attempt>` placeholders that the step body resolves based on project_type and current state. The list is descriptive; nothing enforces it. Its purpose is documentation and review.

**`outputs`** lists the files the step writes. Same conventions as inputs.

The body of a step workflow file describes what the step does. Existing workflows in `agents/` (storyboarding, drafting, compliance, etc.) are the model. Step bodies should:

- read only the declared inputs
- write only to the declared outputs
- treat the file system as the only state
- produce no notes or logs about what was done — the artifacts themselves are the record
- if blocked, write to the project's `open-questions.md` and exit; do not invent missing canon

## State file format

`pipeline-state.md` lives at the project root. Format:

```markdown
---
project_type: short_story
last_updated: 2026-05-04T14:32:18-06:00
---

# Pipeline State

The line marked `[>]` is the next step the dispatcher will run. `[x]` is complete. `[ ]` is pending.

To redo a step, move the `[>]` marker to that step and change downstream `[x]` markers back to `[ ]`.

## Steps

- [>] character_extraction
- [ ] scene_generation
- [ ] storyboarding
- [ ] drafting
- [ ] compliance_report
- [ ] compliance_fix
- [ ] prose_pass
- [ ] metaphor_identify
- [ ] metaphor_fix
- [ ] metaphor_apply
- [ ] line_pass
- [ ] anti_ai
```

The frontmatter carries `project_type` (read by step workflows that need to resolve folder layout) and `last_updated` (updated by the dispatcher on every advance). No other fields are required at MVP.

The step list is the project's plan. It may differ between project types, or be customized per project. The dispatcher does not assume a fixed sequence — it reads whatever list is in the file.

## Dispatcher behavior

On invocation, the dispatcher:

1. Reads `pipeline-state.md`. Locates the `[>]` line.
2. Resolves the step workflow file path from `step_id`. (Convention TBD in roadmap Milestone 1: likely `amanuensis/agents/steps/<step_id-with-dashes>.md` or similar.)
3. Reads the step workflow file. Treats its body as the agent's instructions.
4. Runs the step body to completion. The step body reads `pipeline-state.md` frontmatter for `project_type` if it needs path resolution. Otherwise the step ignores the state file.
5. On step completion: changes the `[>]` line to `[x]`, changes the next `[ ]` line to `[>]`, updates `last_updated` to the current ISO 8601 datetime with timezone offset.
6. Exits.

The dispatcher does not:

- carry context between steps
- run multiple steps per invocation
- enforce `review_required` (the human's responsibility)
- track per-step notes or logs
- handle errors beyond exiting cleanly

If a step body cannot complete (missing inputs, unrecoverable error), the step writes to the project's `open-questions.md` (or the chapter's, as appropriate) and exits without advancing the marker. The next dispatcher invocation re-runs the step. The human resolves the blocker by editing files.

## Re-running a step

The human edits `pipeline-state.md` directly:

- Move the `[>]` marker up to the step to redo.
- Change all downstream `[x]` markers back to `[ ]`.

The next dispatcher invocation runs from the new position.

## Path resolution by project type

Step workflows that read or write files use placeholders that resolve based on `project_type`:

- **short_story**: project root is the chapter equivalent. `<chapter-folder>` resolves to `plot/<story-id>/`. `<book-folder>` is undefined; steps that reference book-level files must handle this gracefully or be inapplicable to short stories.
- **book**: `<chapter-folder>` resolves to `plot/<book-id>/<chapter-id>/`. `<book-folder>` resolves to `plot/<book-id>/`.
- **series**: same as book. The series wrapper is just `plot/` containing multiple book folders.

`<latest-attempt>` resolves to the highest-numbered `attemptNN` directory under the chapter's `drafts/`. If none exists and the step expects one, the step creates `attempt01`.

How a step knows which chapter is "the current chapter" for book and series projects is an open question deferred to the book/series rollout phase. For short_story projects there is only one chapter and the question doesn't arise.

## What the orchestrator does not do

- It does not validate that human review has occurred.
- It does not detect upstream changes that should invalidate downstream artifacts.
- It does not enforce the step list — if the human deletes a step from `pipeline-state.md`, the dispatcher skips it.
- It does not coordinate concurrent work across multiple chapters or works.
- It does not produce reports or summaries of what it did.

These are intentional omissions. The orchestrator is mechanical. Judgment lives with the human and with the step bodies.
