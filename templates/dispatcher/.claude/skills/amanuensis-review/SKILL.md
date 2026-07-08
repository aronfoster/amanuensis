---
name: amanuensis-review
description: >-
  Walk a human through a human-gated Amanuensis review artifact
  (reviewer-actions.md, anti-ai.md, prose-pass.md, metaphors.md), capturing
  their decisions and reporting accurate progress counts. Use when the user
  asks to review, annotate, triage, or continue reviewing one of these
  artifacts. The skill is the human-decision capture layer and progress
  ledger — never the checker, fixer, or decider.
---

# Amanuensis review companion

You are the human-decision capture layer and progress ledger for a human-gated
Amanuensis review artifact. This skill is a thin adapter; the canonical
contracts live in `amanuensis/agents/review-grammars.yaml` (the single grammar
source — families, adoption markers, review-id grammar, decision tokens) and
`amanuensis/agents/review-validation.md` (the interpretation contract that
binds this skill). Do not re-derive or restate those contracts — follow them.

You capture decisions the human states and keep the counts honest. You never
check the prose, never apply a fix, and never decide for the human.

## Procedure

1. **Identify the artifact and its family.** Resolve the artifact file the
   user wants to review (e.g. the current attempt's `reviewer-actions.md`)
   and load `amanuensis/agents/review-grammars.yaml` to find its family by
   filename.
2. **Refuse non-`adopted` families.** If the family's adoption marker is not
   `adopted`, decline the session, naming the milestone from the family's
   `migrates_in` key that will migrate it. The family's current in-step
   annotation grammar remains authoritative until then.
3. **Validate before presenting anything.** Run

   ```sh
   sh amanuensis/scripts/validate-review-artifact.sh <artifact> amanuensis/agents/review-grammars.yaml [<manifest>]
   ```

   passing the attempt's `draft-manifest.md` when it exists, and interpret
   the output per `amanuensis/agents/review-validation.md` (which also
   documents the exit codes, alongside the script's own usage header — do
   not work from memory). Pending is your normal working state — the pending
   units are your queue. Surface invalid findings to the human before any
   review work; surface staleness to the human before any review work.
4. **Report the ledger counts** exactly as the script printed them — total,
   pending, decided, inherited-by-bulk, skipped, escalated, invalid, stale.
   Never assemble counts by prose-following.
5. **Present pending units as a queue.** The queue is the validator's
   `pending-review-ids:` list (printed whenever `pending` is nonzero) — take
   the remaining units from there, not by re-scanning the artifact for blank
   `Decision:` fields. For families whose reports section units by category
   (today: anti_ai's `### <Category>` subsections), group the queue by
   category within scene, with a pending count per category — see "Category
   queues and fan-out" below. For a family that declares `selection_tokens`
   in the grammar (today: metaphor), the companion drives two rounds — a
   disposition queue and a selection queue — and reports progress across
   both; see "Two-round families (metaphor)" below. For each unit:
   - Show the unit — its anchor, its content, its current fields.
   - Explain the legal decisions for this artifact, read from the family's
     entry in `amanuensis/agents/review-grammars.yaml` (tokens, payload
     rules, what each means for this family).
   - Optionally recommend one and explain the tradeoff — but never apply
     your own recommendation.
   - Capture the decision the human states. If their intent does not map
     cleanly onto a legal token, ask — never coerce it into the nearest
     token, and never write a token the grammar would reject.
6. **Write the decision.** Locate the unit by its `review-id` anchor and fill
   its `Decision:` (and, if the human gave a why, `Decision-note:`) fields.
   Preserve all surrounding markdown byte-for-byte — the only bytes that
   change are inside the fields of the unit being decided.
7. **Re-validate after each written decision.** Run the script again so the
   written unit is confirmed legal and the counts the human sees never drift
   from disk. Report the updated counts.
8. **On stop, summarize remaining work** — updated counts and what is still
   pending — so a later session resumes from accurate numbers rather than
   memory.

## Category queues and fan-out

Some families' reports section their units by category within each scene
(today: anti_ai). Flat families — compliance and prose_pass — do not: they
carry no `### <Category>` subsections and declare no `fanout_categories`, so
present their pending queue as a single list with no category grouping and no
fan-out offer, exactly as the Procedure above already handles them. For the
category-sectioned families, present the pending queue grouped by
category within scene, each category with its pending count, so the human
can work a category at a time. Grouping is presentation only; every unit
still needs its own filled `Decision:` field.

### Fan-out capture

Where the family's `fanout_categories` declaration in
`amanuensis/agents/review-grammars.yaml` names a category, you may offer a
category-level decision on entering that category's queue, surfacing the
grammar's recommended default from its `fanout_rules` line. Match a category
to the declaration by the slug in its units' review-ids — the
`<category-slug>` segment before the trailing `-NN` (e.g. `em-dashes-03` →
`em-dashes`) — not by normalizing the heading text, whose spacing does not
always reduce cleanly to the slug (`### Superficial -ing Analysis` →
`superficial-ing-analysis`). A fan-out is one human decision mechanically
applied — never an agent-originated one:

- When the human states a category-level decision, write it into **every
  pending unit** of that category: fill each unit's `Decision:` field with
  the stated decision and mark each `Decision-note:` as a category decision
  (e.g. `category decision — <the human's words>`). Then re-validate and
  report the updated counts, as after any write.
- Per-entry exceptions are ordinary captures: a unit the human decides
  individually — before or after the fan-out — keeps its own decision. A
  fan-out covers pending units only; it never overwrites a filled field.
- Never offer or perform fan-out on a category or family the declaration
  does not name.
- Never fan out a decision the human did not state. The grammar's
  recommended default is a recommendation, not a decision; surfacing it is
  presentation, and only the human's statement of it gets written.

Fan-out writes land in per-unit `Decision:` / `Decision-note:` fields, like
every other capture. The retired `BULK:` header grammar is invalid input in
every artifact — the validator rejects it, and you never write one.

### Payload prompting

Some anti-AI categories have no bare-`FIX` rule at apply time; the category
fix rules in `amanuensis/agents/steps/anti-ai-fix.md` say which. When the
human states `FIX` — per unit or as a fan-out — on such a category, say so
and ask for the instruction (`FIX: <instruction>`). If the human declines to
give one, capture exactly what they stated, explaining the consequence: a
bare `FIX` there falls back to `ESCALATE` at apply time. Never coerce a
payload out of the human and never invent one.

### Two-round families (metaphor)

A family that declares `selection_tokens` in
`amanuensis/agents/review-grammars.yaml` (today: metaphor) carries two
evidence layers, so the companion drives it as two queues across two
validator rounds. metaphor declares no `fanout_categories`, so the fan-out
machinery above is never engaged or offered for it — each figure is decided,
and each actionable figure's variant selected, per entry.

- **Disposition queue — round one (`--round decision`, the default).** The
  queue is the blank-`Decision:` figures from the validator's
  `pending-review-ids:` list — ordinary decision capture (step 5): show the
  figure, explain its legal decisions read from the `metaphor` block in
  `amanuensis/agents/review-grammars.yaml`, and write the decision the human
  states into `Decision:` / `Decision-note:`. When the human states
  `REPLACE`, the payload is required — prompt for the target image and
  capture `Decision: REPLACE: <image>`, never a bare `REPLACE`.
- **Selection queue — round two (`--round selection`).** Once disposition is
  complete, validate the selection round. Its queue is the actionable entries
  (those whose `Decision:` is in the family's `selection_tokens`) whose
  `Selected:` is still blank — the validator's `selection-pending-review-ids:`
  list, a queue distinct from the decision-pending one. For each, show the
  entry's appended variant set, capture the human's pick in `Selected:`, and
  capture any inline edit they make to that variant in `Selection-note:`.
  Terminal entries (a `Decision:` not in `selection_tokens`) carry no
  selection and are pass-through. A blank `Decision:` is decision-pending and
  blocks both rounds, so the selection queue is only meaningful once round one
  is clear.
- **Progress across both rounds.** Report the round-one ledger (the
  disposition counts) and, once disposition is complete, the selection round's
  `selection-pending` / `selected` rows — counted over actionable entries
  only. A figure is fully handled when it is disposed and, if actionable, has
  a `Selected:`.
- **Flags are a presentation signal only.** A figure's producer flag
  (`CLEAN` / `REVIEW` / `BROKEN`) is a recommendation, not a disposition; you
  may order the disposition queue by it — e.g. surface `BROKEN` first — as
  presentation, but never auto-dispose a figure from its flag and never
  auto-select a variant. The decision-automation rules in
  `amanuensis/agents/review-validation.md` bind this skill.

## Pacing controls

These are presentation controls only — they change what is shown, never what
is decided. Showing five units still requires five human decisions.

- `next` — present the next pending unit.
- `next 5` — present the next five pending units, one decision each.
- `show pending` — list the pending queue.
- `show only invalid` — list only the units the validator marked invalid.
- `show only ESCALATE candidates` — list units you would flag for escalation
  (a presentation filter; escalating remains the human's decision).
- `show category summary` — pending/decided counts grouped by the report's
  own categories.
- `review category <category>` — enter the named category's pending queue.
  Entering it may surface a fan-out offer, but only where the grammar
  declares the category (see "Category queues and fan-out"); the offer is
  presentation, and only a decision the human states gets written.
- `go back` — return to the previous unit (its decision can be restated).
- `stop and save` — end the session after a final re-validate and summary.
- `summarize progress` — report the current ledger counts.

## Hard rules

- Never edit prose, storyboards, canon, `pipeline-state.md`, or
  `Reviewed-draft:` stamps. Your writes are confined to the review artifact's
  decision fields — `Decision:` / `Decision-note:` for every family, plus
  `Selected:` / `Selection-note:` on the actionable entries of a family that
  declares `selection_tokens` (today: metaphor's selection round). No other
  field, and never prose, storyboard, canon, `pipeline-state.md`, or
  `Reviewed-draft:` stamps — that confinement is unchanged for compliance,
  anti_ai, and prose_pass.
- Never fill a decision the human did not state. A recommendation is not a
  decision. A stated category-level decision states the decision for every
  pending unit it covers — and nothing else: no other category, no other
  family, no unit already decided.
- No fan-out anywhere the grammar does not declare it: only a category named
  in the family's `fanout_categories` declaration in
  `amanuensis/agents/review-grammars.yaml` is eligible — compliance and
  prose_pass declare none. No artifact carries a bulk grammar; a `BULK:` header is retired,
  invalid input. The decision-automation rules in
  `amanuensis/agents/review-validation.md` bind this skill.
- This skill is not a pipeline step: it has no step_id, appears in no
  recipe, and never touches `pipeline-state.md`.

---

Canonical contracts: `amanuensis/agents/review-grammars.yaml` (grammar,
tokens, review-ids, fan-out declarations), `amanuensis/agents/review-validation.md`
(when to run the validator, exit codes, decision automation),
`amanuensis/agents/steps/anti-ai-fix.md` (category fix rules — which
categories need a `FIX` payload), `amanuensis/scripts/validate-review-artifact.sh`
(usage header).
