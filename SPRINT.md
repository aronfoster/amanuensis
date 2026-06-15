# Sprint 8 — Milestone 3: Bounded canon invention + capture

This Sprint replaces the project's blanket "do not invent canon" stance with one
bounded rule, resolves the contradictory `orchestrator.md` TODO, and adds a
coordinator-managed **capture agent** that records the continuity-relevant inventions
the rule permits into the right canonical files. After this Sprint: a single statement
of the invention rule exists and the step bodies reference it rather than restating a
flat prohibition; the drafting coordinator dispatches a capture agent that writes
permitted inventions to `timeline.md` / `profile.md` / an agent-generated `canon/`
subfolder — **never** `knowledge/` — with annotated, edit-policy-respecting,
non-blocking writes; and both hosts (Claude step bodies and the OpenCode coordinator)
describe the same contract.

Like Sprint 7 this is a documentation/prose-contract milestone: every change edits a
Markdown step body, support doc, or agent prompt. No code, no scripts, no schema
changes. The behavior is enforced by the instructions the LLM coordinator and its
subagents follow, not by an executable test; acceptance is by inspection of those
instructions plus grep invariants.

## Background — what is and isn't wrong today

Established by inspection during planning; tasks should not re-derive this.

- **The contradiction lives at `agents/orchestrator.md:42`.** The dispatcher contract
  says "do not invent missing canon," immediately followed by a TODO stating the
  opposite intent: that drafters *should* be free to invent non-load-bearing detail
  (the "what did John order at breakfast" case) so long as it makes sense and does not
  conflict with canon. This TODO is the thing M3.3 closes; its example is the seed of
  the rule's wording.
- **The canonical prohibition is `agents/update-rules.md:5` — "Rule 1: do not silently
  invent canon."** This is the single statement the rest of the repo should defer to.
  `agents/canon.md:36` ("Do not silently invent settled world facts.") is the
  world-truth restatement. The rule (M3.1) is best written as a qualification of Rule 1
  — the *silently* and *settled/load-bearing* qualifiers are already doing the work;
  the bounded rule makes the permitted case explicit and names the exceptions.
- **The flat prohibition is scattered across these step bodies** and must be pointed at
  the single rule rather than each carrying its own absolute (M3.2):
  `agents/steps/drafting.md:65` and `:153`, `agents/steps/scene-generation.md:27` and
  `:109`, `agents/steps/character-extraction.md:43`, `agents/characters.md:93`, and the
  OpenCode `opencode/agents/chapter-coordinator.md:40`. `storyboarding.md` is named in
  the ROADMAP task; confirm whether it carries an invention prohibition and reference
  the rule there too if so, otherwise no edit.
- **`knowledge/` is off-limits to capture by existing contract.**
  `agents/characters.md:61`: "Knowledge items are only written to these files during
  the scene knowledge update workflow, after drafting confirms what the scene
  committed." That workflow is deferred (see ROADMAP Deferred list). `knowledge/` is
  also the reveal-sensitive state M3's hard prohibition protects. Capture therefore
  never writes `knowledge/`; the eggs-class fact is a `timeline.md` event, and invented
  identity color is a `profile.md` field.
- **Stub-folder creation already has a procedure.** `agents/characters.md:74–91`
  defines how to create a character folder for a not-yet-present character, including
  `status: stub` frontmatter and the minimum files. The capture agent's
  walk-on-with-no-folder path reuses this procedure; it does not invent a new one.
- **The drafting subagents are sandboxed and cannot be the writers.**
  `agents/steps/drafting.md:61–69`: scene-drafters may read only the inputs handed to
  them and write only their own `sceneNN.md` / `sceneNN-notes.md`; they are explicitly
  barred from reading or writing canon and character files. So capture cannot be folded
  into the scene-drafter role — it is a **new, non-sandboxed subagent role** the
  coordinator dispatches. Precedent for a coordinator dispatching a specialized
  subagent exists in both hosts: the metaphor subagents under `agents/metaphor/` and
  the scene-drafters under `opencode/agents/`.
