---
step_id: anti_ai
review_required: true
inputs:
  - <chapter-folder>/drafts/<latest-attempt>/draft-line.md
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/anti-ai.md
---

See `agents/orchestrator.md` for the step workflow contract.

# Anti-AI Pass

## Purpose

Hygiene workflow. Identifies patterns that signal AI-generated prose to trained readers. Reports findings; does not fix.

This pass is the last step in the pipeline. It runs against the line-pass output (`draft-line.md`), the latest prose available in the attempt folder. It operates on surface and structural signals only — it has no awareness of canon, storyboard requirements, or voice spec. Do not use it to evaluate whether prose is good. Use it to find patterns that will get a reader's guard up.

## Inputs

- `<chapter-folder>/drafts/<latest-attempt>/draft-line.md` — the latest prose, after line pass. This is the only file this step reads. The pass is context-free by design.

## Behavior

Scan the input prose for the eight pattern categories below and the flagged-words list. Report every instance found. Do not evaluate whether a pattern's use seems intentional or defensible — that is a human judgment downstream.

The output file is one report per chapter; append across scenes with a scene header.

Begin each scene's section with:

```markdown
## Anti-AI Report — Scene xx-yy
```

---

### Category 1: Em Dashes

Flag every em dash (`—`).

Em dashes are a strong AI tell and are uncommon in literary fiction prose. Flag all instances without exception. Do not evaluate whether the usage seems intentional.

Format:
```markdown
### Em Dashes
- "[quote containing em dash]"
- "[quote containing em dash]"
```

---

### Category 2: Negative Parallelism

The construction: *It's not just X — it's Y. Not X. Y. Not by doing X, but by doing Y.*

This sentence structure has become strongly associated with AI-generated text and has measurably increased in corporate and published writing since 2023. Flag all instances and close variants.

Format:
```markdown
### Negative Parallelism
- "[quote]"
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

### Category 8: Cadence tics

These are moves language models reach for when asked to write literary prose. They read as signature to the writer and as tells to the reader. The patterns themselves are not noteworthy — they are centuries-old rhetorical devices. What is noteworthy is using them excessively.

Flag the passage and list the examples.

* Triplets: three parallel clauses, phrases, or items in a row. "Down, closed over, gone." "Not for any person she had been trained to be, not for anyone's daughter, not for a role." One per chapter is a signature. Three is a habit the reader is tracking.
* Paralepsis cascades: definition by negation stacked three or more deep. "Not a sound, not a smell, not anything that belonged to her body." Used once in a scene, it emphasizes. Used four times in a chapter, it crutches.
* Tautological recursion: "the flame closing into a flame," "the precise firmness of a floor." If a chapter needs one, make it one.
* Delayed-subject inversion: "From somewhere behind her: your highness." Useful once, conspicuous twice.

---

## Specific word list

These words should be flagged whenever they appear, regardless of category:

> delve, delves, delved, nestled, vibrant, tapestry, resonate, resonates, resonating, profound, nuanced, showcase, showcases, showcasing, testament, watershed, robust, seamless, bustling, thriving, realm

Flag each with its quote, under a separate section:

```markdown
### Flagged Words
- "delve" — "[quote]"
- "tapestry" — "[quote]"
```

---

## At the end of each chapter

```markdown
### Summary — Scene xx-yy

- Em dashes: N
- Negative parallelism: N
- Significance inflation: N
- Copula avoidance: N
- Superficial -ing analysis: N
- Transition openers: N
- Synonym cycling: N
- Flagged words: N
- Total flags: N
```

---

## Notes on scope

**This pass does not evaluate prose quality.** A flagged pattern might be intentional and defensible. That is a human decision. This pass surfaces; it does not judge.

**Sentence rhythm and structural uniformity** are real AI tells (uniform sentence length, evenly balanced paragraphs) but are too subjective to audit mechanically. Those belong in the line-level voice pass, not here.

**Business jargon** (`leverage`, `optimize`, `facilitate`, `methodology`) is not included because it would not plausibly appear in this prose under any circumstances. The word list above is scoped to tells that can actually surface in literary fiction.

---

## Anti-Patterns

**Evaluating whether a flag is justified.** Report everything. Do not suppress a flag because the usage seems intentional or defensible.

**Flagging transition words in non-opener positions.** Category 6 targets openers only. "However" mid-sentence is not a flag.

**Fixing.** This pass reports. Nothing else.

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/anti-ai.md` — one report per chapter, with a `## Anti-AI Report — Scene xx-yy` header per scene, the per-category flag sections (only those with hits), a `### Flagged Words` section, and a `### Summary — Scene xx-yy` block at the end of each scene tallying counts per category and a total.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs, append the blocker to the project root `open-questions.md` and exit without advancing the pipeline marker. Do not fabricate inputs and do not write partial outputs. The next dispatcher invocation will re-run this step after the human resolves the blocker. Anti-AI is unusual in that it is a context-free pass against a single file; blockers are rare (effectively limited to `draft-line.md` being missing or empty), but the same handling applies.
