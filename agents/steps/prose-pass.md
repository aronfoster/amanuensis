---
step_id: prose_pass
review_required: true
inputs:
  - <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
  - <chapter-folder>/storyboards/*-storyboard.md
  - voice.md
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/prose-pass.md
preconditions:
  - path: <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
    kind: prose_draft
    required: true
    review_sensitive: false
  - path: <chapter-folder>/storyboards/*-storyboard.md
    kind: source
    required: true
    review_sensitive: false
  - path: voice.md
    kind: source
    required: true
    review_sensitive: false
---

See `agents/orchestrator.md` for the step workflow contract.

# Prose Pass

## Purpose

This pass improves prose quality without turning revision into a sentence-by-sentence art tribunal.

It is **not** a copy edit.
It is **not** a full style workshop.
It is **not** a metaphor census.

It does three things:

1. makes scenes more concrete
2. catches broken or distracting figurative language
3. improves rhythm, emphasis, and readability

This pass should be **selective**. It does not try to perfect every line. It identifies the places where prose is actively costing the chapter clarity, force, or pleasure.

This step produces a report only — it does **not** write to the prose. The `KEEP / TIGHTEN / FLATTEN / REWRITE` recommendations it emits are advisory. The annotated report is consumed by `prose_fix`, the paired prose-advancing consumer: once the human fills in each finding's `Annotation:` line, `prose_fix` applies those per-entry annotations and mints `<next-draft>`. `prose_pass` itself does not mint a draft version — it reads `<latest-draft>` and emits an advisory report.

---

## Inputs

- `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` — the latest prose, resolved at step start via the manifest's active head — or via the read-from override the dispatcher passed — per `agents/project-layouts.md`, not by highest-numbered draft. This is the text the pass reviews; the step does not mint a new draft version.
- `<chapter-folder>/storyboards/*-storyboard.md` — the chapter's storyboard blocks, used to judge whether the prose is serving the scene as designed.
- `voice.md` — the project-root voice file (a sibling of `pipeline-state.md`, not the copy inside the `amanuensis/` submodule; overridable by the path named in the consuming project's local AGENTS.md). Used to judge POV and voice consistency. If no voice file can be found, see Open questions handling.

---

## Output

Write a report in markdown to `<chapter-folder>/drafts/<latest-attempt>/prose-pass.md`.

The file begins with a single top-of-file `Reviewed-draft: draft-vNN.md` line naming the resolved `<latest-draft>` this pass reviewed — the draft this run actually read, so when a read-from override is in effect the stamp names that draft. If the file exists and its stamp does not equal `<latest-draft>`, the report is `regenerated`: overwrite the file with a fresh stamp, and the prior pass's recommendations against the superseded draft are `discarded`. `prose_fix` consumes this stamp to detect stale recommendations against a newer draft, per the general freshness contract in `agents/orchestrator.md`'s Artifact-state section (the report→fix freshness invariant is its canonical worked instance); the stamp is load-bearing for that check.

For each issue:
- quote the line or short passage
- identify the problem
- explain why it matters in context
- recommend one of:
  - `KEEP`
  - `TIGHTEN`
  - `FLATTEN`
  - `REWRITE`

Do **not** rewrite the whole chapter.
Do **not** produce line edits for every issue.
Do **not** praise at length.
Do **not** fix spelling, punctuation, or grammar unless they materially affect rhythm or clarity.
Do **not** modify the prose file. The recommendations are applied by `prose_fix`, the paired prose-advancing consumer, once the human annotates them.

End with:
- `Top priorities`
- `Lines worth preserving`
- `Chapter-level diagnosis`

---

## Behavior

### Review stance

You are not here to reward sentences for sounding literary.
You are here to judge whether the prose is helping the scene.

Prefer:
- specificity over vagueness
- precision over ornamental language
- vividness over abstraction
- coherence over cleverness
- rhythm that matches the moment
- imagery that belongs to the POV and scene

Be skeptical of prose that sounds impressive on first read but becomes fuzzy, inflated, or physically incoherent when examined.

---

### What to look for

#### 1. Concrete detail

Flag passages where the prose becomes abstract when the scene needs something visible, audible, tactile, spatial, or bodily specific.

Common problems:
- emotional summary where concrete perception would be stronger
- vague sensory language
- generic bodily signals
- placeholder description
- repeated abstraction words like pressure, tension, feeling, awareness, presence, weight, edge, distance, silence, shape without enough concrete support

Questions:
- What can the reader actually picture here?
- What does the character physically notice?
- Is this moment being described, or merely labeled?

Use `TIGHTEN` when the sentence is close but needs sharper detail.
Use `REWRITE` when the passage is mostly abstraction.
Use `FLATTEN` when the prose is trying to sound meaningful without showing anything.

---

#### 2. Figurative language

Flag figurative language only when it is causing real trouble.

Trouble includes:
- mixed or conflicting implications
- wrong connotations for the scene
- excessive drama for a small moment
- decorative metaphor with no real gain
- image logic that does not survive literal attention
- comparisons that feel imported from nowhere
- too many live metaphors clustered together
- metaphors that sound literary but do not clarify perception

Do **not** assume all metaphors should be reduced.
Do **not** reward metaphors merely for being novel.
Do **not** excuse a bad metaphor because the intended meaning is recoverable.

Questions:
- What exact property is the image borrowing?
- What else does the image smuggle in?
- Do those extra connotations help or hurt?
- Does this image feel native to the POV and chapter?
- Would the sentence be stronger if made literal or simpler?

Use `KEEP` for imagery that is vivid, apt, and tonally right.
Use `TIGHTEN` for imagery that is almost right.
Use `FLATTEN` for imagery that adds decoration but not value.
Use `REWRITE` for imagery that is broken, misleading, or tonally damaging.

---

#### 3. Rhythm and sentence movement

Flag local prose that is monotonous, clogged, shapeless, or mismatched to scene energy.

Common problems:
- too many sentences of similar length and cadence
- clauses stacked without clear emphasis
- overuse of hedging or throat-clearing
- overwritten transitions
- every sentence carrying the same weight
- high-tension moments slowed by decorative phrasing
- reflective moments written too flatly or abruptly

Questions:
- Does the sentence move the way the moment moves?
- Where does the stress naturally fall?
- Is the prose making the reader work for the wrong reasons?
- Is this paragraph all one tempo?

Use `TIGHTEN` for sentences that need compression or cleaner emphasis.
Use `REWRITE` when the rhythm is consistently fighting the scene.
Use `FLATTEN` when flourish is obscuring motion.

---

#### 4. POV and voice consistency

Flag prose that does not feel like this character, this narrator, or this book.

Common problems:
- imagery from an alien register
- descriptive choices the POV would not plausibly make
- sudden lyrical inflation
- generic "novelist voice" replacing actual voice
- cleverness that breaks character consciousness

Questions:
- Would this mind naturally think or notice this?
- Does this diction belong here?
- Is the line arising from the scene, or from the model trying to impress?

Use `REWRITE` when the voice breaks immersion.
Use `FLATTEN` when the line feels imported or performative.
Use `KEEP` when the prose feels inseparable from the POV.

---

#### 5. Density and clustering

Do not judge lines only in isolation.
Sometimes a fine sentence becomes a problem because of its neighbors.

Flag zones where there is:
- too much figurative pressure in a short span
- too many emphasized lines together
- repeated image families without escalation or variation
- too much "special" prose around routine action
- lyrical stacking that blurs scene function

Questions:
- Are too many sentences asking to be admired at once?
- Has the prose forgotten to breathe?
- Would one strong line survive better if two nearby lines were reduced?

Use `FLATTEN` aggressively here.
A chapter does not need every paragraph to shimmer.

---

### What not to do

- Do not nitpick every sentence.
- Do not require all prose to be plain.
- Do not treat metaphor count as the primary metric.
- Do not confuse familiarity with failure.
- Do not confuse novelty with success.
- Do not recommend cuts merely because a passage is lyrical.
- Do not reward "writerly" sound if the underlying sense is weak.
- Do not fix problems that are really plot or scene-design problems unless the prose is worsening them.

---

### Severity guide

#### KEEP
The line is doing its job well. It may be vivid, restrained, lyrical, or plain. Leave it alone.

#### TIGHTEN
The line is basically sound but needs more precision, cleaner rhythm, or less drag.

#### FLATTEN
The prose is trying too hard, drawing attention away from the scene, or adding decorative language without enough payoff. A simpler line would likely work better.

#### REWRITE
The line is actively failing: broken image, wrong tone, generic abstraction, voice break, or rhythm that damages readability.

---

### Output format

#### Top priorities
List the 5 to 10 highest-value prose problems in the chapter.

#### Findings

For each finding, use this template:

##### [short label]
- Quote: "..."
- Problem: ...
- Why it matters: ...
- Action: `KEEP | TIGHTEN | FLATTEN | REWRITE`
- Annotation: `[FIX | FIX: <instruction> | SKIP | ESCALATE]`

Keep explanations brief and concrete.

The `Annotation:` line is the machine-readable per-entry contract between this pass and `prose_fix`. `prose_pass` emits it blank (or with the bracketed token set as a placeholder); the human fills it in on each finding before dispatching `prose_fix`, so that step has an unambiguous per-finding input. The tokens mean:

- `FIX` — apply this finding's recommended `Action` as written.
- `FIX: <instruction>` — apply the fix, but follow the human's inline instruction instead of (or in addition to) the recommendation.
- `SKIP` — leave this line alone; do not touch it.
- `ESCALATE` — the human wants this raised rather than silently applied; `prose_fix` surfaces it instead of editing.

Rules `prose_fix` relies on:

- `KEEP` findings need no annotation and are treated as `SKIP` by `prose_fix`; the `Annotation:` line may be omitted for `KEEP` entries.
- A finding whose `Action:` is anything other than `KEEP` but whose `Annotation:` is missing or holds an unrecognized token is **not actionable** — `prose_fix` treats it as an unannotated blocker rather than guessing intent.
- **No bulk-annotation headers are used.** There is no file-level "annotate all as FIX" shortcut; every actionable finding is annotated individually. This is a deliberate, locked convention: `prose_pass` is selective (5-10 findings), so per-entry annotation is cheap and keeps intent explicit. Do not reintroduce a bulk header.

This Findings section is the single canonical definition of the annotation grammar; `prose_fix` points here rather than restating the token set. The top-of-file `Reviewed-draft: draft-vNN.md` stamp is what lets `prose_fix` detect stale annotations — annotations written against a superseded draft — per the general freshness contract in `agents/orchestrator.md`'s Artifact-state section (whose `### Report→fix freshness invariant` subsection is the canonical worked instance), which is why that stamp is now load-bearing.

---

### Chapter-level diagnosis

Conclude with short sections:

#### What the prose is already doing well
Name genuine strengths.

#### Repeated failure modes
List patterns, not isolated lines.

#### Best revision strategy
Choose one or two:
- sharpen concrete detail
- reduce abstraction
- repair broken imagery
- lower figurative density in crowded passages
- improve sentence variation
- restore POV-specific diction

#### Lines worth preserving
Quote a few lines or moments that feel alive and should guide revision.

---

### Prioritization rules

When in doubt, prioritize:
1. broken imagery
2. generic abstraction in emotionally important moments
3. rhythm problems in action or tension sequences
4. voice breaks
5. decorative excess in crowded passages

Ignore minor imperfections unless they are part of a pattern.

---

### Decision rule

The goal is not "beautiful prose everywhere."
The goal is prose that makes the chapter vivid, coherent, and pleasurable to read.

A plain sentence that lands is better than a fancy sentence that wobbles.
A strong lyrical sentence is worth keeping when it truly belongs.
Be selective, concrete, and unsentimental.

---

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/prose-pass.md` — the advisory report described above. Begins with a `Reviewed-draft: draft-vNN.md` line naming the `<latest-draft>` this pass reviewed (against a newer draft the report is `regenerated` — the file is overwritten with a fresh stamp and the prior findings `discarded`), then contains `Top priorities`, per-finding entries using the Findings template, a `Chapter-level diagnosis` section (with `What the prose is already doing well`, `Repeated failure modes`, `Best revision strategy`), and `Lines worth preserving`. The step does not modify the prose file; `prose_fix` consumes the annotated report and applies the fixes.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs — including a missing project-root `voice.md` (or the override named in the project's `AGENTS.md`) — append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate inputs and do not write partial outputs. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
