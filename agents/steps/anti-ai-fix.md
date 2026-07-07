---
step_id: anti_ai_fix
review_required: false
inputs:
  - <chapter-folder>/drafts/<latest-attempt>/anti-ai.md
  - <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/<next-draft>
  - <chapter-folder>/drafts/<latest-attempt>/anti-ai.md
  - <chapter-folder>/drafts/<latest-attempt>/draft-manifest.md
preconditions:
  - path: <chapter-folder>/drafts/<latest-attempt>/anti-ai.md
    kind: side_artifact
    required: true
    review_sensitive: true
  - path: <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
    kind: prose_draft
    required: true
    review_sensitive: false
---

See `agents/orchestrator.md` for the step workflow contract.

# Anti-AI Fix

## Purpose

Apply the human-recorded decisions in `anti-ai.md` to the current draft (`<latest-draft>`), producing a new versioned prose file (`<next-draft>`) that resolves the AI-pattern flags whose `Decision:` field the human filled with `FIX`. The step is surgical: it changes only what carries a `FIX` decision, preserves everything else, and records what it did (and what it could not do) by appending to `anti-ai.md`. Units decided `ESCALATE` are not blockers — they are recorded as escalated and the step continues. This step runs after `anti_ai_report` and after a human has reviewed the report and recorded a decision on every flagged instance.

Anti-AI is the last step in the pipeline. The `<next-draft>` this step writes — which becomes the attempt's active head — is the final manuscript output.

## Inputs

