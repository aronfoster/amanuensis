# Review-grammar fixtures

One specimen per human-gated review artifact family, in the target structured
format defined by `agents/review-grammars.yaml`. These are the test inputs
for `scripts/validate-review-artifact.sh`: each fixture ends with an HTML
comment stating its expected ledger, and running the validator against it
must reproduce that expectation exactly. They are not real project artifacts
— content and tone follow the producing steps' report formats, but the prose
they quote is invented for the fixtures.

Run from the repo root, no manifest (the state layer reports `not checked`):

```sh
sh scripts/validate-review-artifact.sh examples/review/<fixture> agents/review-grammars.yaml
```

| Fixture | Family | review-id form | Exercises | Expected today |
| --- | --- | --- | --- | --- |
| `reviewer-actions.md` | `compliance` (adopted) | short_story | CLEAN block vs violations; blank (pending), `FIX`, `FIX: <instruction>`, `SKIP`, `ESCALATE`; one deliberately illegal token | ledger total 6, pending 1, decided 2, skipped 1, escalated 1, invalid 1 — verdict `invalid-present`, exit 3 |
| `anti-ai.md` | `anti_ai` (adopted) | book | fan-out-era cases: a fan-out-eligible category with fanned-out identical decisions carrying category-decision audit notes plus a per-entry `SKIP` exception; a non-eligible category with a decided unit and a blank pending unit; an `ESCALATE` on a nested-auxiliary-line unit; a `No flags.` scene (not a review unit) | ledger total 6, pending 1, decided 3, skipped 1, escalated 1, invalid 0 — verdict `pending-remain`, exit 4 |
| `prose-pass.md` | `prose_pass` (adopted) | book (no scene segment) | every finding an anchored unit, KEEP included: a KEEP finding confirmed with `SKIP`, a decided `FIX`, a blank pending finding, an `ESCALATE`; the `#### Findings` container; no bulk or fan-out anywhere | ledger total 4, pending 1, decided 1, skipped 1, escalated 1, invalid 0 — verdict `pending-remain`, exit 4 |
| `metaphors.md` | `metaphor` (adopted) | short_story | two evidence layers: all five `Decision:` tokens incl. `REPLACE: <image>` with its required payload and a non-destructive `REJECT`; actionable entries carry a `#### ` variant set with a `Selected:` id (one filled `REPLACE`, one filled `FLATTEN` + `Selection-note:` edit, one blank `WORKSHOP` = selection-pending); one blank-`Decision:` pending figure | decision round: total 6, pending 1, decided 5, invalid 0 — `pending-remain`, exit 4; selection round (`--round selection`): same, plus selection-pending 1, selected 2 — `pending-remain`, exit 4 |

All four families are now `adopted`; none remains pending. The `metaphors.md`
fixture is the one two-evidence-layer specimen: its trailing expectation
comment documents **both** round ledgers — the decision round (`metaphor_fix`'s
gate) and the selection round (`metaphor_apply`'s gate, via `--round
selection`) — and their exit codes. The compliance fixture is
deliberately mid-review with one invalid unit; its comment also states the
proceed outcome once the pending unit is filled and the illegal token
corrected. The anti-AI and prose-pass fixtures are each deliberately mid-review
with one pending unit; their comments state the proceed outcome once that unit
is decided.

Note the validator identifies the family by the artifact's filename, so a
scratch copy must keep the canonical basename (e.g.
`<scratch-dir>/reviewer-actions.md`).