- **Capture must run before the M2 fragment deletion.** Per Sprint 7,
  `agents/steps/drafting.md` step 8 assembles `notes.md` and step 9 deletes each
  `sceneNN-notes.md`. The recommendations capture consumes live in those notes files,
  so the coordinator must collect them (during step 8) and dispatch capture before the
  step-9 deletion. Capture is gated the same way deletion is: it runs only on a
  completed assembly, never on a failure/abandon path.
- **`edit_policy` already exists.** `agents/update-rules.md:41` (Rule 7) defines the
  operational-file header field `edit_policy: locked | propose_only | careful_edit |
  editable` (also in `templates/profile.md:5`). Capture's write discipline respects it:
  no silent write into a `locked` or `propose_only` target.
- **`canon/` is world-level truth.** `agents/canon.md:3` and the priority order
  (`canon/` is rank 1). World-level inventions go into a **new agent-generated subfolder
  under `canon/`**, kept visibly distinct from human-authored canon. The subfolder name
  is not yet chosen (see Open decision below).
- **`agents/project-layouts.md`** shows `canon/` in its folder trees; if a new
  agent-generated subfolder is named, decide whether the trees need it (low priority —
  the trees are illustrative, not exhaustive).

## Open decisions (resolve at task start)

1. **Name of the agent-generated `canon/` subfolder.** Candidates: `canon/generated/`,
   `canon/invented/`, `canon/agent/`. Pick one and use it consistently across the
   capture agent doc, `canon.md`, and any tree. Flagged to the human at planning time;
   default to `canon/generated/` if no preference.
2. **Draft-version provenance (M4 dependency).** M3.7's annotation wants a
   "which draft did this come from" stamp, which is **M4.3** and M4 is not yet built.
   Default for this Sprint: capture annotates source **scene + beat + attempt** now (all
   available today), and the draft-version stamp is folded in when M4 lands. Do not
   block this Sprint on M4; do leave the annotation shape extensible.

## Definition of done

The Sprint is complete when:

1. ROADMAP.md tasks M3.1–M3.8 are checked.
2. A single bounded-invention rule exists (a revision of `update-rules.md` Rule 1,
   cross-referenced from `canon.md`): invent only when canon and plan are silent, the
   invention cannot contradict existing canon, it fits genre/register/period, and it is
   **not** load-bearing for reveal timing or character knowledge; otherwise record an
   open question.
3. The scattered flat prohibitions in the step bodies named above reference that single
   rule instead of each restating an absolute; the **hard** prohibition is preserved
   verbatim for reveal- and knowledge-load-bearing facts.
4. The `orchestrator.md:42` TODO is gone, replaced by wording consistent with the rule.
5. `agents/steps/drafting.md` documents that scene-drafters emit invention
   *recommendations* in `sceneNN-notes.md` under a defined schema (invented fact;
   target `character_id`(s) or world-scope; fact-type `event` / `identity` / `world`;
   source scene + beat), and the subagent prompt contract instructs them to do so —
   while they still write nothing outside their notes/prose.
6. `agents/steps/drafting.md` documents the coordinator collecting those
   recommendations during notes assembly and dispatching the capture agent before the
   fragment-deletion step, gated on a completed assembly.
7. A capture agent definition exists for both hosts (a doc under `agents/` plus an
   `opencode/agents/` counterpart) with the routing and write discipline below.
8. Routing is specified: character `event` → `characters/<id>/timeline.md`; invented
   stable identity color → `characters/<id>/profile.md`; **never** `knowledge/`;
   non-character `world` facts → the chosen agent-generated `canon/` subfolder; a
   walk-on with no folder → create a `status: stub` folder per `characters.md:74–91`,
   then write.
9. Write discipline is specified: each write is annotated (source scene + beat +
   attempt, extensible to the M4 draft-version stamp, plus an `invented, unreviewed`
   marker); respects the target file's `edit_policy` (no silent write to a `locked` /
   `propose_only` file — record a proposal/blocker in `notes.md` instead); and is
   non-blocking (a capture failure never blocks draft completion — it is logged in
   `notes.md`). Captured writes ride drafting's existing `review_required: true` gate.
10. Both hosts agree: the Claude `drafting.md` and the OpenCode `chapter-coordinator.md`
    describe the same recommendation/collection/dispatch contract.

## Conventions adopted by this Sprint

Locked at the start so individual tasks don't rediscover them.

