---
description: Advance the Amanuensis pipeline by one step.
---

You are running the Amanuensis dispatcher. This prompt is a thin host adapter; the canonical contract lives in `amanuensis/agents/orchestrator.md` (under "Dispatcher behavior" and "Failure modes"). Do not re-derive that contract — follow it.

The dispatcher runs in the same session as the step body. You read the state file, locate the next step's workflow file, then become that step body for the rest of this session. Marker advancement is the step body's final action, not yours.

## Procedure

1. Read `pipeline-state.md` at the project root. Parse its YAML frontmatter (note `project_type`) and the step list under `## Steps`.
2. Locate the single line marked `[>]`. If the state file is missing, malformed, or has no `[>]`, see Failure modes and stop.
3. If path resolution will need it, read `amanuensis-project.yaml` at the project root for `project_type`. (The frontmatter copy in `pipeline-state.md` is the working value; `amanuensis-project.yaml` is the source of truth.)
4. Convert the `[>]` step's snake_case `step_id` to dashes and resolve the workflow file at `amanuensis/agents/steps/<step-id-with-dashes>.md` (e.g. `metaphor_identify` → `amanuensis/agents/steps/metaphor-identify.md`). If that file does not exist on disk, see Failure modes and stop.
5. Read that step workflow file. Treat its body as the rest of this session's instructions.
6. Follow the step body to completion. Its declared inputs, outputs, and behavior govern the work; this dispatcher does not.
7. The step body's final action — restated here so a human reading this prompt knows what to expect — is to edit `pipeline-state.md`: flip the current `[>]` to `[x]`, flip the next `[ ]` to `[>]`, and update `last_updated` to the current ISO 8601 datetime with timezone offset. Then exit. If the step body exits early, the marker stays put and the next `/next-step` invocation re-runs the same step.

## Failure modes

Stop and ask the human, in plain text, on any of these. Do not guess, do not invent state, do not advance any marker, and do not attempt automatic recovery — describe the problem and exit.

- `pipeline-state.md` is missing at the project root.
- `pipeline-state.md` is malformed: unparseable frontmatter, no step list, or a step list that is not a sequence of `[ ]`/`[>]`/`[x]` entries.
- No `[>]` marker is present (every step is `[x]`, every step is `[ ]`, or the marker has been removed).
- The resolved step workflow file does not exist at `amanuensis/agents/steps/<step-id-with-dashes>.md`.

Recovery is the human's job: edit `pipeline-state.md`, restore the missing step file, or otherwise repair the state, then re-invoke `/next-step`.

## Blocked step

If the step body cannot complete its work, it is responsible for appending a question to project-root `open-questions.md` and exiting without advancing the marker. The dispatcher does not need to do anything special — since you never advance the marker yourself, an early exit from the step body naturally leaves `[>]` in place for the next invocation.

---

Full contract: `amanuensis/agents/orchestrator.md`.
