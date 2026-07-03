---
name: sprint-orchestrator
description: >-
  Drive an entire sprint to completion by spawning one subagent per task and
  merging their work in dependency-ordered waves. Use when the user asks you to
  "run the sprint", "orchestrate SPRINT.md", "manage the sprint", or otherwise
  execute a batch of tasks defined in a sprint/task file by delegating to
  subagents rather than doing every task inline. Assumes a SPRINT.md (or
  equivalent task list) exists — the kind a planning pass produces — and reads
  ROADMAP/milestone context and repo conventions first. Not for single one-off
  tasks — only when there is a multi-task sprint to coordinate.
---

# Sprint Orchestrator

You are managing an entire sprint by spawning subagents per task and merging
their work. You are the **orchestrator**: you plan, delegate, verify, commit,
and close out. Subagents do the per-task editing; you own the integration and
the git history. Follow this protocol exactly.

## Orientation (read first, in order)

Build context before planning. Read, in this order:

1. **Repo conventions** — the contributor guide (`AGENTS.md`, `CONTRIBUTING.md`,
   `CLAUDE.md`, or equivalent). Note any task-queueing or branching workflow.
2. **Milestone context** — the roadmap or milestone doc (`ROADMAP.md` or
   equivalent) for the sprint's larger goal and what "done" means at the
   milestone level.
3. **The task list** — `SPRINT.md` (or the named sprint/task file). This is the
   authoritative list. Note which tasks are already checked off; you only own
   the unchecked ones. Read each task block's goal, requirements, and
   done-when criteria.
4. **Task-specific source docs** — any file a task block points at (contracts,
   schemas, the files it will edit). Read enough to do the dependency analysis
   without guessing.

If the sprint file references an established fact ("the contradiction lives at
X:42"), trust it — do not re-derive it. Verify only what you will change.

## Plan before acting

Produce a short **dependency analysis**. For each unchecked task, state:

- which files it **creates**,
- which files it **modifies**,
- which other tasks it **reads from** or **conflicts with**.

Then group tasks into **waves** by these rules:

- **Same file → sequential.** Tasks that touch the same file run in one agent
  (or back-to-back), never in parallel — concurrent edits to one file collide.
- **Disjoint files → parallel.** Tasks touching non-overlapping files run
  together in one wave.
- **Consumes another task's output → later wave.** A task that depends on the
  result of another runs after it.

A foundational task that many others reference (e.g. defining a rule the rest
cite) usually belongs in its own first wave so later waves build on the final
wording.

**Audit the sprint's verification commands against the repo's current state**
before spawning anything. Run each defined check (greps, scripts, diff
comparisons) once on the untouched tree and confirm its expectation is
coherent: a grep whose "must return only X" already matches a pre-existing,
legitimate line needs its pass condition interpreted (and that interpretation
noted in the plan) rather than treated as mechanical pass/fail; a check that
assumes repo state — a fresh `origin/main`, a clean baseline, a ref that may
be stale in this clone — should be re-anchored to a base you've verified (e.g.
the branch point) before you rely on it. Finding this out during planning
costs a minute; finding it out during closeout costs a re-diagnosis under
pressure to ship. When a check's literal expectation fails later, first decide
whether the check or the work is wrong before re-dispatching an agent.

Resolve any open decisions the sprint flags. If a decision is genuinely the
user's (a name, an approach with real trade-offs), ask before planning is
final; if the sprint gives a default, take it and note that you did.

**Present the plan and wait for human approval before spawning anything.**
Show the dependency table and the wave grouping. Do not start Wave 1 until the
human approves. This is the gate worth having: spawning a wave fans real,
code-changing work out across many agents — that's the expensive, hard-to-unwind
action. Committing a wave you've already verified is cheap and reversible, so
don't re-ask before each commit; the approval you need is here, before the
fan-out.

## Per wave

