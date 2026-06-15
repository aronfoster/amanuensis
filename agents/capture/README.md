# Capture Subsystem

The capture role records the continuity-relevant inventions Rule 1 permits into the right canonical files, so a permitted invention stops being a hidden guess and becomes reviewable truth.

---

## Role

**Subagent prompt contract** (not a step; lives in this directory and is dispatched by the drafting coordinator):

- `capture-agent.md` — writes each permitted invention recommendation to its destination: a character `event` to `characters/<id>/timeline.md`, an invented stable identity color to `characters/<id>/profile.md`, or a non-character `world` fact to the agent-generated `canon/generated/` subfolder. It never writes `knowledge/`, respects each target's `edit_policy`, annotates every write with provenance (scene + beat + attempt) and an `invented, unreviewed` marker, and is non-blocking on failure.

There is no capture *step*. Capture is dispatched by `agents/steps/drafting.md` inside the existing `drafting` step, the same way the metaphor subagents are dispatched inside `metaphor_fix`. **It does not appear in `templates/pipeline-state.md`.**

---

## Who dispatches it

The drafting coordinator (`agents/steps/drafting.md` for the Claude host; `opencode/agents/chapter-coordinator.md` for the OpenCode host). The sandboxed scene-drafters cannot write canon or character files — they only *recommend* inventions in their `sceneNN-notes.md`. During notes assembly, and before the per-scene fragments are deleted, the coordinator collects those recommendations and dispatches one capture agent with them plus the attempt path. Dispatch is gated on a completed assembly: on any failure/abandon path the coordinator does not dispatch capture and records the blocker in `notes.md`.

---

## Why it is a separate role

The scene-drafters are sandboxed (`agents/steps/drafting.md`): they may read only the inputs handed to them and write only their own scene and notes files, and are barred from canon and character files. Capture therefore cannot be folded into the scene-drafter role — it is a separate, non-sandboxed subagent role the coordinator dispatches, the one role permitted to write character and canon files during drafting.

---

## Boundaries

- **Never `knowledge/`.** Knowledge files are written only by the deferred scene-knowledge-update step (`agents/characters.md:61`); this protects reveal timing.
- **Only Rule 1 inventions.** Reveal-/knowledge-load-bearing facts are recorded as open questions, never captured.
- **Visibly distinct generated canon.** World inventions land in `canon/generated/`, separate from human-authored `canon/` files, with distinguishing frontmatter.
- **Annotated, edit-policy-respecting, non-blocking.** Every write is traceable and marked `invented, unreviewed`; locked/propose-only targets become `notes.md` proposals; a capture failure never blocks `draft.md`. Captured writes ride drafting's `review_required: true` gate.
