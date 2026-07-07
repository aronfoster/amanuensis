# Amanuensis dispatcher smoke fixture

## What this is

This directory is a minimal `short_story` project committed inside the Amanuensis repo for one purpose: smoke-testing the dispatcher surface (`/run-step` and `/next-step` for Claude Code, the `run-step` and `next-step` agents for OpenCode) end-to-end against real step bodies. It is not a real story, not a tutorial, and not exercised by any automated test suite. The story plan in `plot/summary.md` is a single sentence — just enough that `character_extraction` has at least one named character to consider.

The goal of running the recipes below is to confirm that the dispatcher itself works: it locates `pipeline-state.md`, confirms the requested (or recommended-next) step_id appears in the recipe list, resolves the workflow file at `amanuensis/agents/steps/<step>.md`, verifies the step's `required: true` preconditions resolve to existing files, and follows the step body in the same session — the step body then either records its own completion or stops with a question. Validating the literary quality of the step bodies' output is **not** a goal here.

Four recipes cover the four selective-execution behaviors: the default recipe run in order (Recipe 1), rerunning a completed step (Recipe 2), a fix step blocking on a stale report (Recipe 3), and a non-dependent step running out of recipe order (Recipe 4). A fifth recipe covers the draft-lineage branch surface: rerunning a fix step from an earlier draft with a read-from argument, which mints a new draft as the active head and stamps the displaced drafts superseded (Recipe 5). Three further recipes exercise the Artifact-state model (`agents/orchestrator.md`'s **Artifact state** section) on the `anti_ai_report → anti_ai_fix` pair: a pending (blank-`Decision:`) report blocking the fix step as `review_pending` (Recipe 6), regenerating a stale report against the active head so the fix step runs clean (Recipe 7), and a human-recorded override that lets a stale apply proceed (Recipe 8). Two further recipes exercise the M10 structured review contract on the `compliance_report → compliance_fix` pair: a blank `Decision:` field blocking the fix step as `review_pending` and the hand-filled decision letting it run clean (Recipe 9), and an `amanuensis-review` companion session recording the same decision by review-id (Recipe 10). Two final recipes exercise the M11 structured anti-AI contract: a companion fan-out session adjudicating a whole eligible category with one stated decision plus a per-entry `SKIP` exception (Recipe 11), and a stray legacy `BULK:` header blocking the fix step as invalid input (Recipe 12). See `agents/orchestrator.md` for the canonical contract the dispatcher follows.

## Layout

Committed in this directory:

- `amanuensis-project.yaml` — `project_type: short_story`.
- `pipeline-state.md` — the project's recipe and status record: the canonical step list with every step `[ ]`.
- `plot/summary.md` — one-sentence story plan.
- `voice.md` — project-root voice file (started from `templates/voice.md`); the voice-consuming steps read it here. Committed so `install.sh` skips it and the fixture stays a valid consuming project, even though the smoke steps do not read it.
- `open-questions.md` — empty placeholder; step bodies append here when they block.
- `README.md` — this file.
- `.gitignore` — blocks accidental commits of the install artifacts and symlink listed below.

**Not** committed (produced by the recipes, removed by the reset procedure):

- `.claude/commands/run-step.md` and `.claude/commands/next-step.md` — copied in by `install.sh`.
- `.opencode/agents/run-step.md` and `.opencode/agents/next-step.md` — copied in by `install.sh`.
- `amanuensis` — symlink to the Amanuensis repo root (this repo). Lets the dispatcher resolve `amanuensis/agents/steps/<step>.md` exactly as it would under a real submodule install.
- `characters/` — written by `character_extraction` on a successful run (Recipes 1–2).
- `plot/drafts/attempt01/` — hand-authored for Recipes 3–12 (filler drafts and a stamped report: a `reviewer-actions.md` for Recipes 3–5 and 9–10, an `anti-ai.md` for Recipes 6–8 and 11–12; Recipe 5 additionally hand-authors a `draft-manifest.md` carrying an `Active-head: draft-vNN.md` pointer and a three-entry lineage). On Recipe 4's success the fix step also writes `draft-v03.md` and `draft-manifest.md` here; on Recipe 5's success it writes the branch output `draft-v04.md` and updates the hand-authored manifest's pointer and `superseded_by` stamps; on Recipes 7–8's success `anti_ai_fix` writes `draft-v03.md` and `draft-manifest.md` and appends to `anti-ai.md`, and in Recipe 7 `anti_ai_report` first overwrites `anti-ai.md` in place; on Recipe 9's success (and Recipe 10's follow-on) `compliance_fix` writes `draft-v03.md` and `draft-manifest.md` here as in Recipe 4; on Recipe 11's success (its second fix run, after the companion session fills the report's decision fields in place) `anti_ai_fix` writes `draft-v03.md` and `draft-manifest.md` and appends to `anti-ai.md` as in Recipes 7–8.

## Setup

From the Amanuensis repo root:

```sh
cd examples/smoke
ln -s ../.. amanuensis
./amanuensis/install.sh .
```

The symlink lets the dispatcher resolve `amanuensis/agents/steps/<step>.md` exactly as it would under a real submodule install at `<project>/amanuensis/`. The `install.sh` invocation copies the four dispatcher source files into `.claude/commands/run-step.md`, `.claude/commands/next-step.md`, `.opencode/agents/run-step.md`, and `.opencode/agents/next-step.md` under this directory.

After setup, this directory should contain:

```
.claude/commands/next-step.md
.claude/commands/run-step.md
.opencode/agents/next-step.md
.opencode/agents/run-step.md
amanuensis -> ../..
amanuensis-project.yaml
open-questions.md
pipeline-state.md
plot/summary.md
voice.md
README.md
.gitignore
```

## Verify the fixture (optional)

The smoke fixture's `pipeline-state.md` is a checked artifact. From the Amanuensis repo root, you can confirm every listed step resolves to an installed step file with:

```sh
sh scripts/check-pipeline-state.sh examples/smoke/pipeline-state.md agents/steps
```

