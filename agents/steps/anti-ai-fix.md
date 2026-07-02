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

Apply the human-annotated fixes recorded in `anti-ai.md` to the current draft (`<latest-draft>`), producing a new versioned prose file (`<next-draft>`) that resolves the AI-pattern flags the human marked `FIX`. The step is surgical: it changes only what is annotated, preserves everything else, and records what it did (and what it could not do) by appending to `anti-ai.md`. Items annotated `ESCALATE` are not blockers — they are recorded as escalated and the step continues. This step runs after `anti_ai_report` and after a human has reviewed and annotated the report.

Anti-AI is the last step in the pipeline. The `<next-draft>` this step writes — the highest-numbered `draft-vNN.md` in the attempt directory — is the final manuscript output.

## Inputs

- `<chapter-folder>/drafts/<latest-attempt>/anti-ai.md` — the report produced by `anti_ai_report`, annotated by the human. Each flagged entry should carry one of `FIX` / `FIX: <instruction>` / `SKIP` / `ESCALATE`, or take the per-category bulk default declared at the head of its category subsection. An unannotated report with no bulk defaults is not a valid input. See "Open questions handling" below.

  At step start, before acting on any entry, read the `Reviewed-draft: draft-vNN.md` header at the top of `anti-ai.md` and confirm it equals `<latest-draft>`. If it does not, see "Open questions handling" below — this is a stale-report blocker.
- `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` — the current draft this step revises. Resolved at step start; read-only at this step's input boundary, revisions are written to `<next-draft>`.

Do not read storyboards, canon files, character files, the voice file, or any other file. Anti-AI's whole identity is being context-free; the fix step preserves that.

## Behavior

Work entry by entry through the annotated `anti-ai.md`, in scene order, then category order within a scene.

### Resolving the effective annotation

For each flagged entry, determine the effective annotation:

1. If the entry has a per-entry annotation (`FIX`, `FIX: <instruction>`, `SKIP`, or `ESCALATE`), use it.
2. Else, if the entry's category section has a valid bulk header (`BULK: FIX` or `BULK: FIX: <instruction>` or `BULK: SKIP`), use the bulk default.
3. Else, the entry is unannotated. Do not act on it. See Anti-Patterns below.

A bulk header on a category declared `BULK not permitted` in the report's BULK eligibility block is invalid; treat as if no bulk header were present.

### Applying a FIX

For each entry whose effective annotation is `FIX` or `FIX: <instruction>`:

