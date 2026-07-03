---
step_id: compliance_fix
review_required: false
inputs:
  - <chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md
  - <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
  - <chapter-folder>/storyboards/*-storyboard.md
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/<next-draft>
  - <chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md
  - <chapter-folder>/drafts/<latest-attempt>/draft-manifest.md
preconditions:
  - path: <chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md
    kind: side_artifact
    required: true
    review_sensitive: true
  - path: <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
    kind: prose_draft
    required: true
    review_sensitive: false
  - path: <chapter-folder>/storyboards/*-storyboard.md
    kind: source
    required: false
    review_sensitive: false
---

See `agents/orchestrator.md` for the step workflow contract.

# Compliance Fix

## Purpose

Apply the human-annotated fixes recorded in `reviewer-actions.md` to the current draft (`<latest-draft>`), producing a new versioned prose file (`<next-draft>`) that resolves the violations the human marked `FIX`. The step is surgical: it changes only what is annotated, preserves everything else, and records what it did (and what it could not do) by appending to `reviewer-actions.md`. Items annotated `ESCALATE` are not blockers — they are recorded as escalated and the step continues. This step runs after `compliance_report` and after a human has reviewed and annotated the report.

## Inputs

- `<chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md` — the compliance report produced by `compliance_report`, annotated by the human. Each violation entry should carry one of:
  - `FIX` — apply the obvious local edit
  - `FIX: [instruction]` — apply the fix as specified
  - `SKIP` — leave as-is; violation accepted
  - `ESCALATE` — conflict cannot be resolved by local edit; flag for storyboard or canon revision
  An unannotated report is not a valid input: with no `FIX`/`SKIP`/`ESCALATE` annotation the report carries no review evidence, so it is `review_pending` and this step blocks. This is the review-evidence gate of the general contract — review is surfaced, not enforced (`agents/orchestrator.md`'s **Artifact state** section), and annotation is the review evidence for the four reports; `compliance_fix` is the model the other fix/apply steps follow. See "Open questions handling" below.

  At step start, before acting on any entry, read the `Reviewed-draft: draft-vNN.md` header at the top of `reviewer-actions.md` and confirm it equals `<latest-draft>`. This is the consumption-time check of the general freshness contract stated in `agents/orchestrator.md`'s **Artifact state** section: `reviewer-actions.md` is `fresh` iff its stamp equals the current `<latest-draft>` (the manifest's active head) and `stale` otherwise — a predicate derived here at step start, never stored. If the stamp does not match, the input is `stale`; see "Open questions handling" below for the stale-report blocker (the report→fix freshness invariant is that contract's named worked instance), unless the human recorded an override — see "Overrides" below.
- `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` — the current draft this step revises. Resolved at step start via the manifest's `Active-head:` pointer (the active head), or via the read-from override the dispatcher passed, per `agents/project-layouts.md` — not by highest-numbered draft. Read-only at this step's input boundary; revisions are written to `<next-draft>`.
- `<chapter-folder>/storyboards/*-storyboard.md` — the storyboard blocks for any `FIX` items, used to confirm what the violation should have enacted. Read only the blocks referenced by `FIX` entries.

Do not read canon files during this step. If a fix requires canon clarification, the human should have marked it `ESCALATE`.

## Behavior

Work entry by entry through the annotated `reviewer-actions.md`.

For each entry annotated `FIX` or `FIX: [instruction]`:

1. Locate the prose in `<latest-draft>` corresponding to the violation (the quote recorded in the report is the anchor).
2. Apply the smallest local edit that resolves the violation. If the annotation is `FIX: [instruction]`, follow the instruction exactly. If the annotation is bare `FIX`, apply the obvious local edit implied by the violation type.
3. Write the revised prose into `<next-draft>` (see Outputs).
4. Append an `Applied:` block to `reviewer-actions.md`:

   ```markdown
   #### Applied: [Item label]
   - Change: [one line describing what changed]
   - Prose before: "[original quote]"
   - Prose after: "[revised quote]"
   ```

For each entry annotated `ESCALATE`:

1. Do not modify the prose for this entry.
2. Append an `Escalated:` block to `reviewer-actions.md`:

   ```markdown
   #### Escalated: [Item label]
   - Reason: [one line — why local edit cannot resolve this]
   - Suggested upstream target: [storyboard block / canon file / open question]
   ```

For each entry annotated `SKIP`: leave the prose as-is and do not append any block. The human has accepted the violation.

For entries with no annotation: do not act on them. See Anti-Patterns below.

### Constraints

- Fix only what is annotated `FIX`. Do not improve, tighten, or rewrite prose beyond the violation.
- If a fix to one violation would introduce a new violation, stop and append a note rather than proceeding.
- Preserve block comment markers (`<!-- scene x, beat y -->`) and scene breaks (`---`) exactly as they appear in `<latest-draft>`.
- The output file (`<next-draft>`) must contain the full prose of the chapter, with `FIX` edits applied — not a diff and not just the changed sections. Everything not touched by a `FIX` annotation is copied through verbatim from `<latest-draft>`.

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/<next-draft>` — the full revised prose, written as the next versioned draft file. `<next-draft>` is the highest existing draft number + 1 (monotonic; per `agents/project-layouts.md`), not one greater than the draft read, so a branch rerun never collides with an existing file. The original `<latest-draft>` is not modified. All unchanged prose is copied through verbatim, with `FIX` edits applied in place. Block comment markers and scene breaks are preserved.
- `<chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md` — the same input file, with `Applied:` blocks appended for each `FIX` entry actioned and `Escalated:` blocks appended for each `ESCALATE` entry. Pre-existing content (the Phase 1 report, its `Reviewed-draft` header, and the human's annotations) is not modified; this step only appends. The apply log for this run lives here.
- `<chapter-folder>/drafts/<latest-attempt>/draft-manifest.md` — append a per-version entry for `<next-draft>` after a successful prose write, following the schema in `agents/project-layouts.md`. `read_from` names the draft this step actually read (the active head, or the read-from override); `timestamp` is the write time (ISO 8601 with timezone offset); `review_gate` is this step's `review_required` value (`false`). Example:

  ```markdown
  ## draft-v03.md
  - produced_by: compliance_fix
  - read_from: [draft-v02.md]
  - timestamp: 2026-05-18T11:32:47-06:00
  - review_gate: false
  - side_artifacts: [reviewer-actions.md]
  - apply_log: apply log appended to `reviewer-actions.md`
  ```

## Overrides

The freshness check above blocks by default: a `stale` report is sent to "Open questions handling" and no prose is written. A human may authorize proceeding against a `stale` input by recording an override, per `agents/orchestrator.md`'s **Artifact state** section. An override authorizes consuming an artifact despite a known *state* problem (staleness); it does **not** supply missing editorial intent. This is the only path by which this step consumes a `stale` input, and it never happens silently.

**Override does not apply to `review_pending`.** An unannotated `reviewer-actions.md` carries no `FIX`/`SKIP`/`ESCALATE` decisions, so there is nothing for this step to apply; an override would waive the gate but leave nothing to act on, and this step must not guess. A `review_pending` input is resolved by the human **adding review evidence** (annotating the entries), not by an override, after which it is no longer `review_pending`.

**Where the human records it.** A human-authored `Override:` block placed in `reviewer-actions.md` — the side artifact this step already reads at step start — naming the specific artifact and the condition overridden. It is not a new frontmatter or manifest field. Shape, for a stale input:

```markdown
Override: proceed despite stale — reviewer-actions.md stamped draft-vNN.md, current <latest-draft> is draft-vMM.md. Authorized by human.
```

The override must name the specific artifact and the draft mismatch.

**Recognition at step start.** After computing freshness, if `reviewer-actions.md` is `stale`, look for a matching `Override:` block naming `reviewer-actions.md` and the draft mismatch. If a matching block is present, proceed with the apply; if none is present, block to `open-questions.md` exactly as today. The `review_pending` (unannotated) path is unaffected by overrides and blocks until the human supplies review evidence.

**Overriding staleness is still anchor-gated.** The override waives the freshness *block*, not the requirement that each edit land on a real anchor. The report was written against an older draft, so a quoted anchor may no longer match `<latest-draft>`; the step still locates each `FIX` entry's anchor under its normal grammar, and an entry whose anchor cannot be found safely is recorded and skipped, not guessed.

**Recording.** On proceeding under an override, record it in this step's apply log — the same place the `Applied:` blocks go, appended to `reviewer-actions.md` — echoing the artifact and the exact condition overridden:

```markdown
#### Override applied: reviewer-actions.md
- Condition overridden: stale — report stamped draft-vNN.md, applied against draft-vMM.md
- Authorized by: human-recorded Override block
```

The step proceeds against a `stale` input only via a recorded override, and always leaves this override record in the apply log.

## Open questions handling

`ESCALATE`-annotated items are **not** blockers. The step appends an `Escalated:` block for each one and continues. An unresolvable upstream conflict is the expected outcome of an `ESCALATE` annotation, not a reason to halt the pipeline.

Open-questions handling fires only when the input itself is unusable. Named blocker conditions:

- **Unannotated report (`review_pending`).** `reviewer-actions.md` exists but contains no annotations at all (every violation is bare, with no `FIX`/`SKIP`/`ESCALATE`). With no review evidence the input is `review_pending`; this is the review-evidence gate (review is surfaced, not enforced — `agents/orchestrator.md`'s **Artifact state** section), and `compliance_fix` is the model the other fix/apply steps follow. An override does not lift this — it supplies no editorial intent — so the human resolves it by annotating the report, after which it is no longer `review_pending`.
- **Missing inputs.** `reviewer-actions.md` is missing, or `<latest-draft>` cannot be resolved (no `draft-vNN.md` in the attempt directory).
- **Stale report (`stale`).** The `Reviewed-draft:` header at the top of `reviewer-actions.md` names a draft other than `<latest-draft>`. The report was generated against a different draft than the current one, which means a prose-advancing step has slipped in between `compliance_report` and `compliance_fix`. Applying the annotations to `<latest-draft>` would be applying notes against the wrong prose. The general freshness contract must hold; only the human can decide whether to rerun `compliance_report` against the current draft or to roll back. See `agents/orchestrator.md`'s **Artifact state** section for the general freshness contract (the report→fix freshness invariant is its named worked instance). Absent a recorded override (see "Overrides"), the step blocks.

In any of these, append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate annotations and do not write a partial `<next-draft>`. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to repoint the manifest's `Active-head:` to the `<next-draft>` it just wrote — and, on a branch (the draft read was not the old active head), stamp each displaced draft `superseded_by: draft-vNN.md` naming `<next-draft>`, per the algorithm in `agents/project-layouts.md` — then mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.

## Anti-Patterns

**Fixing unannotated violations.** This step requires human annotation. An unannotated `reviewer-actions.md` is not a valid input — handle via "Open questions handling," do not guess at intended fixes.

**Rewriting beyond the violation.** The fix pass is surgical. Prose quality improvements are a separate workflow (`prose_pass`, `line_pass`). Do not tighten phrasing, restructure sentences, or polish anything that was not flagged as a violation and annotated `FIX`.
