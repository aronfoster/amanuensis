# Reject obsolete draft evidence

> ILLUSTRATIVE EXAMPLE — NOT REAL PROJECT CANON OR STATE.

Use the two shared `plot/storyboards/scene*-beat01-storyboard.md` files. The manifest selects the draft in this directory; no other attempt is an input.

## Expected semantic result

Only v02 is reviewed. Exactly one Check 1 MISSING, no REDUNDANT; old-version, other-attempt and nonexistent-scene witnesses are rejected. The report itself remains fresh against v02.

## Reproduce

Read `agents/steps/compliance-report.md` Check 4, resolve this manifest, then read the declared storyboards and the entire selected draft. Before opening `reviewer-actions.md`, record each candidate item, its dramatic purpose, exact earlier-scene witness (or reason it fails), and the resulting check/owner. Compare that result with the expected report. The report is a specimen, not evidence of an independent model run.

Run the root fixture checker described in `examples/prior-reader-context/README.md`. This report must be fresh and structurally valid; expected validator exit: **4**. Exit 4 means genuine actionable findings await human decisions, not a grammar error. The validator does not judge semantic truth.

## Rejected witness challenges

The manifest selects `draft-v02.md`, where scene01 omits the conditions. A proposed quote from this attempt’s `draft-v01.md#scene01`, or from `plot/drafts/attempt01/draft-v01.md#scene01`, is inadmissible even though the words match the plan. Reject those paths without treating their prose as proof. Also reject a proposed current-draft `#scene99`: no such scene boundary exists. An explicit read-from override to `draft-v01.md` would require a new report stamped for that draft and a fresh judgment; it does not repair this report’s citations.