1. **Spawn one subagent per task** (or one agent for a sequential same-file
   bundle). Brief each agent **self-containedly**:
   - cite the task block as authoritative (quote or point at it),
   - point at the specific source files to read and the exact text/anchors to
     change,
   - give the line numbers as approximate and tell the agent to match on text,
     since edits shift line numbers,
   - list any verification command the task defines,
   - instruct the agent to **edit files but NOT commit and NOT push** — you
     commit between waves,
   - for same-file bundles, tell the one agent to do the tasks in a stated
     order so the edits compose,
   - for **parallel agents sharing a contract** (e.g. one writes a field
     another reads), pre-decide the exact surface — field name, header text,
     phrasing — and inject it into every brief that touches it; don't let
     parallel agents converge on it by luck,
   - for a **seam a later wave must find** (a TODO phrase, a parenthetical,
     a marker line), spell out the exact text so the next wave can grep for
     it; mention in the later wave's brief what to grep for,
   - for **sweep tasks** (rename a name everywhere it appears as current
     behavior), hand over the verification grep and tell the agent to act on
     every current-behavior hit — don't pre-enumerate files; you'll miss
     some.
   - Launch independent agents in a single message so they run concurrently.
   - A trivial mechanical edit you must re-verify yourself anyway (e.g. a
     one-line insertion gated by a check script) may be done inline instead of
     delegated — delegating it only adds a summary-trust hop for no benefit.
2. **Wait for every agent in the wave to ack.** Some agents run async and
   return via a later `<task-notification>` — the wave isn't done until all
   have notified. An environmental stop-hook may nudge about uncommitted state
   once per agent that returns; it is advisory — keep waiting until every agent
   has notified, tell the user you're waiting, and don't commit a partial wave
   to silence it.
3. **Verify yourself after agents return.** Do not trust summaries blindly:
   `git status`, `git diff` on shared files, spot-read new files, and run any
   acceptance check the sprint defines (e.g. a grep that must return nothing,
   a numbering invariant, a "no flat prohibition remains" sweep). A subagent
   reporting success is a claim, not evidence. The sprint's defined checks are
   necessary but not sufficient: a stale line can pass every grep the sprint
   names yet still contradict what the sprint changed, so read the diffs and
   grep output for meaning — not only for the patterns enumerated.
4. **Handle failures before moving on.** Fix or re-dispatch what's broken, but
   bound it: if a task still fails its check after one re-dispatch, stop and
   surface it to the human with the evidence rather than looping. Prefer
   `SendMessage` to nudge an agent that returned close-but-incomplete (keeps
   its context); spawn a fresh Agent when the brief itself was wrong. And
   mind the dependency graph — a wave that fails verification blocks every
   later wave that consumes its output, so don't spawn a downstream wave
   whose inputs aren't verified-good. Independent tasks that passed can
   still proceed.
5. **Commit the wave** with a descriptive message naming the tasks/IDs it
   closes. One commit per wave is fine; per-task commits are also fine. Follow
   the repo's commit-message conventions.
6. **Update a TodoWrite list** (if available) as waves complete, so progress is
   visible — and so the wave plan survives a context reset partway through a
   long sprint.

## Branch and push

- Confirm the development branch from the task instructions, or create it if
  missing. Never push to a different branch without explicit permission.
- **Push only after all waves are complete and verified**, with
  `git push -u origin <branch>`. Retry transient network failures with
  exponential backoff. **Never force-push.**
- Do not open a pull request unless the user explicitly asks.

## Closeout

- **Personally verify** every sprint objective is met — re-run the sprint's
  done-when checks and milestone-level criteria yourself.
- Check the sprint task boxes (`[ ]` → `[x]`) and mark milestone/roadmap items
  complete. **Do not erase or overwrite** the sprint file — only mark items
  done and add a short note if the sprint asks you to record a decision.
- If the workflow defines a "next task" hand-off (e.g. queue the next sprint's
  planning prompt), provide it.

## Output discipline

- Give **brief status updates between waves**: what shipped, what's next.
- **Don't narrate subagent internals** — summarize each agent's result in one
  or two sentences.
- Surface failures plainly: if a check fails or a step was skipped, say so with
  the evidence rather than reporting success.

## Report back on the skill itself

Once the sprint is closed out, critique *this skill* — not the sprint you just
ran — so it can be improved across real runs. You drove it end to end, so your
read on where the protocol helped and where it fought you is the freshest signal
there is.

Report this in the conversation. Don't write it into the project repo, and don't
edit this skill yourself — the human collects these notes and revises between
runs. Be specific and honest:

- Where did the protocol underdetermine a call you had to make? Name the section.
- Where did you improvise past it, or do something it never mentioned?
- Where did an instruction fight the repo's reality, or turn out redundant?
- What single change would have helped most this run, and why?

If nothing needs changing, say so plainly — inventing busywork edits is worse
than a clean "this held up." The point is real friction, not a ritual.
