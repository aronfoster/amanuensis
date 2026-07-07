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
| `prose-pass.md` | `prose_pass` (pending until M12) | book (no scene segment) | KEEP finding carrying no anchor and no fields (not a review unit); decided, skipped, and pending actionable findings; no bulk anywhere | not-yet-adopted error, exit 1 |
| `metaphors.md` | `metaphor` (pending until M13) | short_story | all five tokens, including `REPLACE: <image>` with its required payload and a non-destructive `REJECT`; one pending entry | not-yet-adopted error, exit 1 |

The two `pending`-family fixtures (`prose-pass.md`, `metaphors.md`) also
document, in their trailing expectation comments, the ledger the validator
must produce once their milestone flips the adoption marker (verify by
pointing the script at a scratch copy of the grammar file with the marker
flipped — never by editing `agents/review-grammars.yaml` in place). The
compliance fixture is deliberately mid-review with one invalid unit; its
comment also states the proceed outcome once the pending unit is filled and
the illegal token corrected. The anti-AI fixture is deliberately mid-review
with one pending unit; its comment states the proceed outcome once that
unit is decided.

Note the validator identifies the family by the artifact's filename, so a
scratch copy must keep the canonical basename (e.g.
`<scratch-dir>/reviewer-actions.md`).
