# Compliance

Two-phase workflow. Phase 1 reports violations. Phase 2 fixes them. Do not combine phases.

---

## Phase 1: Reporting

### Inputs

- All storyboard blocks for the chapter (`xx-yy-zzz-storyboard.md`)
- The drafted prose (`xx-yy-draft.md`)
- Canon files listed in each block's `canon_active` field

Do not read any other files.

### Output

`reviewer-actions.md` in the current attempt folder. Append — do not overwrite. Begin each run with a header:

```markdown
## Compliance Report — Scene xx-yy, [date]
```

### How to run the report

Read all storyboard blocks for the scene in order. For each block, run three checks against the corresponding prose range. Record one entry per block in `reviewer-actions.md`.

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

---

#### Check 1: Must-Contain

Source fields: `must_preserve`, `character_state_out`.

For each item in `must_preserve`: locate the prose that enacts it. If absent or degraded, record a violation. If present, do not record it.

For each character in `character_state_out`: confirm the prose has moved that character to the stated closing state. If the closing state is not enacted, record a violation. If enacted, do not record it.

---

#### Check 2: Must-Not-Contain

Source fields: `concealment_from_reader`, `concealment_from_characters`.

For each item in `concealment_from_reader`: scan the prose for any naming, explaining, or clarifying of the forbidden fact. If found, record the violating quote and identify what it reveals. If clean, do not record it.

For each item in `concealment_from_characters`: scan for any moment where Character A's hidden information becomes accessible to Character B through dialogue, action, or narratorial slip. If found, record it. If clean, do not record it.

---

#### Check 3: Canon

Source field: `canon_active`.

For each canon mechanic listed: confirm the prose is consistent with the rule as stated in the block. Do not consult the source canon files directly unless the block's `canon_active` field is ambiguous — the block is supposed to contain everything the drafter needed.

If the prose enacts a mechanic in a way that the block's compliant/non-compliant examples would classify as non-compliant, record a violation. If consistent, do not record it.

---

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

Do not propose fixes in Phase 1. The summary observation is a diagnostic, not a recommendation.

---

## Phase 2: Fixing

### When to run

After a human has reviewed `reviewer-actions.md` and annotated each violation with one of:

- `FIX` — apply the obvious local edit
- `FIX: [instruction]` — apply the fix as specified
- `SKIP` — leave as-is; violation accepted
- `ESCALATE` — conflict cannot be resolved by local edit; flag for storyboard or canon revision

Do not run Phase 2 against an unannotated report.

### Inputs

- The annotated `reviewer-actions.md`
- The drafted prose (`xx-yy-draft.md`)
- The storyboard blocks for any `FIX` items

Do not read canon files during Phase 2. If a fix requires canon clarification, it should have been marked `ESCALATE`.

### Output

Revised prose in `xx-yy-draft.md`. For each `FIX` item applied, append to `reviewer-actions.md`:

```markdown
#### Applied: [Item label]
- Change: [one line describing what changed]
- Prose before: "[original quote]"
- Prose after: "[revised quote]"
```

For each `ESCALATE` item, append:

```markdown
#### Escalated: [Item label]
- Reason: [one line — why local edit cannot resolve this]
- Suggested upstream target: [storyboard block / canon file / open question]
```

### Constraints

- Fix only what is annotated `FIX`. Do not improve, tighten, or rewrite prose beyond the violation.
- If a fix to one violation would introduce a new violation, stop and append a note rather than proceeding.
- Preserve block comment markers (`<!-- scene x, beat y -->`) and scene breaks (`---`).

---

## Anti-Patterns

**Fixing during reporting.** Phase 1 is read-only. If the reporting pass rewrites anything, it has failed.

**Recording passing items.** Clean checks are not recorded. A block entry is either one line (`CLEAN`) or a list of violations only. Passing items alongside violations inflate the file and defeat the purpose of the format.

**Collapsing blocks.** Report findings block by block. Pattern-level observations belong only in the summary.

**Consulting files not listed as inputs.** If a storyboard block's `canon_active` field is insufficient to evaluate a canon check, that is a storyboard defect. Note it; do not reach for the source file.

**Fixing unannotated violations.** Phase 2 requires human annotation. An unannotated `reviewer-actions.md` is not a valid input.

**Rewriting beyond the violation.** The fix pass is surgical. Prose quality improvements are a separate workflow.
