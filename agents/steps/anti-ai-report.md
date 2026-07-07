---
step_id: anti_ai_report
review_required: true
inputs:
  - <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/anti-ai.md
preconditions:
  - path: <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
    kind: prose_draft
    required: true
    review_sensitive: false
---

See `agents/orchestrator.md` for the step workflow contract.

# Anti-AI Report

## Purpose

Hygiene workflow. Identifies patterns that signal AI-generated prose to trained readers. Reports findings; does not fix. Fixing is the separate `anti_ai_fix` step.

This pass is the second-to-last step in the pipeline. It runs against `<latest-draft>` resolved at step start — the latest prose available in the attempt folder, which in the canonical pipeline order will be the line-pass output. It operates on surface and structural signals only — it has no awareness of canon, storyboard requirements, or voice spec. Do not use it to evaluate whether prose is good. Use it to find patterns that will get a reader's guard up. This step does not mint a new draft version.

The report is the human review artifact that gates the fix step. After this step runs, the human (companion-assisted) records a decision in each review unit's `Decision:` field; `anti_ai_fix` then reads the decided report and applies edits to the prose.

## Inputs

- `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` — the latest prose, resolved at step start via the manifest's active head — or via the read-from override the dispatcher passed — per `agents/project-layouts.md`, not by highest-numbered draft. In the canonical pipeline order this will be the line-pass output. This is the only file this step reads. The pass is context-free by design.

## Behavior

Scan the input prose for the nine pattern categories below and the flagged-words list. Report every instance found. Do not evaluate whether a pattern's use seems intentional or defensible — that is a human judgment downstream.

The output file is one report per chapter; append across scenes with a scene header.

The file begins with a single top-of-file `Reviewed-draft:` line naming the resolved `<latest-draft>` this run reviewed — the draft this run actually read, so when a read-from override is in effect the stamp names that draft; the downstream `anti_ai_fix` step reads this stamp to detect stale annotations against a newer draft. If the file does not exist, create it with the stamp. If the file exists and its top-of-file stamp equals `<latest-draft>`, preserve the stamp and append new findings below. If the file exists and its top-of-file stamp does not equal `<latest-draft>` — the recovery path when the human is regenerating after a stale-report blocker — the report is `regenerated`: **overwrite the whole file** with a fresh top-of-file stamp, and the prior run's findings against the superseded draft are `discarded`. See the general freshness contract in `agents/orchestrator.md`'s Artifact-state section (the report→fix freshness invariant is its canonical worked instance). On the append path, new units' review-ids must not collide with any already in the file — same epoch, same uniqueness scope: when a category already has anchored instances from an earlier run against this draft in the same scene, continue that category-and-scene's `<NN>` ordinals rather than restarting at `01` where a collision would result.

```markdown
Reviewed-draft: draft-vNN.md
```

Begin each scene's section with:

```markdown
## Anti-AI Report — Scene <scene-id>
```

A scene with zero flags records its scene header plus a single `No flags.` line — no anchor, no fields, not a review unit. It is the audit record that the scene was scanned:

```markdown
## Anti-AI Report — Scene <scene-id>

No flags.
```

**Review unit shape.** Every flagged instance in every category — the nine pattern categories and Flagged Words — is one review unit and shares one shape: a `<!-- review-id: ... -->` anchor on its own line immediately above the unit's single top-level `- ` entry line, with blank `- Decision:` / `- Decision-note:` fields nested one level below it, placed after any nested auxiliary lines (Synonym Cycling's `- Cycled terms:` is the only auxiliary line):

```markdown
<!-- review-id: anti_ai:<scene-id>:<category-slug>-<NN> -->
- [the entry line as the category's Format specifies]
  - Decision:
  - Decision-note:
```

The review-id follows the `anti_ai` family segment grammar in `agents/review-grammars.yaml`. The item segment is `<category-slug>-<NN>`: the category name lowercased and dash-joined (e.g. `em-dashes`, `superficial-ing-analysis`) plus the instance's emission ordinal within that category and scene. Short_story form: `anti_ai:<scene-id>:<category-slug>-<NN>`; book form adds the book and chapter segments: `anti_ai:<book-id>:<chapter-id>:<scene-id>:<category-slug>-<NN>`. The location segments are derivable from the artifact's resolved path. Emit `Decision:` and `Decision-note:` blank — they belong to the human, and a blank `Decision:` means the unit is pending review. The fixture `examples/review/anti-ai.md` shows the exact target shape.

The per-category `Format:` fences below show each category's entry line inside this shape, with short_story-form ids.

