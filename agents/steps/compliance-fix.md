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

Apply the human-recorded decisions in `reviewer-actions.md` to the current draft (`<latest-draft>`), producing a new versioned prose file (`<next-draft>`) that resolves the violations whose `Decision:` field the human filled with `FIX`. The step is surgical: it changes only what carries a `FIX` decision, preserves everything else, and records what it did (and what it could not do) by appending to `reviewer-actions.md`. Units decided `ESCALATE` are not blockers — they are recorded as escalated and the step continues. This step runs after `compliance_report` and after a human has reviewed the report and recorded a decision on every actionable violation.

## Inputs

- `<chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md` — the compliance report produced by `compliance_report`, reviewed by the human. Each violation is a review unit: a `<!-- review-id: ... -->` anchor line sits immediately above the violation line, and nested `- Decision:` / `- Decision-note:` fields sit below it. The human records a decision token in the `Decision:` field — the legal token set, payload rules, and blank-means semantics are defined by the `compliance:` family block in `agents/review-grammars.yaml` (the single grammar source; this step doc does not restate it). `Decision-note:` is optional free text — the human's rationale, never machine-parsed. A filled `Decision:` field is the review evidence for this artifact: review is surfaced, not enforced (`agents/orchestrator.md`'s **Artifact state** section), and `compliance_fix` is the model the other fix/apply steps follow. Any actionable violation whose `Decision:` is blank is a pending unit and this step blocks as `review_pending`; see "Open questions handling" below. Positional inline annotations (decision tokens written after violation lines, the pre-M10 format) are no longer read: an old-format report fails structural validation and blocks as invalid input.

  At step start, before acting on any entry, read the `Reviewed-draft: draft-vNN.md` header at the top of `reviewer-actions.md` and confirm it equals `<latest-draft>`. This is the consumption-time check of the general freshness contract stated in `agents/orchestrator.md`'s **Artifact state** section: `reviewer-actions.md` is `fresh` iff its stamp equals the current `<latest-draft>` (the manifest's active head) and `stale` otherwise — a predicate derived here at step start, never stored. If the stamp does not match, the input is `stale`; see "Open questions handling" below for the stale-report blocker (the report→fix freshness invariant is that contract's named worked instance), unless the human recorded an override — see "Overrides" below.

  After the freshness check, and before acting on any entry, run the shared validator over the report:

  ```sh
  sh amanuensis/scripts/validate-review-artifact.sh <chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md amanuensis/agents/review-grammars.yaml <chapter-folder>/drafts/<latest-attempt>/draft-manifest.md
  ```

  (paths as seen from a consuming project, per `agents/review-validation.md`). Pass the attempt's `draft-manifest.md` when it exists so the script's state layer runs; if none exists yet, omit it — freshness is already established at step start. When the dispatcher passed a read-from draft, additionally pass that draft filename as the validator's fourth argument (the effective draft): freshness is derived against the draft this run reads, per the freshness check above, so the state layer compares the stamp against the read-from draft rather than the manifest's `Active-head:`. Interpret the ledger and exit code per `agents/review-validation.md`: proceed only on exit 0 — the grammar's proceed state, zero actionable-pending units and zero invalid units. Exit 4 (pending-remain) blocks as `review_pending`, copying the validator's `pending-review-ids:` list into the blocker (the deterministic set of remaining units — do not re-enumerate blank `Decision:` fields by eye); exit 3 (invalid-present) blocks as invalid input, naming the validator's findings; exit 5 (stale) blocks as `stale` unless a recorded override applies — an override lifts the stale axis only, never pending or invalid (see "Overrides"). See "Open questions handling" below for the blockers.
- `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` — the current draft this step revises. Resolved at step start via the manifest's `Active-head:` pointer (the active head), or via the read-from override the dispatcher passed, per `agents/project-layouts.md` — not by highest-numbered draft. Read-only at this step's input boundary; revisions are written to `<next-draft>`.
- `<chapter-folder>/storyboards/*-storyboard.md` — the storyboard blocks for any units decided `FIX`, used to confirm what the violation should have enacted. Read only the blocks referenced by `FIX` units.

Do not read canon files during this step. If a fix requires canon clarification, the human should have marked it `ESCALATE`.

## Behavior

Work unit by unit through the review units of `reviewer-actions.md`, consuming each unit's `Decision:` field. (The validator has already run — see Inputs — so every actionable unit holds a legal decision; the step never encounters a blank `Decision:`, because a blank on any unit blocked the step at validation.)

Before reading a unit's defect label, check the violation line for a `[premise: unreviewed]` tag (appended by `compliance_report` on a finding whose resolved `continuity/`/`knowledge/`/`canon/generated/` referent is itself unconfirmed; this step reads the tag, it does not re-derive it). This check runs **before** the defect-label rule below and overrides it: if the violation line carries `[premise: unreviewed]` and the unit's `Decision:` is `FIX` or `ESCALATE`, the unit is routed upstream via the `Escalated:`-block mechanism below — regardless of the unit's defect label or its absence. This matters precisely because it is the common case for a `[premise: unreviewed]`-tagged finding: a Check 3 escalation-path finding carries no defect tag at all, and a Check 4 finding against what reads as "settled, valid" canon is labeled `prose`, since the taxonomy doesn't independently know the canon it just checked against is itself unconfirmed. Without this override, a `FIX` on exactly this kind of finding would still silently edit prose to match an unconfirmed guess — the precise failure this milestone exists to prevent. **`SKIP` is excluded from this override**: a `[premise: unreviewed]`-tagged unit decided `SKIP` keeps its existing behavior exactly — leaves prose as-is and appends no block (see below) — since `SKIP` already carries no risk (it writes nothing), and forcing it into escalation would override a human's fully resolved, deliberate choice they never asked to have escalated. Only once the underlying entry is confirmed (via `/revise`, which clears the tag on regeneration) can a `FIX` on that unit reach a prose edit.

Otherwise — for a unit whose violation line carries no `[premise: unreviewed]` tag, or whose decision is `SKIP` — read its **defect label** — the ` [defect: <type>]` tag on the violation line, where `<type>` ∈ {prose, storyboard, state, canon, missing-context} (the taxonomy and routing are defined in `agents/review-context.md`; this step reads the label, it does not re-derive it, and it reads no canon or state file to route). The label — not the decision token alone — determines where remediation goes, for **every** decision, `FIX` included:

- A **prose**-defect unit — or a local unit carrying **no** `[defect: …]` tag, which is the pre-M16 Must-Contain / Must-Not-Contain / Canon-as-stated finding, a prose fix — decided `FIX` is applied to prose, as below, **unless the violation line carries `[premise: unreviewed]`**, in which case the premise check above already routed it upstream instead.
- A **state / storyboard / canon / missing-context** unit is **never applied to prose**, whether the human recorded `FIX` **or** `ESCALATE`. It is routed to its authoritative artifact via the `Escalated:`-style upstream-target block below, so a non-prose `FIX` cannot bypass the routing and edit the wrong artifact.

For each unit whose `Decision:` is `FIX` or `FIX: [instruction]`, whose defect label is `prose` (or absent), **and whose violation line carries no `[premise: unreviewed]` tag**:

1. Locate the prose in `<latest-draft>` corresponding to the violation (the quote recorded in the report is the anchor).
2. Apply the smallest local edit that resolves the violation. If the decision is `FIX: [instruction]`, follow the instruction — the token's payload, carried exactly as the report records it — exactly. If the decision is bare `FIX`, apply the obvious local edit implied by the violation type. `Decision-note:`, where present, is the human's rationale or clarification — available as context for the edit, never a machine-parsed instruction.
3. Write the revised prose into `<next-draft>` (see Outputs).
4. Append an `Applied:` block to `reviewer-actions.md`, which may name the unit's review-id alongside the item label:

   ```markdown
   #### Applied: [Item label] (review-id: [review-id])
   - Change: [one line describing what changed]
   - Prose before: "[original quote]"
   - Prose after: "[revised quote]"
   ```

For each unit routed upstream — decided `ESCALATE`, decided `FIX` on a **non-prose** defect (`state` / `storyboard` / `canon` / `missing-context`), **or** decided `FIX` on a unit whose violation line carries `[premise: unreviewed]` (regardless of defect label, per the premise check above):

1. Do not modify the prose for this unit.
2. Append an `Escalated:` block to `reviewer-actions.md`, which may name the unit's review-id alongside the item label. The **Suggested upstream target** routes by the unit's defect type (per the taxonomy in `agents/review-context.md`): storyboard → the storyboard block; state → continuity_update / revise (continuity), scene_knowledge_update / revise (knowledge), or the human who maintains reveals.md; canon → the named canon file; missing-context → an open question. **When the violation line carries `[premise: unreviewed]`** — whether the unit reached this block via `ESCALATE`, a non-prose-defect `FIX`, or the `[premise: unreviewed]` premise-check override above — sharpen this beyond the artifact class: name `/revise` against the **specific entry**, reading the locator straight off the violation line's `[ref: <referent>]` tag and copying it verbatim, never re-deriving it (this step reads no canon or state file to route, per "Do not read canon files during this step" above). For a `continuity/`/`knowledge/` referent, that locator is the minted `co-NN`/`kn-NN` id (unchanged shape); for a `canon/generated/` referent (reached via either check's canon-file escalation), it is the self-contained file + scene/beat/attempt + quote locator that check wrote into the tag — never claim a plain "file + entry id" for `canon/generated/`, which mints no id.

   ```markdown
   #### Escalated: [Item label] (review-id: [review-id])
   - Reason: [one line — why local edit cannot resolve this; for a non-prose FIX, that the label routes it upstream; for a `[premise: unreviewed]`-tagged unit, that the cited entry is itself unconfirmed]
   - Suggested upstream target: [routed by defect type, per above — for a `[premise: unreviewed]`-tagged unit, `/revise` against the entry named in the violation line's `[ref:]` tag, copied verbatim]
   ```

