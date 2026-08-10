# Rin Knowledge State — Book 1

<!--
ILLUSTRATIVE EXAMPLE — NOT REAL PROJECT CANON OR STATE.

A worked demonstration of the character-belief → objective-fact boundary
(`agents/continuity.md`, "Character belief refers to objective fact — never
copies it"), mirroring the field shapes in `templates/knowledge-book.md`. Rin,
her belief, the drafts, and the story positions are invented for the example.
See the folder README at `examples/continuity/README.md`.

The load-bearing entry here is the `## Believes incorrectly` one: Rin believes
the *cook* breached the water casks. Its `truth:` field carries the QUALIFIED
reference `continuity/book-1.md#co-08` to the objective fact she is wrong about —
objectively it was the quartermaster (co-08, the **resolved** thread; the question
was open as co-07 in chapter02 and the prose answered it in chapter03). The
objective fact lives once, in `continuity/`; this file points, never copies or
overrides it. The reference is
continuity-tracking metadata, not character knowledge, and does not affect
reveal timing.
-->

---

## Knows

<!-- Facts the character holds with confidence. -->

### The water casks were found breached in the night watch
- **id:** kn-01
- **story-position:** book1/chapter02/scene04
- **committed-in:** draft-v03.md
- **basis:** witnessed
- **fact:** Rin found three of the six water casks staved in during the night watch and raised the alarm. She holds this correctly — she was present at the discovery (the objective staging is co-03 in continuity/book-1.md).
- **notes:** —
- **review:** unreviewed

---

## Suspects

<!-- Facts the character holds as probable but unconfirmed. -->

<!-- No current entries. -->

---

## Believes incorrectly

<!-- Facts the character holds confidently but which are wrong. -->

### The cook breached the water casks
- **id:** kn-02
- **story-position:** book1/chapter02/scene05
- **committed-in:** draft-v03.md
- **basis:** inferred
- **belief:** Rin is convinced the ship's cook staved in the water casks — he had the run of the forward hold and had quarreled with her over the ration count the day before.
- **truth:** continuity/book-1.md#co-08
- **notes:** The qualified `truth:` reference points at the objective fact in `continuity/`: objectively it was the *quartermaster* (co-08, the **resolved** thread — the question was open as co-07 at book1/chapter02/scene04 and the prose answered it at book1/chapter03/scene04). Rin formed this belief at chapter02/scene05, while the thread was still open, and does not know the answer. The objective fact is the authority; this entry records only her belief and defers to `continuity/book-1.md#co-08` for the true state — it never restates or overrides it.
- **review:** unreviewed

---

## Must not know yet

<!-- Hard guardrails authored by planning. These are the things reveal timing protects. -->

- Who actually breached the casks (the quartermaster) — must remain unknown to Rin until book1/chapter04/scene02, when the quartermaster's ledger is exposed to the crew.

---

## Lost or superseded

<!--
A correction never overwrites a current-state entry. Per the non-destruction
invariant (agents/characters.md), a superseded entry moves here keeping its id,
and the corrected state is recorded as a new stamped entry above.
-->

<!-- No transitions yet — Rin's false belief still stands at the positions this
     example reconstructs. -->
