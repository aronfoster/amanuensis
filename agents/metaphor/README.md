# Metaphor Subsystem

The metaphor pipeline consists of three orchestrator steps and three subagent prompt contracts.

---

## Roles

**Step workflows** (invoked by the dispatcher; live under `agents/steps/`):

- `agents/steps/metaphor-identify.md` — extracts every live metaphor and simile from the latest prose into `<chapter-folder>/drafts/<latest-attempt>/metaphors.md`. `review_required: true`.
- `agents/steps/metaphor-fix.md` — coordinator step. Reads the human-reviewed `metaphors.md`, validates the decision layer (`--round decision`), dispatches one subagent per actionable (`FLATTEN` / `REPLACE` / `WORKSHOP`) entry in parallel against the contracts below, and appends each subagent's `#### ` variant section plus a blank `Selected:` field to its entry. `review_required: true`.
- `agents/steps/metaphor-apply.md` — applies the human-selected variant to `<latest-draft>`, producing the next `draft-vNN.md` at `<chapter-folder>/drafts/<latest-attempt>/` and appending a per-version entry to the attempt's `draft-manifest.md`. `review_required: false`.

**Subagent prompt contracts** (not steps; live in this directory and are dispatched by `metaphor_fix`):

- `metaphor-flatten.md` — generates literal rewrites for `FLATTEN`-annotated entries.
- `metaphor-replace.md` — integrates a human-supplied target image for `REPLACE: [target image]`-annotated entries.
- `metaphor-workshop.md` — generates replacement candidates for `WORKSHOP`-annotated entries where the human has not supplied an image. The integration phase that previously lived in this contract has been removed; integration is `metaphor_apply`'s job.

---

## Pipeline

1. **`metaphor_identify`** runs against the latest prose and writes `metaphors.md` with one anchored review unit per live figure — each carrying a `<!-- review-id: ... -->` anchor and blank `- Decision:` / `- Decision-note:` fields.
2. **Human review — round one (disposition).** The human — hand-editing or via the `amanuensis-review` companion — records a `Decision:` on every figure, per the `metaphor` family grammar in `agents/review-grammars.yaml`: `KEEP`, `REJECT`, `FLATTEN`, `REPLACE: [target image]`, or `WORKSHOP`. Deletion is no longer a decision signal — a rejected figure carries `Decision: REJECT` and **stays** in the file as the audit record. Inline corrections to identify fields (tenor, implication, register fit) go in `Decision-note:`; the fix subagents honor them.
3. **`metaphor_fix`** runs as a coordinator. It validates the decision layer (`--round decision`) and proceeds only when every figure is decided, then dispatches one subagent per **actionable** entry (`Decision:` in `FLATTEN` / `REPLACE` / `WORKSHOP`) in parallel — `FLATTEN` against `metaphor-flatten.md`, `REPLACE` against `metaphor-replace.md`, `WORKSHOP` against `metaphor-workshop.md`; `KEEP` / `REJECT` entries are left untouched, and an all-`KEEP`/`REJECT` file is a clean no-op. Each subagent receives only what its prompt contract requires (the entry block, the surrounding paragraph from the latest prose, and — for workshop — the storyboard block plus the voice file). It inserts a blank `- Selected:` / `- Selection-note:` pair on each actionable entry and appends a `#### ` variant section with stable per-variant ids (`A`/`B`/`C`; workshop `A`–`H`) directly below the entry.
4. **Human selection — round two.** The human records the chosen variant's id in the entry's `- Selected:` field (with any inline edit in `- Selection-note:`); the unchosen variants stay in the file as the audit record. Deletion is not a selection signal — the id in `Selected:` is.
5. **`metaphor_apply`** runs against the post-selection `metaphors.md`, validates the selection layer (`--round selection`) and proceeds only when every actionable entry names a variant, then applies each `Selected:` variant (with any `Selection-note:` edit as the target) to `<latest-draft>`, and writes the next `draft-vNN.md` (appending a per-version entry to `draft-manifest.md`). An all-`KEEP`/`REJECT` file is a valid pass-through. Workshop entries arrive as bare sentences (since workshop's integration phase was removed); the apply step's existing sentence-variant branch handles them.

---

## Working document

`metaphors.md` is the working document for the entire pipeline. It begins as the identify output, accumulates variants in the fix step, and becomes the apply input after human selection. Do not discard it after the pipeline completes — it is the audit record of every figurative decision made in the chapter.
