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

The file begins with a single top-of-file `Reviewed-draft:` line naming the resolved `<latest-draft>` this run reviewed — the draft this run actually read, so when a read-from override is in effect the stamp names that draft; this stamp is the draft-version identity the downstream `metaphor_fix` and `metaphor_apply` steps read to detect stale annotations against a newer draft. If the file does not exist, create it with the stamp. If the file exists and its top-of-file stamp equals `<latest-draft>`, preserve the stamp and append new findings below. If the file exists and its top-of-file stamp does not equal `<latest-draft>` — the recovery path when the human is regenerating after a stale-report blocker — **overwrite the whole file** with a fresh top-of-file stamp; the prior run's findings against the superseded draft are discarded. See `agents/orchestrator.md`'s report→fix freshness invariant for the canonical statement. `metaphor_fix` preserves whatever stamp it inherits and does not refresh it.

```markdown
Reviewed-draft: draft-vNN.md
```

Begin each scene's section with:

```markdown
## Metaphor Report — Scene xx-yy
```

For each figure collected, produce one entry:

```markdown
### [Short label — e.g. "fork bends like something living"]

- **Quote:** "[exact prose quote]"
- **Tenor:** [what is actually being described]
- **Vehicle:** [what it is being compared to]
- **Borrowed property:** [the specific quality the comparison imports from vehicle to tenor]
- **Uninvited properties:** [what else the vehicle brings that the author didn't intend to borrow]
- **Implication:** [what the reader is invited to feel or understand about the tenor as a result]
- **Register fit:** [does the implication serve the scene's emotional register, or work against it?]
- **Flag:** CLEAN | REVIEW | BROKEN
- **Human Assessment:**
```

**Flag definitions:**

- `CLEAN` — comparison holds; implication serves the scene
- `REVIEW` — comparison holds logically but the implication may be off-register, overwrought, or compete with the prose's stated intent; human should decide
- `BROKEN` — the comparison does not hold, imports wrong connotations, or contradicts the scene's emotional work

Do not editorialize in `Register fit` or `Implication`. State what the metaphor does, not whether you like it. The flag is where judgment lands.

Leave the `Human Assessment` line empty. It will be completed by the human reviewer.

### At the end of each scene

Append a summary:

```markdown
### Summary — Scene xx-yy

- Figures collected: N
- CLEAN: N
- REVIEW: N
- BROKEN: N
```

No pattern-level commentary. The summary is a count.

### Anti-Patterns

**Reporting dead metaphors.** Conventional idioms are not figures. Skip them unless genuinely unsure.

**Editorializing in the entry fields.** `Implication` and `Register fit` are descriptive. Judgment belongs in the flag only.

**Proposing rewrites.** This workflow reports. Fixes are out of scope.

**Consulting the storyboard as a spec.** The storyboard tells you what the scene was supposed to feel like. Use it to calibrate register fit. Do not treat it as a checklist to diff against — that is compliance's job.

**Skipping a figure because it seems intentional.** Intentionality is not the test. A broken metaphor the author chose deliberately is still broken. Report it; the human decides.

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/metaphors.md` — one file per chapter; append across scenes with a scene header. Begins with a single top-of-file `Reviewed-draft: draft-vNN.md` line naming the `<latest-draft>` this report covers. Subsequent runs against the same draft append below and preserve the stamp; a run against a newer draft (stale-report recovery path) overwrites the file with a fresh stamp. Each scene section contains one entry per figure (in the format above) and a per-scene summary count. The file is a working artifact the human will annotate before `metaphor_fix` runs; `metaphor_fix` and `metaphor_apply` read the reviewed-draft stamp to detect stale annotations.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs, append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate inputs and do not write partial outputs. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
