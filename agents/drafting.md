# Drafting

This workflow generates the prose of the story for a single scene. It has no knowledge of adjacent scenes except what is captured in `character_state_in`.

## Inputs

- The project's selected voice file or Amanuensis voice profile; this should not change between scenes within one run
- A group of storyboard blocks (`xx-yy-zzz-storyboard.md`) covering a scene

Do not read any other files before writing prose.

## Output

Drafted prose for the block, written to `xx-yy-draft.md` in the chapter folder. Block will begin with `<!-- scene x, beat y -->` and end with `<!-- end scene x, beat y -->`. If the block already exists, overwrite it.

Scene breaks are indicated with a horizontal line (`---`).

## What Goes in the LLM Call

**System message:** the selected voice file in full. Placing it in the system message allows it to be cached and keeps the user message focused on the specific beat.

**User message:** all storyboard blocks for the scene in order. Treat them as production notes for a single dramatic arc. Pace against the arc, not against beat boundaries.

Do not add canon files, scene lists, or summaries to the user message. If information from those sources is needed in the prose, it must have been extracted into the block's `canon_active` field during Storyboarding.

---

## Experimental Mode

When finding a voice and process that will work, each drafting run goes into its own folder under `drafts/` so that different model, storyboard, and voice combinations can be compared side by side.

Each attempt is a self-contained record of what produced it:

```text
plot/bookN/chapterYY/drafts/
  attempt01/
    NN-YY-ZZZ-storyboard.md   # storyboard block used
    voice.md                  # voice spec used
    NN-YY-draft.md            # prose output
    notes.md                  # model and any other run notes
  attempt02/
    NN-YY-ZZZ-storyboard.md
    voice.md
    NN-YY-draft.md
    notes.md
```

The `voice.md` and `notes.md` in each attempt folder are the specific versions used for that run, not references to the source voice file.

Set up a new attempt by copying the source files — do not move them, and do not retype their contents:

```bash
BOOK=01
CHAPTER=01
SCENE=01
CHAPTER_DIR=plot/book$BOOK/chapter$CHAPTER
VOICE_FILE=amanuensis/agents/voice.md
ATTEMPT=$CHAPTER_DIR/drafts/attemptXX
mkdir -p $ATTEMPT
cp $VOICE_FILE $ATTEMPT/voice.md
cp $CHAPTER_DIR/storyboards/$BOOK-$CHAPTER-$SCENE-*-storyboard.md $ATTEMPT/
```

Then write the model name into `notes.md` and write your output going to `$ATTEMPT/$BOOK-$CHAPTER-draft.md`.

### Subsequent runs

Write your output in `$ATTEMPT/$BOOK-$CHAPTER-draft.md` and copy the `$BLOCK` storyboard into the folder.

---

## Anti-Patterns

**Full canon file dumps in the prompt.** Pasting entire reference files into the user message inflates the prompt, dilutes focus, and defeats the purpose of the storyboard. Extract only the specific constraint or mechanic that operates in this beat into `canon_active` during storyboarding.

**Reading extra files before drafting.** If the storyboard block is complete, no other file is needed. Reaching for the scene list or a character file mid-drafting is a signal that the block is incomplete — the fix belongs in storyboarding, not in the drafting prompt.
