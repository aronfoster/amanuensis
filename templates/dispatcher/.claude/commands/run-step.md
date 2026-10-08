---
description: Run a specific Amanuensis pipeline step by step_id.
---

You are running the Amanuensis dispatcher. This prompt is a thin host adapter; the canonical contract lives in `amanuensis/agents/orchestrator.md` (under "Dispatcher behavior" and "Failure modes"). Do not re-derive that contract — follow it.

The dispatcher runs in the same session as the step body. You read the state file, confirm the requested step is in the recipe, verify the step's required preconditions resolve to existing files, then become that step body for the rest of this session. Recording completion is the step body's final action, not yours.

The arguments are: $ARGUMENTS

`$ARGUMENTS` carries the requested step_id, optionally followed by `in attemptNN` and/or `from draft-vNN.md` in either order. Parse tolerantly: a bare `attemptNN` or `draft-vNN` after the step_id also counts. The attempt argument selects an existing attempt for all attempt-scoped paths in this invocation; the draft argument selects a draft within that attempt (or within the numeric latest attempt when no attempt is named). Neither selection persists. See `amanuensis/agents/project-layouts.md`.

## Procedure

1. Read `pipeline-state.md` at the project root. Parse its YAML frontmatter (note `project_type`) and the step list under `## Steps`. Confirm the requested step_id appears in the recipe list. If the state file is missing or malformed, or the step_id is not listed, see Failure modes and stop.
2. If path resolution will need it, read `amanuensis-project.yaml` at the project root for `project_type`. (The frontmatter copy in `pipeline-state.md` is the working value; `amanuensis-project.yaml` is the source of truth.)
3. Convert the snake_case step_id to dashes and resolve the workflow file at `amanuensis/agents/steps/<step-id-with-dashes>.md` (e.g. `metaphor_identify` → `amanuensis/agents/steps/metaphor-identify.md`). If that file does not exist on disk, see Failure modes and stop.
4. If an attempt was given: confirm the step declares an attempt-scoped input or output (an `inputs:` or `outputs:` frontmatter path containing `<latest-attempt>`, not a mention in the body), is not `drafting`, and that the named `attemptNN` directory exists under this chapter's `drafts/`. For `continuity_update` and `scene_knowledge_update`, also require that the selected attempt is the numerically highest existing attempt under this chapter's `drafts/`, computed independently of the override; reject an older attempt before loading the step body or writing any project file. These sole-writer steps update shared maintained state whose freshness remains tied to the numeric latest attempt. Explicit selection of that latest attempt remains valid. If a read-from draft was given (with or without an attempt argument): confirm a `prose_draft` precondition and the named `draft-vNN.md` in the selected attempt (or the numeric latest attempt by default). If any check fails, see Failure modes and stop.
5. Parse the step file's `preconditions:` frontmatter block and verify every `required: true` entry resolves to an existing file. A glob resolves if at least one file matches. Resolve **every** `<latest-attempt>` placeholder to the selected attempt when supplied; otherwise use the numeric latest attempt. Resolve `<latest-draft>` to that attempt's active head, or to the read-from draft for this invocation. Follow `amanuensis/agents/project-layouts.md`. If any required precondition is missing, see Failure modes and stop before loading the step body.
6. Read that step workflow file. Treat its body as the rest of this session's instructions. Pass the selected attempt and read-from draft, if any, as the step body's path context for inputs and outputs. The step body must preserve that selected attempt for all attempt-scoped paths rather than recompute the highest-numbered directory; shared maintained-state freshness still uses the numeric latest attempt as defined in `amanuensis/agents/project-layouts.md`.
7. Follow the step body to completion. Its declared inputs, outputs, and behavior govern the work; this dispatcher does not.
8. The step body's final action on success — restated here so a human reading this prompt knows what to expect — is to edit `pipeline-state.md`: set its own step line to `[x]` (a no-op if the line is already `[x]` — reruns don't move anything) and update `last_updated` to the current ISO 8601 datetime with timezone offset. Then exit. On a blocked exit the step body touches `pipeline-state.md` not at all. You never record completion yourself.

## Failure modes

Stop and ask the human, in plain text, on any of these. Do not guess, do not invent state, do not touch `pipeline-state.md`, and do not attempt automatic recovery — describe the problem and exit.

- `pipeline-state.md` is missing at the project root.
- `pipeline-state.md` is malformed: unparseable frontmatter, no step list, or a step list that is not a sequence of checkbox entries.
- The requested step_id does not appear in the recipe list. Do not guess and do not run unlisted steps: the human either mistyped or needs to add the step line to the recipe first.
- The resolved step workflow file does not exist at `amanuensis/agents/steps/<step-id-with-dashes>.md`.
- A `required: true` precondition does not resolve to any existing file. Name the missing file(s) and stop before loading the step body.
- A named `attemptNN` is absent, or was passed to `drafting` or a step with no attempt-scoped input/output. Name the invalid selection and stop before loading the step body.
- `continuity_update` or `scene_knowledge_update` selects an attempt other than the numerically highest existing attempt in the source chapter. Name both attempts, explain that shared maintained state requires the numeric latest attempt, and stop before loading the step body or writing any project file.
- A read-from draft does not resolve to an existing `draft-vNN.md` in the selected attempt (or numeric latest attempt by default). Name the missing draft and stop before loading the step body.
- A read-from argument is passed to a step that declares no `prose_draft` precondition. This is a usage error — the step reads no draft, so the override is meaningless. Name the problem and stop before loading the step body.

Recovery is the human's job: edit `pipeline-state.md`, restore the missing step file, produce the missing input (typically by running the step that emits it), or otherwise repair the state, then re-invoke `/run-step`.

## Blocked step

If the step body cannot complete its work, it is responsible for appending a question to project-root `open-questions.md` and exiting without recording completion in `pipeline-state.md`. The dispatcher does not need to do anything special — since you never record completion yourself, an early exit from the step body naturally leaves `pipeline-state.md` untouched; a later `/run-step` invocation for the same step_id re-runs the step.

---

Full contract: `amanuensis/agents/orchestrator.md`.
