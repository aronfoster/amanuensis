# Amanuensis Roadmap

Remaining work, in rough dependency order. Tasks plus short notes on what's done.
Project overview, architecture, and current status live elsewhere.

Several milestones edit the canonical step list (`templates/pipeline-state.md`); they
are sequenced, not parallel, so it is never edited by two at once.

---

## Milestone 10: Agent-Addressable Human Review

### Goal

Create an agent-assisted review companion for Amanuensis human-gated artifacts.

The companion is **not** a checker, fixer, or decider. It is the human-decision capture layer **and progress ledger** over structured review artifacts. Its job is to make review work fast, auditable, resumable, and visibly finite: the human sees pending review units, makes decisions, and the agent records those decisions in the correct fields without brittle markdown surgery.

This milestone is a **big-bang migration**. Existing review pipelines may break during implementation. All four human-gated artifact families will be retargeted together from human-only markdown reports to agent-addressable structured markdown.

Reports remain readable and editable by humans, but every review unit becomes addressable, countable, and validated against a single shared grammar contract.

### Motivation

Several Amanuensis passes produce side artifacts that require human review before downstream fix/apply steps can run:

* `reviewer-actions.md` from `compliance_report`
* `prose-pass.md` from `prose_pass`
* `anti-ai.md` from `anti_ai_report`
* `metaphors.md` from `metaphor_identify`

Today, the human must hand-edit markdown files using artifact-specific annotation conventions. This is tedious, error-prone, and difficult to resume.

The core problem is not lack of automation. Most decisions are irreducibly human: whether to keep a metaphor, fix a compliance issue, accept a prose-pass finding, or escalate an ambiguous case. The problem is that the work is not ergonomic or visibly finite.

A review companion should answer:

* What artifact am I reviewing?
* Which draft was this report generated against?
* How many review units are pending?
* What is the next pending unit?
* What decisions are legal for this unit?
* What did I decide?
* Was that decision recorded in a machine-readable way?
* Can the downstream fix/apply step validate and consume the decision?

The milestone succeeds when reviewing seventy-five metaphors or thirty compliance findings feels like working through a bounded queue, not manually editing an open-ended markdown blob.

### Core Principle

The value is not that the agent decides more.

The value is that the human decides faster, safer, and with visible progress toward done.

The companion exists to support this loop:

```text id="32h3h0"
identify/report → human decision capture + progress ledger → fix/apply
```

### Design Principles

1. **Human decisions remain human.**
   The companion may recommend actions, explain tradeoffs, and batch presentation. It must not silently make editorial decisions except where the artifact grammar explicitly permits mechanical bulk handling.

2. **The report/identify step surfaces findings; the companion captures decisions; the fix/apply step changes prose.**
   The companion must not become the checker or the fixer.

3. **A field is a promise; a position is only a hope.**
   Do not rely on “insert below the flag line” or similar positional conventions. Each review item gets explicit decision fields.

4. **Progress must be countable.**
   Blank decision fields usually mean pending. Filled decision fields mean adjudicated. Accepted and unreviewed items must never look identical at the review-unit level.

5. **Bulk changes the unit of countability.**
   In anti-AI bulk-eligible categories, the category is the review unit once a legal `BULK:` header is set. Blank item-level decisions under that valid bulk header inherit the category decision and are not counted as pending.

6. **Grammars are artifact-specific and single-sourced.**
   There is no universal annotation grammar. The parser, validator, skill, and fix/apply steps must consume the same machine-readable grammar definition.

7. **Static grammar and dynamic report declarations are separate.**
   The static grammar defines what an artifact type can support. The report itself may declare narrower per-report or per-scene permissions, such as anti-AI `BULK permitted` categories.

8. **Structured markdown remains the primary artifact.**
   Reports must stay readable, hand-editable, and friendly to Git diffs. Do not introduce JSON sidecars as the source of truth.

9. **IDs are stable within a reviewed-draft epoch, not across regenerations.**
   A `review-id` only needs to be stable for the report generated against its `Reviewed-draft:` stamp. When a report is regenerated against a newer draft, prior findings are discarded by existing contract; IDs may be regenerated too.

### Single-Source Grammar Contract

Add one machine-readable grammar definition, for example:

```text id="vcxqtm"
agents/review-grammars.yaml
```

This file is the single source of truth for review grammars.

It should define, per artifact:

* artifact name
* producer step
* consumer step or steps
* artifact path pattern
* review item shape
* anchor pattern
* legal decision tokens
* decision payload requirements
* whether blank means pending
* whether bulk is statically supported
* whether dynamic report declarations are required
* bulk header grammar, if any
* how progress is counted
* what constitutes valid review evidence
* what state allows the downstream consumer to proceed

Step documentation should reference this grammar file rather than restating token sets in prose. The validator, review companion, and downstream fix/apply steps must all use this same contract.

### Structured Markdown Format

Each review artifact begins with its existing freshness stamp:

```markdown id="6d15u1"
Reviewed-draft: draft-vNN.md
```

Each review item includes an embedded HTML-comment anchor:

```markdown id="2oq65y"
<!-- review-id: <artifact>:<book-or-project-scope>:<chapter>:<scene-or-section>:<item-id> -->
```

The `review-id` must be unique within the artifact and reviewed-draft epoch.

Each item-level review decision uses explicit fields:

```markdown id="st7emi"
- Decision:
- Decision-note:
```

`Decision:` is machine-readable and must use the artifact’s legal token set.

`Decision-note:` is optional free text for human instructions, rationale, or clarification.

Blank item-level `Decision:` means pending unless the artifact grammar and the current report context provide a valid higher-level decision, such as an anti-AI category `BULK:` header.

### Review Unit Model

A **review unit** is the thing the progress ledger counts.

Most artifacts use item-level review units:

```text id="tntwmm"
one finding = one review unit
one violation = one review unit
one metaphor = one review unit
```

