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
sh scripts/validate-review-artifact.sh [--round decision|selection] <artifact-file> agents/review-grammars.yaml [<manifest-file> [<effective-draft>]]
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

### The `--round` selector (metaphor)

The metaphor family is the one **two-evidence-layer** family: a single
`metaphors.md` gates two consumers with different proceed conditions, so the
consumer names which layer it gates. `metaphor_fix` passes `--round decision`
(the default) and gates the **disposition** layer — the `Decision:` field;
`metaphor_apply` passes `--round selection` and gates the **selection** layer
— the `Selected:` field `metaphor_fix` appended on each actionable entry
(`Decision:` in the family's `selection_tokens`). The companion drives both
rounds. The default is `decision`, so the other three families and every
existing invocation are unchanged; `--round selection` on a family without
`selection_tokens` is an input error (exit 1) naming the mismatch. A still-blank
`Decision:` is decision-pending and blocks **both** rounds — the selection
layer is only meaningful once disposition is complete.

## Reading the output

The script prints the family and its adoption marker, the state line, the
findings (each naming a line number and the specific defect), the ledger, and
the verdict. Ledger fields: `total` (review units plus standalone defects),
`pending` (blank decision, no bulk cover), `decided` (explicit legal
non-SKIP/ESCALATE decisions), `inherited-by-bulk` (blank under a legal bulk
header — printed but permanently 0: no adopted family grants artifact-level
bulk), `skipped`, `escalated`, `invalid` (illegal tokens, payload
violations, duplicate or missing anchors, missing `Decision:` fields, illegal
bulk headers), `stale` (0 or 1, artifact-level).

In the **selection round** (`--round selection`, metaphor only) the ledger
adds two rows beneath `stale`: `selection-pending` (an actionable entry whose
`Selected:` is blank) and `selected` (an actionable entry whose `Selected:`
names one well-formed variant id), both counted over actionable entries only.
Terminal `KEEP` / `REJECT` entries carry no selection and appear in neither.
These rows never print in the decision round, so every other family's output
is unchanged.

When `pending` is nonzero the script additionally prints a
`pending-review-ids:` section listing the review-id of every pending unit,
one per line, in document order — the same units the `pending` count covers.
This is the deterministic source a consumer uses to *name* the remaining
units: a fix/apply step's `review_pending` blocker copies these ids rather
than re-scanning the artifact for blank `Decision:` fields by eye, and the
companion uses them as its pending queue. The section is absent when
`pending` is 0 (a clean or purely-invalid artifact lists no pending ids).
In the selection round, a parallel `selection-pending-review-ids:` section
prints whenever `selection-pending` is nonzero, naming each actionable entry
still awaiting a `Selected:` — the deterministic selection queue, distinct
from the decision-pending queue above (an entry can be in only one: a blank
`Decision:` is decision-pending, never selection-pending).

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
  `review_pending`, copying the script's `pending-review-ids:` list into the
  blocker (or, when the list is long, their count with a few examples); exit
  3 blocks as invalid input, naming the findings; exit 5 blocks as stale
  unless a recorded override applies (per the Artifact-state section — an
  override lifts the stale axis only, never pending or invalid). Each
  family's `proceed_state` line in the grammar file states its instance of
  this rule.
- **The metaphor family's two consumers gate two layers.** `metaphor_fix`
  proceeds only on `--round decision` exit 0 (zero decision-pending, zero
  invalid), then acts on `FLATTEN` / `REPLACE` / `WORKSHOP` entries only — an
  all-`KEEP`/`REJECT` file is a clean no-op. `metaphor_apply` proceeds only on
  `--round selection` exit 0 (zero decision-pending, zero **selection-pending**,
  zero invalid), then applies the variant each actionable entry names in
  `Selected:`, treating an all-`KEEP`/`REJECT` file as valid pass-through. Both
  exit 4s block as `review_pending`; on the selection round the blocker copies
  the `selection-pending-review-ids:` queue for entries awaiting a `Selected:`
  and the `pending-review-ids:` queue for any entry still awaiting a
  `Decision:`. A blank `Selected:` is never best-guessed — it is a block, and
  the human resolves it by selecting a variant (an override lifts stale only,
  never a pending or selection-pending unit).
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

- Fan out one human-stated category-level decision into every pending unit
  of that category — but only where the family's `fanout_categories`
  declaration in the grammar file names the category. The companion writes
  the stated decision into each pending unit's `Decision:` field.
- Mark each fanned-out unit's `Decision-note:` as a category decision — the
  audit record that the unit was decided at category level, not entry by
  entry.
- Honor per-entry statements as exceptions: a unit the human decides
  individually — before or after a fan-out — keeps its own decision.

Forbidden:

- Fan-out anywhere the grammar does not declare it: a category absent from
  `fanout_categories`, or a family with no fan-out declaration at all.
- Treating any blank decision as decided — blank means pending in every
  family, and no inheritance of any kind exists anywhere (header bulk is
  retired; the validator rejects a `BULK:` header as invalid input).
- Auto-disposing metaphor entries from their `CLEAN` / `REVIEW` / `BROKEN`
  flags — those are producer recommendations, never decisions.
- Auto-selecting a variant for a metaphor entry — the `Selected:` field is the
  human's round-two decision, and a blank one is selection-pending, never an
  agent's pick. `metaphor_apply` blocks on a blank `Selected:`; it never
  best-guesses which variant the human meant (the retired delete-to-select
  convention is what made guessing tempting — a structured field removes it).
- Writing any decision the human did not state. A recommendation is not a
  decision; a fan-out is one human decision mechanically applied, never an
  agent-originated one.
