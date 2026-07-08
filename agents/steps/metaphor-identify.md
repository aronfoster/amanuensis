---
step_id: metaphor_identify
review_required: true
inputs:
  - <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
  - <chapter-folder>/storyboards/*-storyboard.md
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/metaphors.md
preconditions:
  - path: <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
    kind: prose_draft
    required: true
    review_sensitive: false
  - path: <chapter-folder>/storyboards/*-storyboard.md
    kind: source
    required: true
    review_sensitive: false
---

See `agents/orchestrator.md` for the step workflow contract.

# Metaphor Identify

## Purpose

Reviews drafted prose for figurative comparisons. Reports findings for human evaluation. Does not fix. The step produces a working file the human annotates before `metaphor_fix` dispatches subagents to generate variants.

## Inputs

- `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` — the latest prose, resolved at step start via the manifest's active head — or via the read-from override the dispatcher passed — per `agents/project-layouts.md`, not by highest-numbered draft. This step does not mint a new draft version.
- `<chapter-folder>/storyboards/*-storyboard.md` — the storyboard blocks for the chapter, used for emotional register and scene intent only; do not treat storyboard fields as specifications to diff against.

Do not read canon files, the scene list, or any other file.

## Behavior

### What to collect

Collect every simile and live metaphor in the prose. A **live metaphor** is a comparison the prose is actively deploying — one where the vehicle is doing work on the tenor in this sentence, in this scene.

**Ignore dead metaphors.** A dead metaphor is a comparison so conventionalized that it no longer evokes the vehicle: "grasped the idea," "the heart of the matter," "a sharp answer." These are idioms, not figures. Do not report them.

**If unsure whether a metaphor is dead or live, report it.** The cost of a false positive is low. The cost of missing a broken live metaphor is not.

### Format

The file begins with a single top-of-file `Reviewed-draft:` line naming the resolved `<latest-draft>` this run reviewed — the draft this run actually read, so when a read-from override is in effect the stamp names that draft; this stamp is the draft-version identity the downstream `metaphor_fix` and `metaphor_apply` steps read to detect stale annotations against a newer draft. If the file does not exist, create it with the stamp. If the file exists and its top-of-file stamp equals `<latest-draft>`, preserve the stamp and append new findings below. If the file exists and its top-of-file stamp does not equal `<latest-draft>` — the recovery path when the human is regenerating after a stale-report blocker — the report is `regenerated`: **overwrite the whole file** with a fresh top-of-file stamp, and the prior run's findings against the superseded draft are `discarded`. See the general freshness contract in `agents/orchestrator.md`'s Artifact-state section (the report→fix freshness invariant is its canonical worked instance). `metaphor_fix` preserves whatever stamp it inherits and does not refresh it.

```markdown
Reviewed-draft: draft-vNN.md
```

Begin each scene's section with:

```markdown
## Metaphor Report — Scene xx-yy
```

A scene with no figures records its scene header plus a single `No figures.` line — no anchor, no fields, not a review unit. It is the audit record that the scene was scanned:

```markdown
## Metaphor Report — Scene xx-yy

No figures.
```

**Review unit shape.** Every figure collected is one review unit and shares one shape: a `<!-- review-id: ... -->` anchor on its own line immediately above the entry's `### [Short label]` heading, the identify fields (Quote / Tenor / Vehicle / Borrowed property / Uninvited properties / Implication / Register fit) and the `Flag` line unchanged, and blank `- Decision:` / `- Decision-note:` fields as the entry's final two fields — the human's disposition, replacing the free-text assessment line this step no longer emits:

```markdown
<!-- review-id: metaphor:<scene-id>:figure-<NN> -->
### [Short label — e.g. "fork bends like something living"]

- **Quote:** "[exact prose quote]"
- **Tenor:** [what is actually being described]
- **Vehicle:** [what it is being compared to]
- **Borrowed property:** [the specific quality the comparison imports from vehicle to tenor]
- **Uninvited properties:** [what else the vehicle brings that the author didn't intend to borrow]
- **Implication:** [what the reader is invited to feel or understand about the tenor as a result]
- **Register fit:** [does the implication serve the scene's emotional register, or work against it?]
- **Flag:** CLEAN | REVIEW | BROKEN
- Decision:
- Decision-note:
```

The review-id follows the `metaphor` family segment grammar in `agents/review-grammars.yaml`; the item segment is `figure-<NN>`, the entry's emission ordinal within its scene section, and the short_story and book forms are defined there — do not restate them here. Emit `Decision:` and `Decision-note:` blank — they belong to the human, and a blank `Decision:` means the unit is pending review. The fixture `examples/review/metaphors.md` shows the exact target shape.

**Flag definitions:**

- `CLEAN` — comparison holds; implication serves the scene
- `REVIEW` — comparison holds logically but the implication may be off-register, overwrought, or compete with the prose's stated intent; human should decide
- `BROKEN` — the comparison does not hold, imports wrong connotations, or contradicts the scene's emotional work

Do not editorialize in `Register fit` or `Implication`. State what the metaphor does, not whether you like it. The flag is where judgment lands.

### Decisions

After this step runs, the human — companion-assisted, via the `amanuensis-review` skill — records a disposition in each unit's `Decision:` field, per the `metaphor` family grammar in `agents/review-grammars.yaml` (the legal token set, the payload rule, and blank-means-pending semantics live there, not here). `Decision-note:` is optional free text for the human's why and is never machine-parsed. A blank `Decision:` means the unit is still pending review. The `Flag` this step emits is a producer recommendation only — it never disposes of an entry; the disposition lands in `Decision:`. `metaphor_fix` then consumes the filled per-unit fields. There is no per-scene count block: the validator's ledger is the count.

### Anti-Patterns

**Reporting dead metaphors.** Conventional idioms are not figures. Skip them unless genuinely unsure.

**Editorializing in the entry fields.** `Implication` and `Register fit` are descriptive. Judgment belongs in the flag only.

**Proposing rewrites.** This workflow reports. Fixes are out of scope.

**Consulting the storyboard as a spec.** The storyboard tells you what the scene was supposed to feel like. Use it to calibrate register fit. Do not treat it as a checklist to diff against — that is compliance's job.

**Skipping a figure because it seems intentional.** Intentionality is not the test. A broken metaphor the author chose deliberately is still broken. Report it; the human decides.

**Pre-filling a decision field.** `Decision:` and `Decision-note:` are emitted blank. They belong to the human; a report that fills any `Decision:` — however obvious the flag — has decided instead of reported, and a blank `Decision:` is the only honest signal that a figure is still pending.

**Anchoring a `No figures.` line.** A scene that collected no figures records `## Metaphor Report — Scene xx-yy` plus one `No figures.` line — no anchor, no fields. An anchor turns it into a countable review unit.

**Dropping the anchor on a figure.** Every figure carries a `<!-- review-id: ... -->` anchor immediately above its `### ` heading. A figure without its anchor is an orphaned item the validator rejects.

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/metaphors.md` — the human review artifact; one file per chapter, appended across scenes with a scene header. Begins with a single top-of-file `Reviewed-draft: draft-vNN.md` line naming the `<latest-draft>` this report covers — the draft this run actually read. Subsequent runs against the same draft append below and preserve the stamp; on the append path each scene's `figure-<NN>` ordinals continue rather than restarting so review-ids never collide within the epoch. Against a newer draft (stale-report recovery path) the report is `regenerated` — the file is overwritten with a fresh stamp and the prior findings `discarded`. Each scene section holds either a single `No figures.` line (no anchor, no fields, not a review unit) or one review unit per figure — each carrying its `<!-- review-id: ... -->` anchor immediately above its `### [Short label]` heading, the identify fields, the `Flag`, and blank `- Decision:` / `- Decision-note:` fields. There is no per-scene summary count; the validator's ledger is the count. The human records a disposition in each unit's `Decision:` field per the `metaphor` family grammar in `agents/review-grammars.yaml` before `metaphor_fix` runs; `metaphor_fix` and `metaphor_apply` read the `Reviewed-draft` stamp to detect stale annotations.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs, append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate inputs and do not write partial outputs. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