Anti-AI has mixed granularity:

```text id="o29eu2"
bulk-eligible category with legal BULK header = one adjudicated category review unit
bulk-eligible category without BULK header = each undecided item remains a pending review unit
bulk-not-permitted category = each item is its own review unit
```

This prevents blank item decisions under a valid anti-AI bulk header from looking like pending work. The act of setting the legal `BULK:` header is the human decision for that category, except where item-level overrides are supplied.

Progress reports should distinguish:

```text id="d78nnf"
item units pending
category units pending
units decided by explicit item decision
units decided by category bulk
invalid units
stale artifact state
```

### Artifact Grammar Table

| Artifact              | Producer            | Consumer                         | Review Unit                                                          | Legal Decisions                                                                                                                          | Blank Means                                         | Bulk Legal?                                                                                     | Notes                                                                                                                                        |
| --------------------- | ------------------- | -------------------------------- | -------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- | ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `reviewer-actions.md` | `compliance_report` | `compliance_fix`                 | Per violation                                                        | `FIX`, `FIX: <instruction>`, `SKIP`, `ESCALATE`                                                                                          | Pending / review evidence missing                   | No generic bulk                                                                                 | Compliance has the crispest grammar and should be the first implementation slice. `CLEAN` blocks require no action and are not review units. |
| `prose-pass.md`       | `prose_pass`        | `prose_fix`                      | Per finding                                                          | `FIX`, `FIX: <instruction>`, `SKIP`, `ESCALATE`                                                                                          | Pending for non-`KEEP` findings                     | No                                                                                              | `KEEP` recommendations are treated as `SKIP`; actionable non-`KEEP` findings require explicit per-entry annotation.                          |
| `anti-ai.md`          | `anti_ai_report`    | `anti_ai_fix`                    | Per item, except legal bulk categories count as category-level units | Per item: `FIX`, `FIX: <instruction>`, `SKIP`, `ESCALATE`; category header: `BULK: FIX[: <instruction>]` or `BULK: SKIP` where permitted | Pending unless a legal category bulk header applies | Yes, only when static grammar allows bulk and the report declares the category `BULK permitted` | Per-entry decisions override category bulk defaults. The companion must not offer bulk where the report says bulk is not permitted.          |
| `metaphors.md`        | `metaphor_identify` | `metaphor_fix`, `metaphor_apply` | Per metaphor entry                                                   | `KEEP`, `REJECT`, `FLATTEN`, `REPLACE: <image>`, `WORKSHOP`                                                                              | Pending                                             | No                                                                                              | Replace delete-as-rejection with `Decision: REJECT` so the file remains an audit record and progress is countable.                           |

### Required Format Changes

#### Compliance

Retarget `reviewer-actions.md` so each violation has a stable anchor and decision fields:

```markdown id="wk90ow"
<!-- review-id: compliance:book1:chapter02:scene03:block011:item002 -->
- MISSING (must_preserve): Promise withheld — not found in prose range
  - Decision:
  - Decision-note:
```

`compliance_fix` must consume the explicit `Decision:` field rather than scanning for positional annotations.

`CLEAN` blocks are not actionable review units. They may appear in the report for completeness, but they should not inflate pending counts.

#### Prose Pass

Retarget each finding in `prose-pass.md`:

```markdown id="n3hjd5"
<!-- review-id: prose:book1:chapter02:finding004 -->
##### [short label]

- Quote: "..."
- Problem: ...
- Why it matters: ...
- Action: `TIGHTEN`
- Decision:
- Decision-note:
```

`KEEP` findings may either be omitted from the actionable queue or emitted with `Decision: SKIP`.

Non-`KEEP` findings require explicit review evidence before `prose_fix` can apply them.

Bulk headers remain forbidden.

#### Anti-AI

Retarget `anti-ai.md` to preserve category-level bulk while making entries addressable.

Example with valid category bulk:

```markdown id="5hcm8k"
### Em Dashes
BULK: FIX: rewrite

<!-- review-id: anti-ai:book1:chapter02:scene03:emdash001 -->
- Quote: "..."

<!-- review-id: anti-ai:book1:chapter02:scene03:emdash002 -->
- Quote: "..."
- Decision: SKIP
- Decision-note: Dialogue interruption; alternatives read worse.
```

In this example:

* The `Em Dashes` category is adjudicated by the `BULK:` header.
* Blank item-level decisions inherit `BULK: FIX: rewrite`.
* The explicit `SKIP` item overrides the bulk default.
* The blank item is not pending.
* The category, not each inherited item, is the primary countable review act.

Example without valid category bulk:

```markdown id="42f1ad"
### Negative Parallelism

<!-- review-id: anti-ai:book1:chapter02:scene03:negative-parallelism001 -->
- Quote: "..."
- Decision:
- Decision-note:
```

Here, blank means pending because the category has no valid bulk decision.

Anti-AI validation requires two layers:

1. Static grammar: anti-AI supports category bulk.
2. Dynamic report declaration: the current scene/category declares whether bulk is permitted.

A `BULK:` header on a category not declared `BULK permitted` is invalid and must not satisfy review evidence.

#### Metaphors

Retarget `metaphors.md` so accepted, rejected, and unreviewed figures are distinct:

```markdown id="uyy89h"
<!-- review-id: metaphor:book1:chapter02:scene03:fig017 -->
### Fork bends like something living

- Quote: "..."
- Tenor: fork
- Vehicle: living thing
- Borrowed property: unnerving animation
- Uninvited properties: agency, hunger, intent
- Implication: ...
- Register fit: ...
- Flag: REVIEW
- Decision:
- Decision-note:
```

Legal decisions:

```text id="7s0kro"
KEEP
REJECT
FLATTEN
REPLACE: <image>
WORKSHOP
```