This is a convenience for maintainers, not a required step of the smoke test — the same check runs in CI.

## Run — Claude Code

All recipes assume Setup is done and each dispatcher invocation happens in a fresh Claude Code session with cwd = `examples/smoke`. Recipe 2 follows directly from Recipe 1; Recipes 3–12 each start from a freshly reset fixture (see **Reset between runs**) plus the hand-authored files described inline.

### Recipe 1 — default recipe in order

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/next-step
```

`/next-step` is the recommended-path convenience layer: it resolves the first non-`[x]` step in the recipe list — on the fresh fixture, `character_extraction` — reports its selection, and then proceeds exactly as `/run-step character_extraction` would: same precondition checks, same failure modes, one step per invocation. This recipe is identical in intent to the original single-step smoke run.

Two acceptable observable outcomes:

1. **Success.** The dispatcher reads `pipeline-state.md`, selects `character_extraction`, loads `amanuensis/agents/steps/character-extraction.md`, the step body identifies at least the lighthouse-keeper character (`rao`) plus the unnamed replacement, writes `characters/<id>/profile.md` and `characters/<id>/knowledge/baseline.md` for each, possibly appends `important` or `minor` entries to `open-questions.md` for stub fields, and as its final action flips `[ ] character_extraction` to `[x] character_extraction` and updates `last_updated`. No other checkbox changes — there is no marker to move. The dispatcher exits cleanly.
2. **Stop and ask.** The step body decides the one-sentence plan is too thin to proceed safely, appends a `critical` blocker to `open-questions.md` describing what could not be resolved, and exits without recording completion: the `character_extraction` line stays `[ ]` and `pipeline-state.md` is untouched (`last_updated` unchanged). The dispatcher exits cleanly.

Either outcome confirms the dispatcher is wired correctly. A third outcome — the dispatcher itself errors before reaching the step body — indicates a real defect in the dispatcher source, the install script, or the orchestrator contract, and is the failure mode this smoke test is designed to surface.

### Recipe 2 — rerun a completed step

Run after Recipe 1 succeeds (the `character_extraction` line is `[x]`):

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/run-step character_extraction
```

The mechanism under test is rerun-of-a-completed-step. Using `character_extraction` is deliberate: it is the fixture's only cheaply runnable step, so it stands in for the fix/pass steps a real project would rerun.

Expected observable outcome: the dispatcher confirms `character_extraction` appears in the recipe, resolves the step file, checks preconditions, and runs the step body again. The existing `characters/` outputs are overwritten. The completion action is a no-op on the already-checked line — it stays `[x]`, `last_updated` refreshes, and **no downstream checkbox changes**: every other line stays `[ ]`. Rerunning never rewinds anything.

### Recipe 3 — fix step blocks on a stale report

Reset the fixture and repeat Setup. Then hand-author the following three untracked files. Per the `short_story` layout in `agents/project-layouts.md`, `<chapter-folder>` resolves to `plot/` and attempt directories are named `attemptNN`, so the attempt folder is `plot/drafts/attempt01/`.

`plot/drafts/attempt01/draft-v01.md`:

```markdown
The lamp went dark and Rao climbed the stair without a light.

He told no one what he found at the top.
```

`plot/drafts/attempt01/draft-v02.md`:

```markdown
The lamp went dark and Rao climbed the stair without a light.

He told no one what he found at the top, and by morning he had talked himself out of telling anyone at all.
```

`plot/drafts/attempt01/reviewer-actions.md` — a minimal structured compliance report stamped against `draft-v01.md`, carrying one anchored review unit whose `Decision:` field the human has filled with a `FIX` instruction (shape per the `compliance:` family block in `agents/review-grammars.yaml`; `examples/review/reviewer-actions.md` is the reference fixture):

```markdown
Reviewed-draft: draft-v01.md

## Compliance Report — Scene 001, 2026-07-02

### Block 001
<!-- review-id: compliance:001:block-001-v01 -->
- DEGRADED (must_preserve): Lamp failure cause — the block requires the lamp to fail on its own; the prose leaves the cause unstated. Prose: "The lamp went dark and Rao climbed the stair without a light."
  - Decision: FIX: change "The lamp went dark" to "The lamp guttered out on its own"
  - Decision-note:
```

Then:

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/run-step compliance_fix
```

Expected observable outcome — a clean blocked exit, not a dispatcher error:

- The dispatcher's existence checks pass: `reviewer-actions.md` exists and `<latest-draft>` resolves (`draft-v02.md` is the highest-numbered draft in `plot/drafts/attempt01/`), so the step body loads. The storyboard precondition is `required: false`, so the absence of `plot/storyboards/` does not block dispatch.
- At step start, the step body compares the report's `Reviewed-draft: draft-v01.md` stamp against the current `<latest-draft>` (`draft-v02.md`), detects the mismatch, and appends the stale-report blocker to `open-questions.md`, recording the stamped draft and the current one. The freshness check precedes the shared validator run, so the block fires on the state axis alone — the unit's filled `Decision:` field never comes into play.
- No `plot/drafts/attempt01/draft-v03.md` is written.
- No completion is recorded: the `compliance_fix` line stays `[ ]` and `pipeline-state.md` is untouched (`last_updated` unchanged).

### Recipe 4 — non-dependent step runs out of recipe order

Reset the fixture, repeat Setup, and hand-author the same three files as Recipe 3, with one difference: stamp the report against the current latest draft, so the first line of `plot/drafts/attempt01/reviewer-actions.md` reads:

```markdown
Reviewed-draft: draft-v02.md
```

The quoted prose anchor in the review unit appears verbatim in `draft-v02.md`, so the fix step can locate it, and the unit's `Decision:` field carries the filled `FIX` instruction, so nothing is pending. Note that every upstream step in the recipe (`drafting`, `compliance_report`, etc.) is still `[ ]` — the point of this recipe is that recipe position does not gate execution; preconditions do.

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/run-step compliance_fix
```

Expected observable outcome:

- The existence checks pass, and the step-start freshness check passes: the stamp names `draft-v02.md`, which is the current `<latest-draft>`.
- The shared validator run that follows reports `proceed` (exit 0) before any entry is acted on: one decided unit — `compliance:001:block-001-v01`, its `Decision: FIX: …` filled and legal — zero pending, zero invalid. (No `draft-manifest.md` exists yet, so the validator's state layer is `not checked`; freshness was already confirmed at step start.)
- The step applies the unit's `FIX` decision, following the instruction carried in its `Decision:` payload, and writes the full revised prose to `plot/drafts/attempt01/draft-v03.md` (the first sentence now opens "The lamp guttered out on its own…"; the untouched paragraph is copied through verbatim).
- An `Applied:` block naming the unit's review-id is appended to `reviewer-actions.md`, and a `## draft-v03.md` entry is appended to `plot/drafts/attempt01/draft-manifest.md` (created here, since the hand-authored fixture has none), with the step's completion action pointing `Active-head: draft-v03.md` at the draft it just wrote.
- The step's final action flips `[ ] compliance_fix` to `[x] compliance_fix` and updates `last_updated` — out of recipe order, while every upstream line stays `[ ]`.

### Recipe 5 — branch a rerun from an earlier draft

Reset the fixture and repeat Setup. Then hand-author the following five untracked files under `plot/drafts/attempt01/`: a linear `v01→v02→v03` draft chain, a `draft-manifest.md` recording that chain with its top-of-file `Active-head: draft-vNN.md` pointer set to the tip, and a compliance report stamped against the *earliest* draft. The mechanism under test is M8's branch surface: `run-step`'s read-from argument overrides which draft `<latest-draft>` resolves to for one invocation, and the prose-advancing step repoints the head and supersedes the displaced drafts on completion.

`plot/drafts/attempt01/draft-v01.md` and `plot/drafts/attempt01/draft-v02.md` — identical to Recipe 3's two drafts.

`plot/drafts/attempt01/draft-v03.md`:

```markdown
The lamp went dark and Rao climbed the stair without a light.

He told no one what he found at the top, and by morning he had talked himself out of telling anyone at all. The replacement keeper arrived at noon and asked no questions.
```

`plot/drafts/attempt01/draft-manifest.md` — hand-authored per the schema in `agents/project-layouts.md`, with the pointer at the tip of the linear chain:

```markdown
Active-head: draft-v03.md

## draft-v01.md
- produced_by: drafting
- read_from: []
- timestamp: 2026-07-01T09:00:00-06:00
- review_gate: true

## draft-v02.md
- produced_by: compliance_fix
- read_from: [draft-v01.md]
- timestamp: 2026-07-01T10:30:00-06:00
- review_gate: false
- side_artifacts: [reviewer-actions.md]

## draft-v03.md
- produced_by: prose_fix
- read_from: [draft-v02.md]
- timestamp: 2026-07-01T12:00:00-06:00
- review_gate: false
```

`plot/drafts/attempt01/reviewer-actions.md` — Recipe 3's report verbatim, including its stamp: the first line reads `Reviewed-draft: draft-v01.md` and the single anchored review unit (`compliance:001:block-001-v01`) carries its filled `Decision: FIX: …` field, its quoted prose found in `draft-v01.md`.

Then:

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/run-step compliance_fix from draft-v01
```

Expected observable outcome:

- The dispatcher parses the read-from argument, confirms `compliance_fix` declares a `prose_draft` precondition and that `draft-v01.md` exists in `plot/drafts/attempt01/`, and substitutes it for `<latest-draft>` for this invocation only.
- The step-start freshness check passes: the report's `Reviewed-draft: draft-v01.md` stamp equals the draft the step reads — `draft-v01.md`, the override. (Without the read-from argument this run would be Recipe 3's stale-report block, since the stamp names `draft-v01.md` while the active head is `draft-v03.md`; the override is what makes the report fresh.)
- The shared validator run passes `draft-v01.md` — the read-from draft this run reads — as its fourth argument, the effective draft, alongside the hand-authored manifest. Its state layer reports fresh against the effective draft (`Reviewed-draft: draft-v01.md` equals it), noting the manifest's `Active-head: draft-v03.md` as overridden by read-from rather than treating it as stale; one decided unit, zero pending, zero invalid — verdict proceed, exit 0. (Without the read-from argument the same run would report stale, exit 5 — Recipe 3's block.)
- The step applies the unit's `FIX` decision and writes the full revised prose to `plot/drafts/attempt01/draft-v04.md` — highest existing draft number + 1, **not** `draft-v02.md`: `<next-draft>` is monotonic, so a branch output never collides with or renumbers an existing file.
- A `## draft-v04.md` entry is appended to `draft-manifest.md` with `read_from: [draft-v01.md]`, a write-time `timestamp`, and `review_gate: false`; an `Applied:` block naming the unit's review-id is appended to `reviewer-actions.md`.
- The manifest's pointer is repointed to `Active-head: draft-v04.md`.
- `draft-v02.md` and `draft-v03.md` — the displaced branch — are each stamped `superseded_by: draft-v04.md` in their manifest entries. `draft-v01.md` gets no stamp: it is an ancestor of the new head, not a displaced draft. Both superseded files remain on disk, unrenamed and unmodified as prose.
- The step's final action flips `[ ] compliance_fix` to `[x] compliance_fix` and updates `last_updated`, while every upstream line stays `[ ]`.

Follow-on check — reader steps follow the pointer: a subsequent `/run-step compliance_report` (no override) now reads `draft-v04.md` — the active head — not `draft-v03.md`, and stamps its report `Reviewed-draft: draft-v04.md`.

### M9.7 recipes — artifact state

The next three recipes exercise the general Artifact-state model — freshness, review, and override — from `agents/orchestrator.md`'s **Artifact state** section, using the `anti_ai_report → anti_ai_fix` pair. This pair is chosen because `anti_ai_report`'s only `required: true` precondition is `<latest-draft>`: it needs no storyboards and no voice file, so it runs in the bare smoke fixture, and `anti_ai_fix` reads only `anti-ai.md` plus `<latest-draft>`. As in Recipes 3–5, no `draft-manifest.md` is hand-authored, so `<latest-draft>` falls back to the highest-numbered `draft-vNN.md`; keeping `draft-v01.md` and `draft-v02.md` on disk makes `draft-v02.md` the active head. The hand-authored `anti-ai.md` fixtures use the structured M11 format — anchored review units with `Decision:` / `Decision-note:` fields, no eligibility block, no `BULK:` header, no summary tally (shape per `agents/steps/anti-ai-report.md`; `examples/review/anti-ai.md` is the reference fixture) — and because `anti_ai_fix` runs the shared validator after its freshness check, exactly as `compliance_fix` does in Recipes 9–10, the expected outcomes name the validator's verdicts and ledger counts.

**Stale-report detection** is the `stale` case of this contract and is already covered — Recipe 3 shows `compliance_fix` blocking on a report stamped `draft-v01.md` while the active head is `draft-v02.md`. The identical stale block governs the `anti_ai_report → anti_ai_fix` pair; Recipe 8 exercises it directly (and then lifts it with a recorded override), so it is not duplicated here.

### Recipe 6 — pending report blocks the fix step (`review_pending`)

Reset the fixture and repeat Setup. Then hand-author the following three untracked files under `plot/drafts/attempt01/`. As in Recipe 3, no `draft-manifest.md` is present, so `<latest-draft>` resolves to `draft-v02.md` — the highest-numbered draft, and thus the active head.

`plot/drafts/attempt01/draft-v01.md`:

```markdown
The lamp went dark and Rao climbed the stair without a light.

He told no one — not even the keeper who came at dawn.
```

`plot/drafts/attempt01/draft-v02.md` — the active head; its em-dash paragraph is verbatim identical to `draft-v01.md`'s and the draft differs only by a trailing paragraph, so a report stamped against `draft-v01.md` is stale yet its quoted anchor is still locatable here (used by Recipes 7–8):

```markdown
The lamp went dark and Rao climbed the stair without a light.

He told no one — not even the keeper who came at dawn.

By morning he had talked himself out of telling anyone at all.
```

`plot/drafts/attempt01/anti-ai.md` — an anti-AI report stamped against the current active head (`draft-v02.md`, so it is *fresh*), carrying one anchored em-dash review unit whose `Decision:` field is blank, exactly as `anti_ai_report` emits it (shape per `agents/steps/anti-ai-report.md`; a blank `Decision:` is the pending-review signal — the decision belongs to the human):

```markdown
Reviewed-draft: draft-v02.md

## Anti-AI Report — Scene 001

### Em Dashes

<!-- review-id: anti_ai:001:em-dashes-01 -->
- "He told no one — not even the keeper who came at dawn."
  - Decision:
  - Decision-note:
```

Then:

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/run-step anti_ai_fix
```

Expected observable outcome — a clean blocked exit, not a dispatcher error:

- The dispatcher's existence checks pass: both `required: true` preconditions resolve — `anti-ai.md` exists and `<latest-draft>` resolves to `draft-v02.md` — so the step body loads.
- The step-start freshness check passes (the stamp names `draft-v02.md`, the active head), so staleness is not the blocker.
- The step then runs the shared validator over the report, which reports `pending-remain` (exit 4): total 1, pending 1, everything else 0 — the single unit carries a blank `Decision:` and therefore no review evidence. Because pending is nonzero, the validator also prints a `pending-review-ids:` section naming `anti_ai:001:em-dashes-01`. The per-unit review-evidence gate is what fails: the report is `review_pending`. (No `draft-manifest.md` exists, so the validator's state layer is `not checked`; freshness was already confirmed at step start.)
- The step appends the `review_pending` blocker to `open-questions.md`, copying the validator's `pending-review-ids:` list — here the single id `anti_ai:001:em-dashes-01`.
- No `plot/drafts/attempt01/draft-v03.md` is written, and no `draft-manifest.md` is created.
- No completion is recorded: the `anti_ai_fix` line stays `[ ]` and `pipeline-state.md` is untouched (`last_updated` unchanged).

A `review_pending` block is **not** liftable by an override — an override authorizes consuming an artifact despite a *state* problem (staleness), but a pending unit carries no editorial intent to apply. The human resolves this by recording a decision in the unit's `Decision:` field — by hand-edit, as in Recipe 9, or through the `amanuensis-review` companion, as in Recipes 10–11 — after which the unit is no longer pending; Recipe 8's override path is available only for the `stale` case.

### Recipe 7 — regenerate a stale report against the active head, then fix clean

Reset the fixture and repeat Setup. Hand-author the same `draft-v01.md` and `draft-v02.md` as Recipe 6, and the same `anti-ai.md` with two differences: stamp it against the **superseded** `draft-v01.md`, and fill the unit's `Decision:` field so the earlier review evidence is present. The first line reads:

```markdown
Reviewed-draft: draft-v01.md
```

and the em-dash unit carries the filled decision:

```markdown
### Em Dashes

<!-- review-id: anti_ai:001:em-dashes-01 -->
- "He told no one — not even the keeper who came at dawn."
  - Decision: FIX: split
  - Decision-note:
```

This is a report decided against `draft-v01.md` before a prose-advancing step produced `draft-v02.md`, which left it stale. The mechanism under test is the `regenerated`/`discarded` recovery path: rerunning the report-emitting step against the newer active head overwrites its side artifact with a fresh stamp and discards the prior findings.

First rerun the report step against the active head:

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/run-step anti_ai_report
```

Expected observable outcome (regeneration):

- The existence check passes (`<latest-draft>` resolves to `draft-v02.md`). The step body reads the existing `anti-ai.md` stamp (`draft-v01.md`), finds it does not equal the active head (`draft-v02.md`), and takes the regeneration path: it **overwrites** the whole file with a fresh top-of-file `Reviewed-draft: draft-v02.md` stamp and a freshly scanned report against `draft-v02.md`. The prior run's `draft-v01.md` findings — the anchored unit and its filled `Decision: FIX: split` — are `discarded`: a regeneration starts a new `Reviewed-draft:` epoch, so the re-minted unit carries no prior decision.
- The regenerated report flags the same em dash, now anchored in `draft-v02.md`, as a structured unit with blank `Decision:` / `Decision-note:` fields — a fresh scan carries no decisions. (Were `anti_ai_fix` run now, the validator would report `pending-remain`, exit 4, exactly as in Recipe 6.)
- No new draft is minted (`anti_ai_report` does not advance the draft) and no `draft-manifest.md` is created.
- The step's final action flips `[ ] anti_ai_report` to `[x] anti_ai_report` and updates `last_updated`; every other line stays `[ ]`.

Then record the decision on the regenerated report — fill its unit's `Decision:` field with `FIX: split` again, the review a human performs before the fix runs — and run the fix step:

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/run-step anti_ai_fix
```

Expected observable outcome (clean fix):

- The step-start freshness check passes: the regenerated stamp (`draft-v02.md`) equals the active head, so `anti-ai.md` is `fresh`.
- The shared validator run that follows reports `proceed` (exit 0): total 1, decided 1, pending 0, invalid 0 — the unit's `Decision: FIX: split` is filled and legal. Only on that verdict does the step act on any entry. (No `draft-manifest.md` exists, so the validator's state layer is `not checked`; freshness was already confirmed at step start.)
- The step locates the flagged sentence in `draft-v02.md`, applies the period split, and writes the full revised prose to `plot/drafts/attempt01/draft-v03.md` (the em-dash line becomes "He told no one. Not even the keeper who came at dawn."; every other paragraph is copied through verbatim).
- An `#### Applied:` block naming the unit's review-id is appended to `anti-ai.md`, and a `## draft-v03.md` entry is appended to `plot/drafts/attempt01/draft-manifest.md` (created here, since the fixture has none) with `read_from: [draft-v02.md]`, `review_gate: false`, and `side_artifacts: [anti-ai.md]`; the completion action points `Active-head: draft-v03.md` at the draft just written.
- The step's final action flips `[ ] anti_ai_fix` to `[x] anti_ai_fix` and updates `last_updated`, while every upstream line stays `[ ]`.

### Recipe 8 — recorded override lets a stale apply proceed

Reset the fixture and repeat Setup. Hand-author the same `draft-v01.md` and `draft-v02.md` as Recipe 6, and the same decided `anti-ai.md` as Recipe 7's starting report (stamped `Reviewed-draft: draft-v01.md`, its em-dash unit carrying the filled `Decision: FIX: split`) — so that with the decision recorded, staleness is the only blocker. Then add a human-recorded `Override:` block immediately below the stamp, so the top of `anti-ai.md` reads:

```markdown
Reviewed-draft: draft-v01.md

Override: proceed despite stale — anti-ai.md stamped draft-v01.md, current <latest-draft> is draft-v02.md. Authorized by human.
```

The flagged sentence appears verbatim in the active head `draft-v02.md`, so the fixer can locate the anchor even though the report is stamped against `draft-v01.md`. The mechanism under test is the override surface of the Artifact-state contract: a human-recorded `Override:` block is the only path by which the fix step consumes a `stale` input, and it is never silent — the step echoes the override into its apply log.

Then:

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/run-step anti_ai_fix
```

Expected observable outcome — the fix step proceeds under the override and completes:

- The existence checks pass. At step start the freshness check computes `stale` (the stamp names `draft-v01.md`; the active head is `draft-v02.md`), but the step finds the matching `Override:` block naming `anti-ai.md` and the `draft-v01.md` → `draft-v02.md` mismatch, so instead of blocking it proceeds with the apply.
- The shared validator run that follows reports `proceed` (exit 0): total 1, decided 1, pending 0, invalid 0 — nothing is pending or invalid, which the override could not have lifted anyway: a recorded override lifts the validator's exit-5 `stale` verdict only, never exit 4 (`review_pending`) or exit 3 (invalid input). (As in Recipes 9–10, no `draft-manifest.md` is hand-authored, so the validator's state layer is `not checked`; the staleness was computed — and overridden — at step start, where the stamp was compared against the fallback active head `draft-v02.md`.)
- The step applies the unit's `FIX: split` decision against `draft-v02.md` and writes the full revised prose to `plot/drafts/attempt01/draft-v03.md` (the em-dash line becomes "He told no one. Not even the keeper who came at dawn."; every other paragraph is copied through verbatim).
- The step records the override in its apply log — appended to `anti-ai.md` alongside the `Applied:` blocks, **not** the end-of-draft tally block comment:

  ```markdown
  #### Override applied: anti-ai.md
  - Condition overridden: stale — report stamped draft-v01.md, applied against draft-v02.md
  - Authorized by: human-recorded Override block
  ```

  The record names the artifact (`anti-ai.md`) and the draft mismatch (`draft-v01.md` → `draft-v02.md`). An `#### Applied:` block for the em-dash fix is appended as well.
- A `## draft-v03.md` entry is appended to `plot/drafts/attempt01/draft-manifest.md` (created here, since the fixture has none) with `read_from: [draft-v02.md]`, `review_gate: false`, and `side_artifacts: [anti-ai.md]`; the completion action points `Active-head: draft-v03.md` at the draft just written.
- The step's final action flips `[ ] anti_ai_fix` to `[x] anti_ai_fix` and updates `last_updated`, while every upstream line stays `[ ]`.

### M10.7 recipes — structured compliance review

The next two recipes exercise the structured review contract (M10) on the `compliance_report → compliance_fix` pair: the per-unit review-evidence gate — a blank `Decision:` field blocking the fix step as `review_pending` — and the two decision-capture paths that lift it, hand-editing the field (Recipe 9) and the `amanuensis-review` companion skill (Recipe 10). Both the fix step and the companion run the shared validator (`amanuensis/scripts/validate-review-artifact.sh` against `amanuensis/agents/review-grammars.yaml`, interpreted per `agents/review-validation.md`), so the expected outcomes name its verdicts and ledger counts. As in Recipes 3–4, no `draft-manifest.md` is hand-authored, so `<latest-draft>` falls back to the highest-numbered `draft-vNN.md`; keeping `draft-v01.md` and `draft-v02.md` on disk makes `draft-v02.md` the active head.

### Recipe 9 — blank `Decision:` blocks the fix step; filling it runs clean

Reset the fixture and repeat Setup. Hand-author the same `draft-v01.md` and `draft-v02.md` as Recipe 3, plus `plot/drafts/attempt01/reviewer-actions.md` — Recipe 3's report with two differences: stamp it against the active head (`draft-v02.md`, so it is *fresh*) and leave its `Decision:` field blank, exactly as `compliance_report` emits it (a blank `Decision:` is the pending-review signal; the decision belongs to the human):

```markdown
Reviewed-draft: draft-v02.md

## Compliance Report — Scene 001, 2026-07-02

### Block 001
<!-- review-id: compliance:001:block-001-v01 -->
- DEGRADED (must_preserve): Lamp failure cause — the block requires the lamp to fail on its own; the prose leaves the cause unstated. Prose: "The lamp went dark and Rao climbed the stair without a light."
  - Decision:
  - Decision-note:
```

Then:

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/run-step compliance_fix
```

Expected observable outcome — a clean blocked exit, not a dispatcher error:

- The dispatcher's existence checks pass and the step-start freshness check passes (the stamp names `draft-v02.md`, the active head), so staleness is not the blocker.
- The step then runs the shared validator over the report, which reports `pending-remain` (exit 4): total 1, pending 1, everything else 0 — the single unit carries a blank `Decision:` and therefore no review evidence, and the validator prints a `pending-review-ids:` section naming `compliance:001:block-001-v01`. The per-unit review-evidence gate is what fails: the report is `review_pending`.
- The step appends the `review_pending` blocker to `open-questions.md`, copying the validator's `pending-review-ids:` list — here the single id `compliance:001:block-001-v01`.
- No `plot/drafts/attempt01/draft-v03.md` is written and no `draft-manifest.md` is created.
- No completion is recorded: the `compliance_fix` line stays `[ ]` and `pipeline-state.md` is untouched (`last_updated` unchanged).

As in Recipe 6, a `review_pending` block is not liftable by an override — the human resolves it by recording a decision. Fill the unit's `Decision:` field so its line reads:

```markdown
  - Decision: FIX: change "The lamp went dark" to "The lamp guttered out on its own"
```

and rerun the fix step:

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/run-step compliance_fix
```

Expected observable outcome (clean fix):

- The freshness check passes again, and the validator now reports `proceed` (exit 0): total 1, decided 1, pending 0, invalid 0. Only on that verdict does the step act on any entry.
- The step applies the unit's `FIX` decision, following the instruction carried in its `Decision:` payload, and writes the full revised prose to `plot/drafts/attempt01/draft-v03.md` (the first sentence now opens "The lamp guttered out on its own…"; the untouched paragraph is copied through verbatim).
- An `Applied:` block naming the unit's review-id is appended to `reviewer-actions.md`, and a `## draft-v03.md` entry is appended to `plot/drafts/attempt01/draft-manifest.md` (created here, since the hand-authored fixture has none), with the step's completion action pointing `Active-head: draft-v03.md` at the draft it just wrote.
- The step's final action flips `[ ] compliance_fix` to `[x] compliance_fix` and updates `last_updated`, while every upstream line stays `[ ]`.

### Recipe 10 — companion session records the decision by review-id

Reset the fixture, repeat Setup, and hand-author the same three files as Recipe 9's first run (fresh stamp, blank `Decision:`). Setup's `install.sh` run installs the `amanuensis-review` companion skill at `.claude/skills/amanuensis-review/SKILL.md` alongside the dispatcher files (gitignored with the rest of `.claude/`), so the skill is available in any Claude Code session in this directory. The companion is not a pipeline step: it is invoked conversationally, not through `/run-step`, and it captures decisions — it never fixes prose, never touches `pipeline-state.md`, and never records a completion.

```
# In a new Claude Code session, with cwd = examples/smoke, activate the
# skill conversationally — e.g. open with:
Review the compliance report.
```

Expected observable outcome:

- The skill activates, identifies `plot/drafts/attempt01/reviewer-actions.md` as a compliance artifact (an `adopted` family), and runs the shared validator before presenting anything. It reports the ledger — total 1, pending 1, everything else 0 — and queues the single pending unit named in the validator's `pending-review-ids:` list. (No `draft-manifest.md` exists, so the validator's state layer is `not checked`; the stamp names the fallback active head `draft-v02.md`, so nothing stale is surfaced.)
- It presents unit `compliance:001:block-001-v01`, explains the legal decisions for the compliance family (per `agents/review-grammars.yaml`), and may recommend one without applying it. The human states the decision — e.g. "fix it: change 'The lamp went dark' to 'The lamp guttered out on its own'".
- The skill writes the decision into the unit's `Decision:` field, located by review-id — the line now reads exactly as Recipe 9's hand-edit — preserving all surrounding markdown, then re-validates: decided 1, pending 0, verdict `proceed` (exit 0).
- Nothing else changes: no prose file is written or modified, no draft is minted, and `pipeline-state.md`, the `Reviewed-draft:` stamp, and every checkbox are untouched.
- Follow-on check: `/run-step compliance_fix` in a fresh session now runs clean, exactly as Recipe 9's second invocation.