- `<chapter-folder>/drafts/<latest-attempt>/anti-ai.md` — the report produced by `anti_ai_report`, reviewed by the human. Each flagged instance is a review unit: a `<!-- review-id: ... -->` anchor line sits immediately above the unit's single top-level `- ` entry line, and nested `- Decision:` / `- Decision-note:` fields sit below it. The human records a decision token in the `Decision:` field — the legal token set, payload rules, and blank-means semantics are defined by the `anti_ai:` family block in `agents/review-grammars.yaml` (the single grammar source; this step doc does not restate it). `Decision-note:` is optional free text — the human's rationale, never machine-parsed. A filled `Decision:` field is the review evidence for this artifact: review is surfaced, not enforced (`agents/orchestrator.md`'s **Artifact state** section), and `compliance_fix` is the model this step follows. Any flagged instance whose `Decision:` is blank is a pending unit and this step blocks as `review_pending`; see "Open questions handling" below. There are no bulk defaults and no inheritance of any kind: a `BULK:` header is invalid input the validator rejects, and positional inline annotations (decision tokens written after entry lines, the pre-M11 format) are no longer read — an old-format report fails structural validation and blocks as invalid input.

  At step start, before acting on any entry, read the `Reviewed-draft: draft-vNN.md` header at the top of `anti-ai.md` and confirm it equals `<latest-draft>`. This is the consumption-time check of the general freshness contract stated in `agents/orchestrator.md`'s **Artifact state** section: `anti-ai.md` is `fresh` iff its stamp equals the current `<latest-draft>` (the manifest's active head) and `stale` otherwise — a predicate derived here at step start, never stored. If the stamp does not match, the input is `stale`; see "Open questions handling" below for the stale-report blocker (the report→fix freshness invariant is that contract's named worked instance), unless the human recorded an override — see "Overrides" below.

  After the freshness check, and before acting on any entry, run the shared validator over the report:

  ```sh
  sh amanuensis/scripts/validate-review-artifact.sh <chapter-folder>/drafts/<latest-attempt>/anti-ai.md amanuensis/agents/review-grammars.yaml <chapter-folder>/drafts/<latest-attempt>/draft-manifest.md
  ```

  (paths as seen from a consuming project, per `agents/review-validation.md`). Always pass the manifest so the script's state layer runs. When the dispatcher passed a read-from draft, additionally pass that draft filename as the validator's fourth argument (the effective draft): freshness is derived against the draft this run reads, per the freshness check above, so the state layer compares the stamp against the read-from draft rather than the manifest's `Active-head:`. Interpret the ledger and exit code per `agents/review-validation.md`: proceed only on exit 0 — the grammar's proceed state, zero pending units and zero invalid units. Exit 4 (pending-remain) blocks as `review_pending`, copying the validator's `pending-review-ids:` list into the blocker (the deterministic set of remaining units — do not re-enumerate blank `Decision:` fields by eye); exit 3 (invalid-present) blocks as invalid input, naming the validator's findings; exit 5 (stale) blocks as `stale` unless a recorded override applies — an override lifts the stale axis only, never pending or invalid (see "Overrides"). See "Open questions handling" below for the blockers.
- `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` — the current draft this step revises. Resolved at step start via the manifest's `Active-head:` pointer (the active head), or via the read-from override the dispatcher passed, per `agents/project-layouts.md` — not by highest-numbered draft. Read-only at this step's input boundary; revisions are written to `<next-draft>`.

Do not read storyboards, canon files, character files, the voice file, or any other file. Anti-AI's whole identity is being context-free; the fix step preserves that.

## Behavior

Work unit by unit through the review units of `anti-ai.md`, in scene order, then category order within a scene, consuming each unit's `Decision:` field. (The validator has already run — see Inputs — so every unit holds a filled legal decision; the step never encounters a blank `Decision:`, because a blank on any unit blocked the step at validation, and no effective-decision resolution exists — the field itself is the decision.)

### Applying a FIX

For each unit whose `Decision:` is `FIX` or `FIX: <instruction>`:

1. Locate the prose in `<latest-draft>` corresponding to the flag (the quote in the report is the anchor).
2. Apply the smallest local edit that resolves the flag, following the category's fix rule (see below). If the decision is `FIX: <instruction>`, follow the instruction — the token's payload, carried exactly as the report records it — exactly. `Decision-note:`, where present, is the human's rationale or clarification — available as context for the edit, never a machine-parsed instruction.
3. Write the revised prose into `<next-draft>` (see Outputs).
4. Append an `Applied:` block to `anti-ai.md`, which may name the unit's review-id alongside the entry label:

   ```markdown
   #### Applied: [Category — entry label or first words of quote] (review-id: [review-id])
   - Change: [one line describing what changed]
   - Strategy: [for em dashes only: split / comma / restructure / bespoke]
   - Prose before: "[original quote, including immediate sentence context]"
   - Prose after: "[revised quote, including immediate sentence context]"
   ```

   The `Strategy:` line is only emitted for em-dash entries. Other categories omit it.

### Category fix rules

The fixer's default behavior for a bare `FIX` on each category:

- **Em Dashes (Cat 1).** Read the local sentence. Classify the em dash and apply the appropriate strategy:
  - *Apposition or parenthetical*: replace with comma, parentheses, or period (period is the default; comma if the insert is grammatically tight; parentheses only as last resort).
  - *Dramatic clause join*: split into two sentences, or invert clauses so the emphasis lands without punctuation help.
  - *Self-interruption or speech-cut*: restructure the sentence to remove the interruption, or escalate if no clean restructure exists.
  Record the chosen strategy in the apply log's `Strategy:` line. The fixer is licensed to restructure the sentence containing the em dash, but **must not** touch neighboring sentences.
- **Negative Parallelism (Cat 2).** No bare-FIX rule. Requires `FIX: <instruction>` or `ESCALATE`. If a bare `FIX` is encountered, treat as `ESCALATE` and record.
- **Significance Inflation (Cat 3).** No bare-FIX rule for the whole category. For *single-word* flags from the word list (`vibrant`, `tapestry`, `profound`, `nuanced`, etc.), bare `FIX` deletes the word, repairing any agreement (article, number) the deletion breaks. For phrase flags (`testament to`, `stands as`, `serves as a metaphor`, `reminder that`), bare `FIX` is invalid; require `FIX: <instruction>` or `ESCALATE`.
- **Copula Avoidance (Cat 4).** Bare `FIX` replaces the construction with the appropriate form of "to be": *serves as* → *is*, *acts as* → *is*, *functions as* → *is*, etc. For *featuring/boasting/presenting/showcasing*, bare `FIX` rewrites the construction to use plain verbs ("featuring a dome" → "with a dome" or restructure).
- **Superficial -ing Analysis (Cat 5).** Bare `FIX` deletes the participial gloss from the end of the sentence, leaving the action to stand alone. The fixer is licensed to lightly adjust the sentence's terminal punctuation if the deletion requires it.
- **Transition Openers (Cat 6).** Bare `FIX` deletes the opener and capitalizes the next word. If the sentence after deletion no longer scans, fall through to `ESCALATE`.
- **Synonym Cycling (Cat 7).** No bare-FIX rule. Requires `FIX: STANDARDIZE <term>` (the human picks the canonical term; the fixer collapses all cycled terms in the flagged passage to that term, keeping pronouns where they fall). Bare `FIX` is invalid; if encountered, treat as `ESCALATE`.
- **Cadence tics (Cat 8).** No bare-FIX rule. Requires `FIX: <instruction>` (e.g., "reduce this triplet to two beats") or `ESCALATE`. Bare `FIX` is invalid; if encountered, treat as `ESCALATE`.
- **Animacy Projection (Cat 9).** No bare-FIX rule. Requires `FIX: <instruction>` (e.g., "attribute the sensation to Louise instead", "delete the clause") or `ESCALATE`. Bare `FIX` is invalid; if encountered, treat as `ESCALATE`.
- **Flagged Words.** Bare `FIX` deletes the word and repairs immediate agreement (article, number, verb conjugation). For the literary-prestige register sub-list (`resilience`, `remembrance`, `witness`, etc.), bare `FIX` may not always produce a sensible sentence on deletion; if the sentence breaks, fall through to `ESCALATE`.

### Applying a SKIP

For each unit whose `Decision:` is `SKIP`: leave the prose as-is and do not append any block. The human has accepted the flag.

### Applying an ESCALATE

For each unit whose `Decision:` is `ESCALATE` (whether by direct decision or by fallback from an invalid bare `FIX` under the category rules above):

1. Do not modify the prose for this unit.
2. Append an `Escalated:` block to `anti-ai.md`, which may name the unit's review-id alongside the entry label:

   ```markdown
   #### Escalated: [Category — entry label or first words of quote] (review-id: [review-id])
   - Reason: [one line — why local edit cannot resolve this]
   - Suggested upstream target: [hand rewrite / prose pass rerun / metaphor pass rerun / etc.]
   ```

### Constraints

- Fix only units decided `FIX`. Do not improve, tighten, or rewrite prose beyond the flag.
- The em-dash category is the only category licensed to restructure the sentence containing the flag. All other categories edit only the flagged construction itself plus minimal agreement repair.
- Collateral edits to sentences adjacent to a flagged sentence are forbidden in every category, including em dashes.
- If a fix to one flag would introduce a new flag (e.g., a copula-avoidance rewrite that produces an em dash), stop and append an `Escalated:` block rather than proceeding.
- Preserve block comment markers (`<!-- scene x, beat y -->`) and scene breaks (`---`) exactly as they appear in `<latest-draft>`.
- Preserve the line-pass apply log block-comment at the end of `<latest-draft>` (carried over from the prior line-pass run). Copy it through verbatim. Do not modify it. Append the anti-ai apply-log block-comment after it in `<next-draft>`.
- The output file (`<next-draft>`) must contain the full prose of the chapter, with all applied edits in place — not a diff and not just the changed sections. Everything not touched by a `FIX` decision is copied through verbatim from `<latest-draft>`.

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/<next-draft>` — the full revised prose, written as the next versioned draft file. `<next-draft>` is the highest existing draft number + 1 (monotonic; per `agents/project-layouts.md`), not one greater than the draft read, so a branch rerun never collides with an existing file. The original `<latest-draft>` is not modified. All unchanged prose is copied through verbatim, with `FIX` edits applied in place. Block comment markers, scene breaks, and the existing line-pass log are preserved. An anti-AI apply-log block comment is appended at the end summarizing the run. Because anti-AI is the last step in the pipeline, this `<next-draft>` is the final manuscript output for the attempt.
- `<chapter-folder>/drafts/<latest-attempt>/anti-ai.md` — the same input file, with `Applied:` blocks appended for each `FIX` unit actioned and `Escalated:` blocks appended for each `ESCALATE` unit. Pre-existing content (the report, its `Reviewed-draft` header, the review-id anchors, and the human's `Decision:` / `Decision-note:` fields) is not modified; this step only appends.
- `<chapter-folder>/drafts/<latest-attempt>/draft-manifest.md` — append a per-version entry for `<next-draft>` after a successful prose write, following the schema in `agents/project-layouts.md`. `read_from` names the draft this step actually read (the active head, or the read-from override); `timestamp` is the write time (ISO 8601 with timezone offset); `review_gate` is this step's `review_required` value (`false`). Example:

  ```markdown
  ## draft-v06.md
  - produced_by: anti_ai_fix
  - read_from: [draft-v05.md]
  - timestamp: 2026-05-19T13:05:26-06:00
  - review_gate: false
  - side_artifacts: [anti-ai.md]
  - apply_log: tally block comment at end of `draft-v06.md`; per-entry blocks in `anti-ai.md`
  ```

### Apply log at the end of `<next-draft>`

```markdown
<!--
Anti-AI fix log

- Em dashes: N flagged, N fixed (split: N, comma: N, restructure: N, bespoke: N), N skipped, N escalated
- Negative parallelism: N flagged, N fixed, N skipped, N escalated
- Significance inflation: N flagged, N fixed, N skipped, N escalated
- Copula avoidance: N flagged, N fixed, N skipped, N escalated
- Superficial -ing analysis: N flagged, N fixed, N skipped, N escalated
- Transition openers: N flagged, N fixed, N skipped, N escalated
- Synonym cycling: N flagged, N fixed, N skipped, N escalated
- Cadence tics: N flagged, N fixed, N skipped, N escalated
- Animacy projection: N flagged, N fixed, N skipped, N escalated
- Flagged words: N flagged, N fixed, N skipped, N escalated

Notes: [any non-routine observation; usually empty]
-->
```

The detailed per-entry `Applied:` and `Escalated:` blocks live in `anti-ai.md`, not in the prose file. The block-comment at the end of `<next-draft>` is a tally only.

## Overrides

The freshness check above blocks by default: a `stale` report is sent to "Open questions handling" and no prose is written. A human may authorize proceeding against a `stale` input by recording an override, per `agents/orchestrator.md`'s **Artifact state** section. An override authorizes consuming an artifact despite a known *state* problem (staleness); it does **not** supply missing editorial intent. This is the only path by which this step consumes a `stale` input, and it never happens silently. In validator terms, a recorded override lifts the exit-5 `stale` verdict only — never exit 4 (`review_pending`) or exit 3 (invalid input).

**Override does not apply to `review_pending`.** A pending unit — a flagged instance whose `Decision:` field is blank — carries no decision for this step to apply; an override would waive the gate but leave nothing to act on, and this step must not guess. A `review_pending` input is resolved by the human **adding review evidence** (filling the blank `Decision:` fields), not by an override, after which the units are no longer pending. Override does not apply to invalid input either: an illegal token, a `BULK:` header, or a structural defect is fixed in the artifact, not waived.

**Where the human records it.** A human-authored `Override:` block placed in `anti-ai.md` — the side artifact this step already reads at step start — naming the specific artifact and the condition overridden. It is not a new frontmatter or manifest field. Shape, for a stale input:

```markdown
Override: proceed despite stale — anti-ai.md stamped draft-vNN.md, current <latest-draft> is draft-vMM.md. Authorized by human.
```

The override must name the specific artifact and the draft mismatch.

**Recognition at step start.** After computing freshness, if `anti-ai.md` is `stale`, look for a matching `Override:` block naming `anti-ai.md` and the draft mismatch. If a matching block is present, proceed with the apply; if none is present, block to `open-questions.md` exactly as today. The `review_pending` (blank-`Decision:`) path is unaffected by overrides and blocks until the human supplies review evidence.

**Overriding staleness is still anchor-gated.** The override waives the freshness *block*, not the requirement that each edit land on a real anchor. The report was written against an older draft, so a quoted anchor may no longer match `<latest-draft>`; the step still locates each flagged entry's anchor under its normal grammar, and an entry whose anchor cannot be found safely is recorded and skipped, not guessed.

**Recording.** On proceeding under an override, record it in this step's apply log — the same place the per-entry `Applied:` blocks go, appended to `anti-ai.md` — echoing the artifact and the exact condition overridden:

```markdown
#### Override applied: anti-ai.md
- Condition overridden: stale — report stamped draft-vNN.md, applied against draft-vMM.md
- Authorized by: human-recorded Override block
```

The step proceeds against a `stale` input only via a recorded override, and always leaves this override record in the apply log — in `anti-ai.md`, alongside the `Applied:` blocks, not the end-of-draft tally block comment.

## Open questions handling

Units decided `ESCALATE` are **not** blockers. The step appends an `Escalated:` block for each one and continues. Categories that fall through to `ESCALATE` from an invalid bare `FIX` are likewise not blockers; they are recorded and the step continues.

Open-questions handling fires only when the input itself is unusable. Named blocker conditions:

- **Pending units (`review_pending`).** The validator reports pending units — flagged instances whose `Decision:` field is blank (exit 4, pending-remain). **Any** single pending unit blocks the whole step: a blank `Decision:` carries no review evidence for its unit, so the input is `review_pending`. This is the review-evidence gate (review is surfaced, not enforced — `agents/orchestrator.md`'s **Artifact state** section), applied per unit, and `compliance_fix` is the model this step follows. The per-unit gate is deliberately stronger than the old whole-file gate: a silently skipped blank unit is exactly the accepted-vs-unreviewed ambiguity the structured format removes, and a human who wants to defer a unit records `SKIP`. The `open-questions.md` blocker copies the validator's `pending-review-ids:` list (or, when many, their count with a few examples) — the deterministic remaining set, not an eyeball scan of the artifact. An override does not lift this — it supplies no editorial intent — so the human resolves it by filling the blank `Decision:` fields, after which the units are no longer pending.
- **Invalid input (`invalid`).** The validator reports invalid units or grammar defects (exit 3, invalid-present): an illegal decision token, a missing required payload, a duplicate review-id, a missing anchor or `Decision:` field, a `BULK:` header (this artifact carries no bulk grammar; a header is rejected as invalid, never silently treated as absent) — or an old-format positional report, which fails the container check. Block as invalid input, naming the validator's specific findings (line numbers and defects) in the `open-questions.md` blocker. Invalid takes precedence over pending — invalid units must be fixed before the pending count is trustworthy (`scripts/validate-review-artifact.sh` usage header) — and an override does not lift it.
- **Missing inputs.** `anti-ai.md` is missing, or `<latest-draft>` cannot be resolved (no `draft-vNN.md` in the attempt directory).
- **Stale report (`stale`).** The `Reviewed-draft:` header at the top of `anti-ai.md` names a draft other than `<latest-draft>`. The report was generated against a different draft than the current one, which means a prose-advancing step has slipped in between `anti_ai_report` and `anti_ai_fix`. Applying the recorded decisions to `<latest-draft>` would be applying notes against the wrong prose. The general freshness contract must hold; only the human can decide whether to rerun `anti_ai_report` against the current draft or to roll back. See `agents/orchestrator.md`'s **Artifact state** section for the general freshness contract (the report→fix freshness invariant is its named worked instance). Absent a recorded override (see "Overrides"), the step blocks.

In any of these, append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate decisions and do not write a partial `<next-draft>`. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to repoint the manifest's `Active-head:` to the `<next-draft>` it just wrote — and, on a branch (the draft read was not the old active head), stamp each displaced draft `superseded_by: draft-vNN.md` naming `<next-draft>`, per the algorithm in `agents/project-layouts.md` — then mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.

## Anti-Patterns

**Acting past blank decisions.** This step requires a human decision on every flagged instance. A blank `Decision:` on any unit blocks the whole step as `review_pending` — handle via "Open questions handling"; the step never guesses at intended fixes and never silently skips an undecided unit.

**Rewriting beyond the flag.** The fix pass is surgical. Prose quality improvements are not in scope. Do not tighten phrasing, restructure paragraphs, or polish anything that was not flagged. Em-dash restructuring is the only category-level license to touch sentence structure, and even that is confined to the sentence containing the dash.

**Touching neighboring sentences.** Forbidden across all categories, including em dashes. If removing a dash leaves a sentence pair that no longer flows, the apply-log entry notes the collateral problem and the next pass (or human hand-edit) addresses it.

**Introducing new flags via fixes.** If a copula-avoidance fix produces an em dash, or a participle deletion produces a triplet, stop and escalate. Recursive fix is not the fixer's job.