`metaphor_fix` should skip `KEEP` and `REJECT`, and generate variants only for `FLATTEN`, `REPLACE`, and `WORKSHOP`.

Reject-by-deletion must be removed. A rejected metaphor is still part of the audit trail.

Bare `REPLACE` must have an explicit policy. Choose one:

```text id="oyk6v8"
Preferred policy: bare REPLACE is invalid; use WORKSHOP when the human wants candidates.
```

Under the preferred policy, `REPLACE` requires a non-empty image payload:

```text id="6yrk0w"
REPLACE: broken glass
```

If the project wants to preserve the old convenience behavior, the validator must normalize bare `REPLACE` to `WORKSHOP` before `metaphor_fix` consumes it. Do not leave this behavior implicit.

### Validator / Review Evidence Gate

Add a shared parser/validator used by the companion and downstream fix/apply steps.

This is not a side tool beside the architecture. It is the existing review-evidence gate made structural.

The validator must use `agents/review-grammars.yaml` plus the current artifact contents.

It must check:

* `Reviewed-draft:` exists.
* The artifact’s reviewed draft matches the active draft unless a valid human override exists.
* Every review item has a unique `review-id`.
* Every review item has the required structured fields.
* Filled decisions use legal tokens for that artifact.
* Payload-bearing decisions include required payloads.
* Blank decisions are counted as pending unless a valid artifact-specific higher-level decision applies.
* Anti-AI bulk headers are statically supported by grammar and dynamically permitted by the current report’s eligibility declaration.
* Anti-AI per-entry decisions override category bulk defaults.
* Prose-pass bulk annotation is invalid.
* Metaphor delete-as-rejection is invalid.
* Bare metaphor `REPLACE` follows the chosen project policy.
* No duplicate IDs exist within the reviewed-draft epoch.
* The artifact can report total, pending, decided, inherited-by-bulk, skipped, rejected, escalated, invalid, and stale counts.

The fix/apply steps must run the same validator before consuming a review artifact.

### Review Companion Skill

Create a focused skill, tentatively named:

```text id="n2qm0v"
amanuensis-review
```

The skill activates when the user asks to review, annotate, triage, or continue a human-gated Amanuensis artifact.

The skill should:

1. Identify the artifact type.
2. Load `agents/review-grammars.yaml`.
3. Parse the artifact.
4. Read dynamic report declarations where applicable.
5. Run the validator.
6. Check the `Reviewed-draft:` freshness stamp.
7. Show progress counts.
8. Present pending review units as a queue.
9. Explain legal decisions for the current unit.
10. Recommend a decision when useful, without silently applying it.
11. Capture the human’s decision.
12. Write the decision into the correct field by `review-id` or category header.
13. Preserve surrounding markdown.
14. Summarize remaining work.

The skill must support pacing controls:

```text id="dp2cp2"
next
next 5
show pending
show only invalid
show only ESCALATE candidates
show only BROKEN metaphors
show category summary
go back
stop and save
summarize progress
```

Pacing controls are not decision automation. Showing five metaphors at once still requires five human decisions.

### Decision Automation Rules

Decision automation is legal only when the artifact grammar explicitly allows it or when the item requires no downstream action.

Allowed:

* Treat compliance `CLEAN` blocks as non-actionable.
* Use anti-AI `BULK:` headers only in categories declared `BULK permitted`.
* Apply per-entry overrides to anti-AI bulk defaults.
* Count a valid anti-AI `BULK:` header as the adjudication of that category.

Forbidden:

* Bulk annotate `prose-pass.md`.
* Auto-dispose metaphor entries based on `CLEAN`, `REVIEW`, or `BROKEN`.
* Auto-fix compliance violations without explicit human decision.
* Invent bulk behavior not present in the static grammar and current report declaration.
* Treat blank item-level anti-AI decisions as pending when a valid category bulk decision applies.
* Treat blank item-level anti-AI decisions as decided when no valid category bulk decision applies.

### Implementation Plan

This is a big-bang migration. The slices below describe implementation order, not compatibility phases. The final merged state should convert all four artifact families and may break existing generated artifacts.

#### Slice 0: Shared Grammar and Parser

Create the contract before migrating individual steps.

Deliverables:

* Add `agents/review-grammars.yaml`.
* Define all four artifact grammars.
* Define static vs dynamic grammar responsibilities.
* Implement parser primitives for structured markdown review items.
* Implement progress ledger model.
* Implement validator framework.
* Add fixture examples for all four artifacts.

This slice prevents the four implementations from inventing four subtly different contracts.

#### Slice 1: Compliance

Prove the core plumbing on the crispest artifact.

Deliverables:

* Add `review-id`, `Decision:`, and `Decision-note:` to `reviewer-actions.md`.
* Update `compliance_report` to emit structured review items.
* Update `compliance_fix` to consume structured decisions.
* Add validator support for compliance grammar.
* Add companion support for compliance review queues.
* Preserve existing stale-report behavior and override semantics.

This slice proves:

* Stable anchors
* Artifact-specific token validation
* Freshness checks
* Pending/decided counts
* Field-writing by ID
* Fix-step consumption of structured review evidence

#### Slice 2: Anti-AI

Prove category-level bulk using the existing anti-AI concept, but fix progress accounting.

Deliverables:

* Add `review-id`, `Decision:`, and `Decision-note:` to anti-AI entries.
* Preserve `BULK eligibility` and `BULK:` category headers.
* Treat valid bulk headers as category-level review decisions.
* Update `anti_ai_fix` to consume structured per-entry decisions and legal bulk defaults.
* Add validator support for static grammar plus dynamic report eligibility.
* Add companion support for category queues and legal bulk prompting.

This slice proves:

* Category-level review units
* Bulk eligibility validation
* Per-category defaults
* Per-entry overrides
* Mechanical-pattern review workflows
* Accurate progress accounting despite blank inherited decisions

