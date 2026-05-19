---
step_id: anti_ai_fix
review_required: false
inputs:
  - <chapter-folder>/drafts/<latest-attempt>/anti-ai.md
  - <chapter-folder>/drafts/<latest-attempt>/draft-line.md
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/draft-anti-ai.md
  - <chapter-folder>/drafts/<latest-attempt>/anti-ai.md
---

See `agents/orchestrator.md` for the step workflow contract.

# Anti-AI Fix

## Purpose

Apply the human-annotated fixes recorded in `anti-ai.md` to the line-pass draft, producing a revised prose file (`draft-anti-ai.md`) that resolves the AI-pattern flags the human marked `FIX`. The step is surgical: it changes only what is annotated, preserves everything else, and records what it did (and what it could not do) by appending to `anti-ai.md`. Items annotated `ESCALATE` are not blockers — they are recorded as escalated and the step continues. This step runs after `anti_ai_report` and after a human has reviewed and annotated the report.

Anti-AI is the last step in the pipeline. `draft-anti-ai.md` is the final manuscript output.

## Inputs

- `<chapter-folder>/drafts/<latest-attempt>/anti-ai.md` — the report produced by `anti_ai_report`, annotated by the human. Each flagged entry should carry one of `FIX` / `FIX: <instruction>` / `SKIP` / `ESCALATE`, or take the per-category bulk default declared at the head of its category subsection. An unannotated report with no bulk defaults is not a valid input. See "Open questions handling" below.
- `<chapter-folder>/drafts/<latest-attempt>/draft-line.md` — the prose this step revises. Read-only at this step's input boundary; revisions are written to a new file.

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

1. Locate the prose in `draft-line.md` corresponding to the flag (the quote in the report is the anchor).
2. Apply the smallest local edit that resolves the flag, following the category's fix rule (see below). If the annotation is `FIX: <instruction>`, follow the instruction exactly.
3. Write the revised prose into `draft-anti-ai.md` (see Outputs).
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
- Preserve block comment markers (`<!-- scene x, beat y -->`) and scene breaks (`---`) exactly as they appear in `draft-line.md`.
- Preserve the line-pass apply log block-comment at the end of `draft-line.md`. Do not modify it. Append an anti-ai apply-log block-comment after it in `draft-anti-ai.md`.
- The output file (`draft-anti-ai.md`) must contain the full prose of the chapter, with all applied edits in place — not a diff and not just the changed sections. Everything not touched by a `FIX` annotation is copied through verbatim from `draft-line.md`.

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/draft-anti-ai.md` — the full revised prose. This is a new file produced by this step; the original `draft-line.md` is not modified. All unchanged prose is copied through verbatim, with annotated edits applied in place. Block comment markers, scene breaks, and the existing line-pass log are preserved. An anti-AI apply-log block comment is appended at the end summarizing the run.
- `<chapter-folder>/drafts/<latest-attempt>/anti-ai.md` — the same input file, with `Applied:` blocks appended for each effective-FIX entry actioned and `Escalated:` blocks appended for each `ESCALATE` entry. Pre-existing content (the report and the human's annotations) is not modified; this step only appends.

### Apply log at the end of `draft-anti-ai.md`

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

The detailed per-entry `Applied:` and `Escalated:` blocks live in `anti-ai.md`, not in the prose file. The block-comment at the end of `draft-anti-ai.md` is a tally only.

## Open questions handling

`ESCALATE`-annotated items are **not** blockers. The step appends an `Escalated:` block for each one and continues. Categories that fall through to `ESCALATE` from invalid bare `FIX` are likewise not blockers; they are recorded and the step continues.

Open-questions handling fires only when the input itself is unusable. The canonical case: `anti-ai.md` exists but contains no annotations *and* no bulk headers (every flag is bare). Other unusable-input cases include a missing `anti-ai.md` or a missing `draft-line.md`. In any of these, append the blocker to the project root `open-questions.md` and exit without advancing the pipeline marker. Do not fabricate annotations and do not write a partial `draft-anti-ai.md`. The next dispatcher invocation will re-run this step after the human resolves the blocker.

## Anti-Patterns

**Fixing unannotated flags without a bulk default.** This step requires either per-entry annotation or a per-category bulk header. An unannotated `anti-ai.md` with no bulk headers is not a valid input — handle via "Open questions handling," do not guess at intended fixes.

**Rewriting beyond the flag.** The fix pass is surgical. Prose quality improvements are not in scope. Do not tighten phrasing, restructure paragraphs, or polish anything that was not flagged. Em-dash restructuring is the only category-level license to touch sentence structure, and even that is confined to the sentence containing the dash.

**Touching neighboring sentences.** Forbidden across all categories, including em dashes. If removing a dash leaves a sentence pair that no longer flows, the apply-log entry notes the collateral problem and the next pass (or human hand-edit) addresses it.

**Introducing new flags via fixes.** If a copula-avoidance fix produces an em dash, or a participle deletion produces a triplet, stop and escalate. Recursive fix is not the fixer's job.
