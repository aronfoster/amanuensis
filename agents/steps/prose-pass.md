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

This step produces a report only — it does **not** write to the prose. The `KEEP / TIGHTEN / FLATTEN / REWRITE` recommendations it emits are advisory. The report is the human review artifact consumed by `prose_fix`, the paired prose-advancing consumer: once the human records a decision in each finding's `Decision:` field, `prose_fix` applies those per-entry decisions and mints `<next-draft>`. `prose_pass` itself does not mint a draft version — it reads `<latest-draft>` and emits an advisory report.

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
Do **not** modify the prose file. The recommendations are applied by `prose_fix`, the paired prose-advancing consumer, once the human records decisions on them.

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

Every finding is an anchored review unit — **every finding, `KEEP` included**. Use this template:

<!-- review-id: prose_pass:<location...>:finding-<NN> -->
##### [short label]
- Quote: "..."
- Problem: ...
- Why it matters: ...
- Action: `KEEP | TIGHTEN | FLATTEN | REWRITE`
- Decision:
- Decision-note:

Keep explanations brief and concrete.

**Review unit shape.** The `<!-- review-id: ... -->` anchor sits on its own line immediately above the finding's `##### [short label]` heading. `Quote / Problem / Why it matters / Action` are unchanged. The blank `- Decision:` / `- Decision-note:` fields — top-level `- ` lines, siblings of the other finding fields — come after the `Action:` line, in place of the old positional per-entry line. Emit them blank. **Every finding gets this shape, `KEEP` included**: a `KEEP` finding is a review unit now, not an anchorless note.

The review-id follows the `prose_pass` family segment grammar in `agents/review-grammars.yaml`. The item segment is `finding-<NN>` — the finding's emission ordinal within the report, counted over **every** finding, `KEEP` included. Short_story form `prose_pass:finding-<NN>`; book form `prose_pass:<book-id>:<chapter-id>:finding-<NN>` (chapter-scoped — no scene segment). The location segments are derivable from the artifact's resolved path. Emit `Decision:` / `Decision-note:` blank — they belong to the human, and a blank `Decision:` means the unit is pending review. On the append path, continue each report's `finding-<NN>` ordinals rather than restarting at `01` where a collision would result. The fixture `examples/review/prose-pass.md` shows the exact target shape.

A report that found nothing to comment on records `#### Findings — none` (a single heading, real em dash) plus a single `No findings.` line — no anchor, no fields, not a review unit. This is the container-exempt heading (the analog of compliance's `— CLEAN` and anti-AI's `No flags.`); it is distinct from an all-`KEEP` report, which has anchored `KEEP` units.

The human — companion-assisted, via the `amanuensis-review` skill — records a decision in each finding's `Decision:` field per the `prose_pass` family grammar in `agents/review-grammars.yaml` (the legal tokens, payload rules, and blank-means-pending semantics live there, not here). Every finding is a review unit, `KEEP` included; a `KEEP` finding's decision is typically `SKIP`, confirming the producer's keep. `Decision-note:` is optional free text for the human's why and is never machine-parsed. `prose_fix` then consumes the filled per-unit fields.

There is no bulk and no fan-out in this family: the pass is selective, so every finding is decided individually. `Action:` (`KEEP/TIGHTEN/FLATTEN/REWRITE`) stays the producer's severity recommendation, distinct from the human's `Decision:`.

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

- `<chapter-folder>/drafts/<latest-attempt>/prose-pass.md` — the human review artifact described above. Begins with a single top-of-file `Reviewed-draft: draft-vNN.md` line naming the `<latest-draft>` this pass reviewed — the draft this run actually read (against a newer draft the report is `regenerated`: the file is overwritten with a fresh stamp and the prior findings `discarded`; on the append path each report's `finding-<NN>` ordinals continue so ids never collide within the epoch). Then `#### Top priorities`, then a `#### Findings` section holding either a single `#### Findings — none` heading plus one `No findings.` line (no anchor, no fields, not a review unit) when nothing was found, or per-finding review units — each carrying its `<!-- review-id: ... -->` anchor immediately above its `##### [short label]` heading and blank `- Decision:` / `- Decision-note:` fields — then the `### Chapter-level diagnosis` subsections (`#### What the prose is already doing well`, `#### Repeated failure modes`, `#### Best revision strategy`) and `#### Lines worth preserving`. The file is the human review artifact: the human records decisions in each unit's `Decision:` field per the `prose_pass` family grammar in `agents/review-grammars.yaml` before `prose_fix` runs. The step does not modify the prose file.

## Anti-Patterns

**Filling decision fields.** `Decision:` and `Decision-note:` are emitted blank. They belong to the human; a report that pre-fills a decision — however obvious — has decided instead of reported, and a blank `Decision:` is the only honest signal that a finding is still pending.

**Anchoring a `No findings.` line.** A report that found nothing is `#### Findings — none` plus one `No findings.` line — no anchor, no fields. An anchor turns it into a countable review unit.

**Dropping the anchor on `KEEP` findings.** KEEP findings are review units now, not anchorless notes; every finding carries a `review-id` anchor and blank decision fields, `KEEP` included.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs — including a missing project-root `voice.md` (or the override named in the project's `AGENTS.md`) — append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate inputs and do not write partial outputs. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
