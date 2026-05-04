# Metaphor Apply

Substitutes the surviving variants from the working metaphors file into the draft. Produces a new draft file. The terminal step of the metaphor pipeline.

---

## Inputs

- `xx-yy-metaphors.md` — the working file after human selection. Each surviving entry carries the variant the human kept.
- `xx-yy-draft.md` — the current prose

Do not read the storyboard, canon files, or the selected voice file or profile. The variants have already been generated and chosen under those constraints. Apply locates each change in the draft and integrates it; it does not re-evaluate the rewrite.

---

## Output

`xx-yy-draft-metaphor.md` in the chapter folder. Identical to `xx-yy-draft.md` except for the substitutions described below.

Do not modify `xx-yy-draft.md` or `xx-yy-metaphors.md`.

---

## How to apply

For each entry in `xx-yy-metaphors.md` that carries a surviving variant:

**Step 1: Identify the surviving variant.**

Find what the human left beneath the entry's flag. After human selection there is normally a single variant. The variant may take any of the forms the upstream steps produce:

- A FLATTEN variant — typically a paragraph with a rewritten sentence in place
- A REPLACE version — typically a paragraph with the new image integrated
- A WORKSHOP candidate — typically a single sentence

If the entry is ambiguous — multiple variants left in, or none — use your best understanding of what the human meant. If the human edited a variant inline, that edited form is the target. If multiple variants remain but one is clearly more recent or annotated as chosen, use it. If the entry has been deleted entirely, skip it. Note the call you made in the apply log.

**Step 2: Locate the change in the draft.**

Find the original sentence using the entry's `Quote` field. Treat the quote as a guide, not a string to match. Minor differences — punctuation, smart vs. straight quotes, whitespace, a typo on either side, an em-dash that became a comma — should not stop you. Find the sentence the entry is clearly about and proceed.

If the surviving variant is a paragraph, identify the corresponding paragraph in the draft (the one containing the original sentence) as the substitution target.

If you genuinely cannot identify the target — the prose has shifted enough that no candidate is clearly the right one — note it in the apply log and move on. Do not guess wildly.

**Step 3: Substitute.**

- For a paragraph variant: replace the corresponding paragraph in the draft with the variant's paragraph. Bracketed adjustment notes the upstream step left in the variant are instructions, not literal text — apply the adjustment, drop the brackets.
- For a sentence variant: replace the original sentence with the new sentence and make the smallest collateral adjustments to neighboring sentences that the rewrite requires (pronoun continuity, a conjunction that no longer scans, content that now duplicates the variant).

**Step 4: Preserve everything else.**

Scene breaks, section headers, block comment markers, dialogue formatting, and any paragraph that contains no flagged figure must remain bit-identical to the source draft.

---

## Apply log

At the end of `xx-yy-draft-metaphor.md`, append a block comment:

```markdown
<!--
Apply log — xx-yy

- [entry label]: applied [variant ID]; [collateral note, or "no collateral change"]
- [entry label]: applied [variant ID]; resolved ambiguity by [reason]
- [entry label]: skipped — entry deleted / no surviving variant
- [entry label]: skipped — could not locate target in draft
-->
```

The log records every entry and every judgment call. It is the audit trail for this pass and does not survive into the published manuscript.

---

## Constraints

- Do not introduce new figurative comparisons. Only apply what the working file specifies.
- Do not re-flag, re-evaluate, or second-guess the rewrites themselves. The variants are the spec.
- Preserve the project's established POV and voice constraints.
- Preserve all scene breaks, headers, and block comment markers exactly.

---

## Anti-Patterns

**Halting on a near-match.** Quote and draft will sometimes diverge on punctuation, whitespace, or a stray typo. Use judgment to identify the target sentence and continue. Halt only when no candidate is clearly the right one.

**Editing beyond the substitution.** Do not improve unflagged sentences. Do not normalize style. If a variant exposes a weakness in a neighboring line, leave it for the next pass.

**Re-flowing surrounding prose.** Adjust only what grammar or pronoun continuity requires. Cadence preference is not a license to re-edit the paragraph.

**Silently dropping an entry.** Every entry must appear in the apply log: applied (with any judgment calls noted), or skipped (with the reason).

**Treating the variant as a draft.** The surviving variant is the chosen line. Apply it as written, except where bracketed notes from the upstream step direct an adjustment.

**Modifying the working file.** Apply reads from it. It does not write to it.
