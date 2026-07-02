---
description: Run the recommended next Amanuensis pipeline step.
---

You are running the Amanuensis dispatcher. This prompt is a thin host adapter; the canonical contract lives in `amanuensis/agents/orchestrator.md` (under "Dispatcher behavior" and "Failure modes"). Do not re-derive that contract — follow it.

This command is the convenience layer over `/run-step`: it resolves the recommended next step — the first non-`[x]` step in the recipe list — and then proceeds exactly as `/run-step` would for that step_id. Same precondition checks, same failure modes, one step per invocation. The dispatcher runs in the same session as the step body: you read the state file, select the step, verify its required preconditions resolve to existing files, then become that step body for the rest of this session. Recording completion is the step body's final action, not yours.

## Procedure

1. Read `pipeline-state.md` at the project root. Parse its YAML frontmatter (note `project_type`) and the step list under `## Steps`. If the state file is missing or malformed, see Failure modes and stop.
2. Resolve the recommended next step: the first non-`[x]` step in the recipe list. (A legacy `[>]` marker in a pre-M7 state file is deprecated and read as `[ ]`.) If every step is `[x]`, report the recipe complete and stop. Otherwise, report which step you selected.
3. If path resolution will need it, read `amanuensis-project.yaml` at the project root for `project_type`. (The frontmatter copy in `pipeline-state.md` is the working value; `amanuensis-project.yaml` is the source of truth.)
4. Convert the selected step's snake_case step_id to dashes and resolve the workflow file at `amanuensis/agents/steps/<step-id-with-dashes>.md` (e.g. `metaphor_identify` → `amanuensis/agents/steps/metaphor-identify.md`). If that file does not exist on disk, see Failure modes and stop.
5. Parse the step file's `preconditions:` frontmatter block and verify that every `required: true` entry resolves to at least one existing file. A glob pattern resolves if at least one file matches; a `<latest-draft>` path resolves if at least one `draft-vNN.md` exists in the latest attempt; placeholder resolution follows `amanuensis/agents/project-layouts.md`. If any required precondition is missing, see Failure modes and stop before loading the step body.
6. Read that step workflow file. Treat its body as the rest of this session's instructions.
7. Follow the step body to completion. Its declared inputs, outputs, and behavior govern the work; this dispatcher does not.
8. The step body's final action on success — restated here so a human reading this prompt knows what to expect — is to edit `pipeline-state.md`: set its own step line to `[x]` (a no-op if the line is already `[x]` — reruns don't move anything) and update `last_updated` to the current ISO 8601 datetime with timezone offset. Then exit. On a blocked exit the step body touches `pipeline-state.md` not at all. You never record completion yourself.

## Failure modes

Stop and ask the human, in plain text, on any of these. Do not guess, do not invent state, do not touch `pipeline-state.md`, and do not attempt automatic recovery — describe the problem and exit.

- `pipeline-state.md` is missing at the project root.
- `pipeline-state.md` is malformed: unparseable frontmatter, no step list, or a step list that is not a sequence of checkbox entries.
- The recipe is complete: every step in the list is `[x]`. Report the recipe complete and stop.
- The resolved step workflow file does not exist at `amanuensis/agents/steps/<step-id-with-dashes>.md`.
- A `required: true` precondition does not resolve to any existing file. Name the missing file(s) and stop before loading the step body.

Recovery is the human's job: edit `pipeline-state.md`, restore the missing step file, produce the missing input (typically by running the step that emits it), or otherwise repair the state, then re-invoke `/next-step` (or `/run-step <step_id>` for a specific step).

## Blocked step

If the step body cannot complete its work, it is responsible for appending a question to project-root `open-questions.md` and exiting without recording completion in `pipeline-state.md`. The dispatcher does not need to do anything special — since you never record completion yourself, an early exit from the step body naturally leaves `pipeline-state.md` untouched; the step stays non-`[x]`, so the next `/next-step` invocation selects it again.

---

Full contract: `amanuensis/agents/orchestrator.md`.
