---
step_id: compliance_fix
review_required: false
inputs:
  - <chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md
  - <chapter-folder>/drafts/<latest-attempt>/draft.md
  - <chapter-folder>/storyboards/*-storyboard.md
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/draft-compliance.md
  - <chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md
---

See `agents/orchestrator.md` for the step workflow contract.

# Compliance Fix

## Purpose

Apply the human-annotated fixes recorded in `reviewer-actions.md` to the draft, producing a revised prose file (`draft-compliance.md`) that resolves the violations the human marked `FIX`. The step is surgical: it changes only what is annotated, preserves everything else, and records what it did (and what it could not do) by appending to `reviewer-actions.md`. Items annotated `ESCALATE` are not blockers — they are recorded as escalated and the step continues. This step runs after `compliance_report` and after a human has reviewed and annotated the report.

## Inputs

- `<chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md` — the compliance report produced by `compliance_report`, annotated by the human. Each violation entry should carry one of:
  - `FIX` — apply the obvious local edit
  - `FIX: [instruction]` — apply the fix as specified
  - `SKIP` — leave as-is; violation accepted
  - `ESCALATE` — conflict cannot be resolved by local edit; flag for storyboard or canon revision
  An unannotated report is not a valid input. See "Open questions handling" below.
- `<chapter-folder>/drafts/<latest-attempt>/draft.md` — the drafted prose this step revises. Read-only at this step's input boundary; revisions are written to a new file.
- `<chapter-folder>/storyboards/*-storyboard.md` — the storyboard blocks for any `FIX` items, used to confirm what the violation should have enacted. Read only the blocks referenced by `FIX` entries.

Do not read canon files during this step. If a fix requires canon clarification, the human should have marked it `ESCALATE`.

## Behavior

Work entry by entry through the annotated `reviewer-actions.md`.

For each entry annotated `FIX` or `FIX: [instruction]`:

1. Locate the prose in `draft.md` corresponding to the violation (the quote recorded in the report is the anchor).
2. Apply the smallest local edit that resolves the violation. If the annotation is `FIX: [instruction]`, follow the instruction exactly. If the annotation is bare `FIX`, apply the obvious local edit implied by the violation type.
3. Write the revised prose into `draft-compliance.md` (see Outputs).
4. Append an `Applied:` block to `reviewer-actions.md`:

   ```markdown
   #### Applied: [Item label]
   - Change: [one line describing what changed]
   - Prose before: "[original quote]"
   - Prose after: "[revised quote]"
   ```

For each entry annotated `ESCALATE`:

1. Do not modify the prose for this entry.
2. Append an `Escalated:` block to `reviewer-actions.md`:

   ```markdown
   #### Escalated: [Item label]
   - Reason: [one line — why local edit cannot resolve this]
   - Suggested upstream target: [storyboard block / canon file / open question]
   ```

For each entry annotated `SKIP`: leave the prose as-is and do not append any block. The human has accepted the violation.

For entries with no annotation: do not act on them. See Anti-Patterns below.

### Constraints

- Fix only what is annotated `FIX`. Do not improve, tighten, or rewrite prose beyond the violation.
- If a fix to one violation would introduce a new violation, stop and append a note rather than proceeding.
- Preserve block comment markers (`<!-- scene x, beat y -->`) and scene breaks (`---`) exactly as they appear in `draft.md`.
- The output file (`draft-compliance.md`) must contain the full prose of the chapter, with `FIX` edits applied — not a diff and not just the changed sections. Everything not touched by a `FIX` annotation is copied through verbatim from `draft.md`.

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/draft-compliance.md` — the full revised prose. This is a new file produced by this step; the original `draft.md` is not modified. All unchanged prose is copied through verbatim, with `FIX` edits applied in place. Block comment markers and scene breaks are preserved.
- `<chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md` — the same input file, with `Applied:` blocks appended for each `FIX` entry actioned and `Escalated:` blocks appended for each `ESCALATE` entry. Pre-existing content (the Phase 1 report and the human's annotations) is not modified; this step only appends.

## Open questions handling

`ESCALATE`-annotated items are **not** blockers. The step appends an `Escalated:` block for each one and continues. An unresolvable upstream conflict is the expected outcome of an `ESCALATE` annotation, not a reason to halt the pipeline.

Open-questions handling fires only when the input itself is unusable. The canonical case: `reviewer-actions.md` exists but contains no annotations at all (every violation is bare, with no `FIX`/`SKIP`/`ESCALATE`). Other unusable-input cases include a missing `reviewer-actions.md` or a missing `draft.md`. In any of these, append the blocker to the project root `open-questions.md` and exit without advancing the pipeline marker. Do not fabricate annotations and do not write a partial `draft-compliance.md`. The next dispatcher invocation will re-run this step after the human resolves the blocker.

## Anti-Patterns

**Fixing unannotated violations.** This step requires human annotation. An unannotated `reviewer-actions.md` is not a valid input — handle via "Open questions handling," do not guess at intended fixes.

**Rewriting beyond the violation.** The fix pass is surgical. Prose quality improvements are a separate workflow (`prose_pass`, `line_pass`). Do not tighten phrasing, restructure sentences, or polish anything that was not flagged as a violation and annotated `FIX`.