### M11.5 recipes — anti-AI fan-out and the retired bulk grammar

The final two recipes exercise the M11 structured anti-AI contract beyond Recipes 6–8: companion fan-out — one stated human decision adjudicating every pending unit of an eligible category, per the `anti_ai` family's `fanout_categories` / `fanout_rules` declaration in `agents/review-grammars.yaml` — and the validator's rejection of the retired `BULK:` header grammar. As in Recipes 6–8, no `draft-manifest.md` is hand-authored (keeping `draft-v01.md` and `draft-v02.md` on disk makes `draft-v02.md` the active head), and the expected outcomes name the shared validator's verdicts and ledger counts.

### Recipe 11 — fan-out adjudicates a category; a per-entry exception is honored

Reset the fixture and repeat Setup. Hand-author the same `draft-v01.md` as Recipe 6, plus the following `draft-v02.md` — the active head, carrying three em dashes and one two-beat negative parallelism:

```markdown
The lamp went dark and Rao climbed the stair without a light.

He told no one — not even the keeper who came at dawn.

By morning he had talked himself out of telling anyone at all — the habit of silence was older than the lamp.

He wound the clock anyway — the ritual had outlived its reasons.

It wasn't the dark that troubled him. It was the quiet.
```

and `plot/drafts/attempt01/anti-ai.md` — a fresh structured report against it (stamped `draft-v02.md`), with three pending units in `### Em Dashes` (a `fanout_categories` category) and one pending unit in `### Negative Parallelism` (a category the declaration does not name), every decision field blank:

```markdown
Reviewed-draft: draft-v02.md

## Anti-AI Report — Scene 001

### Em Dashes

<!-- review-id: anti_ai:001:em-dashes-01 -->
- "He told no one — not even the keeper who came at dawn."
  - Decision:
  - Decision-note:
<!-- review-id: anti_ai:001:em-dashes-02 -->
- "By morning he had talked himself out of telling anyone at all — the habit of silence was older than the lamp."
  - Decision:
  - Decision-note:
<!-- review-id: anti_ai:001:em-dashes-03 -->
- "He wound the clock anyway — the ritual had outlived its reasons."
  - Decision:
  - Decision-note:

### Negative Parallelism

<!-- review-id: anti_ai:001:negative-parallelism-01 -->
- two-beat: "It wasn't the dark that troubled him. It was the quiet."
  - Decision:
  - Decision-note:
```

First run the fix step:

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/run-step anti_ai_fix
```

Expected observable outcome — a clean blocked exit, not a dispatcher error:

- The existence checks pass and the step-start freshness check passes (the stamp names `draft-v02.md`, the active head).
- The shared validator reports `pending-remain` (exit 4): total 4, pending 4, everything else 0 — every unit's `Decision:` is blank — and its `pending-review-ids:` section lists all four (`anti_ai:001:em-dashes-01` through `-03` and `anti_ai:001:negative-parallelism-01`).
- The step appends the `review_pending` blocker to `open-questions.md`, copying that `pending-review-ids:` list — all four ids.
- No draft is written, no `draft-manifest.md` is created, and no completion is recorded.

Then run a companion session (Recipe 10's precedent — invoked conversationally, not through `/run-step`):

```
# In a new Claude Code session, with cwd = examples/smoke, activate the
# skill conversationally — e.g. open with:
Review the anti-AI report.
```

Expected observable outcome:

- The skill activates, identifies `plot/drafts/attempt01/anti-ai.md` as an anti_ai artifact (an `adopted` family), and runs the shared validator before presenting anything. It reports the ledger — total 4, pending 4 — and, from the validator's `pending-review-ids:` list, presents the pending units as category queues within the scene: Em Dashes (3 pending), Negative Parallelism (1 pending).
- On the Em Dashes queue it may offer a category-level decision — em-dashes is named in the family's `fanout_categories` declaration — surfacing the grammar's recommended default (`FIX: rewrite`) without applying it. It never offers fan-out on Negative Parallelism, which the declaration does not name.
- The human states the category decision plus one per-entry exception — e.g. "fix all em dashes — rewrite; but skip the clock one, the aside reads right there". The skill writes `Decision: SKIP` into `anti_ai:001:em-dashes-03` with a per-entry `Decision-note:` (e.g. `per-entry exception to the category decision; the aside reads right here`) and fans the stated decision into the two still-pending em-dash units — each `Decision:` reading `FIX: rewrite`, each `Decision-note:` marked as a category decision (e.g. `category decision — fix all em dashes, rewrite around them`). A fan-out is one human decision mechanically applied; the skill writes nothing the human did not state.
- Re-validation after the write batch: total 4, pending 1, decided 2, skipped 1 — verdict `pending-remain` (exit 4). Only the non-eligible `anti_ai:001:negative-parallelism-01` is still pending; the human decides it per entry. Negative Parallelism has no bare-`FIX` rule, so on a bare "fix it" the skill says so and asks for the instruction — e.g. `FIX: collapse the two beats into "The quiet troubled him more than the dark."` The skill writes it and re-validates: total 4, pending 0, decided 3, skipped 1 — verdict `proceed` (exit 0).
- Nothing else changes: no prose file is written or modified, no draft is minted, and `pipeline-state.md`, the `Reviewed-draft:` stamp, and every checkbox are untouched.

Then rerun the fix step:

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/run-step anti_ai_fix
```

