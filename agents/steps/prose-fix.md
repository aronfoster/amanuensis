---
step_id: prose_fix
review_required: false
inputs:
  - <chapter-folder>/drafts/<latest-attempt>/prose-pass.md
  - <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
  - voice.md
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/<next-draft>
  - <chapter-folder>/drafts/<latest-attempt>/prose-pass.md
  - <chapter-folder>/drafts/<latest-attempt>/draft-manifest.md
preconditions:
  - path: <chapter-folder>/drafts/<latest-attempt>/prose-pass.md
    kind: side_artifact
    required: true
    review_sensitive: true
  - path: <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
    kind: prose_draft
    required: true
    review_sensitive: false
  - path: voice.md
    kind: source
    required: true
    review_sensitive: false
---

See `agents/orchestrator.md` for the step workflow contract.

# Prose Fix

## Purpose

`prose_fix` applies the human-annotated recommendations recorded in `prose-pass.md` to the current draft (`<latest-draft>`), producing a new versioned prose file (`<next-draft>`). The step is surgical: it changes only what is annotated, preserves everything else, and records what it did (and what it could not do) by appending to `prose-pass.md`. Items annotated `ESCALATE` are not blockers — they are recorded as escalated and the step continues. This step runs after `prose_pass` and after a human has reviewed and annotated the advisory report.

## Inputs

