# Metaphor Replace

Integrates a human-supplied replacement image for REPLACE-marked entries. Does not invent the replacement. Does not write to the draft — that is the apply step's job.

---

## Inputs

- `xx-yy-metaphors.md` — the human-reviewed working file; each REPLACE entry carries the target image supplied by the human inline
- `xx-yy-draft.md` — the current prose, for the flagged sentence's surrounding paragraph

Do not read storyboard blocks, canon files, or voice.md. The identify entry plus the surrounding paragraph contains everything needed.

---

## Output

Append integration versions directly below each REPLACE entry in `xx-yy-metaphors.md`:

```markdown
### Replace Options
- **Original:** "[original quote]"
- **Target image:** "[human-supplied image]"
- **Version A (minimal):** "[paragraph with rewritten sentence]"
- **Version B (balanced):** "[paragraph with rewritten sentence]"
- **Version C (fuller):** "[paragraph with rewritten sentence]"
```

Do not write to the draft. Do not select a version. The human deletes the versions not wanted and leaves one.

---

## How to integrate a replacement image

For each REPLACE entry in the working file:

**Step 1: Read the entry.**

Read the identify fields: tenor, implication, register fit. If the human has added corrections or notes below the action word, those take precedence over the original field values. Use the corrected understanding, not the original.

The human has also supplied a target image. Your job is to make that image fit the sentence, paragraph, and register — not to evaluate whether it is the right choice.

**Step 2: Identify integration constraints.**

From the tenor, implication, and register fit — corrected if necessary — and from the flagged sentence's surrounding paragraph, establish:

- The diction level of surrounding sentences
- Whether surrounding lines are figurative or plain — do not crowd the new figure
- The sentence's rhythmic position in the paragraph
- POV register — the perceiving mind is Louise's, thirteen years old

**Step 3: Produce three versions at different levels of integration intensity.**

- **Version A — minimal:** the target image introduced with the lightest possible touch. Closest to the original sentence's length and structure.
- **Version B — balanced:** the target image integrated at standard depth. The sentence earns the image without foregrounding it.
- **Version C — fuller:** the target image given slightly more room. Use only if the register warrants it and the paragraph can absorb it without crowding.

**Step 4: Embed each version in its paragraph.**

Show each version inside the full paragraph. Note any collateral adjustments to adjacent sentences in brackets.

---

## Constraints

- Do not modify the target image. Integrate it as given.
- Do not introduce additional figures elsewhere in the paragraph.
- If the target image does not fit the sentence's grammatical structure, reshape the sentence around the image — not the image around the sentence.
- Preserve POV.
- Preserve block comment markers and scene breaks in any quoted paragraph context.

---

## Anti-Patterns

**Ignoring human corrections.** If the human has written a correction below the action word, it overrides the original field. Do not revert to the original assessment.

**Improving the supplied image.** The human chose it. Integrate it as given.

**Crowding.** If an adjacent sentence already carries a live figure, Version A is the default.

**Producing three versions that differ only in word count.** Each version must represent a genuine difference in how much weight the image is asked to carry.

**Reintroducing the uninvited properties of the original.** The new sentence must not bring them back through similar phrasing.