#### Slice 3: Prose Pass

Prove selective per-entry review with no bulk.

Deliverables:

* Add `review-id`, `Decision:`, and `Decision-note:` to prose findings.
* Update `prose_fix` to consume structured decisions.
* Enforce no-bulk behavior in the validator.
* Add companion support for small, high-value finding queues.

This slice proves:

* Advisory recommendation vs. human decision
* `KEEP` / `SKIP` behavior
* Explicit review evidence for non-`KEEP` findings

#### Slice 4: Metaphors

Prove the most subjective workflow after the machinery is reliable.

Deliverables:

* Add `review-id`, `Decision:`, and `Decision-note:` to each metaphor entry.
* Replace delete-as-rejection with `Decision: REJECT`.
* Choose and enforce bare `REPLACE` policy.
* Update `metaphor_fix` to generate variants only for `FLATTEN`, `REPLACE`, and `WORKSHOP`.
* Update `metaphor_apply` to consume selected variants under the structured review contract.
* Add validator support for metaphor grammar.
* Add companion support for metaphor pacing, progress counts, and non-automated review.

This slice proves:

* Subjective human-only decision queues
* Progress ledger value
* Non-destructive rejection
* Audit preservation for every figurative decision

### Downstream Gate Changes

Existing fix/apply steps should stop relying on ad-hoc string checks.

Each consumer step should:

1. Parse the artifact with the shared parser.
2. Validate it against `agents/review-grammars.yaml`.
3. Refuse stale artifacts unless a valid override exists.
4. Refuse invalid decisions.
5. Refuse pending review units unless the grammar allows pass-through.
6. Apply only decisions legal for that consumer.

Specific required behavior:

* `compliance_fix`: blocks if any actionable compliance violation is pending.
* `prose_fix`: blocks if any non-`KEEP` finding is pending.
* `anti_ai_fix`: accepts valid category bulk decisions and per-entry overrides; blocks only on unresolved pending units.
* `metaphor_fix`: generates variants only for `FLATTEN`, `REPLACE`, and `WORKSHOP`; skips `KEEP` and `REJECT`; blocks if metaphor entries remain pending.
* `metaphor_apply`: must treat a fully reviewed file with all `KEEP` / `REJECT` decisions as valid pass-through, not “nothing to do” failure.

### Non-Goals

This milestone does not:

* Improve the quality of the report/identify passes.
* Rewrite prose directly from the review companion.
* Replace the fix/apply steps.
* Create a general-purpose markdown editor.
* Introduce JSON sidecars as the source of truth.
* Automate metaphor decisions.
* Add bulk decisions where the artifact grammar forbids them.
* Preserve compatibility with old human-only artifact formats.

### Acceptance Criteria

The milestone is complete when:

1. `agents/review-grammars.yaml` exists and is the single source of truth for review artifact grammars.
2. All four human-gated artifact families use structured markdown with embedded `review-id` anchors and explicit decision fields.
3. Static grammar and dynamic report declarations are both validated where applicable.
4. The validator can report pending, decided, inherited-by-bulk, invalid, and stale states.
5. Progress accounting is accurate for both item-level and category-level review units.
6. Fix/apply steps consume the same grammar contract as the review companion.
7. Blank decisions are always distinguishable from reviewed-and-accepted decisions at the relevant review-unit level.
8. Anti-AI category bulk decisions count as category adjudication, not as ambiguous blank item decisions.
9. Metaphor rejection is non-destructive.
10. Bare metaphor `REPLACE` behavior is explicit and enforced.
11. Prose-pass bulk annotation is rejected by the validator.
12. The review companion can walk a human through pending units and write decisions by ID or legal category header.
13. A human can stop mid-review and later resume from accurate remaining counts.
14. A fully reviewed metaphor file with all `KEEP` / `REJECT` decisions passes downstream gates.
15. The workflow preserves the audit trail of human decisions.
16. The companion never becomes the checker, fixer, or silent decider.

### Summary

This milestone turns review artifacts into addressable, countable, human-decision ledgers.

The companion exists to make the human review loop tolerable:

```text id="0l030g"
identify/report → human decision capture + progress ledger → fix/apply
```

Addressable lets the agent write to the right place.

Countable lets the human believe the task ends.

Both are required.

---

## M11 — Reverse ingestion: existing prose into Amanuensis

Ingest a finished work into Amanuensis artifacts (characters, scene-list, storyboards,
overview), chunked to fit context. Design-gated.

Done when: a single existing chapter or short story ingests into a valid project
structure that the forward pipeline's downstream steps can consume.

* [ ] M10.1 Design note (blocking): split reverse ingestion into smaller milestones.
  Candidate areas: prose chunking and source maps; character/entity extraction from
  prose; scene reconstruction; storyboard reconstruction; overview synthesis; canon
  reconciliation; reverse-to-forward bridge.
* [ ] M10.2+ Implementation tasks opened from the approved design note.

Notes: Formerly M8. This is intentionally tabled until selective execution and artifact
lineage are stable enough to support reverse-generated artifacts.

---

## Completed

### M1 — Pipeline step-list consistency

Make every step list agree with `agents/steps/` and single-source it.

Done when: all step lists match the step files; `orchestrator.md` references the
canonical list instead of duplicating it; the smoke fixture is checked against it.

- [x] M1.1 Propagate the `anti_ai_report`/`anti_ai_fix` split into
  `examples/smoke/pipeline-state.md`, the `orchestrator.md` state example, and any
  README references still showing monolithic `anti_ai`.
- [x] M1.2 Make `templates/pipeline-state.md` canonical; point `orchestrator.md` at it
  rather than re-listing; add a check that the smoke fixture's step set matches.
- [x] M1.3 Replace any other hard-coded step lists (README, `workflows.md`, adapter
  template) with references.

