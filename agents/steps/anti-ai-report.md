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

The report is the human review artifact that gates the fix step. After this step runs, the human annotates the report; `anti_ai_fix` then reads the annotated report and applies edits to the prose.

## Inputs

- `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` — the latest prose, resolved at step start via the manifest's active head — or via the read-from override the dispatcher passed — per `agents/project-layouts.md`, not by highest-numbered draft. In the canonical pipeline order this will be the line-pass output. This is the only file this step reads. The pass is context-free by design.

## Behavior

Scan the input prose for the nine pattern categories below and the flagged-words list. Report every instance found. Do not evaluate whether a pattern's use seems intentional or defensible — that is a human judgment downstream.

The output file is one report per chapter; append across scenes with a scene header.

The file begins with a single top-of-file `Reviewed-draft:` line naming the resolved `<latest-draft>` this run reviewed — the draft this run actually read, so when a read-from override is in effect the stamp names that draft; the downstream `anti_ai_fix` step reads this stamp to detect stale annotations against a newer draft. If the file does not exist, create it with the stamp. If the file exists and its top-of-file stamp equals `<latest-draft>`, preserve the stamp and append new findings below. If the file exists and its top-of-file stamp does not equal `<latest-draft>` — the recovery path when the human is regenerating after a stale-report blocker — **overwrite the whole file** with a fresh top-of-file stamp; the prior run's findings against the superseded draft are discarded. See `agents/orchestrator.md`'s report→fix freshness invariant for the canonical statement.

```markdown
Reviewed-draft: draft-vNN.md
```

Begin each scene's section with:

```markdown
## Anti-AI Report — Scene <scene-id>
```

At the head of each scene's section, before any category subsections, emit one line per bulk-eligible category declaring the default action:

```markdown
BULK eligibility:
- Em Dashes: BULK permitted (recommended default: FIX: rewrite)
- Copula Avoidance: BULK permitted (recommended default: FIX)
- Superficial -ing Analysis: BULK permitted (recommended default: FIX)
- Transition Openers: BULK permitted (recommended default: FIX)
- Flagged Words: BULK permitted (recommended default: FIX)
- Negative Parallelism: BULK not permitted
- Significance Inflation: BULK not permitted
- Synonym Cycling: BULK not permitted
- Cadence tics: BULK not permitted
- Animacy Projection: BULK not permitted
```

The human writes their bulk choice (or omits it) at the head of the relevant category subsection during annotation. See "Annotation grammar" at the bottom of this document.

---

### Category 1: Em Dashes

Flag every em dash (`—`).

Em dashes are a strong AI tell and the standing project policy is zero em dashes in prose. Flag all instances without exception. Do not evaluate whether the usage seems intentional.

Format:
```markdown
### Em Dashes
- "[quote containing em dash]"
- "[quote containing em dash]"
```

---

### Category 2: Negative Parallelism

The construction. Two-beat: *It's not just X — it's Y. Not X. Y.* Three-beat: *Not X, not Y, but Z. / Not from X, nor from Y, but from Z.* Also: *Not by doing X, but by doing Y.*

This sentence structure has become strongly associated with AI-generated text and has measurably increased in corporate and published writing since 2023. The three-beat variant has its own signature and should be flagged distinctly from the two-beat. Flag all instances and close variants.

Format:
```markdown
### Negative Parallelism
- two-beat: "[quote]"
- three-beat: "[quote]"
```

---

### Category 3: Significance Inflation

Words and phrases that artificially elevate the weight of a moment. Common instances:

> tapestry, watershed, profound, resonate / resonates / resonating, nestled, vibrant, rich, nuanced, testament to, stands as, reminder that, serves as a metaphor, speaks to

Flag each instance with its quote.

Format:
```markdown
### Significance Inflation
- "vibrant" — "[quote]"
- "tapestry" — "[quote]"
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
- "serves as" — "[quote]"
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
- "[quote]"
```

---

### Category 6: Transition Words as Sentence or Paragraph Openers

Flag instances where the following words open a sentence or paragraph:

> Moreover, Furthermore, Additionally, However (as opener), Nevertheless, Consequently, Subsequently, In conclusion, Ultimately, Indeed, Certainly, Notably, Importantly, Interestingly

These are not banned in all positions — flag them only as openers, where they most strongly signal AI-generated structure.

Format:
```markdown
### Transition Openers
- "Moreover, ..." — "[full sentence or opening clause]"
```

