# Metaphor Replace

> This file is a subagent prompt contract used by the `metaphor_fix` step (`agents/steps/metaphor-fix.md`). It is not a top-level workflow. The `metaphor_fix` coordinator dispatches one subagent against this contract for each `REPLACE`-annotated entry in the working metaphors file.

Integrates a human-supplied replacement image for REPLACE-marked entries. Does not invent the replacement. Does not write to the draft — that is the apply step's job.

---

## Inputs

- The entry block from the working metaphors file — the human-reviewed REPLACE entry assigned to this subagent, carrying the target image supplied by the human inline
- The surrounding paragraph from the latest prose, supplied by the coordinator — the flagged sentence in its paragraph context

Do not read storyboard blocks, canon files, or the selected voice file or profile. The identify entry plus the surrounding paragraph contains everything needed.

---

## Output

Append integration versions directly below the REPLACE entry in the working metaphors file:

```markdown
### Replace Options
- **Original:** "[original quote]"
- **Target image:** "[human-supplied image]"
- **Version A (minimal):** "[paragraph with rewritten sentence]"
- **Version B (balanced):** "[paragraph with rewritten sentence]"
- **Version C (fuller):** "[paragraph with rewritten sentence]"
```

Each version is the full paragraph with the rewrite in place, so the human can assess the change in context. The substitution is sentence-level — keep collateral edits to surrounding sentences to the minimum the rewrite demands. Note any such adjustment in brackets.

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
- POV register — the project's established POV and voice constraints

**Step 3: Produce three versions at different levels of integration intensity.**

- **Version A — minimal:** the target image introduced with the lightest possible touch. Closest to the original sentence's length and structure.
- **Version B — balanced:** the target image integrated at standard depth. The sentence earns the image without foregrounding it.
- **Version C — fuller:** the target image given slightly more room. Use only if the register warrants it and the paragraph can absorb it without crowding.

**Step 4: Embed each version in its paragraph.**

Show each version inside the full paragraph so the human can assess the integration in context. Keep collateral change to surrounding sentences to the minimum the rewrite demands. Note any such adjustment in brackets.

---

## Constraints

- Do not modify the target image. Integrate it as given.
- Do not introduce additional figures elsewhere in the paragraph.
- If the target image does not fit the sentence's grammatical structure, reshape the sentence around the image — not the image around the sentence.
- Preserve the project's established POV and voice constraints.
- Preserve block comment markers and scene breaks in any quoted paragraph context.

---

## Anti-Patterns

**Ignoring human corrections.** If the human has written a correction below the action word, it overrides the original field. Do not revert to the original assessment.

**Improving the supplied image.** The human chose it. Integrate it as given.

**Crowding.** If an adjacent sentence already carries a live figure, Version A is the default.

**Producing three versions that differ only in word count.** Each version must represent a genuine difference in how much weight the image is asked to carry.

**Reintroducing the uninvited properties of the original.** The new sentence must not bring them back through similar phrasing.
