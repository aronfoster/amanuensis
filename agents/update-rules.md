# Update Rules

These rules exist to keep agentic edits safe.

## Rule 1: do not silently invent canon
An agent may invent a missing detail only when **all four** of these hold:

1. canon and the plan are silent on it;
2. it cannot contradict any existing canon;
3. it fits the work's genre, register, and period; and
4. it is **not** load-bearing for reveal timing or character knowledge.

When all four hold, the agent may invent the detail rather than halting (the
breakfast-order case: if canon does not say what a character ordered, supply
something that fits — never pop tarts in a medieval fantasy). When any one fails —
the detail is settled in canon, would conflict with it, breaks register, or is
load-bearing — the agent does **not** invent it; it records an open question instead.

The reveal-/knowledge-load-bearing prohibition is a hard line: nothing a character
knows, suspects, or believes, and no fact that controls reveal timing, may be
invented under this rule. Those are always open questions.

"Silently" is what this rule forbids. Permitted invention must be *captured, not
hidden*: it is recorded into the appropriate canonical files so it stops being a
guess and becomes reviewable truth (the capture mechanism is defined in the drafting
workflow). An invention that no one can see or review is a silent invention and is
not permitted.

## Rule 2: protect reveal timing
A character must not know something before the story allows it.

Track the difference between:
- knows
- suspects
- believes incorrectly
- does not know

## Rule 3: keep file roles clean
Do not mix:
- planning into prose files
- prose into summary files
- unresolved questions into canon as if they were settled truth

## Rule 4: update downstream state
If a chapter changes:
- character knowledge
- relationships
- timeline
- world implications

then update the relevant files or explicitly note that follow-up is required.

## Rule 5: prefer explicit deltas
When possible, store chapter consequences in `aftermath.md` rather than relying on memory.

## Rule 6: report uncertainty
When making progress, identify:
- what was changed
- what remains uncertain
- what follow-up files may need updates

## Rule 7: Operational file headers

Some files may include YAML frontmatter that tells LLMs and coding agents how to treat that file during updates.

These headers are not for tagging or aesthetics. They exist to support safe change propagation.

### Purpose

The header helps answer:

- Is this file a source of truth or a derived/planning file?
- May an LLM edit this file directly?
- If this file changes, what other files should be reviewed?
- What kinds of downstream consequences might the change create?

### Supported fields

```yaml
---
role: canonical | planning | derived_state | open_question | scratch
edit_policy: locked | propose_only | careful_edit | editable
concept_id: concept_name
aliases:
  - concept alias 1
  - concept alias 2
review_on_change:
  - relative/path/to/file.md
change_affects:
  - concrete downstream consequence
---
```

### Field meanings

#### `role`

Defines what kind of file this is in the project.

#### `edit_policy`

Defines how freely an LLM may edit the file.

* `locked` — do not edit directly
* `propose_only` — analyze and propose edits, but do not silently rewrite
* `careful_edit` — may edit, but preserve structure and report downstream implications
* `editable` — normal working file; direct edits are allowed

#### `concept_id`

A stable, normalized identifier for the primary concept this file defines.

Use snake_case and keep it consistent across the repository.

This field exists to make concept ownership easier to track across files, links, searches, and future automation. When a file has a `concept_id`, that file should usually be treated as the main authority for that concept unless another rule explicitly overrides it.

Examples:
- `concept_id: armageddon_vision`
- `concept_id: cohorts`
- `concept_id: residue`

#### `aliases`

Optional alternate names, spellings, abbreviations, or human-facing labels for the same concept.

Use this when the concept may be referred to in different ways across notes, planning files, or character files.

Examples:
- `aliases: [Armageddon Vision, apocalypse vision]`
- `aliases: [Residue]`

#### `review_on_change`

Lists files that should be reviewed if this file changes.

Only include concrete, plausible review targets.

Do not add speculative or generic review paths.

#### `change_affects`

Lists the kinds of downstream consequences a change to this file may cause.

Use specific effects such as:

* reveal timing
* character knowledge boundaries
* prophecy logic
* institutional behavior
* resource constraints

Avoid vague labels like:

* story stuff
* canon
* plot implications

### Usage rules

- Prefer accuracy over completeness.
- Use `concept_id` for files that are primarily about one concept.
- Prefer clear, stable snake_case names.
- Reuse an existing `concept_id` if the concept already exists elsewhere in the repository.
- Do not create multiple `concept_id` values for the same concept just because different files use different wording.
- If a file covers several concepts, omit `concept_id` unless one concept is clearly primary.
- Use `aliases` for alternate names, shorthand, capitalization differences, or common in-world phrasing.
- Do not use `aliases` for loosely related ideas; only include true alternate references to the same concept.
- When a file has a `concept_id`, related planning and character files should generally link to that file rather than redefining the concept independently.
- If a concept file changes, review any files listed in `review_on_change` and any files that substantially depend on that concept.