---

### Category 1: Em Dashes

Flag every em dash (`—`).

Em dashes are a strong AI tell and the standing project policy is zero em dashes in prose. Flag all instances without exception. Do not evaluate whether the usage seems intentional.

Format:
```markdown
### Em Dashes
<!-- review-id: anti_ai:<scene-id>:em-dashes-01 -->
- "[quote containing em dash]"
  - Decision:
  - Decision-note:
<!-- review-id: anti_ai:<scene-id>:em-dashes-02 -->
- "[quote containing em dash]"
  - Decision:
  - Decision-note:
```

---

### Category 2: Negative Parallelism

The construction. Two-beat: *It's not just X — it's Y. Not X. Y.* Three-beat: *Not X, not Y, but Z. / Not from X, nor from Y, but from Z.* Also: *Not by doing X, but by doing Y.*

This sentence structure has become strongly associated with AI-generated text and has measurably increased in corporate and published writing since 2023. The three-beat variant has its own signature and should be flagged distinctly from the two-beat. Flag all instances and close variants.

Format:
```markdown
### Negative Parallelism
<!-- review-id: anti_ai:<scene-id>:negative-parallelism-01 -->
- two-beat: "[quote]"
  - Decision:
  - Decision-note:
<!-- review-id: anti_ai:<scene-id>:negative-parallelism-02 -->
- three-beat: "[quote]"
  - Decision:
  - Decision-note:
```

---

### Category 3: Significance Inflation

Words and phrases that artificially elevate the weight of a moment. Common instances:

> tapestry, watershed, profound, resonate / resonates / resonating, nestled, vibrant, rich, nuanced, testament to, stands as, reminder that, serves as a metaphor, speaks to

Flag each instance with its quote.

Format:
```markdown
### Significance Inflation
<!-- review-id: anti_ai:<scene-id>:significance-inflation-01 -->
- "vibrant" — "[quote]"
  - Decision:
  - Decision-note:
<!-- review-id: anti_ai:<scene-id>:significance-inflation-02 -->
- "tapestry" — "[quote]"
  - Decision:
  - Decision-note:
```

---

### Category 4: Copula Avoidance

Constructions that replace the verb "to be" with a fancier copula, usually to sound more dynamic. The result often feels stilted or over-written.

Common instances:

> serves as, acts as, functions as, stands as, operates as, exists as, works as, featuring, boasting, presenting, showcasing

Flag each instance.

Format:
```markdown
### Copula Avoidance
<!-- review-id: anti_ai:<scene-id>:copula-avoidance-01 -->
- "serves as" — "[quote]"
  - Decision:
  - Decision-note:
```

---

### Category 5: Superficial -ing Analysis

Participial phrases that perform interpretive commentary on the action, typically tacked to the end of a sentence.

Common pattern: `[action], [signaling / symbolizing / reflecting / highlighting / underscoring / reinforcing / illustrating / suggesting / revealing] [thematic claim]`

Example: *She turned away, signaling the end of their conversation.*

This pattern is a tell because it does the reader's interpretive work for them. Flag all instances.

Format:
```markdown
### Superficial -ing Analysis
<!-- review-id: anti_ai:<scene-id>:superficial-ing-analysis-01 -->
- "[quote]"
  - Decision:
  - Decision-note:
```

---

### Category 6: Transition Words as Sentence or Paragraph Openers

Flag instances where the following words open a sentence or paragraph:

> Moreover, Furthermore, Additionally, However (as opener), Nevertheless, Consequently, Subsequently, In conclusion, Ultimately, Indeed, Certainly, Notably, Importantly, Interestingly

These are not banned in all positions — flag them only as openers, where they most strongly signal AI-generated structure.

Format:
```markdown
### Transition Openers
<!-- review-id: anti_ai:<scene-id>:transition-openers-01 -->
- "Moreover, ..." — "[full sentence or opening clause]"
  - Decision:
  - Decision-note:
```

---

### Category 7: Synonym Cycling

When the prose rotates through multiple synonyms for the same noun within a short passage to avoid repetition. Common in AI output because models are trained to avoid word repetition.

Example: referring to the same character as "the girl," "the young woman," "the princess," "the child," and the character's proper name within a single paragraph.

Flag the passage and list the synonyms being cycled. Each instance is exactly one top-level `- Passage:` line — the unit's entry line — with `- Cycled terms:` nested beneath it and the decision fields after it.

