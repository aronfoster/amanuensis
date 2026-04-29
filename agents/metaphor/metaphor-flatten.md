# Metaphor Flatten

Generates literal rewrites for FLATTEN-marked entries in the working metaphors file. Does not write to the draft — that is the apply step's job.

---

## Inputs

- `xx-yy-metaphors.md` — the human-reviewed working file
- `xx-yy-draft.md` — the current prose, for the flagged sentence's surrounding paragraph

Do not read storyboard blocks, canon files, or voice.md. The identify entry plus the surrounding paragraph contains everything needed.

---

## Output

Append variants directly below each FLATTEN entry in `xx-yy-metaphors.md`:

```markdown
### Flatten Options
- **Original:** "[original quote]"
- **Variant A (plain):** "[paragraph with rewritten sentence]"
- **Variant B (textured):** "[paragraph with rewritten sentence]"
- **Variant C (rhythmic):** "[paragraph with rewritten sentence]"
```

Do not write to the draft. Do not select a variant. The human deletes the variants not wanted and leaves one.

---

## How to flatten an entry

For each FLATTEN entry in the working file:

**Step 1: Read the entry.**

Read the identify fields: tenor, implication, register fit. If the human has added corrections or notes below the action word, those take precedence over the original field values. Use the corrected understanding, not the original.

Then locate the flagged sentence in the draft and read its surrounding paragraph.

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

Show each variant inside the full paragraph it belongs to. Minimal collateral change to surrounding sentences. If a variant requires a small adjustment to an adjacent sentence for rhythm, make it and note it in brackets.

---

## Constraints

- Do not introduce new figurative comparisons. Variant B's specificity must come from concrete detail, not analogy.
- Do not lengthen the sentence significantly unless compression is the root of the problem.
- Match the diction level of surrounding prose.
- Preserve POV. The perceiving mind is Louise's, thirteen years old.
- Preserve block comment markers and scene breaks in any quoted paragraph context.

---

## Anti-Patterns

**Ignoring human corrections.** If the human has written a correction below the action word, it overrides the original field. Do not revert to the original assessment.

**Replacing one metaphor with another.** Variants must be figuratively inert. If a variant contains a comparison, rewrite it.

**Preserving the shape of the original sentence while swapping the vehicle.** Start the sentence over.

**Producing variants that all say the same thing at different lengths.** Each variant must represent a genuinely different approach to the line's job.

**Flattening the emotion out of the line.** Remove the figure, not the feeling.
