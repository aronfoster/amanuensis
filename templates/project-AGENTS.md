# Project Agent Guide Example

This is an example adapter for a story repository that consumes Amanuensis as a submodule.

Use the reusable guidance in `amanuensis/agents/` for planning, drafting, and review workflows.

## Project Paths

- `canon/` — project-level world truth
- `characters/` — character profiles, timelines, relationships, and knowledge state
- `locations/` — location references
- `plot/` — book, chapter, storyboard, draft, and aftermath files
- `amanuensis/` — reusable workflow tooling

## Where To Look

- `amanuensis/agents/update-rules.md` — start here for safety rules.
- `amanuensis/agents/workflows.md` — use when choosing workflow order.
- `amanuensis/agents/canon.md` — use when validating or changing world-level truths.
- `amanuensis/agents/books.md` — use when creating or revising book-level files.
- `amanuensis/agents/chapters.md` — use when creating or editing chapter files.
- `amanuensis/agents/characters.md` — use when updating character state.
- `amanuensis/agents/steps/character-extraction.md` — use when bootstrapping character folders from the story plan and canon.
- `amanuensis/agents/steps/scene-generation.md` — use when producing a chapter's `scene-list.md` from the plan, characters, and canon.
- `amanuensis/agents/steps/storyboarding.md` — use when creating storyboard blocks.
- `amanuensis/agents/steps/drafting.md` — use when drafting prose from storyboards (chapter coordinator that dispatches per-scene subagents).

## Project Rules

Add project-specific canon, voice, naming, or reveal-timing rules here. Keep story facts in the story repository, not in Amanuensis.