Notes: Also shipped a consumer-side validator — `scripts/check-pipeline-state.sh` plus
a CI workflow template (`templates/dispatcher/.github/workflows/pipeline-state-check.yml`)
installed by `install.sh` — so consuming projects' `pipeline-state.md` files are
checked against their installed Amanuensis step set on push and pull request.

---

### M2 — Drafting artifact cleanup

Delete per-scene fragments after assembly; align the step body with the OpenCode
coordinator.

Done when: a drafting run leaves `draft.md` and `notes.md` only; `sceneNN.md` /
`sceneNN-notes.md` removed; `drafting.md` frontmatter no longer lists them as durable
outputs.

- [x] M2.1 Add post-assembly deletion of `sceneNN.md` / `sceneNN-notes.md` to
  `drafting.md`, mirroring `opencode/agents/chapter-coordinator.md`.
- [x] M2.2 Reconcile `drafting.md` frontmatter: drop the per-scene fragments from
  durable outputs or mark them transient.
- [x] M2.3 Document the audit-record vs transient-fragment distinction (persist
  `reviewer-actions.md`, `metaphors.md`, `anti-ai.md`, `notes.md`; delete scene fragments).

Notes: The OpenCode coordinator (`chapter-coordinator.md`) was also pointed at the
shared persist-vs-delete rule in `chapters.md` for host parity.

---

### M3 — Bounded canon invention + capture

Replace the blanket "do not invent canon" with one bounded rule; resolve the
`orchestrator.md` TODO; add a coordinator-managed **capture agent** that records the
continuity-relevant inventions the rule permits into the right canonical files.

Done when: a single statement of the rule exists and is referenced from the step
bodies; the contradictory TODO is gone; the drafting coordinator dispatches a capture
agent that writes permitted inventions to `timeline.md` / `profile.md` / an
agent-generated `canon/` subfolder (never `knowledge/`), with annotated, edit-policy-
respecting, non-blocking writes, at parity on both hosts.

#### The rule

- [x] M3.1 Write the rule (in `canon.md` or `update-rules.md`): invent only when canon
  and plan are silent, it cannot contradict existing canon, it fits genre/register/period,
  and it is not load-bearing for reveal timing or character knowledge; otherwise record an
  open question.
- [x] M3.2 Reference it from `drafting.md`, `scene-generation.md`,
  `character-extraction.md`, `storyboarding.md`, `update-rules.md`; keep the hard
  prohibition for reveal- and knowledge-load-bearing facts.
- [x] M3.3 Resolve the `orchestrator.md` invention TODO.

#### The capture agent

A new subagent role dispatched by the drafting coordinator (and the OpenCode
`chapter-coordinator`), **not** a new pipeline step. The sandboxed scene-drafters stay
sandboxed — they only emit *recommendations*; the capture agent is the one role permitted
to write character and canon files.

- [x] M3.4 Recommendation hand-off. Define the schema a scene-drafter emits in its
  `sceneNN-notes.md` for each continuity-relevant invention: the invented fact, the target
  (`character_id`(s) or world-scope), the fact-type (`event` / `identity` / `world`), and the
  source scene+beat. Add a line to the `drafting.md` subagent prompt contract instructing
  subagents to record these (they still write nothing outside their notes/prose).
- [x] M3.5 Coordinator collection + dispatch. The coordinator gathers recommendations while
  assembling `notes.md` (drafting step 8) and dispatches the capture agent **before** the
  step-9 fragment deletion, so nothing is lost when `sceneNN-notes.md` is removed. Capture
  is gated like deletion: it runs only on a completed assembly, never on a failure/abandon
  path.
- [x] M3.6 Capture agent definition + routing. Write the agent (a host doc under `agents/`
  plus an `opencode/agents/` counterpart). Routing:
  character `event` → `characters/<id>/timeline.md`; invented stable identity color →
  `characters/<id>/profile.md`; **never `knowledge/`** (reserved for the deferred
  scene-knowledge-update step and reveal-sensitive — `characters.md:61`); non-character /
  `world` facts → a new agent-generated subfolder under `canon/` (kept distinct from
  human-authored canon); a walk-on with no folder → create a `status: stub` folder per
  `characters.md` then write. Capture only records inventions the M3.1 rule permits;
  reveal-/knowledge-load-bearing facts are still recorded as open questions, never captured.
- [x] M3.7 Write discipline. Each write is annotated with source scene+beat, draft-version
  provenance (the M4.3 stamp — "which draft did this come from"), and an
  `invented, unreviewed` marker; respects the target file's `edit_policy` (no silent write
  to a locked / propose-only file — emit a proposal / log instead); and is non-blocking —
  a capture failure never blocks draft completion, it is logged in `notes.md`. Captured
  writes ride drafting's existing `review_required: true` gate.
- [x] M3.8 Host parity. Mirror the coordinator dispatch and the capture agent across the
  `.claude` drafting coordinator (`agents/steps/drafting.md`) and
  `opencode/agents/chapter-coordinator.md`.

Notes: knowledge/ is deliberately out of bounds for capture — it stays the sole province of
the deferred scene-knowledge-update step, which protects reveal timing. M3.7's provenance
annotation depends on M4.3's per-draft-version stamp. The agent-generated canon subfolder was
named `canon/generated/` (Sprint 8 Open decision 1); capture annotates source scene + beat +
attempt now and folds in the M4.3 draft-version stamp when M4 lands.

---

### M4 — Versioned draft naming

Decouple prose-bearing draft filenames from the producing step so prose-chain reordering
is a `pipeline-state.md`-only edit. Prerequisite for M5 and M7.

Done when: prose-advancing steps read `<latest-draft>` and write the next version; report
steps read `<latest-draft>` and do not increment; provenance is recorded; side-artifacts
keep their step names; the report→fix adjacency invariant is documented.