For each unit whose `Decision:` is `SKIP`: leave the prose as-is and do not append any block. The human has accepted the violation. This is unchanged for a `[premise: unreviewed]`-tagged unit too — the premise-check override above applies only to `FIX` and `ESCALATE`; `SKIP` keeps its existing no-write behavior regardless of the tag.

### Constraints

- Fix only units decided `FIX`. Do not improve, tighten, or rewrite prose beyond the violation.
- If a fix to one violation would introduce a new violation, stop and append a note rather than proceeding.
- Preserve block comment markers (`<!-- scene x, beat y -->`) and scene breaks (`---`) exactly as they appear in `<latest-draft>`.
- The output file (`<next-draft>`) must contain the full prose of the chapter, with `FIX` edits applied — not a diff and not just the changed sections. Everything not touched by a `FIX` decision is copied through verbatim from `<latest-draft>`.

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/<next-draft>` — the full revised prose, written as the next versioned draft file. `<next-draft>` is the highest existing draft number + 1 (monotonic; per `agents/project-layouts.md`), not one greater than the draft read, so a branch rerun never collides with an existing file. The original `<latest-draft>` is not modified. All unchanged prose is copied through verbatim, with `FIX` edits applied in place. Block comment markers and scene breaks are preserved.
- `<chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md` — the same input file, with `Applied:` blocks appended for each **prose-defect** `FIX` unit actioned and `Escalated:` blocks appended for each unit routed upstream — every `ESCALATE` unit **and** every non-prose (`state` / `storyboard` / `canon` / `missing-context`) `FIX` unit, whose remediation goes to its authoritative artifact rather than to prose. Pre-existing content (the Phase 1 report, its `Reviewed-draft` header, the review-id anchors, and the human's `Decision:` / `Decision-note:` fields) is not modified; this step only appends. The apply log for this run lives here.
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

**Override does not apply to `review_pending`.** A pending unit — an actionable violation whose `Decision:` field is blank — carries no decision for this step to apply; an override would waive the gate but leave nothing to act on, and this step must not guess. A `review_pending` input is resolved by the human **adding review evidence** (filling the blank `Decision:` fields), not by an override, after which the units are no longer pending. Override does not apply to invalid input either: an illegal token or structural defect is fixed in the artifact, not waived.

**Where the human records it.** A human-authored `Override:` block placed in `reviewer-actions.md` — the side artifact this step already reads at step start — naming the specific artifact and the condition overridden. It is not a new frontmatter or manifest field. Shape, for a stale input:

```markdown
Override: proceed despite stale — reviewer-actions.md stamped draft-vNN.md, current <latest-draft> is draft-vMM.md. Authorized by human.
```

The override must name the specific artifact and the draft mismatch.

**Recognition at step start.** After computing freshness, if `reviewer-actions.md` is `stale`, look for a matching `Override:` block naming `reviewer-actions.md` and the draft mismatch. If a matching block is present, proceed with the apply; if none is present, block to `open-questions.md` exactly as today. The `review_pending` (blank-`Decision:`) path is unaffected by overrides and blocks until the human supplies review evidence.

**Overriding staleness is still anchor-gated.** The override waives the freshness *block*, not the requirement that each edit land on a real anchor. The report was written against an older draft, so a quoted anchor may no longer match `<latest-draft>`; the step still locates each `FIX` unit's anchor under its normal grammar, and a unit whose anchor cannot be found safely is recorded and skipped, not guessed.

**Recording.** On proceeding under an override, record it in this step's apply log — the same place the `Applied:` blocks go, appended to `reviewer-actions.md` — echoing the artifact and the exact condition overridden:

```markdown
#### Override applied: reviewer-actions.md
- Condition overridden: stale — report stamped draft-vNN.md, applied against draft-vMM.md
- Authorized by: human-recorded Override block
```

The step proceeds against a `stale` input only via a recorded override, and always leaves this override record in the apply log.

## Open questions handling

Units decided `ESCALATE` are **not** blockers. The step appends an `Escalated:` block for each one and continues. An unresolvable upstream conflict is the expected outcome of an `ESCALATE` decision, not a reason to halt the pipeline.

Open-questions handling fires only when the input itself is unusable. Named blocker conditions:

- **Pending units (`review_pending`).** The validator reports pending units — actionable violations whose `Decision:` field is blank (exit 4, pending-remain). **Any** single pending unit blocks the whole step: a blank `Decision:` carries no review evidence for its unit, so the input is `review_pending`. This is the review-evidence gate (review is surfaced, not enforced — `agents/orchestrator.md`'s **Artifact state** section), applied per unit, and `compliance_fix` is the model the other fix/apply steps follow. The per-unit gate is deliberately stronger than the old whole-file gate: a silently skipped blank unit is exactly the accepted-vs-unreviewed ambiguity the structured format removes, and a human who wants to defer a unit records `SKIP`. The `open-questions.md` blocker copies the validator's `pending-review-ids:` list (or, when many, their count with a few examples) — the deterministic remaining set, not an eyeball scan of the artifact. An override does not lift this — it supplies no editorial intent — so the human resolves it by filling the blank `Decision:` fields, after which the units are no longer pending.
- **Invalid input (`invalid`).** The validator reports invalid units or grammar defects (exit 3, invalid-present): an illegal decision token, a missing required payload, a duplicate review-id, a missing anchor or `Decision:` field — or an old-format report carrying positional inline annotations, which fails structural validation. Block as invalid input, naming the validator's specific findings (line numbers and defects) in the `open-questions.md` blocker. Invalid takes precedence over pending — invalid units must be fixed before the pending count is trustworthy (`scripts/validate-review-artifact.sh` usage header) — and an override does not lift it.
- **Missing inputs.** `reviewer-actions.md` is missing, or `<latest-draft>` cannot be resolved (no `draft-vNN.md` in the attempt directory).
- **Stale report (`stale`).** The `Reviewed-draft:` header at the top of `reviewer-actions.md` names a draft other than `<latest-draft>`. The report was generated against a different draft than the current one, which means a prose-advancing step has slipped in between `compliance_report` and `compliance_fix`. Applying the recorded decisions to `<latest-draft>` would be applying notes against the wrong prose. The general freshness contract must hold; only the human can decide whether to rerun `compliance_report` against the current draft or to roll back. See `agents/orchestrator.md`'s **Artifact state** section for the general freshness contract (the report→fix freshness invariant is its named worked instance). Absent a recorded override (see "Overrides"), the step blocks.

In any of these, append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate decisions and do not write a partial `<next-draft>`. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to repoint the manifest's `Active-head:` to the `<next-draft>` it just wrote — and, on a branch (the draft read was not the old active head), stamp each displaced draft `superseded_by: draft-vNN.md` naming `<next-draft>`, per the algorithm in `agents/project-layouts.md` — then mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.

## Anti-Patterns

**Acting past blank decisions.** This step requires a human decision on every actionable violation. A blank `Decision:` on any unit blocks the whole step as `review_pending` — handle via "Open questions handling"; the step never guesses at intended fixes and never silently skips an undecided unit.

**Rewriting beyond the violation.** The fix pass is surgical. Prose quality improvements are a separate workflow (`prose_pass`, `line_pass`). Do not tighten phrasing, restructure sentences, or polish anything that was not flagged as a violation and decided `FIX`.
