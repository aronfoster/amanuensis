# Prior-reader establishment evidence fixtures

> **ILLUSTRATIVE EXAMPLES — NOT REAL PROJECT CANON OR STATE.**
> Wayfinder, Eda, Hale, and all events here are invented workflow examples.

FOS-41 supplies isolated drafters with scene-entry context. FOS-84 protects the
reader's first actual establishment when the earlier draft did not enact that
plan. These are expected-output specimens for `compliance_report`, plus a
reproducible reviewer walk-through; they are not a semantic classification engine
or a transcript of independent model evaluations.

## Inputs and expected results

The six `plot/drafts/attemptNN/` variants share the original two Wayfinder
storyboards and scene list. Each attempt is an **independent test selection**:
select that attempt explicitly, not the numerically highest sibling. Resolve its
manifest before reviewing. `cases/` contains four compact independent input
sets, each with only its own short storyboard excerpts and drafts. It does not
inherit the Wayfinder storyboards. Each case/attempt has a README describing its
exact inputs and expected behavior.

Counts below are Must-Contain / relational / redundant / unverified diagnostic.
The redundant count is a subset of relational; the diagnostic creates no unit.

| Case | Expected semantic result | Counts | Units | Validator exit |
| --- | --- | --- | --- | --- |
| [attempt01](plot/drafts/attempt01/README.md) | Earlier prose establishes every repeated sailing claim; one item-specific REDUNDANT | 0 / 1 / 1 / 0 | 1 | 0 |
| [attempt02](plot/drafts/attempt02/README.md) | Earlier Must Preserve omitted; reuse Check 1 MISSING, retain later introduction; bare FIX escalates placement conflict | 1 / 0 / 0 / 0 | 1 | 0 |
| [attempt03](plot/drafts/attempt03/README.md) | Ship/course/wind repeated; swell first appears later: DEGRADED plus narrowly scoped REDUNDANT; retain swell | 1 / 1 / 1 / 0 | 2 | 4 |
| [attempt04](plot/drafts/attempt04/README.md) | Wind/sensation hint establishes none of the specific sailing claims; DEGRADED, later scene retained | 1 / 0 / 0 / 0 | 1 | 4 |
| [attempt05](plot/drafts/attempt05/README.md) | Active v02 omits establishment; reject old v01, another attempt and nonexistent scene pointers | 1 / 0 / 0 / 0 | 1 | 4 |
| [attempt06](plot/drafts/attempt06/README.md) | Both statements occur inside scene02; same-scene witness cannot prove prior-scene knowledge | 1 / 0 / 0 / 0 | 1 | 4 |
| [takeaway-only](cases/takeaway-only/README.md) | Signal meaning planned only as takeaway; first explained later: both blocks CLEAN, diagnostic only | 0 / 0 / 0 / 1 | 0 | 0 |
| [pre-chapter](cases/pre-chapter/README.md) | Scene01 key and scene02 bell lack reader proof despite state records; two missing-context units. Scene03 key has current-scene01 proof: REDUNDANT | 0 / 3 / 1 / 0 | 3 | 0 |
| [exceptions](cases/exceptions/README.md) | Natural use, changed condition, contrast, correction and justified reminder all CLEAN | 0 / 0 / 0 / 0 | 0 | 0 |
| [storyboard-defect, attempt01](cases/storyboard-defect/README.md) | Earlier evidence exists; Beat demands pointless repetition: REDUNDANT routes to storyboard | 0 / 1 / 1 / 0 | 1 | 4 |
| [storyboard-defect, attempt02](cases/storyboard-defect/plot/drafts/attempt02/README.md) | Same Beat, absent earlier enactment: MISSING only, no storyboard REDUNDANT | 1 / 0 / 0 / 0 | 1 | 4 |

Exit 4 is expected for fresh reports with blank human decisions. Exit 0 means
there are no units or the **illustrative** human decisions are filled, not that a
model may fill them. No specimen has an invalid unit or a stale report stamp.
The original `storyboard-review.md` remains the separate pre-draft planning
example; it cannot prove enacted reader knowledge.

## Reproduce the reviewer walk-through

1. Read Check 4 of `agents/steps/compliance-report.md` and the selected case's
   README. Resolve its manifest and read only the named inputs, including the
   whole current draft. Initially hide the expected `reviewer-actions.md`.
