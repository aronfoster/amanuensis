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

`prose_fix` applies the human's recorded decisions in `prose-pass.md` to the current draft (`<latest-draft>`), producing a new versioned prose file (`<next-draft>`). The step is surgical: it changes only what carries a `FIX` decision, preserves everything else, and records what it did (and what it could not do) by appending to `prose-pass.md`. Findings decided `ESCALATE` are not blockers — they are recorded as escalated and the step continues. This step runs after `prose_pass` and after a human has reviewed the report and recorded a decision on every finding.

## Inputs

- `<chapter-folder>/drafts/<latest-attempt>/prose-pass.md` — the advisory report produced by `prose_pass`, reviewed by the human. Each finding is a review unit: a `<!-- review-id: ... -->` anchor line sits immediately above the finding's `##### [short label]` heading, and `- Decision:` / `- Decision-note:` fields sit below the finding's `Action:` line. The human records a decision token in the `Decision:` field — the legal token set, payload rules, and blank-means semantics are defined by the `prose_pass:` family block in `agents/review-grammars.yaml` (the single grammar source; this step doc does not restate it). `Decision-note:` is optional free text — the human's rationale, never machine-parsed. A filled `Decision:` field is the review evidence for this artifact: review is surfaced, not enforced (`agents/orchestrator.md`'s **Artifact state** section), and `compliance_fix` is the model the other fix/apply steps follow. Any finding whose `Decision:` is blank is a pending unit and this step blocks as `review_pending`; see "Open questions handling" below. Positional inline decisions (a decision written on its own positional line rather than in a `Decision:` field, the pre-M12 format) are no longer read: an old-format report fails structural validation (the `#### Findings` container check) and blocks as invalid input.

  At step start, before acting on any entry, read the `Reviewed-draft: draft-vNN.md` header at the top of `prose-pass.md` and confirm it equals `<latest-draft>`. This is the consumption-time check of the general freshness contract stated in `agents/orchestrator.md`'s **Artifact state** section: `prose-pass.md` is `fresh` iff its stamp equals the current `<latest-draft>` (the manifest's active head) and `stale` otherwise — a predicate derived here at step start, never stored. If the stamp does not match, the input is `stale`; see "Open questions handling" below for the stale-report blocker (the report→fix freshness invariant is that contract's named worked instance), unless the human recorded an override — see "Overrides" below.

  After the freshness check, and before acting on any entry, run the shared validator over the report:

  ```sh
  sh amanuensis/scripts/validate-review-artifact.sh <chapter-folder>/drafts/<latest-attempt>/prose-pass.md amanuensis/agents/review-grammars.yaml <chapter-folder>/drafts/<latest-attempt>/draft-manifest.md
  ```

  (paths as seen from a consuming project, per `agents/review-validation.md`). Always pass the manifest so the script's state layer runs. When the dispatcher passed a read-from draft, additionally pass that draft filename as the validator's fourth argument (the effective draft): freshness is derived against the draft this run reads, per the freshness check above, so the state layer compares the stamp against the read-from draft rather than the manifest's `Active-head:`. Interpret the ledger and exit code per `agents/review-validation.md`: proceed only on exit 0 — the grammar's proceed state, zero pending units and zero invalid units. Exit 4 (pending-remain) blocks as `review_pending`, copying the validator's `pending-review-ids:` list into the blocker (the deterministic set of remaining units — do not re-enumerate blank `Decision:` fields by eye); exit 3 (invalid-present) blocks as invalid input, naming the validator's findings; exit 5 (stale) blocks as `stale` unless a recorded override applies — an override lifts the stale axis only, never pending or invalid (see "Overrides"). See "Open questions handling" below for the blockers.
- `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` — the current draft this step revises. Resolved at step start via the manifest's `Active-head:` pointer (the active head), or via the read-from override the dispatcher passed, per `agents/project-layouts.md` — not by highest-numbered draft. Read-only at this step's input boundary; revisions are written to `<next-draft>`.
- `voice.md` — the project-root voice file (a sibling of `pipeline-state.md`, not the copy inside the `amanuensis/` submodule; overridable by the path named in the consuming project's local `AGENTS.md`), loaded in full as the system message for `REWRITE` generation, mirroring `line_pass`. It is the calibration anchor for in-voice rewrites. If no voice file can be found, see "Open questions handling" below.

Storyboards and canon are **not** inputs. `prose_pass` already reviewed the prose against them when it emitted its recommendations; `prose_fix` applies those reviewed judgments without re-evaluating them. If a fix would require re-checking the prose against the storyboard or canon, the human should have marked it `ESCALATE`.

## Behavior

Work unit by unit through the review units of `prose-pass.md`, consuming each finding's `Decision:` field. (The validator has already run — see Inputs — so every finding holds a filled legal decision; the step never encounters a blank `Decision:`, because a blank on any finding blocked the step at validation.)

### Severity fix rules (bare `FIX`)

The fixer's default behavior for a bare `FIX` at each severity:

- **`KEEP`.** A `KEEP` finding carries no severity fix strategy — the producer diagnosed no problem — so a bare `FIX` on it has no default: `prose_fix` treats a bare `FIX` on a `KEEP` finding as `ESCALATE` and records it (parallel to the no-bare-`FIX` categories in `anti_ai_fix`). A `FIX: <instruction>` is honored sentence-locally, following the instruction exactly. The validator stays token-agnostic — it does not read `Action:`, so it accepts `FIX` on a `KEEP` unit — and the fixer owns this fallback.
- **`TIGHTEN`.** Apply the smallest local edit that sharpens the flagged sentence — compress clauses, cut hedges, clean up emphasis — within the sentence itself. No collateral edits beyond the punctuation or grammar the change forces.
- **`FLATTEN`.** Apply the smallest local edit that reduces decoration in place — drop the ornamental clause, replace the fancy image with the literal one — within the sentence itself. Same collateral discipline: no touching neighbors beyond forced punctuation/grammar.
- **`REWRITE`.** Generative. Produce a new sentence or paragraph, in voice, that resolves the diagnosed failure. Load `voice.md` in full as the system message. Pass the target paragraph plus one paragraph on either side as read-only context, labeled `<<<PRECEDING CONTEXT — READ ONLY>>>` / `<<<TARGET — REWRITE THIS>>>` / `<<<FOLLOWING CONTEXT — READ ONLY>>>` (mirroring `line_pass`'s prompt shape), and instruct the LLM to return only the rewritten target. Substitute the rewritten target for the original paragraph in `<next-draft>`. Make the smallest collateral adjustments to neighboring sentences that the rewrite forces (pronoun continuity, a conjunction that no longer scans).

### Applying `FIX: <instruction>`, `SKIP`, and `ESCALATE`

- **`FIX: <instruction>`** overrides the severity default. Follow the instruction exactly, within the same scope as the severity rule — sentence-local for `TIGHTEN`/`FLATTEN`, paragraph-local for `REWRITE`.
- **`SKIP`** — leave the prose as-is. Do not append an `Applied:` or `Escalated:` block. The human has accepted the line.
- **`ESCALATE`** — do not modify the prose for this entry. Append an `Escalated:` block noting the reason and a suggested upstream target.

### Apply log

After each `FIX` action (bare `FIX` or `FIX: <instruction>`), append an `Applied:` block to `prose-pass.md`, which may name the unit's review-id alongside the entry label:

```markdown
#### Applied: [entry label] (review-id: [review-id])
- Change: [one line describing what changed]
- Prose before: "[original prose]"
- Prose after: "[revised prose]"
```

After each `ESCALATE`, append an `Escalated:` block to `prose-pass.md`, which may name the unit's review-id alongside the entry label:

```markdown
#### Escalated: [entry label] (review-id: [review-id])
- Reason: [one line — why local edit cannot resolve this]
- Suggested upstream target: [prose pass rerun / storyboard block / canon file / hand rewrite / etc.]
```

For each `SKIP` decision: leave the prose as-is and do not append any block.

### Constraints

- Fix only what is decided `FIX`. Do not improve, tighten, or rewrite prose beyond the flagged span.
- `TIGHTEN` and `FLATTEN` are sentence-local; `REWRITE` is paragraph-local. No cross-paragraph reshaping.
- If a fix to one finding would introduce a new finding (e.g., a `REWRITE` that produces broken imagery), stop and append an `Escalated:` block rather than proceeding.
- Preserve block comment markers (`<!-- scene x, beat y -->`), scene breaks (`---`), and dialogue formatting exactly as they appear in `<latest-draft>`.
- Preserve any prior apply-log block-comment at the end of `<latest-draft>` (e.g., a line-pass log carried in from a later-stage rerun) verbatim. `prose_fix` does **not** append a tally block-comment to the prose file; its per-entry log lives in `prose-pass.md`.
- The output file (`<next-draft>`) must contain the full chapter prose with `FIX` edits applied — not a diff and not just the changed sections. Everything not touched by a `FIX` decision is copied through verbatim from `<latest-draft>`.

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/<next-draft>` — the full revised prose, written as the next versioned draft file. `<next-draft>` is the highest existing draft number + 1 (monotonic; per `agents/project-layouts.md`), not one greater than the draft read, so a branch rerun never collides with an existing file. The original `<latest-draft>` is not modified. All unchanged prose is copied through verbatim, with `FIX` edits applied in place. Block comment markers, scene breaks, dialogue formatting, and any prior apply-log block-comment are preserved.
- `<chapter-folder>/drafts/<latest-attempt>/prose-pass.md` — the same input file, with `Applied:` blocks appended for each `FIX` finding actioned and `Escalated:` blocks appended for each `ESCALATE` finding. Pre-existing content (the report, its `Reviewed-draft:` stamp, the review-id anchors, and the human's `Decision:` / `Decision-note:` fields) is not modified; this step only appends. The apply log for this run lives here.
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

The freshness check above blocks by default: a `stale` report is sent to "Open questions handling" and no prose is written. A human may authorize proceeding against a `stale` input by recording an override, per `agents/orchestrator.md`'s **Artifact state** section. An override authorizes consuming an artifact despite a known *state* problem (staleness); it does **not** supply missing editorial intent. This is the only path by which this step consumes a `stale` input, and it never happens silently. In validator terms, a recorded override lifts the exit-5 `stale` verdict only — never exit 4 (`review_pending`) or exit 3 (invalid input).

**Override does not apply to `review_pending`.** A pending unit — a finding whose `Decision:` field is blank — carries no decision for this step to apply; an override would waive the gate but leave nothing to act on, and this step must not guess. A `review_pending` input is resolved by the human **adding review evidence** (filling the blank `Decision:` fields), not by an override, after which the units are no longer pending. Override does not apply to invalid input either: an illegal token or structural defect is fixed in the artifact, not waived.

**Where the human records it.** A human-authored `Override:` block placed in `prose-pass.md` — the side artifact this step already reads at step start — naming the specific artifact and the condition overridden. It is not a new frontmatter or manifest field. Shape, for a stale input:

```markdown
Override: proceed despite stale — prose-pass.md stamped draft-vNN.md, current <latest-draft> is draft-vMM.md. Authorized by human.
```

The override must name the specific artifact and the draft mismatch.

**Recognition at step start.** After computing freshness, if `prose-pass.md` is `stale`, look for a matching `Override:` block naming `prose-pass.md` and the draft mismatch. If a matching block is present, proceed with the apply; if none is present, block to `open-questions.md` exactly as today. The `review_pending` (blank-`Decision:`) path is unaffected by overrides and blocks until the human supplies review evidence.

**Overriding staleness is still anchor-gated.** The override waives the freshness *block*, not the requirement that each edit land on a real anchor. The report was written against an older draft, so a quoted anchor may no longer match `<latest-draft>`; the step still locates each decided finding's anchor under its normal grammar, and a finding whose anchor cannot be found safely is recorded and skipped, not guessed.

**Recording.** On proceeding under an override, record it in this step's apply log — the same place the `Applied:` blocks go, appended to `prose-pass.md` — echoing the artifact and the exact condition overridden:

```markdown
#### Override applied: prose-pass.md
- Condition overridden: stale — report stamped draft-vNN.md, applied against draft-vMM.md
- Authorized by: human-recorded Override block
```

The step proceeds against a `stale` input only via a recorded override, and always leaves this override record in the apply log.

## Open questions handling

Units decided `ESCALATE` are **not** blockers. The step appends an `Escalated:` block for each one and continues. An unresolvable finding is the expected outcome of an `ESCALATE` decision, not a reason to halt the pipeline.

Open-questions handling fires only when the input itself is unusable. Named blocker conditions:

- **Pending units (`review_pending`).** The validator reports pending units — findings whose `Decision:` field is blank (exit 4, pending-remain). **Any** single pending unit blocks the whole step: a blank `Decision:` carries no review evidence for its finding, so the input is `review_pending`. This is the review-evidence gate (review is surfaced, not enforced — `agents/orchestrator.md`'s **Artifact state** section), applied per unit, and `compliance_fix` is the model the fix/apply steps follow. The per-unit gate is deliberately stronger than the old whole-file gate: a silently skipped blank unit is exactly the accepted-vs-unreviewed ambiguity the structured format removes, and a human who wants to defer a finding records `SKIP`. The `open-questions.md` blocker copies the validator's `pending-review-ids:` list (or, when many, their count with a few examples) — the deterministic remaining set, not an eyeball scan of the artifact. An override does not lift this — it supplies no editorial intent — so the human resolves it by filling the blank `Decision:` fields, after which the units are no longer pending.
- **Invalid input (`invalid`).** The validator reports invalid units or grammar defects (exit 3, invalid-present): an illegal decision token, a missing required payload, a duplicate review-id, a missing anchor or `Decision:` field — or an old-format positional report whose `##### ` findings under `#### Findings` carry no `<!-- review-id: ... -->` anchor, so the container holds zero anchored units and fails the container check. Block as invalid input, naming the validator's specific findings (line numbers and defects) in the `open-questions.md` blocker. Invalid takes precedence over pending — invalid units must be fixed before the pending count is trustworthy (`scripts/validate-review-artifact.sh` usage header) — and an override does not lift it.
- **Missing inputs.** `prose-pass.md` is missing, `<latest-draft>` cannot be resolved (no `draft-vNN.md` in the attempt directory), or `voice.md` cannot be found (neither the project-root `voice.md` nor the override named in the project's `AGENTS.md`).
- **Stale report (`stale`).** The `Reviewed-draft:` header at the top of `prose-pass.md` names a draft other than `<latest-draft>`. The report was generated against a different draft than the current one, which means a prose-advancing step has slipped in between `prose_pass` and `prose_fix`. Applying the recorded decisions to `<latest-draft>` would be applying notes against the wrong prose. The general freshness contract must hold; only the human can decide whether to rerun `prose_pass` against the current draft or to roll back. See `agents/orchestrator.md`'s **Artifact state** section for the general freshness contract (the report→fix freshness invariant is its named worked instance). Absent a recorded override (see "Overrides"), the step blocks.

In any of these, append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate decisions and do not write a partial `<next-draft>`. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to repoint the manifest's `Active-head:` to the `<next-draft>` it just wrote — and, on a branch (the draft read was not the old active head), stamp each displaced draft `superseded_by: draft-vNN.md` naming `<next-draft>`, per the algorithm in `agents/project-layouts.md` — then mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.

## Anti-Patterns

**Acting past blank decisions.** This step requires a human decision on every finding. A blank `Decision:` on any finding blocks the whole step as `review_pending` — handle via "Open questions handling"; the step never guesses at intended fixes and never silently skips an undecided finding.

**Rewriting beyond the flagged span.** The fix pass is surgical. Do not tighten phrasing, restructure sentences, or polish anything outside the span the finding flagged and the human decided `FIX`.

**Cross-paragraph reshaping on `TIGHTEN`/`FLATTEN`.** These severities are sentence-local. Reflowing or restructuring across paragraph boundaries is out of scope for them; only `REWRITE` reaches paragraph scope, and even then does not reshape adjacent paragraphs.

**Using `voice.md` as a style ceiling.** The voice file is a calibration anchor for `REWRITE` generation, not a target that licenses rewrites of unflagged prose. If a line is in voice and unflagged, leave it alone.

**Introducing new figurative language on non-`REWRITE` fixes.** `TIGHTEN` and `FLATTEN` reduce; they do not reach for fresh imagery. Only a `REWRITE` may generate new phrasing, and even then only to resolve the diagnosed failure.

**Touching the prior apply-log block-comment.** Any apply-log block-comment carried in at the end of `<latest-draft>` (e.g., from a line-pass rerun) is copied through verbatim. Do not modify it, and do not append a `prose_fix` tally block-comment to the prose file.

**Silently dropping a decided finding.** Every `FIX` produces an `Applied:` block and every `ESCALATE` produces an `Escalated:` block in `prose-pass.md`. A decided finding that leaves no trace in the apply log is a failed pass.
