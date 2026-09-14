# Prior-reader scene-entry fixture

> **ILLUSTRATIVE EXAMPLE — NOT REAL PROJECT CANON OR STATE.**
> The survey brig *Wayfinder*, Eda Venn, Hale, and every event in this folder
> are invented only to demonstrate the Amanuensis workflow. Do not treat them
> as a real project's story files or copy them into a consuming project as
> canon.

This focused `short_story` fixture reproduces the FOS-41 failure boundary: two
scenes are drafted in isolation, while the second scene continues materially
unchanged conditions that the first scene has already established.

## What to inspect

- `plot/storyboards/scene01-beat01-storyboard.md` uses the exact opening-scene
  sentinels, then establishes the ship, weather, sea, role, and active concern
  in its `Reader takeaway`.
- `plot/storyboards/scene02-beat01-storyboard.md` derives `Reader state in` from
  that reader-visible outcome. Its `Since previous scene` records both the
  elapsed time and the material non-change in wind, sea, course, and point of
  sail. The current beat directs the isolated drafter to open on the new action,
  not replay the establishing shot.
- `plot/storyboards/storyboard-review.md` is a pre-draft advisory excerpt showing
  the scene-2 entry fields passing placement, reader-state, delta, and scope
  checks against the preceding planned scene.
- `plot/drafts/attempt01/draft-v01.md` is deliberately noncompliant. Scene 2
  opens by establishing the same ship, wind, and swell again before reaching
  its actual action.
- `plot/drafts/attempt01/reviewer-actions.md` shows the chapter-wide
  assembled-draft safeguard: scene 1's block is `CLEAN`, and scene 2 carries one
  `REDUNDANT (reader_state_in)` prose finding cited to its entry field. The
  summary reports one of two blocks clean and counts the redundant finding as a
  subset of the relational total. Its decision is filled so the checked-in
  artifact validates as ready to proceed.

The two review stages protect different boundaries. `storyboard_review` checks
that the isolated drafter receives correct, compact context before prose exists.
`compliance_report` reads the assembled draft across scenes and catches a
drafter that nevertheless treats that context as material to explain again.

## Validate the review artifact

From the Amanuensis repository root:

```sh
sh scripts/validate-review-artifact.sh \
  examples/prior-reader-context/plot/drafts/attempt01/reviewer-actions.md \
  agents/review-grammars.yaml \
  examples/prior-reader-context/plot/drafts/attempt01/draft-manifest.md
```

Expected result: `proceed` with one decided review unit and exit status `0`.