2. Identify exact candidate propositions and test current dramatic purpose
   first. For each remaining item, record the smallest reader-sufficient quote
   and its strictly earlier **scene** in that exact draft, or why proof fails.
   Plans, hints, another attempt/version, same-scene witnesses, and objective
   state alone do not satisfy this gate.
3. Run the local checks as well. Assign an earlier Must Preserve omission to
   Check 1 once, with a later-establishment cross-reference. Takeaway-only
   omissions get the separate diagnostic, without a pending review unit.
4. Compare the resulting item set, owning block, evidence, defect routing,
   counts and retained information to the checked-in report and table above.
   Rejected evidence must not become an instruction to delete the later text.
5. For attempt02, follow `compliance-fix.md` with its illustrative bare FIX:
   compare the no-prose-change escalation to `expected-fix-log.md`. For the
   pre-chapter case, verify that a missing-context FIX still routes upstream.

### Recorded implementation walk-through — 2026-11-13

The implementation self-review followed the above gates across all eleven
reports and matched the expected finding sets. Specific observations:

- The original first sentence establishes ship/type, eastward course and the
  northwest wind on the starboard quarter; its second sentence establishes the
  long following swell. In the mixed variant only the first survives, so the
  later swell cannot be included in the redundancy unit.
- A wind worrying a sleeve and something shifting underfoot establish neither
  northwest direction nor long following swell. The hint-only result is
  DEGRADED, not evidence for deletion.
- Eda's unease in the original fixture is also specified by Character state
  out. It is therefore **not** a clean takeaway-only test. The independent
  tide-bell fixture uses signal meaning absent from both Must Preserve and
  Character state out, so its zero-unit result is intentional.
- The obsolete-draft specimen's active v02 has no earlier establishment. The
  same-scene specimen has the words, but only after scene02 begins. Neither
  permits a prior-scene redundancy finding.
- Pre-chapter fact/knowledge records do not attest the reader's explanation.
  Current scene01 nevertheless supplies a valid witness for scene03. Scene02
  naturally using the key and silence about Eda's role add no findings.
- The fix guard is needed because a local, untagged Check 1 unit normally
  reaches prose repair. The old generic “do not introduce a violation” rule
  did not explicitly identify or route this two-scene placement conflict.

This is a documented semantic **self-review**, not independent model validation.
Independent review should repeat the walk-through and challenge any judgment
with a concrete passage and proposition.

## Mechanical validation

From the repository root:

```sh
python3 examples/prior-reader-context/check-fixtures.py
sh scripts/check-pipeline-state.sh templates/pipeline-state.md agents/steps
git diff --check
```

The fixture checker invokes the **unchanged** shared review validator with each
report's own manifest. It also verifies expected counts, single refs, quoted
witness presence, exact draft path, canonical scene boundaries and scene order.
Both `Earlier:` proof and all six `First enacted later:` cross-references are
checked, with opposite strict scene-order requirements. Negative controls reject
wrong attempts/versions, same or earlier scenes on a later reference, nonexistent
scenes, and invented quotes.
It preserves the intentionally invalid `examples/review/reviewer-actions.md`
exit 3, checks the existing [relational-review](../relational-review/README.md)
report with its manifest, preserves the already-applied
`unreviewed-confirmation` report’s intentional stale state (and its v01
read-from result), and exercises stale-stamp/read-from controls in scratch copies. It validates specimen integrity, **not semantic sufficiency**.

For one report, the underlying command is:

```sh
sh scripts/validate-review-artifact.sh \
  examples/prior-reader-context/plot/drafts/attempt01/reviewer-actions.md \
  agents/review-grammars.yaml \
  examples/prior-reader-context/plot/drafts/attempt01/draft-manifest.md
```

## Review follow-up — 2026-11-13

The Check 1 templates now show the conditional later-establishment cross-reference,
and the report reconciles earlier omissions after reading the whole chapter.
The fix-step walk-through for attempt02 was repeated with that cross-reference
omitted: the named missing sailing claims still appear in scene02 of the same
draft, so the independent later-scene check reaches the same no-write escalation.
The pre-chapter README also records the dependent-fix boundary: changing scene01
requires regenerating the report before relying on it to delete scene03’s claim.
These are semantic walk-throughs; the mechanical checker does not execute an LLM
fix step or prove its behavior.