- [x] M4.1 Define `<latest-draft>` resolution (highest-numbered `draft-vNN.md` in the
  attempt), parallel to `<latest-attempt>`. Drafting produces `draft-v01.md`.
- [x] M4.2 Convert prose-advancing steps (`drafting`, `compliance_fix`,
  `metaphor_apply`, `line_pass`, `anti_ai_fix`) to write `<next-draft>`; convert prose-reading
  steps (`compliance_report`, `prose_pass`, `metaphor_identify`, `metaphor_fix`,
  `anti_ai_report`) to read `<latest-draft>`.
- [x] M4.3 Add provenance to each draft version (frontmatter stamp `produced_by` / `reads`,
  or an attempt-level manifest). This is also the "which draft did this come from" stamp that
  M3.7's capture annotations reference — define it so a captured invention can name its source
  draft version.
- [x] M4.4 Document the report→fix adjacency invariant: no draft increment between a report
  and its paired fix.
- [x] M4.5 Sweep the rename through docs that hard-code `draft.md` (`chapters.md`,
  `project-layouts.md`, schema examples) and the canonical state list.

Notes: side-artifacts (`reviewer-actions.md`, `metaphors.md`, `anti-ai.md`,
`prose-pass.md`) stay step-named; only prose-bearing files are versioned. Sprint 9 landed
provenance as an attempt-level `draft-manifest.md` (not per-draft frontmatter) because
drafting's prose-only invariant precludes in-file YAML in the draft files themselves; each
prose-advancing step appends a per-version entry to the manifest. `prose_fix` remains deferred
to M5; M4 only makes the versioned naming model ready for it.

---

### M5 — Prose fix apply step

Close the prose-apply orphan: `prose_pass` recommendations get applied into the versioned
draft the metaphor stage reads. Depends on M4.

Done when: `prose_fix` reads annotated `prose-pass.md` + `<latest-draft>` and writes the
next draft version; `prose_pass` output carries an annotation grammar; the metaphor stage
consumes the prose-applied draft.

- [x] M5.1 Add `FIX` / `FIX: <instruction>` / `SKIP` / `ESCALATE` per-entry annotation
  grammar to `prose-pass.md`, keyed off the existing KEEP/TIGHTEN/FLATTEN/REWRITE labels;
  `KEEP` needs no annotation and is treated as `SKIP`. No bulk headers (Sprint 10 locked
  decision — `prose_pass` is deliberately selective at 5-10 findings, so bulk-annotation
  surface would go unused).
- [x] M5.2 Record the apply strategy in `agents/steps/prose-fix.md`: surgical per-entry
  (Sprint 10 locked decision). Locate quote → apply local edit → copy rest verbatim,
  matching `compliance_fix` / `anti_ai_fix` / `metaphor_apply`. Bare `FIX` on `REWRITE` is
  generative — the fixer produces a new sentence/paragraph in-voice using `voice.md` as
  system message and the target paragraph plus one paragraph either side as read-only
  context. Chunked-like-`line_pass` was considered and rejected: `prose_pass` is
  deliberately selective, so a whole-chapter chunk pass would reprocess mostly untouched
  prose.
- [x] M5.3 Write `agents/steps/prose-fix.md` (inputs: annotated `prose-pass.md`,
  `<latest-draft>`, `voice.md`; outputs: `<next-draft>` + appended `prose-pass.md` apply
  log + appended `draft-manifest.md` entry). `review_required: false`. Follows the
  report→fix adjacency invariant via the `Reviewed-draft:` stamp `prose_pass` already
  writes.
- [x] M5.4 Insert `prose_fix` after `prose_pass` in the canonical step list
  (`templates/pipeline-state.md` and `examples/smoke/pipeline-state.md`); the pipeline
  check (`scripts/check-pipeline-state.sh`) must pass.

Notes: with M4 done, the metaphor steps already read `<latest-draft>`, so no input
rewiring is needed. Sprint 10 retires the "Manual prose-edit handoff" procedure in
`agents/chapters.md` and the "advisory only until M5" language in `prose-pass.md` /
`AGENTS.md`; `prose_pass → prose_fix` joins the report→fix invariant list in
`agents/orchestrator.md`. Storyboards and canon are deliberately *not* read by `prose_fix`
(matches `metaphor_apply` / `anti_ai_fix`) — `prose_pass` already reviewed the prose
against the storyboard and voice, and `prose_fix` applies the reviewed judgments without
re-evaluating them.

---

### M6 — Storyboard reader-reveal coverage

Storyboards declare what the reader must understand, not only what is concealed; an
advisory review pass flags under-communication. Order-independent of M4/M5.

Done when: the schema has a reader-takeaway field; `storyboarding` populates it;
`storyboard_review` flags beats whose takeaway is unsupported or whose reveals lack prior
setup; it sits between storyboarding and drafting.

- [x] M6.1 Add a reader-takeaway field to `storyboard-schema.md` (distinct from
  `concealment_from_reader` and `must_preserve`), held to the spec-not-prose discipline.
- [x] M6.2 Update `storyboarding.md` to populate it; make an empty field a default-to-fill
  anti-pattern.
- [x] M6.3 Write `agents/steps/storyboard-review.md` (advisory, report-only): check each
  beat's takeaway is carried and that dependent beats have prior setup.
- [x] M6.4 Insert `storyboard_review` between `storyboarding` and `drafting` in the
  canonical list.

