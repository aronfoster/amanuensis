---
description: Propagate a targeted, human-directed change through the active working set.
---

You are running the Amanuensis revision command. This prompt is a thin host adapter; the canonical contract lives in `amanuensis/agents/revision.md`. Do not re-derive that contract — follow it.

A revision is not a pipeline step: it has no step_id, appears in no recipe, and never touches `pipeline-state.md` or any `Reviewed-draft:` stamp. It propagates one human-directed change — a corrected fact, a reshaped concept, a renamed element — through the files that carry it.

The arguments are: $ARGUMENTS

`$ARGUMENTS` carries the change description in prose: what is wrong and what should be true instead. If it asks for a new draft version — "as a new draft", "make a new version", or equivalent, anywhere in the request — run in new-draft mode; otherwise revise the active head in place. Parse tolerantly — the human is describing a change, not writing a strict CLI. If no change description was given, ask the human what to revise and stop.

## Procedure (summary — the contract governs)

1. Restate the change as old truth → new truth before editing anything; if the request is ambiguous, ask the human directly, in-session.
2. Read `amanuensis-project.yaml` for `project_type`; resolve `<chapter-folder>`, `<latest-attempt>`, `<latest-draft>`, and (new-draft mode) `<next-draft>` per `amanuensis/agents/project-layouts.md`.
3. Fix the canonical source of the fact first; then sweep the whole project for the old shape, including paraphrases and echoes a keyword search misses.
4. Edit in place: character files, canon files, the active storyboards, and — default mode — `<latest-draft>`. In new-draft mode, write `<next-draft>` instead, append its manifest entry (`produced_by: revision`), and repoint `Active-head:`.
5. Surface, do not edit, occurrences outside that scope (plan files, notes, reports); never edit archived attempts, superseded drafts, or archive directories.
6. Honor the guardrails in `amanuensis/agents/update-rules.md`; confirm with the human before revising anything marked immutable.
7. Verify with a final sweep; report what changed, what was found and deliberately left (and why), and any adjacent inconsistencies noticed.

## Failure modes

Stop and ask the human, in plain text, per the contract: ambiguous change description; collision with locked structure the request does not resolve; new-draft mode with no existing draft; a malformed manifest (or one missing when new-draft mode must append to it). Do not guess, and do not touch any state file.

---

Full contract: `amanuensis/agents/revision.md`.
