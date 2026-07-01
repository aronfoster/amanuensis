---
name: pm-plan
description: >-
  PM/planning loop: turn a feature, milestone, or open-ended "how should we
  approach this" into a grounded, decided, recorded plan. Use when scoping a
  sprint, refining a roadmap, or making design/scoping decisions before
  implementing — even when the user never says "plan", and especially when the
  request has open boundaries the user should decide. Records decisions into the
  project's planning docs (typically ROADMAP.md + SPRINT.md) and commits them to
  the working branch; the deliverable is a SPRINT.md a separate implementation
  agent can execute. Stops at the recorded plan; writes no implementation code.
  Arguments refine this planning run — they don't replace it.
---

# Planning / PM loop

Turn a request with open boundaries into decisions that are grounded in the
codebase, made by the user where they should be, and recorded in the project's
planning docs. The end product is a SPRINT.md a downstream agent can pick up and
deliver without having seen the planning conversation. This is a planning skill —
it stops at the recorded plan, it does not implement.

## 1. Ground before asking

- Read the relevant code and docs first; find the real constraints, invariants,
  and existing conventions.
- Cite specific files and lines (`path:line`) when framing a question or plan.
  Never ask what the codebase already answers; if you must inspect to act, inspect.
- Grounding and questioning interleave — they aren't strict phases. An answer to
  one fork often opens another that needs fresh grounding. Loop back and inspect
  again rather than guessing to keep the pipeline tidy.

## 2. Surface only the genuine forks

- Use AskUserQuestion only for decisions that are the user's: ones you can't settle
  from the request, the code, or a sensible default.
- Recommended option first, labeled "(Recommended)". Ground each option in a real
  trade-off. Mark risky options "rejected unless you want it" with the reason.
- Recommend, don't enumerate. Lock silently when ≥3 sibling files already do it
  the same way; ask when repo precedent points two ways or none.

## 3. Record decisions into the project's planning docs

- This project keeps two planning docs: ROADMAP.md holds the high-level direction,
  SPRINT.md, rewritten each sprint, holds exactly what that sprint must deliver. Read both, and match
  the format and tone already inside them — checklists, headings, status markers.
  You're appending to a living document, not founding a new one; a foreign format
  reads as noise and invites drift. If a project doesn't keep these files yet,
  create them in this same two-altitude shape.
- Update the right item; add cross-references between dependent items. Reference a
  rule's single source; don't restate it in many places.
- Record the *why*, not just the verdict. Each locked decision carries a one-line
  rationale and, where it mattered, the rejected alternative. A bare conclusion
  rots: the next reader re-litigates it, and if downstream steps are separate agent
  runs reading these docs cold, they'll happily reopen a fork you already closed.
- Update BOTH altitudes. A ROADMAP.md entry with no SPRINT.md breakdown is a
  decision no one can execute; a SPRINT.md detail not reflected in ROADMAP.md
  silently drifts from the plan of record. Keep the roadmap checkbox and the sprint
  breakdown in sync.

## 4. The SPRINT.md breakdown

This is the deliverable. A separate implementation agent will execute SPRINT.md
with no access to the planning conversation — so it has to stand on its own. Mirror
the structure already in the repo's SPRINT.md; the shape below is the fallback when
there isn't one yet:

- Intro: what the sprint changes, one paragraph.
- Background — what is and isn't wrong today: established by inspection, with
  file:line cites, so tasks don't re-derive it.
- Definition of done: enumerated and checkable.
- Conventions adopted: decisions locked (each with its one-line why, per §3) so
  tasks don't rediscover them.
- Tasks: each with Goal / Requirements / Done-when, sized for one owner and
  grouped by file-touch so a dependency-ordered wave plan is possible.
- Out of scope: what this does not touch, and where that work lives instead.

Write for a reader who has only this file. If a fact, a cite, or a decision is
needed to do a task correctly, it lives *in* SPRINT.md — not in your head and not
in the chat history the next agent will never see.

## 5. Close out

- Commit with a clear message; push to the working branch.
- The working branch is the right place to land a plan: the commit is cheap and
  reversible, and the human gate lives downstream at the merge/MR — which the user
  owns. So don't insert your own "OK to commit?" prompt before recording; that gate
  already exists. But never push to a shared or protected branch (main, release,
  someone else's branch) without explicit permission — that *is* surprising.
- Flag leftover open items as open questions — don't invent answers to fill them.
- Respect existing invariants; if a decision would violate one, surface it instead
  of proceeding.

## 6. Report back on the skill itself

After the plan is recorded, take a moment to critique *this skill* — not the
project plan — so it can be improved across real runs. You just used it end to end,
so your read on where it helped and where it fought you is the freshest signal
there is.

Report this in the conversation. Don't write it into the project repo, and don't
edit this skill yourself — the human collects these notes and revises between runs.
Be specific and honest:

- Where did the skill underdetermine a choice you had to make? Name the section.
- Where did you improvise past what it said, or do something it never mentioned?
- Where did an instruction fight the repo's reality, or turn out redundant?
- What single change would have helped most this run, and why?

If nothing needs changing, say so plainly — inventing busywork edits is worse than
a clean "this held up." The point is real friction, not a ritual.