Format:
```markdown
### Synonym Cycling
<!-- review-id: anti_ai:<scene-id>:synonym-cycling-01 -->
- Passage: "[quote]"
  - Cycled terms: [term1], [term2], [term3]
  - Decision:
  - Decision-note:
```

---

### Category 8: Cadence tics

These are moves language models reach for when asked to write literary prose. They read as signature to the writer and as tells to the reader. The patterns themselves are not noteworthy — they are centuries-old rhetorical devices. What is noteworthy is using them excessively.

Flag the passage and list the examples.

* Triplets: three parallel clauses, phrases, or items in a row. "Down, closed over, gone." One per chapter is a signature. Three is a habit the reader is tracking.
* Paralepsis cascades: definition by negation stacked three or more deep. "Not a sound, not a smell, not anything that belonged to her body." Used once in a scene, it emphasizes. Used four times in a chapter, it crutches.
* Tautological recursion: "the flame closing into a flame," "the precise firmness of a floor." If a chapter needs one, make it one.
* Delayed-subject inversion: "From somewhere behind her: your highness." Useful once, conspicuous twice.

Format:
```markdown
### Cadence tics
<!-- review-id: anti_ai:<scene-id>:cadence-tics-01 -->
- triplet: "[quote]"
  - Decision:
  - Decision-note:
<!-- review-id: anti_ai:<scene-id>:cadence-tics-02 -->
- paralepsis cascade: "[quote]"
  - Decision:
  - Decision-note:
<!-- review-id: anti_ai:<scene-id>:cadence-tics-03 -->
- tautological recursion: "[quote]"
  - Decision:
  - Decision-note:
<!-- review-id: anti_ai:<scene-id>:cadence-tics-04 -->
- delayed-subject inversion: "[quote]"
  - Decision:
  - Decision-note:
```

---

### Category 9: Animacy Projection

Verbs of consciousness, sensation, or volition applied to inanimate subjects — places, buildings, landscapes, weather, objects, abstractions. The pattern is a sympathy-laundering move: rather than describing what the human is feeling, the prose attributes the feeling to the setting itself.

Flag every instance where one of the following verbs is applied to an inanimate subject:

> hum, hums, hummed, humming, thrum, thrums, thrummed, thrumming, breathe, breathes, breathed, breathing, listen, listens, listened, listening, witness, witnesses, witnessed, witnessing, remember, remembers, remembered, remembering, hold (as in "holds its breath"), watch, watches, watched, watching, wait, waits, waited, waiting, know, knows, knew, knowing

The flag is the verb-plus-inanimate-subject pairing. Do not flag these verbs when applied to animate subjects (a person remembering, a dog listening). Do not flag them when the inanimate-subject pairing is conventional dead-metaphor usage that the reader does not register as animation ("the engine hummed," "the clock kept time") — though when in doubt, flag.

Format:
```markdown
### Animacy Projection
<!-- review-id: anti_ai:<scene-id>:animacy-projection-01 -->
- "remembered" / subject: grove — "[quote]"
  - Decision:
  - Decision-note:
<!-- review-id: anti_ai:<scene-id>:animacy-projection-02 -->
- "witnesses" / subject: bastions — "[quote]"
  - Decision:
  - Decision-note:
<!-- review-id: anti_ai:<scene-id>:animacy-projection-03 -->
- "hums" / subject: city — "[quote]"
  - Decision:
  - Decision-note:
```

---

## Specific word list

These words should be flagged whenever they appear, regardless of category:

**High-confidence tells** (single instance is signal):

> delve, delves, delved, showcase, showcases, showcasing, testament, watershed, robust, seamless

**Density-dependent tells** (single instance is noise; clustering is signal):

> nestled, vibrant, tapestry, resonate, resonates, resonating, profound, nuanced, bustling, thriving, realm

> Note on "realm": flag in contemporary fiction; in fantasy or SFF prose this may be functional vocabulary rather than a tell. Reconsider per project.

**Literary-prestige register** (density-dependent; over-represented in AI-generated literary fiction):

> resilience, remembrance, dignity, witness, witnesses, witnessing, haunting, lyrical, quietly, layers, layered, enduring

Flag each with its quote, under a separate section:

```markdown
### Flagged Words
<!-- review-id: anti_ai:<scene-id>:flagged-words-01 -->
- "delve" — "[quote]"
  - Decision:
  - Decision-note:
<!-- review-id: anti_ai:<scene-id>:flagged-words-02 -->
- "tapestry" — "[quote]"
  - Decision:
  - Decision-note:
```

---

## Decisions