---

### Category 7: Synonym Cycling

When the prose rotates through multiple synonyms for the same noun within a short passage to avoid repetition. Common in AI output because models are trained to avoid word repetition.

Example: referring to the same character as "the girl," "the young woman," "the princess," "the child," and the character's proper name within a single paragraph.

Flag the passage and list the synonyms being cycled.

Format:
```markdown
### Synonym Cycling
- Passage: "[quote]"
- Cycled terms: [term1], [term2], [term3]
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
- triplet: "[quote]"
- paralepsis cascade: "[quote]"
- tautological recursion: "[quote]"
- delayed-subject inversion: "[quote]"
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
- "remembered" / subject: grove — "[quote]"
- "witnesses" / subject: bastions — "[quote]"
- "hums" / subject: city — "[quote]"
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
- "delve" — "[quote]"
- "tapestry" — "[quote]"
```

---

## At the end of each scene

```markdown
### Summary — Scene <scene-id>

- Em dashes: N
- Negative parallelism: N (two-beat: N, three-beat: N)
- Significance inflation: N
- Copula avoidance: N
- Superficial -ing analysis: N
- Transition openers: N
- Synonym cycling: N
- Cadence tics: N
- Animacy projection: N
- Flagged words: N
- Total flags: N
```

---

## Annotation grammar

After this step runs, the human edits this report file to direct `anti_ai_fix`. The grammar parallels `compliance_report.md` and adds an optional bulk header per category.

**Per-entry annotations** (write the annotation after the quote, on the same line or the next):

- `FIX` — apply the obvious local edit defined by the category's fix rule.
- `FIX: <instruction>` — apply the fix as specified. Required for categories where there is no obvious local edit (Categories 2, 3, 7, 8, 9 generally; em dashes when a specific strategy is wanted).
- `SKIP` — leave the prose as-is. The instance is accepted.
- `ESCALATE` — the fix cannot be applied by a local edit; flag for human rewrite. The fixer records the escalation in the apply log and moves on.

**Per-category bulk header** (write at the head of the category subsection during annotation, before any per-entry annotations):

```markdown
### Em Dashes
BULK: FIX: rewrite

- "[quote 1]" (no annotation — takes bulk default)
- "[quote 2]" FIX: comma (override: this one wants a comma)
- "[quote 3]" SKIP (override: keep this one)
```

Grammar: `BULK: <action>[: <instruction>]`, where `<action>` is `FIX` or `SKIP`, and `<instruction>` is free text passed to the fixer the same way `FIX: <instruction>` is passed on individual entries.

Per-entry annotations override the bulk header.

Bulk headers are only valid on categories declared `BULK permitted` in the BULK eligibility block at the head of the scene section. Writing a bulk header on a `BULK not permitted` category is an annotation defect; the fixer will treat it as if no bulk header were present and require per-entry annotations.

**Em dash specifics** (the most common fix-step decision):

- Default bulk: `BULK: FIX: rewrite`. The fixer reads the local sentence and picks split / comma / restructure per instance.
- Per-entry overrides: `FIX: split` (force period split), `FIX: comma` (force comma), `FIX: rewrite` (force restructure), `FIX: <bespoke instruction>`.
- `SKIP` is reserved for mid-speech interruption in dialogue, where alternatives all read worse. The standing project policy is zero em dashes in narration.

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

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/anti-ai.md` — one report per chapter. Begins with a single top-of-file `Reviewed-draft: draft-vNN.md` line naming the `<latest-draft>` this report covers. Subsequent runs against the same draft append below and preserve the stamp; a run against a newer draft (stale-report recovery path) overwrites the file with a fresh stamp. Has a `## Anti-AI Report — Scene <scene-id>` header per scene, a BULK eligibility block at the head of each scene section, the per-category flag sections (only those with hits), a `### Flagged Words` section, and a `### Summary — Scene <scene-id>` block at the end of each scene tallying counts per category and a total. The file is the human review artifact that the human annotates with the grammar above before `anti_ai_fix` runs; `anti_ai_fix` reads the reviewed-draft stamp to detect stale annotations.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs, append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate inputs and do not write partial outputs. The next dispatcher invocation will re-run this step after the human resolves the blocker. Anti-AI report is unusual in that it is a context-free pass against a single file; blockers are rare (effectively limited to `<latest-draft>` being missing or empty), but the same handling applies. On a successful run, the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
