---
step_id: compliance_report
review_required: true
inputs:
  - <chapter-folder>/storyboards/*-storyboard.md
  - <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md
---

See `agents/orchestrator.md` for the step workflow contract.

# Compliance Report

## Purpose

Report compliance violations between a chapter's storyboard blocks and its drafted prose. This step is read-only: it produces a per-block report of Must-Contain, Must-Not-Contain, and Canon-consistency violations for a human to triage. Fixing happens in the separate `compliance_fix` step. The report is the human review artifact that gates the fix step.

## Inputs

- `<chapter-folder>/storyboards/*-storyboard.md` — all storyboard blocks for the chapter. The block fields drive the three checks below: `must_preserve` and `character_state_out` for Must-Contain; `concealment_from_reader` and `concealment_from_characters` for Must-Not-Contain; `canon_active` for Canon.
- `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` — the drafted prose to evaluate against the storyboard blocks. Resolved at step start; this step does not mint a new draft version.

Do not read any other files. In particular, do not consult source canon files: each block's `canon_active` field is supposed to contain everything needed to evaluate a canon check.

## Behavior

Read all storyboard blocks for the scene in order. For each block, run the three checks below against the corresponding prose range. Record one entry per block in `reviewer-actions.md`.

### Output file format

Append — do not overwrite. Begin each run with a header followed by a `Reviewed-draft:` line naming the resolved `<latest-draft>` filename (e.g. `draft-v03.md`). The stamp lets `compliance_fix` detect stale annotations when a newer draft has been minted since this report was written.

```markdown
## Compliance Report — Scene [scene-id], [date]
Reviewed-draft: draft-vNN.md
```

If a block is fully clean across all three checks, record a single line:

```markdown
### Block NNN — CLEAN
```

If a block has any violation, record only the violations — not the passing items:

```markdown
### Block NNN
- DEGRADED (must_preserve): [Item label] — [one sentence: what was required, what is wrong with what was written]. Prose: "[quote]"
- MISSING (must_preserve): [Item label] — not found in prose range
- NOT ENACTED (character_state_out): [CharacterName] — closing state "[spec]" not reached
- VIOLATED (concealment_from_reader): "[quote]" names or implies [what it reveals]
- VIOLATED (concealment_from_characters): [Character A]'s [X] accessible to [Character B] — "[quote]"
- INCONSISTENT (canon): [Mechanic label] — "[quote]" violates rule: "[rule as stated in block]"
```

Use only the violation types that apply. Do not record passing items alongside violations.

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

[Any pattern-level observation — e.g. "violations cluster in blocks 011 and 050" — goes here. One or two lines only. Do not propose fixes.]
```

Do not propose fixes. The summary observation is a diagnostic, not a recommendation.

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md` — append-only compliance report. Begins with a `## Compliance Report — Scene [scene-id], [date]` header for this run, immediately followed by a `Reviewed-draft: draft-vNN.md` line naming the `<latest-draft>` this run reviewed, then one `### Block NNN` entry per storyboard block (either a single `CLEAN` line or a list of violations), and ends with a `### Summary` block tallying violations by check type and noting any pattern-level observation. The `Reviewed-draft` stamp is required so `compliance_fix` can detect stale annotations against a newer draft. The file is the human review artifact that the human annotates with `FIX` / `FIX: [instruction]` / `SKIP` / `ESCALATE` before `compliance_fix` runs.

## Anti-Patterns

**Fixing during reporting.** This step is read-only. If the reporting pass rewrites anything, it has failed. Prose changes are the `compliance_fix` step's job.

**Recording passing items.** Clean checks are not recorded. A block entry is either one line (`CLEAN`) or a list of violations only. Passing items alongside violations inflate the file and defeat the purpose of the format.

**Collapsing blocks.** Report findings block by block. Pattern-level observations belong only in the summary.

**Consulting files not listed as inputs.** If a storyboard block's `canon_active` field is insufficient to evaluate a canon check, that is a storyboard defect. Note it; do not reach for the source file.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs (e.g., no storyboard files, no draft, or a storyboard block whose fields cannot be parsed), append the blocker to the project root `open-questions.md` and exit without advancing the pipeline marker. Do not fabricate inputs and do not write a partial report. The next dispatcher invocation will re-run this step after the human resolves the blocker.