Expected observable outcome (clean fix):

- The freshness check passes again, and the validator now reports `proceed` (exit 0): total 4, decided 3, skipped 1, pending 0, invalid 0. Only on that verdict does the step act on any entry.
- The step applies the two `FIX: rewrite` decisions — restructuring each flagged sentence to remove its em dash — and the negative-parallelism instruction, and honors the `SKIP`: `anti_ai:001:em-dashes-03`'s sentence is copied through untouched, em dash intact, with no block appended for it. The full revised prose goes to `plot/drafts/attempt01/draft-v03.md`; the unflagged paragraphs are copied through verbatim.
- `#### Applied:` blocks naming the actioned review-ids (`anti_ai:001:em-dashes-01`, `-02`, `anti_ai:001:negative-parallelism-01`) are appended to `anti-ai.md`, and a `## draft-v03.md` entry is appended to `plot/drafts/attempt01/draft-manifest.md` (created here, since the fixture has none) with `read_from: [draft-v02.md]`, `review_gate: false`, and `side_artifacts: [anti-ai.md]`; the completion action points `Active-head: draft-v03.md` at the draft just written.
- The step's final action flips `[ ] anti_ai_fix` to `[x] anti_ai_fix` and updates `last_updated`, while every upstream line stays `[ ]`.

