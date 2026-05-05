# Workflows

This file defines when and why each workflow runs, and what order to follow. For *how* to execute storyboarding or drafting, see the dedicated files.

## Workflow: book setup

1. Read relevant canon files
2. Create or revise `overview.md`
3. Create or revise `outline.md`
4. Note major continuity risks in `continuity.md`

## Workflow: chapter planning

1. Read relevant canon files
2. Read relevant character knowledge files (`characters/<name>/knowledge/book_n.md`)
3. Read book `overview.md` and `outline.md`
4. Write or revise chapter `summary.md`
5. Write or revise chapter `scene-list.md`
6. Record unresolved questions in chapter `open-questions.md`

For projects on the orchestrator, scene-list creation is automated by [`steps/scene-generation.md`](steps/scene-generation.md).

## Workflow: character folder creation

Run this during chapter planning if a character expected in the chapter does not yet have a folder.

1. Check `characters/` for an existing folder
2. If absent, create the folder and minimum required files per `characters.md`
3. Fill in what is known; leave unknown fields blank and mark `status: stub` if role is unsettled

For projects on the orchestrator, initial character folder bootstrapping is automated by [`steps/character-extraction.md`](steps/character-extraction.md).

## Workflow: storyboarding

Follow `steps/storyboarding.md`.

Before storyboarding a scene, read the current knowledge files for all characters who appear in it. These are the inputs that determine what each character can plausibly know, suspect, or believe at scene-start.

After completing all storyboard blocks for a scene, produce a **knowledge delta** — a compact list of facts that at least one character has newly learned, confirmed, or falsely come to believe by the scene's end. Format one line per item:

```
[CharacterName] now knows: [fact] [from <book-id>/<chapter-id>/<scene-id>]
[CharacterName] falsely believes: [fact] [from <book-id>/<chapter-id>/<scene-id>]
```

Use the folder-style scene citation: `[from <book-id>/<chapter-id>/<scene-id>]` (for example, `[from book1/chapter02/scene03]`). For `short_story` projects `<book-id>` is omitted, giving `[from <chapter-id>/<scene-id>]`. Include the scene reference so the source is traceable if the storyboard changes later. Attach the delta to the storyboard output. Do not apply it to character knowledge files yet — that happens after drafting.

## Workflow: drafting

Follow `steps/drafting.md`. The drafting step is a chapter coordinator: it dispatches per-scene subagents (each treating its storyboard blocks as production notes for a single dramatic arc and pacing against the arc, not beat boundaries), then assembles their per-scene files into one chapter draft and one notes file for the attempt.

## Workflow: compliance pass

Review the drafted prose and fix any deviations from storyboard requirements (especially Must Preserve) and `canon/`. See [steps/compliance-report.md](steps/compliance-report.md) for the report phase and [steps/compliance-fix.md](steps/compliance-fix.md) for the apply phase.

## Workflow: continuity review

* Compare reveal timing against character knowledge files
* Identify contradictions or premature knowledge
* Record risks in the relevant continuity or open questions file

## Workflow: scene knowledge update

* Read the knowledge deltas attached to the completed scene's storyboard blocks
* Confirm the deltas reflect what the drafted prose actually committed — if the draft changed something, update the delta first
* Apply confirmed deltas to the relevant `characters/<name>/knowledge/book_n.md` files, including the scene citation
* Note any open questions the deltas surface

## Workflow: metaphor check

* List all metaphors and similes of the chapter: exact text, what thing is written down, what it represents, what we want to say about the thing it represents, whether this metaphor does that. The canonical file is `metaphors.md` at `<chapter-folder>/drafts/<latest-attempt>/metaphors.md`.

For projects on the orchestrator, this file is produced by [`steps/metaphor-identify.md`](steps/metaphor-identify.md).

## Workflow: Anti-AI update

* Remove em-dashes and famously AI words, figures of speech, turns of phrase.

## Workflow: post-chapter update

Run this after all scenes in a chapter are drafted and knowledge files are current.

1. Write or revise `aftermath.md`
2. Update `relationships.md` or `timeline.md` if chapter events require it
3. Note any canon files that may need review
4. Record new open questions

---

## Workflow Backlog

**POV-age pass.** Scan for reference points, comparisons, and abstractions outside the POV character's plausible frame — narrator-adult language, institutional vocabulary used unironically, interpretive frames. Closely related to line-level voice, but a different failure mode: this catches unearned sophistication.  
**Line-level voice pass.** Sentence rhythm, subordination doing real work vs. sideways qualification, cutting any clause the sentence would be more accurate without. Last because it's least leveraged — it polishes prose that's already structurally sound, and does nothing for prose that isn't.
**Chapter-boundary continuity** the next chapter's storyboards need to know what
   the previous chapter committed to in its drafts (active concern flags, pending
   appointments, named characters, scheduled obligations). Currently: storyboards
   only commit generic shapes ("the household concern flag"); specifics emerge in
   drafting. Create `aftermath.md` as a drafter input for
   the next chapter's chapter-boundary blocks, and update `steps/drafting.md` files to read the previous chapter's boundary notes as appropriate.
