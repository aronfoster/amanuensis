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

## Workflow: character folder creation

Run this during chapter planning if a character expected in the chapter does not yet have a folder.

1. Check `characters/` for an existing folder
2. If absent, create the folder and minimum required files per `agents/characters.md`
3. Fill in what is known; leave unknown fields blank and mark `status: stub` if role is unsettled

## Workflow: storyboarding

Follow `agents/storyboarding.md`.

Before storyboarding a scene, read the current knowledge files for all characters who appear in it. These are the inputs that determine what each character can plausibly know, suspect, or believe at scene-start.

After completing all storyboard blocks for a scene, produce a **knowledge delta** — a compact list of facts that at least one character has newly learned, confirmed, or falsely come to believe by the scene's end. Format one line per item:

```
[CharacterName] now knows: [fact] [from xx-yy]
[CharacterName] falsely believes: [fact] [from xx-yy]
```

Include the scene reference so the source is traceable if the storyboard changes later. Attach the delta to the storyboard output. Do not apply it to character knowledge files yet — that happens after drafting.

## Workflow: drafting

Follow `agents/drafting.md`. Draft at scene level: read all storyboard blocks for a scene before writing, and treat them as production notes for a single dramatic arc. Pace against the arc, not against beat boundaries.

## Workflow: agentic chapter drafting

Follow `agents/agentic-drafting.md`. Use this only after storyboard files are complete. A coordinator assigns each scene to a subagent, subagents write per-scene markdown files and per-scene notes files in an `attemptXX` folder, and the coordinator mechanically assembles those files into one chapter draft and one notes file for that attempt.

## Workflow: compliance pass

Review the drafted prose and fix any deviations from storyboard requirements (especially Must Preserve) and `canon/`. See [compliance.md](compliance.md) for details.

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

* Write xx-yy-metaphors.md to list all metaphors and similes of the chapter: exact text, what thing is written down, what it represents, what we want to say about the thing it represents, whether this metaphor does that.

## Workflow: Anti-AI update

* Remove em-dashes and famously AI words, figures of speech, turns of phrase.

## Workflow: post-chapter update

Run this after all scenes in a chapter are drafted and knowledge files are current.

1. Write or revise `aftermath.md`
2. Update `relationships.md` or `timeline.md` if chapter events require it
3. Note any canon files that may need review
4. Record new open questions

---

# Consdier workflows:

**POV-age pass.** Scan for reference points, comparisons, and abstractions that a thirteen-year-old wouldn't reach for — narrator-adult language, institutional vocabulary used unironically, interpretive frames. Closely related to #2 but a different failure mode: #2 catches imported labels; this catches unearned sophistication.  
**Line-level voice pass.** Sentence rhythm, subordination doing real work vs. sideways qualification, cutting any clause the sentence would be more accurate without. Last because it's least leveraged — it polishes prose that's already structurally sound, and does nothing for prose that isn't.
**Chapter-boundary continuity** the next chapter's storyboards need to know what
   the previous chapter committed to in its drafts (active concern flags, pending
   appointments, named characters, scheduled obligations). Currently: storyboards
   only commit generic shapes ("the household concern flag"); specifics emerge in
   drafting. Create `aftermath.md` as a drafter input for
   the next chapter's chapter-boundary blocks, and update `drafting.md` files to read the previous chapter's boundary notes as appropriate.