- `<chapter-folder>/drafts/<latest-attempt>/prose-pass.md` — the advisory report produced by `prose_pass`, annotated by the human. Each finding carries an `Action:` recommendation (`KEEP | TIGHTEN | FLATTEN | REWRITE`) from the report, plus a human-filled `Annotation:` line resolving what to do. See "Behavior" below for how the effective annotation is resolved. An unannotated report is not a valid input: a report whose non-`KEEP` findings carry no `Annotation:` line carries no review evidence, so it is `review_pending` and this step blocks. This is the review-evidence gate of the general contract — review is surfaced, not enforced (`agents/orchestrator.md`'s **Artifact state** section), with the human's annotation the review evidence; `compliance_fix`'s unannotated-report blocker is the model. See "Open questions handling" below.

  At step start, before acting on any entry, read the `Reviewed-draft: draft-vNN.md` header at the top of `prose-pass.md` and confirm it equals `<latest-draft>`. This is the consumption-time check of the general freshness contract stated in `agents/orchestrator.md`'s **Artifact state** section: `prose-pass.md` is `fresh` iff its stamp equals the current `<latest-draft>` (the manifest's active head) and `stale` otherwise — a predicate derived here at step start, never stored. If the stamp does not match, the input is `stale`; see "Open questions handling" below for the stale-report blocker (the report→fix freshness invariant is that contract's named worked instance), unless the human recorded an override — see "Overrides" below.
- `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` — the current draft this step revises. Resolved at step start via the manifest's `Active-head:` pointer (the active head), or via the read-from override the dispatcher passed, per `agents/project-layouts.md` — not by highest-numbered draft. Read-only at this step's input boundary; revisions are written to `<next-draft>`.
- `voice.md` — the project-root voice file (a sibling of `pipeline-state.md`, not the copy inside the `amanuensis/` submodule; overridable by the path named in the consuming project's local `AGENTS.md`), loaded in full as the system message for `REWRITE` generation, mirroring `line_pass`. It is the calibration anchor for in-voice rewrites. If no voice file can be found, see "Open questions handling" below.

Storyboards and canon are **not** inputs. `prose_pass` already reviewed the prose against them when it emitted its recommendations; `prose_fix` applies those reviewed judgments without re-evaluating them. If a fix would require re-checking the prose against the storyboard or canon, the human should have marked it `ESCALATE`.

## Behavior

Work entry by entry through the annotated `prose-pass.md`, in report order.

### Resolving the effective annotation

The per-finding template in `prose-pass.md` is `Quote / Problem / Why it matters / Action` with `Action: KEEP | TIGHTEN | FLATTEN | REWRITE`. Beneath the `Action:` line, the human fills an `Annotation:` line: `Annotation: [FIX | FIX: <instruction> | SKIP | ESCALATE]`.

For each finding, determine the effective annotation:

1. If the finding has a per-entry `Annotation:` (`FIX`, `FIX: <instruction>`, `SKIP`, or `ESCALATE`), use it.
2. Else, if the finding's `Action:` is `KEEP` and no `Annotation:` is present, treat it as `SKIP`. A `KEEP` recommendation the human left untouched is an accepted line.
3. Else, the finding is unannotated (a non-`KEEP` `Action:` with no `Annotation:` line). Do not act on it. See Anti-Patterns below.

There are **no** bulk headers in `prose_fix`. Unlike `anti_ai_fix`, there is no per-section bulk default: every non-`KEEP` finding must carry its own `Annotation:`, or it is unannotated (case 3 above).

### Severity fix rules (bare `FIX`)

The fixer's default behavior for a bare `FIX` at each severity:

- **`TIGHTEN`.** Apply the smallest local edit that sharpens the flagged sentence — compress clauses, cut hedges, clean up emphasis — within the sentence itself. No collateral edits beyond the punctuation or grammar the change forces.
- **`FLATTEN`.** Apply the smallest local edit that reduces decoration in place — drop the ornamental clause, replace the fancy image with the literal one — within the sentence itself. Same collateral discipline: no touching neighbors beyond forced punctuation/grammar.
- **`REWRITE`.** Generative. Produce a new sentence or paragraph, in voice, that resolves the diagnosed failure. Load `voice.md` in full as the system message. Pass the target paragraph plus one paragraph on either side as read-only context, labeled `<<<PRECEDING CONTEXT — READ ONLY>>>` / `<<<TARGET — REWRITE THIS>>>` / `<<<FOLLOWING CONTEXT — READ ONLY>>>` (mirroring `line_pass`'s prompt shape), and instruct the LLM to return only the rewritten target. Substitute the rewritten target for the original paragraph in `<next-draft>`. Make the smallest collateral adjustments to neighboring sentences that the rewrite forces (pronoun continuity, a conjunction that no longer scans).

### Applying `FIX: <instruction>`, `SKIP`, and `ESCALATE`

- **`FIX: <instruction>`** overrides the severity default. Follow the instruction exactly, within the same scope as the severity rule — sentence-local for `TIGHTEN`/`FLATTEN`, paragraph-local for `REWRITE`.
- **`SKIP`** — leave the prose as-is. Do not append an `Applied:` or `Escalated:` block. The human has accepted the line.
- **`ESCALATE`** — do not modify the prose for this entry. Append an `Escalated:` block noting the reason and a suggested upstream target.

### Apply log

After each `FIX` action (bare `FIX` or `FIX: <instruction>`), append an `Applied:` block to `prose-pass.md`:

```markdown
#### Applied: [entry label]
- Change: [one line describing what changed]
- Prose before: "[original prose]"
- Prose after: "[revised prose]"
```

After each `ESCALATE`, append an `Escalated:` block to `prose-pass.md`:

```markdown
#### Escalated: [entry label]
- Reason: [one line — why local edit cannot resolve this]
- Suggested upstream target: [prose pass rerun / storyboard block / canon file / hand rewrite / etc.]
```

For each `SKIP` (whether annotated directly or resolved from an unannotated `KEEP`): leave the prose as-is and do not append any block.

### Constraints

- Fix only what is annotated. Do not improve, tighten, or rewrite prose beyond the flagged span.
- `TIGHTEN` and `FLATTEN` are sentence-local; `REWRITE` is paragraph-local. No cross-paragraph reshaping.
- If a fix to one finding would introduce a new finding (e.g., a `REWRITE` that produces broken imagery), stop and append an `Escalated:` block rather than proceeding.
- Preserve block comment markers (`<!-- scene x, beat y -->`), scene breaks (`---`), and dialogue formatting exactly as they appear in `<latest-draft>`.
- Preserve any prior apply-log block-comment at the end of `<latest-draft>` (e.g., a line-pass log carried in from a later-stage rerun) verbatim. `prose_fix` does **not** append a tally block-comment to the prose file; its per-entry log lives in `prose-pass.md`.
- The output file (`<next-draft>`) must contain the full chapter prose with `FIX` edits applied — not a diff and not just the changed sections. Everything not touched by a `FIX` annotation is copied through verbatim from `<latest-draft>`.

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/<next-draft>` — the full revised prose, written as the next versioned draft file. `<next-draft>` is the highest existing draft number + 1 (monotonic; per `agents/project-layouts.md`), not one greater than the draft read, so a branch rerun never collides with an existing file. The original `<latest-draft>` is not modified. All unchanged prose is copied through verbatim, with `FIX` edits applied in place. Block comment markers, scene breaks, dialogue formatting, and any prior apply-log block-comment are preserved.
- `<chapter-folder>/drafts/<latest-attempt>/prose-pass.md` — the same input file, with `Applied:` blocks appended for each `FIX` entry actioned and `Escalated:` blocks appended for each `ESCALATE` entry. Pre-existing content (the report, its `Reviewed-draft:` stamp, and the human's annotations) is not modified; this step only appends. The apply log for this run lives here.
- `<chapter-folder>/drafts/<latest-attempt>/draft-manifest.md` — append a per-version entry for `<next-draft>` after a successful prose write, following the schema in `agents/project-layouts.md`. `read_from` names the draft this step actually read (the active head, or the read-from override); `timestamp` is the write time (ISO 8601 with timezone offset); `review_gate` is this step's `review_required` value (`false`). Example:

  ```markdown
  ## draft-v04.md
  - produced_by: prose_fix
  - read_from: [draft-v03.md]
  - timestamp: 2026-05-18T14:16:18-06:00
  - review_gate: false
  - side_artifacts: [prose-pass.md]
  - apply_log: apply log appended to `prose-pass.md`
  ```

## Overrides

The freshness check and the review-evidence check above both block by default: a `stale` report, or a `review_pending` (unannotated) report, is sent to "Open questions handling" and no prose is written. A human may authorize proceeding against such an input by recording an override, per `agents/orchestrator.md`'s **Artifact state** section. This is the only path by which this step consumes a `stale` or `review_pending` input, and it never happens silently.

**Where the human records it.** A human-authored `Override:` block placed in `prose-pass.md` — the side artifact this step already reads at step start — naming the specific artifact and the condition overridden. It is not a new frontmatter or manifest field. Shape, for a stale input:

```markdown
Override: proceed despite stale — prose-pass.md stamped draft-vNN.md, current <latest-draft> is draft-vMM.md. Authorized by human.
```

or, for a review-pending input:

```markdown
Override: proceed despite review_pending — prose-pass.md carries no review annotations. Authorized by human.
```

The override must name the specific artifact and the draft mismatch (for stale) or the review-pending condition.

**Recognition at step start.** After computing freshness and the review-evidence check, if `prose-pass.md` is `stale` or `review_pending`, look for a matching `Override:` block that names `prose-pass.md` and the same condition. If a matching block is present, proceed with the apply. If none is present, block to `open-questions.md` exactly as today — the stale and unannotated paths are unchanged in the no-override case.

**Recording.** On proceeding under an override, record it in this step's apply log — the same place the `Applied:` blocks go, appended to `prose-pass.md` — echoing the artifact and the exact condition overridden:

```markdown
#### Override applied: prose-pass.md
- Condition overridden: stale — report stamped draft-vNN.md, applied against draft-vMM.md
- Authorized by: human-recorded Override block
```

For a review-pending override, the `Condition overridden:` line reads `review_pending — no review annotations`. The step proceeds against a `stale` or `review_pending` input only via a recorded override, and always leaves this override record in the apply log.

## Open questions handling

`ESCALATE`-annotated items are **not** blockers. The step appends an `Escalated:` block for each one and continues. An unresolvable finding is the expected outcome of an `ESCALATE` annotation, not a reason to halt the pipeline.

Open-questions handling fires only when the input itself is unusable. Named blocker conditions:

- **Unannotated report (`review_pending`).** `prose-pass.md` contains findings with non-`KEEP` `Action:` values and no `Annotation:` line. With no review evidence the input is `review_pending`; this is the review-evidence gate (review is surfaced, not enforced — `agents/orchestrator.md`'s **Artifact state** section), and `compliance_fix` is the model the fix/apply steps follow. The step requires human annotation to know which recommendations to apply and how; it must not guess. Absent a recorded override (see "Overrides"), the step blocks.
- **Missing inputs.** `prose-pass.md` is missing, `<latest-draft>` cannot be resolved (no `draft-vNN.md` in the attempt directory), or `voice.md` cannot be found (neither the project-root `voice.md` nor the override named in the project's `AGENTS.md`).
- **Stale report (`stale`).** The `Reviewed-draft:` header at the top of `prose-pass.md` names a draft other than `<latest-draft>`. The report was generated against a different draft than the current one, which means a prose-advancing step has slipped in between `prose_pass` and `prose_fix`. Applying the annotations to `<latest-draft>` would be applying notes against the wrong prose. The general freshness contract must hold; only the human can decide whether to rerun `prose_pass` against the current draft or to roll back. See `agents/orchestrator.md`'s **Artifact state** section for the general freshness contract (the report→fix freshness invariant is its named worked instance). Absent a recorded override (see "Overrides"), the step blocks.

In any of these, append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate annotations and do not write a partial `<next-draft>`. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to repoint the manifest's `Active-head:` to the `<next-draft>` it just wrote — and, on a branch (the draft read was not the old active head), stamp each displaced draft `superseded_by: draft-vNN.md` naming `<next-draft>`, per the algorithm in `agents/project-layouts.md` — then mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.

## Anti-Patterns

**Fixing unannotated findings.** This step requires human annotation. A finding with a non-`KEEP` `Action:` and no `Annotation:` line is not actionable — handle via "Open questions handling," do not guess at the intended fix.

**Rewriting beyond the flagged span.** The fix pass is surgical. Do not tighten phrasing, restructure sentences, or polish anything outside the span the finding flagged and the human annotated `FIX`.

**Cross-paragraph reshaping on `TIGHTEN`/`FLATTEN`.** These severities are sentence-local. Reflowing or restructuring across paragraph boundaries is out of scope for them; only `REWRITE` reaches paragraph scope, and even then does not reshape adjacent paragraphs.

**Using `voice.md` as a style ceiling.** The voice file is a calibration anchor for `REWRITE` generation, not a target that licenses rewrites of unflagged prose. If a line is in voice and unflagged, leave it alone.

**Introducing new figurative language on non-`REWRITE` fixes.** `TIGHTEN` and `FLATTEN` reduce; they do not reach for fresh imagery. Only a `REWRITE` may generate new phrasing, and even then only to resolve the diagnosed failure.

**Touching the prior apply-log block-comment.** Any apply-log block-comment carried in at the end of `<latest-draft>` (e.g., from a line-pass rerun) is copied through verbatim. Do not modify it, and do not append a `prose_fix` tally block-comment to the prose file.

**Silently dropping an annotated finding.** Every `FIX` produces an `Applied:` block and every `ESCALATE` produces an `Escalated:` block in `prose-pass.md`. An annotated finding that leaves no trace in the apply log is a failed pass.
