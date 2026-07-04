# Targeted revision

The revision command propagates a single human-directed change — a corrected fact, a reshaped concept, a renamed element — through the project's active working set. It is the lateral complement to the pipeline: pipeline steps move a draft forward through passes; a revision fixes one thing everywhere it currently lives, so the working set stays consistent with itself.

The revision command is not a pipeline step. It has no `step_id`, appears in no recipe, and **never touches `pipeline-state.md`** — no checkbox, no `last_updated`. It is a host command (the `/revise` slash command in Claude Code; the `revise` agent in OpenCode) whose thin adapters point here; this file is the canonical contract.

## Invocation

`revise <change description>` — the change description is prose: what is wrong and what should be true instead. The human may request a new draft version by saying so anywhere in the request ("as a new draft", "make a new version", or equivalent); absent that request, the draft is revised in place. Parse the request tolerantly — the human is describing a change, not writing a strict CLI. If no change description was given, ask the human what to revise and stop.

## Edit scope

**Always edited in place, in both modes:** character files (`characters/`), canon files (`canon/`), and the chapter's active storyboards (`<chapter-folder>/storyboards/`). These files carry current truth; they are not versioned, and the corrected fact has no other home.

**The draft, by mode:**

- **In-place (default):** edit `<latest-draft>` — the attempt manifest's active head — in place. No new file is minted, no manifest entry is added, and the `Active-head:` pointer does not move.
- **New-draft (on request):** leave the active head's file untouched; write the revised prose as `<next-draft>` and record it in the manifest per the draft-write rule in the Procedure below.

**Surfaced, not edited by default:** occurrences of the old shape anywhere else in the active working set — plan files (`<story-plan>`, scene lists, summaries), `open-questions.md`, notes and reports, aftermath files. Name them in the closing report; edit them only when the request covers them or the human widens scope when asked.

**Never edited:** `pipeline-state.md`; side-artifact `Reviewed-draft:` stamps; manifest entries for existing drafts; and archived material — any attempt directory other than `<latest-attempt>`, any `draft-vNN.md` other than the draft being revised, and any directory the consuming project keeps as an archive (e.g. a root `archive/`). Superseded and archived files record what was true when they were written. A revision changes the present, never the record.

## Procedure

1. **Restate the change.** Before editing anything, state it as old truth → new truth in a sentence or two, and proceed on that statement. If the request is ambiguous — two readings, an unclear boundary, a visible collision — ask the human now. The revision command runs with the human present: ask directly, in-session; do not write questions to `open-questions.md` that the human can answer immediately.
2. **Resolve paths.** Read `amanuensis-project.yaml` for `project_type`; resolve `<chapter-folder>`, `<latest-attempt>`, `<latest-draft>`, and (in new-draft mode) `<next-draft>` per `agents/project-layouts.md`.
3. **Fix the source of truth first.** Find the file where the changed fact canonically lives — a character profile, a `canon/` file — and correct it before touching anything downstream, so every later edit has a settled target to align to.
4. **Sweep.** Search the whole project for the old shape: keyword matches first, then the mentions a keyword search cannot find — scenes that paraphrase, remember, report, or apply the changed element without using its words (a memory of the advice, a later retelling, a consequence of the fact). Classify every hit: in scope (edit), outside the default scope (surface), archived or superseded (leave).
5. **Check the guardrails.** `agents/update-rules.md` applies in full. Two points bear restating here. An element marked immutable may still be revised — immutability markers exist to stop agent-initiated drift, and a human-directed revision is exactly the authority that may move one — but name the marker and confirm the new shape with the human before editing it. And reveal timing (Rule 2) binds a revision like any other edit: the new shape must not let a character or the reader know something earlier than the story allows.
6. **Apply.** Edit each file in its own register: storyboard and canon edits stay in storyboard and canon language; prose edits are made in the character's voice and the surrounding rhythm, never by mechanical find-and-replace. Verify every downstream echo against the new shape, including the ones that turn out to need no edit.
7. **Write the draft (new-draft mode only).** Write the revised prose to `<next-draft>`; append a manifest entry with `produced_by: revision`, `read_from:` naming the draft revised (the active head), a `timestamp` (ISO 8601 with timezone offset), and `review_gate: false`; repoint `Active-head:` to the new draft. Reading the active head makes this a linear advance — supersede nothing (the lineage and supersession algorithm in `agents/project-layouts.md` governs).
8. **Verify and report.** Re-run the sweep and confirm the old shape survives only where it is meant to (archives, superseded attempts, surfaced-but-unedited files). Close with a report: files changed; occurrences found and deliberately left, each with its reason; and adjacent inconsistencies noticed along the way that the change's scope did not cover.

## Consequences the command accepts

An in-place revision changes the active head's text underneath any side artifacts stamped against it. The stamps still name the right file, so nothing becomes detectably `stale` — the freshness predicate compares filenames, not content (see the Artifact-state section of `agents/orchestrator.md`). This is accepted by design: a revision never touches freshness or review state. When it matters, the human reruns the relevant report step; the closing report names any stamped side artifacts produced against the pre-revision text so the human can decide.

## Failure modes

Stop and ask the human, in plain text, when any of these hold. Describe the problem; do not guess, and do not touch any state file.

- The change description is ambiguous and the ambiguity affects what gets edited.
- The change collides with locked structure — an immutable marker, a reveal-timing constraint — in a way the request does not already resolve.
- New-draft mode was requested but no draft exists in `<latest-attempt>`: there is nothing to revise; the drafting step has not run.
- The attempt manifest is malformed, or missing when new-draft mode must append to it. (In-place mode tolerates a missing manifest: `<latest-draft>` falls back per `agents/project-layouts.md`.)
