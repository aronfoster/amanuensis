# Metaphor Flatten

> This file is a subagent prompt contract used by the `metaphor_fix` step (`agents/steps/metaphor-fix.md`). It is not a top-level workflow. The `metaphor_fix` coordinator dispatches one subagent against this contract for each `FLATTEN`-annotated entry in the working metaphors file.

Generates literal rewrites for FLATTEN-marked entries in the working metaphors file. Does not write to the draft — that is the apply step's job.

---

## Inputs

- The entry block from the working metaphors file — the human-reviewed FLATTEN entry assigned to this subagent
- The surrounding paragraph from the latest prose, supplied by the coordinator — the flagged sentence in its paragraph context

Do not read storyboard blocks, canon files, or the selected voice file or profile. The identify entry plus the surrounding paragraph contains everything needed.

---

## Output

Append variants directly below the FLATTEN entry in the working metaphors file, as a `#### ` section (a level below the figure's `### ` heading, inside the anchored unit):

```markdown
#### Flatten Options
- **Original:** "[original quote]"
- **Variant A (plain):** "[paragraph with rewritten sentence]"
- **Variant B (textured):** "[paragraph with rewritten sentence]"
- **Variant C (rhythmic):** "[paragraph with rewritten sentence]"
```

Each variant is the full paragraph with the rewrite in place, so the human can assess the change in context. The substitution is sentence-level — keep collateral edits to surrounding sentences to the minimum the rewrite demands (pronoun continuity, a conjunction that no longer scans). Note any such adjustment in brackets.

The per-variant labels `A` / `B` / `C` are the stable variant ids: the human records the chosen one in the entry's `- Selected:` field, so keep them exactly as shown and do not renumber.

Do not write to the draft. Do not select a variant. The human records the chosen variant id in the entry's `- Selected:` field; the unchosen variants stay in the file as the audit record.

---

## How to flatten an entry

For each FLATTEN entry in the working file:

**Step 1: Read the entry.**

Read the identify fields: tenor, implication, register fit. If the human has recorded corrections or notes in the entry's `- Decision-note:`, those take precedence over the original field values. Use the corrected understanding, not the original.

Then read the surrounding paragraph supplied by the coordinator and locate the flagged sentence within it.

**Step 2: Establish what the line must do.**

From the tenor, implication, and register fit — corrected if necessary — determine:

- What information the sentence carries
- What emotional temperature it must hold
- What must not change about the sentence's effect

Do not output this reasoning.

**Step 3: Produce three variants.**

Each variant removes the figurative comparison entirely. No new vehicles. The variants differ in how they carry the line's job:

- **Variant A — plain literal:** the simplest rewrite that preserves the narrative fact. Prioritizes clarity over texture.
- **Variant B — textured literal:** concrete physical or sensory detail without figurative comparison. Preserves atmosphere through specificity, not analogy.
- **Variant C — rhythmic literal:** prioritizes cadence and weight. May be close in length to the original. The line earns its place through sentence structure, not imagery.

**Step 4: Embed each variant in its paragraph.**

Show each variant inside the full paragraph it belongs to so the human can assess the rewrite in context. Keep collateral change to surrounding sentences to the minimum the rewrite demands. Note any such adjustment in brackets.

---

## Constraints

- Do not introduce new figurative comparisons. Variant B's specificity must come from concrete detail, not analogy.
- Do not lengthen the sentence significantly unless compression is the root of the problem.
- Match the diction level of surrounding prose.
- Preserve the project's established POV and voice constraints.
- Preserve block comment markers and scene breaks in any quoted paragraph context.

---

## Anti-Patterns

**Ignoring human corrections.** If the human recorded a correction in the entry's `- Decision-note:`, it overrides the original field. Do not revert to the original assessment.

**Replacing one metaphor with another.** Variants must be figuratively inert. If a variant contains a comparison, rewrite it.

**Preserving the shape of the original sentence while swapping the vehicle.** Start the sentence over.

**Producing variants that all say the same thing at different lengths.** Each variant must represent a genuinely different approach to the line's job.

**Flattening the emotion out of the line.** Remove the figure, not the feeling.
