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

Substitutes the human-selected variants from the working metaphors file into the draft. Produces a new draft file. The terminal step of the metaphor pipeline: it integrates the variant each actionable entry names in its `Selected:` field after `metaphor_fix` ran, without re-evaluating them.

## Inputs

- `<chapter-folder>/drafts/<latest-attempt>/metaphors.md` — the working file after human selection. Each actionable entry (`Decision:` in the selection tokens, per `agents/review-grammars.yaml`) carries a `Selected:` field naming the one variant id the human chose, and an optional `Selection-note:` inline edit to it; terminal `KEEP`/`REJECT` entries carry no selection. Unlike the annotation-grammar reports, `metaphor_apply` has no `FIX`/`SKIP`/`ESCALATE` gate; under the general contract (`agents/orchestrator.md`'s **Artifact state** section, review surfaced not enforced) its review evidence is the human's selection here — a filled `Selected:` on each actionable entry. An actionable entry with a blank `Selected:` is selection-pending and carries no such evidence; the validator (below) catches it as exit 4 and the step blocks, not a manufactured unannotated-report gate. The variant a `Selected:` id names may be a FLATTEN paragraph, a REPLACE paragraph, or a WORKSHOP sentence. Note: since `metaphor_fix`'s workshop subagent no longer runs an integration phase (the integration phase was removed; integration now happens here), the workshop variants a `Selected:` id can name arrive as bare individual sentences rather than fully-integrated paragraphs. Step 3 of Behavior already handles this through its "sentence variant" branch — no behavior change is required, but you should not be surprised to see workshop variants as one-line candidates.

  At step start, before substituting any variant, read the `Reviewed-draft: draft-vNN.md` header at the top of `metaphors.md` and confirm it equals `<latest-draft>`. This is the consumption-time check of the general freshness contract stated in `agents/orchestrator.md`'s **Artifact state** section: `metaphors.md` is `fresh` iff its stamp equals the current `<latest-draft>` (the manifest's active head) and `stale` otherwise — a predicate derived here at step start, never stored. If the stamp does not match, the input is `stale`; see "Open questions handling" below for the stale-report blocker (the report→fix freshness invariant is that contract's named worked instance), unless the human recorded an override — see "Overrides" below.

  After the freshness check, and before substituting any variant, run the shared validator over the working file in the selection round:

  ```sh
  sh amanuensis/scripts/validate-review-artifact.sh --round selection <chapter-folder>/drafts/<latest-attempt>/metaphors.md amanuensis/agents/review-grammars.yaml <chapter-folder>/drafts/<latest-attempt>/draft-manifest.md
  ```

  (paths as seen from a consuming project, per `agents/review-validation.md`). `--round selection` gates this step on the selection evidence layer — the metaphor family declares `selection_tokens`, so the validator additionally reads each actionable entry's `- Selected:` / `- Selection-note:` fields (per `agents/review-grammars.yaml`). Pass the attempt's `draft-manifest.md` when it exists so the script's state layer runs; if none exists yet, omit it — freshness is already established at step start. When the dispatcher passed a read-from draft, additionally pass that draft filename as the validator's fourth argument (the effective draft): freshness is derived against the draft this run reads, per the freshness check above, so the state layer compares the stamp against the read-from draft rather than the manifest's `Active-head:`. Interpret the ledger and exit code per `agents/review-validation.md`: proceed only on exit 0 — the grammar's proceed state, zero decision-pending units, zero selection-pending units, and zero invalid units. Exit 4 (pending-remain) blocks as `review_pending`, copying the validator's `pending-review-ids:` and `selection-pending-review-ids:` lists into the blocker (the deterministic set of remaining units — do not re-enumerate blank `Decision:` or `Selected:` fields by eye); exit 3 (invalid-present) blocks as invalid input, naming the validator's findings (a `Selected:` on a terminal `KEEP`/`REJECT` entry, or a malformed/multi-token value, is invalid here); exit 5 (stale) blocks as `stale` unless a recorded override applies — an override lifts the stale axis only, never pending, selection-pending, or invalid (see "Overrides"). See "Open questions handling" below for the blockers.
- `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` — the current prose (the latest prose-revising step's output before this one). Resolved at step start via the manifest's `Active-head:` pointer (the active head), or via the read-from override the dispatcher passed, per `agents/project-layouts.md` — not by highest-numbered draft.

Do not read the storyboard, canon files, or the selected voice file or profile. The variants have already been generated and chosen under those constraints. Apply locates each change in the draft and integrates it; it does not re-evaluate the rewrite.

## Behavior

Terminal `KEEP`/`REJECT` entries carry no selection and are skipped. An all-`KEEP`/`REJECT` file has no actionable entries and is a valid pass-through: write `<next-draft>` with no substitutions (prose bit-identical to `<latest-draft>`, with the apply-log block comment appended) and record the manifest entry, exactly as a run with actionable entries does.

For each actionable entry in `metaphors.md` (`Decision:` in the selection tokens, per `agents/review-grammars.yaml`):

**Step 1: Read the entry's `Selected:` and locate the named variant.**

The validator has already run (see Inputs), so every actionable entry holds a well-formed `Selected:` naming exactly one variant id — the per-variant label the fix subagents assigned (`A`/`B`/`C` for flatten and replace, `A`–`H` for workshop). Read the `Selected:` field and find the variant carrying that id in the entry's appended `#### ` variant section (`#### Flatten Options` / `#### Replace Options` / `#### Workshop Candidates`); that variant is the target. If `Selection-note:` carries an inline edit to the chosen variant, the edited form is the target — read `Selection-note:` as the target the way the fix steps read `Decision-note:` as context. The located variant may take any of the forms the upstream steps produce:

- A FLATTEN variant — typically a paragraph with a rewritten sentence in place
- A REPLACE version — typically a paragraph with the new image integrated
- A WORKSHOP candidate — a single sentence (the workshop subagent no longer integrates the candidate into a paragraph; that integration is this step's job)

Do not best-guess a selection. A blank `Selected:` on an actionable entry is selection-pending and blocked the step at validation (exit 4); an ambiguous or malformed `Selected:` is invalid and blocked it (exit 3) — neither reaches this step. A well-formed `Selected:` naming a variant id this step cannot resolve to an appended variant is skipped and noted per the anchor-gate below (Step 2), never guessed. Note the applied variant id in the apply log.

**Step 2: Locate the change in the draft.**

Find the original sentence in `<latest-draft>` using the entry's `Quote` field. Treat the quote as a guide, not a string to match. Minor differences — punctuation, smart vs. straight quotes, whitespace, a typo on either side, an em-dash that became a comma — should not stop you. Find the sentence the entry is clearly about and proceed.

If the selected variant is a paragraph, identify the corresponding paragraph in the draft (the one containing the original sentence) as the substitution target.

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
- [entry label]: applied [variant ID] as edited by Selection-note; [collateral note]
- [entry label]: skipped — terminal entry (KEEP / REJECT)
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

**Treating the variant as a draft.** The variant named in `Selected:` is the chosen line. Apply it as written, except where bracketed notes from the upstream step direct an adjustment.

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

The freshness check above blocks by default: a `stale` `metaphors.md` is sent to "Open questions handling" and no prose is written. A human may authorize proceeding against a `stale` input by recording an override, per `agents/orchestrator.md`'s **Artifact state** section. An override authorizes consuming an artifact despite a known *state* problem (staleness); it does **not** supply missing editorial intent. This is the only path by which this step applies against a `stale` input, and it never happens silently. `metaphor_apply` has no annotation-grammar report, so on the review axis its evidence is the human's selection in `metaphors.md`; an actionable entry with a blank `Selected:` is its `review_pending` analog — selection-pending, with nothing to substitute, so an override does not apply to it either. The validator catches it (exit 4) and the step blocks; it is resolved by the human selecting a variant rather than by an override.

**Where the human records it.** A human-authored `Override:` block placed in `metaphors.md` — the side artifact this step already reads at step start — naming the specific artifact and the condition overridden. It is not a new frontmatter or manifest field. Shape, for a stale input:

```markdown
Override: proceed despite stale — metaphors.md stamped draft-vNN.md, current <latest-draft> is draft-vMM.md. Authorized by human.
```

The override must name the specific artifact and the draft mismatch.

**Recognition at step start.** After computing freshness, if `metaphors.md` is `stale`, look for a matching `Override:` block naming `metaphors.md` and the draft mismatch. If a matching block is present, proceed with the substitution; if none is present, block to `open-questions.md` exactly as today. An actionable entry with a blank `Selected:` (selection-pending) is unaffected by overrides — the human resolves it by selecting a variant.

**Overriding staleness is still anchor-gated.** The override waives the freshness *block*, not the requirement that each variant land on a real target. The variants were selected against an older draft, so an entry's `Quote` anchor may no longer match `<latest-draft>`; the step still locates each target under its normal guidance, and an entry whose target cannot be identified is noted in the apply log and skipped, not guessed.

**Recording.** On proceeding under an override, record it in this step's apply log — which for `metaphor_apply` is the block comment appended at the end of `<next-draft>` (not `metaphors.md`, which this step never writes) — folding the record into that apply-log block comment, echoing the artifact and the exact condition overridden:

```markdown
- Override applied: metaphors.md — condition overridden: stale — report stamped draft-vNN.md, applied against draft-vMM.md; authorized by human-recorded Override block
```

The step applies against a `stale` `metaphors.md` only via a recorded override, and always leaves this override record in the apply-log block comment.

## Open questions handling

Named blocker conditions:

- **Missing or ambiguous inputs.** `metaphors.md` is missing, or `<latest-draft>` cannot be resolved. Selection evidence is gated by the validator (see Inputs): an actionable entry with a blank `Selected:` is selection-pending — the review-evidence (`review_pending`) analog for this step, whose review evidence is the human's selection — and blocks as `review_pending` (validator exit 4); a malformed or multi-token `Selected:`, or a `Selected:` on a terminal `KEEP`/`REJECT` entry, blocks as invalid input (exit 3). An override supplies no editorial intent and lifts neither; the human resolves a selection-pending entry by selecting a variant.
- **Stale report (`stale`).** The `Reviewed-draft:` header at the top of `metaphors.md` names a draft other than `<latest-draft>`. The general freshness contract requires that the metaphor pipeline (`metaphor_identify` + `metaphor_fix`) ran against the same draft this step is applying to; if a prose-advancing step slipped in between, the recorded variants target the wrong sentences. Only the human can decide whether to rerun the metaphor pipeline against the current draft or to roll back. See `agents/orchestrator.md`'s **Artifact state** section for the general freshness contract (the report→fix freshness invariant is its named worked instance). Absent a recorded override (see "Overrides"), the step blocks.

In any of these, append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate inputs and do not write partial outputs. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to repoint the manifest's `Active-head:` to the `<next-draft>` it just wrote — and, on a branch (the draft read was not the old active head), stamp each displaced draft `superseded_by: draft-vNN.md` naming `<next-draft>`, per the algorithm in `agents/project-layouts.md` — then mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