- **One rule, referenced not restated.** The bounded rule is stated once (Rule 1 in
  `update-rules.md`). Every other file points at it. Only the reveal-/knowledge-
  load-bearing hard prohibition is repeated where it must be unmissable.
- **`knowledge/` is never written by capture.** It stays the sole province of the
  deferred scene-knowledge-update step; this is what protects reveal timing. This is a
  hard line, not a default.
- **Capture is a subagent role, not a pipeline step.** It does not appear in
  `templates/pipeline-state.md`; it is dispatched by the drafting coordinator inside the
  existing `drafting` step, like the metaphor subagents inside `metaphor_fix`.
- **Writes are annotated, edit-policy-respecting, and non-blocking.** Capture never
  silently overwrites human-authored canon and never halts a draft on failure.
- **Host parity.** The Claude step bodies and the OpenCode coordinator describe the same
  contract; neither host gains behavior the other lacks.

---

## Tasks

### Task 1 — Write the bounded-invention rule; resolve the orchestrator TODO [x]

**Goal.** Replace the blanket prohibition with one bounded rule and remove the
self-contradicting TODO. Closes **M3.1** and **M3.3**.

**Requirements.**

- Revise `agents/update-rules.md` Rule 1 so it states the bounded permission: an agent
  may invent a detail only when (a) canon and the plan are silent on it, (b) it cannot
  contradict any existing canon, (c) it fits the work's genre / register / period, and
  (d) it is **not** load-bearing for reveal timing or character knowledge. Otherwise the
  agent records an open question rather than inventing. Keep the "silently" framing — the
  point is that permitted invention is captured (Tasks 3–5), not hidden.
- Cross-reference the rule from `agents/canon.md` (near line 36) so the world-truth file
  and the rules file agree; do not restate the full rule in both.
- Edit `agents/orchestrator.md:42`: remove the parenthetical TODO and reword the bullet
  so the blocked-path guidance is consistent with the new rule (invent the permitted
  case; record an open question for the load-bearing/conflicting case).

**Done when.** Rule 1 states the four-part bounded permission and its exceptions;
`canon.md` references it; the `orchestrator.md` TODO is gone and its bullet matches.

---

### Task 2 — Point the scattered prohibitions at the single rule [x]

**Goal.** Make every step body defer to Rule 1 instead of carrying its own absolute,
while preserving the hard prohibition for reveal/knowledge facts. Closes **M3.2**.

**Requirements.**

- In each of `agents/steps/drafting.md` (lines 65 and 153),
  `agents/steps/scene-generation.md` (27 and 109),
  `agents/steps/character-extraction.md` (43), and `agents/characters.md` (93), change
  the flat "do not invent canon" statement to reference the bounded rule — permitted
  invention is allowed under Rule 1; load-bearing/conflicting facts are still recorded
  as open questions.