After this step runs, the human — companion-assisted, via the `amanuensis-review` skill — records a decision in each unit's `Decision:` field, per the `anti_ai` family grammar in `agents/review-grammars.yaml` (the legal tokens, payload rules, and blank-means-pending semantics live there, not here). `Decision-note:` is optional free text for the human's why and is never machine-parsed. `anti_ai_fix` then consumes the filled per-unit fields.

Category-level review is a companion capture behavior, not an artifact grammar: for the categories named in that file's `fanout_categories` declaration, one stated human decision is fanned out into every pending unit of the category per its `fanout_rules` — each unit's `Decision:` filled, each `Decision-note:` marked as a category decision. The artifact itself carries decisions only in per-unit fields; no header of any kind carries one.

**Em dash specifics** (the most common fix-step decision):

- Default category decision: `FIX: rewrite`. The fixer reads the local sentence and picks split / comma / restructure per instance.
- Per-entry payloads: `Decision: FIX: split` (force period split), `Decision: FIX: comma` (force comma), `Decision: FIX: rewrite` (force restructure), `Decision: FIX: <bespoke instruction>`.
- `Decision: SKIP` is reserved for mid-speech interruption in dialogue, where alternatives all read worse. The standing project policy is zero em dashes in narration.

Which categories have an obvious local edit for a bare `FIX` — and which treat a bare `FIX` as an escalation — is defined by the category fix rules in `agents/steps/anti-ai-fix.md`, not restated here.

---

## Notes on scope

**This pass does not evaluate prose quality.** A flagged pattern might be intentional and defensible. That is a human decision. This pass surfaces; it does not judge.

**Sentence rhythm and structural uniformity** are real AI tells (uniform sentence length, evenly balanced paragraphs) but are too subjective to audit mechanically. Those belong in the line-level voice pass, not here.

**Business jargon** (`leverage`, `optimize`, `facilitate`, `methodology`) is not included because it would not plausibly appear in fiction prose under any circumstances. The word list is scoped to tells that can actually surface in literary fiction.

---

## Anti-Patterns

**Evaluating whether a flag is justified.** Report everything. Do not suppress a flag because the usage seems intentional or defensible.

**Flagging transition words in non-opener positions.** Category 6 targets openers only. "However" mid-sentence is not a flag.

**Flagging animacy verbs on animate subjects.** Category 9 targets the verb-plus-inanimate-subject pairing. A person who "listens" is not a flag.

**Fixing.** This pass reports. The fix step is `anti_ai_fix`.

**Filling decision fields.** `Decision:` and `Decision-note:` are emitted blank. They belong to the human; a report that pre-fills a decision — however obvious the fix — has decided instead of reported, and a blank `Decision:` is the only honest signal that a unit is still pending.

**Anchoring non-units.** A zero-flag scene is its header plus one `No flags.` line — no anchor, no fields. An anchor turns it into a countable review unit and inflates the ledger with items that need no decision.

**Emitting the retired apparatus.** No eligibility block, no `BULK:` headers, no per-scene summary tally. Category-level eligibility and defaults live in `agents/review-grammars.yaml`'s fan-out declaration; the validator's ledger is the authoritative count.

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/anti-ai.md` — one report per chapter. Begins with a single top-of-file `Reviewed-draft: draft-vNN.md` line naming the `<latest-draft>` this report covers — the draft this run actually read; subsequent runs against the same draft append below and preserve the stamp (continuing each category-and-scene's review-id ordinals so ids never collide), runs against a newer draft (stale-report recovery path) overwrite the file with a fresh stamp (the report is `regenerated`, the prior findings `discarded`). Then one `## Anti-AI Report — Scene <scene-id>` header per scene, holding either a single `No flags.` line (no anchor, no fields, not a review unit) or `### <Category>` subsections — only the categories with hits, `### Flagged Words` included — in which every flagged instance carries its `<!-- review-id: ... -->` anchor immediately above its single top-level entry line and blank `- Decision:` / `- Decision-note:` fields nested below it. The `Reviewed-draft` stamp is required so `anti_ai_fix` can detect stale decisions against a newer draft. The file is the human review artifact: the human records decisions in each unit's `Decision:` field per the `anti_ai` family grammar in `agents/review-grammars.yaml` before `anti_ai_fix` runs.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs, append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate inputs and do not write partial outputs. The next dispatcher invocation will re-run this step after the human resolves the blocker. Anti-AI report is unusual in that it is a context-free pass against a single file; blockers are rare (effectively limited to `<latest-draft>` being missing or empty), but the same handling applies. On a successful run, the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