Notes: a `storyboard_review_fix` apply step and the cross-chapter reveals ledger are
deferred. Sprint 11 plans M6 (see SPRINT.md). Locked there: the new field is
`reader_takeaway`, a default-to-fill markdown section (not frontmatter) that states what
the *reader* must understand by a beat's end — distinct from `concealment_from_reader` (its
inverse) and `knowledge_delta` (character knowledge). `storyboard_review` is advisory-only —
a report with no annotation grammar and no paired fix step (the deferred `storyboard_review_fix`
would add the grammar later, mirroring how `prose_pass`'s grammar landed with `prose_fix`); it
runs before drafting so it carries no `Reviewed-draft:` stamp and sits outside the report→fix
invariant. It runs three checks: takeaway-supported, reveal-has-prior-setup (within-chapter
only), and a takeaway/concealment contradiction guard. Reveal dependencies are inferred from
`beat_type`/`reader_takeaway`/`concealment_from_reader` plus `scene-list.md` ordering — no new
dependency field is added.

---

### M7 — Selective step execution

Replace the linear `next-step` cursor model with explicit, selective step invocation.
The default pipeline remains a recommended recipe, but correctness is governed by
artifact preconditions, not by strict sequence position.

Done when: a human can invoke a specific step by `step_id`; the dispatcher validates
that the step's declared inputs exist and are usable; locally ordered pairs such as
`compliance_report -> compliance_fix` are enforced by artifact freshness rules rather
than by global pipeline position; `pipeline-state.md` no longer requires a single
`[>]` cursor to define what may run next; both hosts expose the same model.

- [x] M7.1 Design note: define the selective execution model. Terms to settle:
  `runnable`, `blocked`, `stale`, `superseded`, `active`, `recommended next`,
  and `explicit override`.

- [x] M7.2 Reframe `pipeline-state.md` from cursor state into recipe/status state.
  Remove the requirement that exactly one `[>]` marker controls execution. Preserve
  the default step order as the recommended happy path, not as the only legal path.

- [x] M7.3 Expand the step workflow contract so each step declares machine-readable
  preconditions in addition to descriptive `inputs` / `outputs`. At minimum, distinguish:
  required files, optional files, prose-draft inputs, side-artifact inputs, and
  human-review-sensitive inputs.

- [x] M7.4 Implement explicit step invocation in the dispatcher:
  `run_step <step_id>` or host-equivalent. The dispatcher resolves the requested
  workflow file, checks preconditions, then follows that step body in the same session.

- [x] M7.5 Keep a convenience command for the recommended path:
  `next_recommended_step` or host-equivalent. This reads the recipe/status file and
  chooses the next incomplete recommended step, but it is layered on top of selective
  execution rather than being the core control model.

- [x] M7.6 Generalize local ordering constraints. Report/fix and identify/apply pairs
  must be enforced by artifact stamps such as `Reviewed-draft:`, not by global adjacency
  in the step list. A fix/apply step may run only when its paired report artifact was
  produced against the current usable draft, unless the human explicitly overrides.

- [x] M7.7 Update `orchestrator.md` to remove forward/back/redo language. The
  orchestrator should describe Amanuensis as running selected transformations against
  explicit artifacts, with judgment living in the human and the step bodies.

- [x] M7.8 Host parity: expose the same selective invocation model in Claude Code and
  OpenCode. The names do not have to be identical, but the behavior and safety checks
  must match.

- [x] M7.9 Smoke coverage: verify that the default recipe still runs in order; verify
  that a human can rerun a completed report step; verify that a fix step blocks on a
  stale report; verify that a non-dependent step can run out of recipe order when its
  inputs are valid.

Notes: This milestone deliberately does not change draft version lineage. For now,
`<latest-draft>` may remain the highest-numbered `draft-vNN.md` as defined by M4.
Non-destructive reruns, active draft heads, and superseded draft branches are deferred
to M8. The purpose of M7 is to decouple dispatcher control from strict linear cursor
movement without rewriting the draft manifest model in the same sprint.

Sprint 12 plans M7 (see SPRINT.md). Locked there: the state grammar becomes `[x]`/`[ ]`
only, with `[>]` retired but tolerated as a legacy synonym of `[ ]` (no migration, no
`check-pipeline-state.sh` change); recommended next = first non-`[x]` step. The command
surface adds `run-step` on both hosts and keeps `next-step` as a convenience layer over
the same procedure. The M7.1 design note lands inside `agents/orchestrator.md` as an
Execution model section (single-sourcing; a separate design doc was rejected).
Preconditions are an additive frontmatter block (`path`/`kind: source|prose_draft|side_artifact`/
`required`/`review_sensitive`); the dispatcher checks required-file existence only —
freshness and review checks stay in step bodies until M9.6. The adjacency invariant is
renamed the report→fix freshness invariant with mechanics unchanged.

---

### M8 — Active draft lineage

Replace highest-numbered draft resolution with an explicit active draft head in
`draft-manifest.md`, so arbitrary reruns can create new draft versions without deleting
or archiving prior work.

Done when: `<latest-draft>` resolves to the manifest's active head rather than the
highest-numbered `draft-vNN.md`; rerunning a prose-advancing step can read an earlier
draft and produce a new active draft; superseded downstream drafts remain on disk but
are no longer considered active; stale side artifacts can identify which draft lineage
they belong to.

- [x] M8.1 Design note: define active draft lineage. Terms to settle:
  `active_head`, `reads`, `produced_by`, `supersedes`, `superseded_by`,
  `lineage`, and `abandoned`.

- [x] M8.2 Update `draft-manifest.md` schema so each prose-bearing draft version records:
  producing step, input draft(s), side artifacts consumed, timestamp, review gate if any,
  and whether it is the active head.

- [x] M8.3 Change `<latest-draft>` resolution from highest-numbered draft to active
  manifest head. Keep draft filenames monotonic: reruns create the next `draft-vNN.md`
  rather than overwriting or reusing old numbers.

- [x] M8.4 Define non-destructive rerun semantics. If a human reruns a prose-advancing
  step from an earlier draft, the new output becomes the active head and any previously
  active downstream drafts are marked superseded in the manifest, not deleted.

- [x] M8.5 Update all prose-advancing steps to append manifest entries that preserve
  lineage. Steps must not infer active state from filenames alone.

- [x] M8.6 Update all prose-reading/report steps to resolve the active head through the
  manifest before reading `<latest-draft>`.

- [x] M8.7 Smoke coverage: create a linear draft chain, rerun a prose-advancing step from
  an earlier draft, verify the new draft becomes active, verify old downstream drafts
  remain on disk but are superseded, and verify report steps read the new active head.

Notes: This milestone replaces the archive-on-redo idea from the old M7. Amanuensis
does not move backward. It creates a new version from selected inputs and records which
draft lineage is now active.

Sprint 13 plans M8 (see SPRINT.md). Locked there: the active head is a top-of-manifest
`Active-head: draft-vNN.md` pointer (parallel to the `Reviewed-draft:` stamp), and
`<latest-draft>` resolves to it — falling back to the highest-numbered draft when no
pointer exists, so existing projects need no migration. `<latest-draft>` (the read
pointer) and `<next-draft>` (highest existing draft number + 1, kept monotonic) decouple.
Branch selection is an owner decision: a read-from argument on `run-step`
(`run-step <step_id> from <draft-vNN>`) that overrides which draft `<latest-draft>`
resolves to for that one invocation; `next-step` never branches. On a branch (read-from ≠
active head) the prose-advancing step writes `<next-draft>`, repoints `Active-head`, and
stamps each displaced active-lineage draft `superseded_by: <next-draft>`; abandonment is
derived from that stamp, not a separate field, and a linear advance supersedes nothing.
The M8.1 design note and the lineage/supersession algorithm land in
`agents/project-layouts.md` (the doc that owns the manifest); `orchestrator.md`'s
Execution-model terms are updated to match and cross-reference it. The report→fix
freshness invariant keeps its filename-comparison mechanics unchanged — with active-head
resolution, a report stamped against an abandoned draft is correctly stale, and stamp
filename plus the manifest's `read_from` chain identifies which lineage a stale artifact
belongs to.

---

## M9 — Stale artifacts and review gates

Make arbitrary step execution safe by tracking whether side artifacts are fresh,
stale, reviewed, pending review, superseded, or explicitly overridden.

Done when: side artifacts generated from prose identify the draft they reviewed;
fix/apply steps refuse stale artifacts by default; review-required artifacts carry
an explicit review status or equivalent human-acknowledgment marker; the dispatcher
and step bodies consistently block, warn, or proceed according to declared rules.

* [x] M9.1 Design note: define side-artifact state. Terms to settle:
  `fresh`, `stale`, `review_pending`, `reviewed`, `override`, `discarded`,
  and `regenerated`.

* [x] M9.2 Standardize freshness stamps for prose-derived side artifacts. Existing
  `Reviewed-draft:` behavior becomes the common pattern for reports, annotations,
  metaphor findings, anti-AI findings, and similar artifacts.

* [x] M9.3 Standardize review markers for artifacts produced by `review_required: true`
  steps. Decide whether review state lives in the artifact itself, in a manifest, or
  in the recipe/status file.

* [x] M9.4 Update fix/apply steps to check both freshness and review state before
  consuming side artifacts. On mismatch, append a clear blocker to `open-questions.md`
  and exit without modifying prose.

* [x] M9.5 Define explicit override behavior. Overrides must be human-visible,
  source-specific, and recorded in the relevant artifact or manifest. No stale apply
  should happen silently.

* [ ] M9.6 Update the dispatcher to surface stale/review blockers before loading the
  requested step body when the precondition is machine-checkable. **Deferred out of
  Sprint 14** to a follow-on: the checks stay in the step bodies until the state model
  proves out (see the Sprint-14 note below and the Deferred list).

* [x] M9.7 Smoke coverage: verify stale report detection, reviewed-artifact detection,
  pending-review blocking or warning behavior, regeneration of a stale report against
  the active draft, and explicit override recording.

Notes: M9 generalizes the report→fix adjacency invariant into an artifact-freshness
model. The old adjacency rule remains valid as a special case, but the framework no
longer depends on global step order to protect fix/apply steps.

Sprint 14 plans M9 (see SPRINT.md). Locked there: staleness is a **derived predicate**
(`Reviewed-draft:` stamp = manifest `Active-head:` → fresh, else stale), computed by the
consuming step at step start and never stored or swept — no update walks every artifact
(the owner decision; it applies M8's derived-`abandoned` precedent to the whole model).
Review is **surfaced, not enforced**: `review_sensitive`/`review_gate` remain the
declaration, annotation is the review evidence for the four reports, consumption emits a
non-blocking notice, and the only hard review block is the pre-existing unannotated-report
path. The design note lands in `agents/orchestrator.md` (which owns the freshness invariant
and execution-model vocabulary), generalizing the report→fix invariant into a single
**Artifact state** section that keeps the invariant verbatim as its named special case and
adds the terms `fresh`/`review_pending`/`reviewed`/`override`/`discarded`/`regenerated`.
No new frontmatter or manifest field: override is recorded in the consuming step's apply
log; `discarded`/`regenerated` name behavior that already ships. The one new step-body
behavior is an explicit recorded-override branch in the four fix/apply steps. M9.6
(dispatcher lift) is deferred so the model proves out in step bodies first; Sprint 14
delivers M9.1–M9.5 and M9.7.

---

## Deferred

- dispatcher-level staleness/review lift (M9.6) — surface stale/review blockers before
  loading the step body; deferred out of Sprint 14 until the step-body state model proves out
- storyboard_review_fix apply step (after M6 proves out)
- story-level reveals ledger with buildup (couples to continuity review; matters for book/series)
- continuity review step
- scene knowledge update step
- post-chapter update step
- chapter selection for book/series ("which chapter is current?")
- pre-writing pipeline (vague idea -> plan)
- multi-host beyond Claude Code / OpenCode
- per-attempt comparison tooling (revisit after M7's archive model)
- multi-work concurrency