- **Preserve the hard line.** Where a file protects reveal timing or character
  knowledge (e.g. `drafting.md` Safety rules, the subagent "preserve what a character
  knows/suspects/believes" lines), keep the absolute prohibition unmistakable. The
  bounded permission never reaches reveal-/knowledge-load-bearing facts.
- Check `agents/steps/storyboarding.md` for an invention prohibition; reference the rule
  if present, no edit if absent.

**Done when.** The named prohibitions reference Rule 1; the reveal/knowledge hard
prohibition is intact and clearly separated from the permitted case.

---

### Task 3 — Recommendation hand-off schema [x]

**Goal.** Let sandboxed scene-drafters surface continuity-relevant inventions without
writing canon. Closes **M3.4**.

**Requirements.**

- In `agents/steps/drafting.md`, define the schema a subagent records in its
  `sceneNN-notes.md` for each invention it made under Rule 1: the invented fact; the
  target (`character_id`(s) or world-scope); the fact-type (`event` / `identity` /
  `world`); and the source scene + beat.
- Add a line to the subagent prompt contract (the fenced block around lines 77–99)
  instructing subagents to record these recommendations in their notes file — and
  reaffirm they still write nothing outside their prose/notes files and never touch
  canon or character files themselves.

**Done when.** `drafting.md` specifies the recommendation schema and the subagent
contract tells subagents to emit it, with the sandbox preserved.

---

### Task 4 — Coordinator collection + gated dispatch [x]

**Goal.** Have the coordinator gather recommendations and dispatch capture at the right
point in the run. Closes **M3.5**.

**Requirements.**

- In `agents/steps/drafting.md` "Coordinator responsibilities," add a step (after notes
  assembly, step 8; before fragment deletion, step 9) in which the coordinator collects
  the per-scene recommendations and dispatches the capture agent with them.
- Gate it exactly like deletion: capture runs only on a completed assembly. On any
  failure/abandon path the coordinator does not dispatch capture and records the
  blocker in `notes.md`.
- State explicitly that capture is **non-blocking**: a capture failure is logged in
  `notes.md` and does not prevent `draft.md` from being a completed output.

**Done when.** `drafting.md` collects recommendations and dispatches capture between
notes assembly and fragment deletion, gated on completion and non-blocking on failure.

---

### Task 5 — Capture agent definition: routing + write discipline [x]

**Goal.** Write the agent the coordinator dispatches. Closes **M3.6** and **M3.7**.

**Requirements.**

- Create the capture agent doc for the Claude host (under `agents/`, e.g.
  `agents/capture/` mirroring `agents/metaphor/`) and an `opencode/agents/` counterpart.
- **Routing.** Character `event` → `characters/<id>/timeline.md`; invented stable
  identity color → `characters/<id>/profile.md`; **never** `knowledge/` (cite
  `characters.md:61`); non-character `world` facts → the chosen agent-generated `canon/`
  subfolder (Open decision 1); a walk-on with no folder → create a `status: stub` folder
  per `characters.md:74–91`, then write.
- **Write discipline.** Annotate each write with source scene + beat + attempt (Open
  decision 2 for the M4 draft-version stamp) and an `invented, unreviewed` marker;
  respect the target's `edit_policy` (Rule 7) — no silent write to `locked` /
  `propose_only`, record a proposal/blocker in `notes.md` instead; never write
  `knowledge/`; only ever record inventions Rule 1 permits (reveal/knowledge facts are
  open questions, never captured).

**Done when.** Both host docs specify the routing table and the annotated,
edit-policy-respecting, knowledge-excluded write discipline.

---

### Task 6 — Host parity, verification sweep, closeout [x]

**Goal.** Confirm the two hosts agree, the invariants hold, and the catalogs are
updated. Depends on Tasks 1–5.

**Requirements.**

- **Host parity.** Mirror the recommendation/collection/dispatch contract into
  `opencode/agents/chapter-coordinator.md` so it matches `drafting.md`; confirm the
  capture agent doc exists for both hosts and they describe the same routing/discipline.
- **Rule-reference sweep.** `git grep -n -iE "invent" -- '*.md'`; confirm no step body
  still carries a flat "do not invent canon" absolute that should defer to Rule 1, and
  that the reveal/knowledge hard prohibition is intact everywhere it belongs.
- **Knowledge-boundary invariant.** Confirm nothing in the capture path writes
  `knowledge/`; the only writer remains the deferred scene-knowledge-update step.
- **TODO check.** `git grep -n "TODO" -- agents/orchestrator.md`; confirm the invention
  TODO at line 42 is gone (the unrelated line-106 TODO is out of scope, leave it).
- **ROADMAP.md.** Check M3.1–M3.8. Add a one-line Note if the canon-subfolder name was
  chosen, recording it.
- **Sprint file.** Mark each completed task in this file `[x]`.

**Done when.** Both hosts agree, the invariants and TODO check hold, ROADMAP M3.1–M3.8
are checked, and all Sprint tasks are checked.

---

## Out of scope for this Sprint

- **Versioned draft naming and the draft-version provenance stamp** — that is Milestone
  4 (M4.3). This Sprint annotates captures with source scene + beat + attempt and leaves
  the annotation extensible; it does not build the draft-version counter.
- **The scene knowledge update step** — deferred. This Sprint deliberately does *not*
  write `knowledge/`; that step remains its only writer.
- **Continuity review / cross-chapter reveals ledger** — deferred; not a prerequisite
  for bounded capture.
- **Any executable check.** The step bodies and agent docs are LLM-run; acceptance is by
  inspection plus grep invariants, not a harness.
- **New pipeline steps or `pipeline-state.md` edits.** Capture is a dispatched subagent
  role inside the existing `drafting` step, not a new step.
