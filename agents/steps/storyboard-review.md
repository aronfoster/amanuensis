---
step_id: storyboard_review
review_required: true
inputs:
  - <chapter-folder>/storyboards/*-storyboard.md
  - <chapter-folder>/scene-list.md
outputs:
  - <chapter-folder>/storyboards/storyboard-review.md
preconditions:
  - path: <chapter-folder>/storyboards/*-storyboard.md
    kind: source
    required: true
    review_sensitive: false
  - path: <chapter-folder>/scene-list.md
    kind: source
    required: true
    review_sensitive: false
---

See `agents/orchestrator.md` for the step workflow contract.

# Storyboard Review

## Purpose

Flag where a chapter's storyboard blocks under-serve the reader: takeaways the storyboard does not support, reveals with no prior setup, and takeaways that contradict their own concealment. This step is read-only, report-only, and advisory: it produces a per-block report for a human to read. It runs after `storyboarding` and before `drafting`. It is purely diagnostic — it proposes no fixes and there is no paired fix step (a `storyboard_review_fix` is a future milestone); the human reads the report and revises the storyboards by hand.

## Inputs

- `<chapter-folder>/storyboards/*-storyboard.md` — all storyboard blocks for the chapter. The block fields drive the three checks below: `reader_takeaway` for all three; the `beat` description, `must_preserve`, `canon_active`, and character-state fields for takeaway support; `concealment_from_reader` for setup and consistency.
- `<chapter-folder>/scene-list.md` — read only for canonical scene/beat ordering and scene-level reveal intent. It anchors the reveal-setup check's ordering of blocks.

Do not read any other files. In particular, do not read any draft — none exists at this stage — and do not consult source canon files: each block's fields are self-contained for what this step evaluates. A field that is missing or unparseable is a storyboard defect to note, not a reason to reach for source files.

## Behavior

Read all storyboard blocks for the chapter in order — by `scene-list.md` scene order, then `beat_index`. For each block, run the three checks below. Record one entry per block in `storyboard-review.md`.

### Output file format

Begin each run's section with a dated header:

```markdown
## Storyboard Review — [chapter/scene id], [date]
```

If a block is fully clean across all three checks, record a single line:

```markdown
### Block NNN — CLEAN
```

If a block has any finding, record only the findings — not the passing checks:

```markdown
### Block NNN
- UNSUPPORTED (reader_takeaway): [beat] — [takeaway] has no on-page support in the beat's content
- UNSETUP (reveal): [beat] — depends on [understanding] with no prior setup in the chapter
- CONTRADICTION (reader_takeaway vs concealment_from_reader): [beat] — takeaway "[…]" requires naming what concealment forbids "[…]"
```

Use only the finding types that apply. Do not record passing checks alongside findings. Do not include a draft-version stamp of any kind (there is no draft to stamp) and do not add any FIX/SKIP/ESCALATE annotation grammar — this report is advisory-only and no consumer for annotations exists.

Work block by block. Do not collapse findings across blocks.

#### Check 1: Takeaway supported

Source fields: `reader_takeaway`, checked against the `beat` description, `must_preserve`, `canon_active`, and character-state fields.

For each block, confirm the beat's own content gives the drafter the material to land the block's `reader_takeaway`. If the takeaway asserts an understanding the beat provides no on-page support for, record an `UNSUPPORTED` finding. If supported, do not record it.

#### Check 2: Reveal setup

Source fields: `reader_takeaway`, `beat_type`, `concealment_from_reader`, ordered by `scene-list.md` scene order then `beat_index`.

For each block whose `reader_takeaway` depends on the reader already understanding something — including every `beat_type: reveal` block — confirm that an earlier block establishes that understanding (via its `reader_takeaway` or content) and that the depended-on fact is not still listed under `concealment_from_reader` at that earlier point. If no prior setup exists, record an `UNSETUP` finding. If setup exists, do not record it.

This check is within-chapter only. Cross-chapter and story-level reveal tracking are deferred; do not reason about blocks outside the current chapter.

#### Check 3: Takeaway/concealment consistency guard

Source fields: `reader_takeaway`, `concealment_from_reader`.

For each block, confirm its `reader_takeaway` does not require the reader to grasp something the same block's `concealment_from_reader` forbids naming or clarifying. If they conflict, record a `CONTRADICTION` finding. If consistent, do not record it.

### At the end of the report

After all blocks, append a summary:

```markdown
### Summary

- Unsupported takeaways: N
- Reveals without setup: N
- Takeaway/concealment contradictions: N
- Blocks fully clean: N of N

[Any pattern-level observation — e.g. "unsetup reveals cluster in scene 03" — goes here. One or two lines only. Do not propose fixes.]
```

Do not propose fixes. The summary observation is a diagnostic, not a recommendation. This step never rewrites a storyboard block: it is read-only over the storyboards it reviews.

## Outputs

- `<chapter-folder>/storyboards/storyboard-review.md` — the advisory report. One `## Storyboard Review — [chapter/scene id], [date]` header per run, one `### Block NNN` entry per storyboard block (either a single `CLEAN` line or a list of findings), and a `### Summary` block per run tallying findings by check and noting any pattern-level observation. It is written beside the storyboards it reviews because no `drafts/<latest-attempt>/` folder exists yet — the other report steps write into a draft attempt folder because they review a draft; this step runs before any draft attempt exists. The file is the human review artifact: the human reads it and revises the storyboards by hand before `drafting`.

## Anti-Patterns

**Proposing fixes or rewriting storyboards.** This step is advisory and read-only. If the review pass rewrites a block or recommends a specific revision, it has failed. There is no paired fix step; revision is the human's job.

**Recording passing checks.** Clean checks are not recorded. A block entry is either one line (`CLEAN`) or a list of findings only. Passing items alongside findings inflate the file and defeat the purpose of the format.

**Consulting files not listed as inputs.** If a block's fields are too thin to evaluate a check, that is a storyboard defect. Note it; do not reach for canon source files.

**Reasoning across chapters.** The reveal-setup check is within-chapter only. A takeaway that depends on setup from another chapter is out of scope for this step.

**Adding a draft-version stamp or annotation grammar.** Neither applies to a pre-draft advisory report: there is no draft to stamp against, and no fix step exists to consume annotations.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs (e.g., no storyboard blocks, a storyboard block whose fields cannot be parsed, or no `scene-list.md`), append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate inputs and do not write a partial report. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