1. Locate the prose in `<latest-draft>` corresponding to the flag (the quote in the report is the anchor).
2. Apply the smallest local edit that resolves the flag, following the category's fix rule (see below). If the annotation is `FIX: <instruction>`, follow the instruction exactly.
3. Write the revised prose into `<next-draft>` (see Outputs).
4. Append an `Applied:` block to `anti-ai.md`:

   ```markdown
   #### Applied: [Category — entry label or first words of quote]
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

For each entry whose effective annotation is `SKIP`: leave the prose as-is and do not append any block. The human has accepted the flag.

### Applying an ESCALATE

For each entry whose effective annotation is `ESCALATE` (whether by direct annotation or by fallback from an invalid bare `FIX`):

1. Do not modify the prose for this entry.
2. Append an `Escalated:` block to `anti-ai.md`:

   ```markdown
   #### Escalated: [Category — entry label or first words of quote]
   - Reason: [one line — why local edit cannot resolve this]
   - Suggested upstream target: [hand rewrite / prose pass rerun / metaphor pass rerun / etc.]
   ```

### Constraints

- Fix only what is annotated (per-entry or via bulk default). Do not improve, tighten, or rewrite prose beyond the flag.
- The em-dash category is the only category licensed to restructure the sentence containing the flag. All other categories edit only the flagged construction itself plus minimal agreement repair.
- Collateral edits to sentences adjacent to a flagged sentence are forbidden in every category, including em dashes.
- If a fix to one flag would introduce a new flag (e.g., a copula-avoidance rewrite that produces an em dash), stop and append an `Escalated:` block rather than proceeding.
- Preserve block comment markers (`<!-- scene x, beat y -->`) and scene breaks (`---`) exactly as they appear in `<latest-draft>`.
- Preserve the line-pass apply log block-comment at the end of `<latest-draft>` (carried over from the prior line-pass run). Copy it through verbatim. Do not modify it. Append the anti-ai apply-log block-comment after it in `<next-draft>`.
- The output file (`<next-draft>`) must contain the full prose of the chapter, with all applied edits in place — not a diff and not just the changed sections. Everything not touched by a `FIX` annotation is copied through verbatim from `<latest-draft>`.

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/<next-draft>` — the full revised prose, written as the next versioned draft file (e.g., if `<latest-draft>` is `draft-v05.md`, this writes `draft-v06.md`). The original `<latest-draft>` is not modified. All unchanged prose is copied through verbatim, with annotated edits applied in place. Block comment markers, scene breaks, and the existing line-pass log are preserved. An anti-AI apply-log block comment is appended at the end summarizing the run. Because anti-AI is the last step in the pipeline, this `<next-draft>` is the final manuscript output for the attempt.
- `<chapter-folder>/drafts/<latest-attempt>/anti-ai.md` — the same input file, with `Applied:` blocks appended for each effective-FIX entry actioned and `Escalated:` blocks appended for each `ESCALATE` entry. Pre-existing content (the report, its `Reviewed-draft` header, and the human's annotations) is not modified; this step only appends.
- `<chapter-folder>/drafts/<latest-attempt>/draft-manifest.md` — append a per-version entry for `<next-draft>` after a successful prose write, following the schema in `agents/project-layouts.md`. Example:

  ```markdown
  ## draft-v06.md
  - produced_by: anti_ai_fix
  - read_from: [draft-v05.md]
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

## Open questions handling

`ESCALATE`-annotated items are **not** blockers. The step appends an `Escalated:` block for each one and continues. Categories that fall through to `ESCALATE` from invalid bare `FIX` are likewise not blockers; they are recorded and the step continues.

Open-questions handling fires only when the input itself is unusable. Named blocker conditions:

- **Unannotated report with no bulk headers.** `anti-ai.md` exists but contains no annotations *and* no bulk headers (every flag is bare).
- **Missing inputs.** `anti-ai.md` is missing, or `<latest-draft>` cannot be resolved (no `draft-vNN.md` in the attempt directory).
- **Stale report.** The `Reviewed-draft:` header at the top of `anti-ai.md` names a draft other than `<latest-draft>`. The report was generated against a different draft than the current one, which means a prose-advancing step has slipped in between `anti_ai_report` and `anti_ai_fix`. Applying the annotations to `<latest-draft>` would be applying notes against the wrong prose. The paired report→fix freshness invariant must hold; only the human can decide whether to rerun `anti_ai_report` against the current draft or to roll back. See `agents/orchestrator.md`'s report→fix freshness invariant for the canonical statement.

In any of these, append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate annotations and do not write a partial `<next-draft>`. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.

## Anti-Patterns

**Fixing unannotated flags without a bulk default.** This step requires either per-entry annotation or a per-category bulk header. An unannotated `anti-ai.md` with no bulk headers is not a valid input — handle via "Open questions handling," do not guess at intended fixes.

**Rewriting beyond the flag.** The fix pass is surgical. Prose quality improvements are not in scope. Do not tighten phrasing, restructure paragraphs, or polish anything that was not flagged. Em-dash restructuring is the only category-level license to touch sentence structure, and even that is confined to the sentence containing the dash.

**Touching neighboring sentences.** Forbidden across all categories, including em dashes. If removing a dash leaves a sentence pair that no longer flows, the apply-log entry notes the collateral problem and the next pass (or human hand-edit) addresses it.

**Introducing new flags via fixes.** If a copula-avoidance fix produces an em dash, or a participle deletion produces a triplet, stop and escalate. Recursive fix is not the fixer's job.
