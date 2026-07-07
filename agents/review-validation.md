# Review validation — the interpretation contract

How agents consume `scripts/validate-review-artifact.sh`. The split is
deliberate (ROADMAP M10, locked in Sprint 15): the script — deterministic,
read-only POSIX sh — owns parsing, validation, and counting; agentic judgment
runs it and acts on its ledger and exit code. The two things that must never
be wrong, the counts and the proceed/block verdict, are never assembled by
prose-following. The grammar itself is single-sourced in
`agents/review-grammars.yaml`; the script reads its token lists and bulk
rules from there, and so should you — neither this document nor any step doc
restates a token set.

This contract binds the `amanuensis-review` companion skill and the fix/apply
steps of migrated (`adopted`) families. Freshness, review-evidence, and
override semantics are governed by `agents/orchestrator.md`'s **Artifact
state** section; this document does not restate them — where the validator
reports `stale`, that section says what may lift the block and how it is
recorded.

## When to run the script

- **Companion session start** — before presenting anything, so the human sees
  accurate counts and any invalid or stale condition first.
- **After each written decision** — re-validate so the written unit is
  confirmed legal and the counts the human sees never drift from disk.
- **Fix/apply step start** — after the step's own freshness check, before
  acting on any entry. Pass the attempt's `draft-manifest.md` so the state
  layer runs.

## How to run it

```sh
sh scripts/validate-review-artifact.sh <artifact-file> agents/review-grammars.yaml [<manifest-file> [<effective-draft>]]
```

From a consuming project the paths are
`amanuensis/scripts/validate-review-artifact.sh` and
`amanuensis/agents/review-grammars.yaml`. Always pass the manifest when one
exists; without it the state layer reports `not checked` and staleness goes
unexamined. When the dispatcher passed a read-from draft, fix/apply steps
pass that draft filename as the fourth argument — the effective draft, the
resolved `<latest-draft>` for this invocation — and the state layer compares
the artifact's stamp against it instead of the manifest's `Active-head:`
(freshness is derived against the draft the run reads, per the Artifact-state
contract; the mismatched `Active-head:` is noted, not blocking). Pass `-` as
the manifest placeholder to give an effective draft without a manifest.

## Reading the output

The script prints the family and its adoption marker, the state line, the
findings (each naming a line number and the specific defect), the ledger, and
the verdict. Ledger fields: `total` (review units plus standalone defects),
`pending` (blank decision, no bulk cover), `decided` (explicit legal
non-SKIP/ESCALATE decisions), `inherited-by-bulk` (blank under a legal bulk
header), `skipped`, `escalated`, `invalid` (illegal tokens, payload
violations, duplicate or missing anchors, missing `Decision:` fields, illegal
bulk headers), `stale` (0 or 1, artifact-level).

Exit codes, precedence `invalid > pending > stale > proceed`:

| Exit | Verdict | Meaning |
| --- | --- | --- |
| 0 | proceed | no invalid, no pending, not stale |
| 3 | invalid-present | defects to fix before the pending count is trustworthy |
| 4 | pending-remain | review evidence still missing on some units |
| 5 | stale | fully reviewed and valid, but stamped against a superseded draft |
| 1 | input error | missing file, unrecognized artifact, family not yet adopted, malformed grammar or manifest |
| 2 | usage error | wrong arguments |

Stale is reported alongside the other layers, not instead of them: a stale
artifact's ledger is still printed, and `stale: 1` with exit 3 or 4 means
both problems exist.

## Per-consumer proceed rule

- **Fix/apply steps** proceed only on exit 0 — for compliance: zero
  actionable-pending units and zero invalid units. Exit 4 blocks as
  `review_pending`, naming the pending review-ids (or their count) in the
  blocker; exit 3 blocks as invalid input, naming the findings; exit 5 blocks
  as stale unless a recorded override applies (per the Artifact-state
  section — an override lifts the stale axis only, never pending or
  invalid). Each family's `proceed_state` line in the grammar file states its
  instance of this rule.
- **The companion** treats exit 4 as its normal working state — the pending
  units are its queue. On exit 3 it surfaces the invalid findings before any
  review work; on exit 5 it surfaces staleness to the human before any review
  work; on a not-yet-adopted exit 1 it declines the family, naming the
  migrating milestone from the grammar file.

## What remains agentic judgment

- **Recommendations.** The companion may recommend a decision for a unit and
  explain tradeoffs; it never applies its own recommendation. Only a decision
  the human states gets written.
- **Fix application.** The validator verifies decisions; the fix/apply step
  bodies own locating anchors in prose and making the edits.
- **Ambiguity escalation.** When a human's stated intent does not map cleanly
  onto a legal token, ask — never coerce it into the nearest token, and never
  write a token the grammar would reject.

## Decision automation

What an agent may and may not do without a human decision.

Allowed:

- Treat compliance `CLEAN` blocks as non-actionable — they carry no anchor
  and no fields and are not review units.
- Honor anti-AI bulk, but only where it is both statically supported (the
  family's bulk keys in the grammar file) and dynamically declared (the
  report's `BULK eligibility:` block marks the category `BULK permitted`).
- Honor per-entry decisions as overrides of a bulk default.
- Treat a valid bulk header as adjudicating its category: blank decisions
  under it are inherited, not pending.

Forbidden:

- Bulk-annotating prose-pass findings — the family has no bulk, by locked M5
  decision.
- Auto-disposing metaphor entries from their `CLEAN` / `REVIEW` / `BROKEN`
  flags — those are producer recommendations, never decisions.
- Treating blank decisions under no valid bulk header as decided, or blank
  decisions under a valid bulk header as pending.
- Inventing bulk anywhere the grammar or the report's own declarations do not
  grant it.
