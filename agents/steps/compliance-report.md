---
step_id: compliance_report
review_required: true
inputs:
  - <chapter-folder>/storyboards/*-storyboard.md
  - <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md
preconditions:
  - path: <chapter-folder>/storyboards/*-storyboard.md
    kind: source
    required: true
    review_sensitive: false
  - path: <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
    kind: prose_draft
    required: true
    review_sensitive: false
---

See `agents/orchestrator.md` for the step workflow contract.

# Compliance Report

## Purpose

Report compliance violations between a chapter's storyboard blocks and its drafted prose. This step is read-only: it produces a per-block report of Must-Contain, Must-Not-Contain, and Canon-consistency violations for a human to triage. Fixing happens in the separate `compliance_fix` step. The report is the human review artifact that gates the fix step.

## Inputs

- `<chapter-folder>/storyboards/*-storyboard.md` — all storyboard blocks for the chapter. The block fields drive the three checks below: `must_preserve` and `character_state_out` for Must-Contain; `concealment_from_reader` and `concealment_from_characters` for Must-Not-Contain; `canon_active` for Canon.
- `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` — the drafted prose to evaluate against the storyboard blocks. Resolved at step start via the manifest's active head — or via the read-from override the dispatcher passed — per `agents/project-layouts.md`, not by highest-numbered draft; this step does not mint a new draft version.

Do not read any other files. In particular, do not consult source canon files: each block's `canon_active` field is supposed to contain everything needed to evaluate a canon check.

## Behavior

Read all storyboard blocks for the scene in order. For each block, run the three checks below against the corresponding prose range. Record one entry per block in `reviewer-actions.md`.

### Output file format

The file begins with a single top-of-file `Reviewed-draft:` line naming the resolved `<latest-draft>` filename (e.g. `draft-v03.md`) — the draft this run actually read, so when a read-from override is in effect the stamp names that draft; the stamp lets `compliance_fix` detect stale annotations when a newer draft has been minted since this report was written. If the file does not exist, create it with the stamp. If the file exists and its top-of-file stamp equals `<latest-draft>`, append this run's per-scene sections beneath the existing content. If the file exists and its top-of-file stamp does not equal `<latest-draft>` — the recovery path when the human is regenerating after a stale-report blocker — the report is `regenerated`: **overwrite the whole file** with a fresh top-of-file stamp, and the prior run's findings against the superseded draft are `discarded`. See the general freshness contract in `agents/orchestrator.md`'s Artifact-state section (the report→fix freshness invariant is its canonical worked instance). On the append path, new items' review-ids must not collide with any already in the file — same epoch, same uniqueness scope: when a block already has anchored violations from an earlier run against this draft, continue that block's `v<KK>` ordinals rather than restarting at `v01` where a collision would result.

Below the top-of-file stamp, begin each scene's section with a dated header:

```markdown
Reviewed-draft: draft-vNN.md

## Compliance Report — Scene [scene-id], [date]
```

If a block is fully clean across all three checks, record a single line:

```markdown
### Block NNN — CLEAN
```

CLEAN blocks are not review units: exactly one line, no anchor, no decision fields. They never appear in the review-unit count.

If a block has any violation, record only the violations — not the passing items. Each violation line is one review unit: it gets a `<!-- review-id: ... -->` anchor on its own line immediately above it, and blank `- Decision:` / `- Decision-note:` fields nested one level below it:

```markdown
### Block NNN
<!-- review-id: compliance:[scene-id]:block-NNN-v01 -->
- DEGRADED (must_preserve): [Item label] — [one sentence: what was required, what is wrong with what was written]. Prose: "[quote]"
  - Decision:
  - Decision-note:
<!-- review-id: compliance:[scene-id]:block-NNN-v02 -->
- MISSING (must_preserve): [Item label] — not found in prose range
  - Decision:
  - Decision-note:
<!-- review-id: compliance:[scene-id]:block-NNN-v03 -->
- NOT ENACTED (character_state_out): [CharacterName] — closing state "[spec]" not reached
  - Decision:
  - Decision-note:
<!-- review-id: compliance:[scene-id]:block-NNN-v04 -->
- VIOLATED (concealment_from_reader): "[quote]" names or implies [what it reveals]
  - Decision:
  - Decision-note:
<!-- review-id: compliance:[scene-id]:block-NNN-v05 -->
- VIOLATED (concealment_from_characters): [Character A]'s [X] accessible to [Character B] — "[quote]"
  - Decision:
  - Decision-note:
<!-- review-id: compliance:[scene-id]:block-NNN-v06 -->
- INCONSISTENT (canon): [Mechanic label] — "[quote]" violates rule: "[rule as stated in block]"
  - Decision:
  - Decision-note:
```

Use only the violation types that apply. Do not record passing items alongside violations.

The review-id follows the `compliance:` family segment grammar in `agents/review-grammars.yaml`: short_story form `compliance:<scene-id>:block-<NNN>-v<KK>`, book form `compliance:<book-id>:<chapter-id>:<scene-id>:block-<NNN>-v<KK>`. `<NNN>` is the storyboard block number and `<KK>` the violation's ordinal within that block's entry — both already in the report; the location segments are derivable from the artifact's resolved path. Emit `Decision:` and `Decision-note:` blank — they belong to the human, and a blank `Decision:` means the unit is pending review. The fixture `examples/review/reviewer-actions.md` shows the exact target shape.

Work block by block. Do not collapse findings across blocks.

#### Check 1: Must-Contain

Source fields: `must_preserve`, `character_state_out`.

For each item in `must_preserve`: locate the prose that enacts it. If absent or degraded, record a violation. If present, do not record it.

For each character in `character_state_out`: confirm the prose has moved that character to the stated closing state. If the closing state is not enacted, record a violation. If enacted, do not record it.

#### Check 2: Must-Not-Contain

Source fields: `concealment_from_reader`, `concealment_from_characters`.

For each item in `concealment_from_reader`: scan the prose for any naming, explaining, or clarifying of the forbidden fact. If found, record the violating quote and identify what it reveals. If clean, do not record it.

For each item in `concealment_from_characters`: scan for any moment where Character A's hidden information becomes accessible to Character B through dialogue, action, or narratorial slip. If found, record it. If clean, do not record it.

#### Check 3: Canon

Source field: `canon_active`.

For each canon mechanic listed: confirm the prose is consistent with the rule as stated in the block. Do not consult the source canon files directly unless the block's `canon_active` field is ambiguous — the block is supposed to contain everything the drafter needed.

If the prose enacts a mechanic in a way that the block's compliant/non-compliant examples would classify as non-compliant, record a violation. If consistent, do not record it.

### At the end of the report

After all blocks, append a summary:

```markdown
### Summary

- Must-Contain violations: N
- Must-Not-Contain violations: N
- Canon violations: N
- Blocks fully clean: N of N
- Review units emitted: N

[Any pattern-level observation — e.g. "violations cluster in blocks 011 and 050" — goes here. One or two lines only. Do not propose fixes.]
```

Do not propose fixes. The summary observation is a diagnostic, not a recommendation.

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md` — the compliance report. Begins with a single top-of-file `Reviewed-draft: draft-vNN.md` line naming the `<latest-draft>` this report covers — the draft this run actually read; subsequent runs against the same draft append below, runs against a newer draft (recovery path) overwrite the file with a fresh stamp (the report is `regenerated`, the prior findings `discarded`). Then one `## Compliance Report — Scene [scene-id], [date]` header per scene-run, one `### Block NNN` entry per storyboard block (either a single `CLEAN` line — no anchor, no fields, not a review unit — or a list of violations, each carrying its `<!-- review-id: ... -->` anchor immediately above the violation line and blank `- Decision:` / `- Decision-note:` fields nested below it), and a `### Summary` block per run tallying violations by check type, reporting the review units emitted this run, and noting any pattern-level observation. The `Reviewed-draft` stamp is required so `compliance_fix` can detect stale annotations against a newer draft. The file is the human review artifact: the human records decisions in each unit's `Decision:` field per the `compliance:` family grammar in `agents/review-grammars.yaml` before `compliance_fix` runs.

## Anti-Patterns

**Fixing during reporting.** This step is read-only. If the reporting pass rewrites anything, it has failed. Prose changes are the `compliance_fix` step's job.

**Recording passing items.** Clean checks are not recorded. A block entry is either one line (`CLEAN`) or a list of anchored violations only. Passing items alongside violations inflate the file and defeat the purpose of the format.

**Filling decision fields.** `Decision:` and `Decision-note:` are emitted blank. They belong to the human; a report that pre-fills a decision — however obvious — has decided instead of reported, and a blank `Decision:` is the only honest signal that a unit is still pending.

**Anchoring CLEAN blocks.** A CLEAN block is one line, no anchor, no fields. An anchor turns it into a countable review unit and inflates the ledger with items that need no decision.

**Collapsing blocks.** Report findings block by block. Pattern-level observations belong only in the summary.

**Consulting files not listed as inputs.** If a storyboard block's `canon_active` field is insufficient to evaluate a canon check, that is a storyboard defect. Note it; do not reach for the source file.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs (e.g., no storyboard files, no draft, or a storyboard block whose fields cannot be parsed), append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate inputs and do not write a partial report. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