### Recipe 12 — stray legacy `BULK:` header blocks as invalid input

Reset the fixture and repeat Setup. Hand-author the same `draft-v01.md` and `draft-v02.md` as Recipe 6, and Recipe 6's fresh `anti-ai.md` with one addition: a legacy `BULK: FIX` header at the head of the category subsection — the pre-M11 bulk grammar, retired in Sprint 16, that a hand-migrated report might still carry:

```markdown
Reviewed-draft: draft-v02.md

## Anti-AI Report — Scene 001

### Em Dashes

BULK: FIX
<!-- review-id: anti_ai:001:em-dashes-01 -->
- "He told no one — not even the keeper who came at dawn."
  - Decision:
  - Decision-note:
```

Then:

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/run-step anti_ai_fix
```

Expected observable outcome — a clean blocked exit, not a dispatcher error:

- The existence checks pass and the step-start freshness check passes (the stamp names `draft-v02.md`, the active head).
- The shared validator reports `invalid-present` (exit 3), its findings naming the header line: ``bulk header illegal: family `anti_ai` has no bulk support``. The ledger counts the defect: total 2, pending 1, invalid 1 — and `inherited-by-bulk` stays 0: the blank unit under the header stays pending, never inherited, because the artifact carries no bulk grammar of any kind. Because pending is nonzero the validator still lists that one unit under `pending-review-ids:`, but invalid takes precedence over pending — the pending count is not trustworthy until the defect is fixed.
- The step blocks as invalid input, appending the blocker to `open-questions.md` and naming the validator's finding.
- No draft is written, no `draft-manifest.md` is created, and no completion is recorded.

The resolution is fixing the artifact, **not** waiving it: delete the `BULK: FIX` line, then decide the unit per entry — by hand-edit or companion; for an eligible category, a companion fan-out (Recipe 11) is the category-level path. An override does not apply: a recorded override lifts the validator's exit-5 `stale` verdict only, never exit 3 (invalid input) or exit 4 (`review_pending`).

### Recipes 3–12 touch only untracked files

The hand-authored `plot/drafts/attempt01/` tree — the drafts, the stamped report (`reviewer-actions.md` for Recipes 3–5 and 9–10, `anti-ai.md` for Recipes 6–8 and 11–12), and everything the report and fix steps write into it — lives entirely in untracked paths. Nothing new is committed under `examples/smoke/`, and the existing reset procedure below restores the committed baseline.

## Run — OpenCode

```sh
# In a new OpenCode session, with cwd = examples/smoke:
# Invoke the run-step or next-step agent — e.g. via OpenCode's primary-agent
# dispatch (`/agent next-step` or the host's equivalent for selecting a
# primary agent). For run-step, the step_id goes in the invoking message.
```

The same recipes hold, with the `next-step` agent standing in for `/next-step` (Recipe 1) and the `run-step` agent standing in for `/run-step <step_id>` (Recipes 2–9, 11, and 12); for Recipe 5, the read-from draft goes in the invoking message alongside the step_id (`compliance_fix from draft-v01`). The expected observable outcomes are identical to the Claude Code lists above. The OpenCode dispatcher sources are held to behavioral parity with the Claude Code ones; only host-specific frontmatter and invocation differ. Recipe 10 and Recipe 11's fan-out companion session are Claude Code-only: the companion ships as a Claude Code skill (OpenCode parity is on the ROADMAP's deferred list), so on OpenCode cover their decision-writing by hand-editing the `Decision:` / `Decision-note:` fields instead — Recipe 9's hand-edit is the model; for Recipe 11, hand-write the category decision into each covered em-dash unit's fields (including the category-decision notes) and the per-entry `SKIP` exception, then proceed with the fix runs as written.

## Reset between runs

```sh
git checkout examples/smoke/
git clean -fd examples/smoke/
```

`git checkout` restores `pipeline-state.md`, `open-questions.md`, and any other tracked file the run modified. `git clean -fd` removes the untracked install artifacts (`.claude/`, `.opencode/`), the `amanuensis` symlink, any `characters/` tree written by Recipes 1–2, and the entire hand-authored `plot/drafts/attempt01/` tree from Recipes 3–12 — including anything the report and fix steps wrote into it (`draft-v03.md` or `draft-v04.md`, `draft-manifest.md`, the appended or decision-edited `reviewer-actions.md`, and the regenerated, decision-edited, or appended `anti-ai.md`). After both commands the fixture is back to the committed baseline.

To rerun, repeat the **Setup** section.

## What success looks like

For each recipe: the dispatcher located `pipeline-state.md`, confirmed the step_id appears in the recipe list (selecting the first non-`[x]` step in `/next-step`'s case), resolved the step workflow file under `amanuensis/agents/steps/`, verified every `required: true` precondition resolves to an existing file, and started executing the step body in the same session. From there one of:

- The step body completed, wrote its declared outputs, and as its final action marked its own step line `[x]` and updated `last_updated`. No other checkbox moved.
- The step body decided it could not proceed (a `critical` blocker in Recipe 1's stop-and-ask outcome, the stale-report blocker in Recipe 3, the `review_pending` blockers in Recipes 6 and 9 and Recipe 11's first run, the invalid-input blocker in Recipe 12), appended the blocker to `open-questions.md`, and exited without recording completion — `pipeline-state.md` untouched.

Failure modes — a missing or malformed `pipeline-state.md`, a requested step_id that does not appear in the recipe list, a missing step workflow file, a `required: true` precondition that resolves to no existing file (the dispatcher names the missing files and stops), or `/next-step` finding every step `[x]` (recipe complete) — should print a clear human-readable message and exit without modifying any project file. Surfacing one of those where a recipe does not expect it would mean the fixture is misconfigured or the dispatcher/orchestrator work has a defect; report it.
