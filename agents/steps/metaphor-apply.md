---
step_id: metaphor_apply
review_required: false
inputs:
  - <chapter-folder>/drafts/<latest-attempt>/metaphors.md
  - <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/<next-draft>
  - <chapter-folder>/drafts/<latest-attempt>/metaphors.md
  - <chapter-folder>/drafts/<latest-attempt>/draft-manifest.md
preconditions:
  - path: <chapter-folder>/drafts/<latest-attempt>/metaphors.md
    kind: side_artifact
    required: true
    review_sensitive: true
  - path: <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
    kind: prose_draft
    required: true
    review_sensitive: false
---

See `agents/orchestrator.md` for the step workflow contract.

# Metaphor Apply

## Purpose

Substitutes the surviving variants from the working metaphors file into the draft. Produces a new draft file. The terminal step of the metaphor pipeline: it integrates the variants the human selected after `metaphor_fix` ran, without re-evaluating them.

## Inputs

- `<chapter-folder>/drafts/<latest-attempt>/metaphors.md` — the working file after human selection. Each surviving entry carries the variant the human kept. Unlike the annotation-grammar reports, `metaphor_apply` has no `FIX`/`SKIP`/`ESCALATE` gate; under the general contract (`agents/orchestrator.md`'s **Artifact state** section, review surfaced not enforced) its review evidence is the human's selection here — a surviving variant per entry. A `metaphors.md` with no surviving variant carries no such evidence and is handled by the existing missing/ambiguous-input blocker, not a manufactured unannotated-report gate. Variants may be FLATTEN paragraphs, REPLACE paragraphs, or WORKSHOP sentences. Note: since `metaphor_fix`'s workshop subagent no longer runs an integration phase (the integration phase was removed; integration now happens here), surviving WORKSHOP entries arrive as bare individual sentences rather than fully-integrated paragraphs. Step 3 of Behavior already handles this through its "sentence variant" branch — no behavior change is required, but you should not be surprised to see workshop variants as one-line candidates.

  At step start, before substituting any variant, read the `Reviewed-draft: draft-vNN.md` header at the top of `metaphors.md` and confirm it equals `<latest-draft>`. This is the consumption-time check of the general freshness contract stated in `agents/orchestrator.md`'s **Artifact state** section: `metaphors.md` is `fresh` iff its stamp equals the current `<latest-draft>` (the manifest's active head) and `stale` otherwise — a predicate derived here at step start, never stored. If the stamp does not match, the input is `stale`; see "Open questions handling" below for the stale-report blocker (the report→fix freshness invariant is that contract's named worked instance), unless the human recorded an override — see "Overrides" below.
- `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` — the current prose (the latest prose-revising step's output before this one). Resolved at step start via the manifest's `Active-head:` pointer (the active head), or via the read-from override the dispatcher passed, per `agents/project-layouts.md` — not by highest-numbered draft.

Do not read the storyboard, canon files, or the selected voice file or profile. The variants have already been generated and chosen under those constraints. Apply locates each change in the draft and integrates it; it does not re-evaluate the rewrite.

## Behavior

For each entry in `metaphors.md` that carries a surviving variant:

**Step 1: Identify the surviving variant.**

Find what the human left beneath the entry's flag. After human selection there is normally a single variant. The variant may take any of the forms the upstream steps produce:

- A FLATTEN variant — typically a paragraph with a rewritten sentence in place
- A REPLACE version — typically a paragraph with the new image integrated
- A WORKSHOP candidate — a single sentence (the workshop subagent no longer integrates the candidate into a paragraph; that integration is this step's job)

If the entry is ambiguous — multiple variants left in, or none — use your best understanding of what the human meant. If the human edited a variant inline, that edited form is the target. If multiple variants remain but one is clearly more recent or annotated as chosen, use it. If the entry has been deleted entirely, skip it. Note the call you made in the apply log.

**Step 2: Locate the change in the draft.**

Find the original sentence in `<latest-draft>` using the entry's `Quote` field. Treat the quote as a guide, not a string to match. Minor differences — punctuation, smart vs. straight quotes, whitespace, a typo on either side, an em-dash that became a comma — should not stop you. Find the sentence the entry is clearly about and proceed.

If the surviving variant is a paragraph, identify the corresponding paragraph in the draft (the one containing the original sentence) as the substitution target.

If you genuinely cannot identify the target — the prose has shifted enough that no candidate is clearly the right one — note it in the apply log and move on. Do not guess wildly.

**Step 3: Substitute.**

- For a paragraph variant: replace the corresponding paragraph in the draft with the variant's paragraph. Bracketed adjustment notes the upstream step left in the variant are instructions, not literal text — apply the adjustment, drop the brackets.
- For a sentence variant: replace the original sentence with the new sentence and make the smallest collateral adjustments to neighboring sentences that the rewrite requires (pronoun continuity, a conjunction that no longer scans, content that now duplicates the variant). This branch is the path WORKSHOP variants now travel — the new sentence drops in where the old one stood, with surrounding prose adjusted only as necessary for grammar and continuity.

**Step 4: Preserve everything else.**

Scene breaks, section headers, block comment markers, dialogue formatting, and any paragraph that contains no flagged figure must remain bit-identical to the source draft.

### Apply log

At the end of `<next-draft>`, append a block comment:

```markdown
<!--
Apply log

- [entry label]: applied [variant ID]; [collateral note, or "no collateral change"]
- [entry label]: applied [variant ID]; resolved ambiguity by [reason]
- [entry label]: skipped — entry deleted / no surviving variant
- [entry label]: skipped — could not locate target in draft
- Override applied: metaphors.md — condition overridden: stale — report stamped draft-vNN.md, applied against draft-vMM.md; authorized by human-recorded Override block (emitted only when proceeding under a recorded override; see "Overrides")
-->
```

The log records every entry and every judgment call. It is the audit trail for this pass and does not survive into the published manuscript.

### Constraints

- Do not introduce new figurative comparisons. Only apply what the working file specifies.
- Do not re-flag, re-evaluate, or second-guess the rewrites themselves. The variants are the spec.
- Preserve the project's established POV and voice constraints.
- Preserve all scene breaks, headers, and block comment markers exactly.

### Anti-Patterns

**Halting on a near-match.** Quote and draft will sometimes diverge on punctuation, whitespace, or a stray typo. Use judgment to identify the target sentence and continue. Halt only when no candidate is clearly the right one.

**Editing beyond the substitution.** Do not improve unflagged sentences. Do not normalize style. If a variant exposes a weakness in a neighboring line, leave it for the next pass.

**Re-flowing surrounding prose.** Adjust only what grammar or pronoun continuity requires. Cadence preference is not a license to re-edit the paragraph.

**Silently dropping an entry.** Every entry must appear in the apply log: applied (with any judgment calls noted), or skipped (with the reason).

**Treating the variant as a draft.** The surviving variant is the chosen line. Apply it as written, except where bracketed notes from the upstream step direct an adjustment.

**Modifying the working file.** Apply reads from `metaphors.md`. It does not write to it.

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/<next-draft>` — identical to `<latest-draft>` except for the substitutions described above, with the apply-log block comment appended at the end. Written as the next versioned draft file: `<next-draft>` is the highest existing draft number + 1 (monotonic; per `agents/project-layouts.md`), not one greater than the draft read, so a branch rerun never collides with an existing file. Do not modify `<latest-draft>` or `metaphors.md`.
- `<chapter-folder>/drafts/<latest-attempt>/metaphors.md` — unchanged in content by this step; listed as an output only because the manifest entry records it as the side artifact consulted. The apply log for this run lives in the block comment at the end of `<next-draft>`, not here.
- `<chapter-folder>/drafts/<latest-attempt>/draft-manifest.md` — append a per-version entry for `<next-draft>` after a successful prose write, following the schema in `agents/project-layouts.md`. `read_from` names the draft this step actually read (the active head, or the read-from override); `timestamp` is the write time (ISO 8601 with timezone offset); `review_gate` is this step's `review_required` value (`false`). Example:

  ```markdown
  ## draft-v04.md
  - produced_by: metaphor_apply
  - read_from: [draft-v03.md]
  - timestamp: 2026-05-18T16:41:09-06:00
  - review_gate: false
  - side_artifacts: [metaphors.md]
  - apply_log: apply log at end of `draft-v04.md`
  ```

## Overrides

The freshness check above blocks by default: a `stale` `metaphors.md` is sent to "Open questions handling" and no prose is written. A human may authorize proceeding against a `stale` input by recording an override, per `agents/orchestrator.md`'s **Artifact state** section. This is the only path by which this step applies against a `stale` input, and it never happens silently. `metaphor_apply` has no annotation-grammar report, so on the review axis its evidence is the human's selection in `metaphors.md`; a `metaphors.md` with no surviving variant is its `review_pending` analog, handled as a missing/ambiguous input above rather than as a manufactured annotation gate.

**Where the human records it.** A human-authored `Override:` block placed in `metaphors.md` — the side artifact this step already reads at step start — naming the specific artifact and the condition overridden. It is not a new frontmatter or manifest field. Shape, for a stale input:

```markdown
Override: proceed despite stale — metaphors.md stamped draft-vNN.md, current <latest-draft> is draft-vMM.md. Authorized by human.
```

or, for a review-pending input:

```markdown
Override: proceed despite review_pending — metaphors.md carries no review annotations. Authorized by human.
```

The override must name the specific artifact and the draft mismatch (for stale) or the review-pending condition.

**Recognition at step start.** After computing freshness, if `metaphors.md` is `stale` (or `review_pending` on the selection axis), look for a matching `Override:` block that names `metaphors.md` and the same condition. If a matching block is present, proceed with the substitution. If none is present, block to `open-questions.md` exactly as today — the stale path is unchanged in the no-override case.

**Recording.** On proceeding under an override, record it in this step's apply log — which for `metaphor_apply` is the block comment appended at the end of `<next-draft>` (not `metaphors.md`, which this step never writes) — folding the record into that apply-log block comment, echoing the artifact and the exact condition overridden:

```markdown
- Override applied: metaphors.md — condition overridden: stale — report stamped draft-vNN.md, applied against draft-vMM.md; authorized by human-recorded Override block
```

For a review-pending override, the condition reads `review_pending — no review annotations`. The step applies against a `stale` (or unselected) `metaphors.md` only via a recorded override, and always leaves this override record in the apply-log block comment.

## Open questions handling

Named blocker conditions:

- **Missing or ambiguous inputs.** `metaphors.md` is missing, contains no surviving variants, or `<latest-draft>` cannot be resolved. A `metaphors.md` with no surviving variant is the review-evidence (`review_pending`) analog for this step, whose review evidence is the human's selection; absent a recorded override (see "Overrides"), it blocks here.
- **Stale report (`stale`).** The `Reviewed-draft:` header at the top of `metaphors.md` names a draft other than `<latest-draft>`. The general freshness contract requires that the metaphor pipeline (`metaphor_identify` + `metaphor_fix`) ran against the same draft this step is applying to; if a prose-advancing step slipped in between, the recorded variants target the wrong sentences. Only the human can decide whether to rerun the metaphor pipeline against the current draft or to roll back. See `agents/orchestrator.md`'s **Artifact state** section for the general freshness contract (the report→fix freshness invariant is its named worked instance). Absent a recorded override (see "Overrides"), the step blocks.

In any of these, append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate inputs and do not write partial outputs. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to repoint the manifest's `Active-head:` to the `<next-draft>` it just wrote — and, on a branch (the draft read was not the old active head), stamp each displaced draft `superseded_by: draft-vNN.md` naming `<next-draft>`, per the algorithm in `agents/project-layouts.md` — then mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
