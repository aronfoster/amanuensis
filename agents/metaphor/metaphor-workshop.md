# Metaphor Workshop

Generates replacement candidates for WORKSHOP-marked entries where the human has not supplied a target image. Works one entry per session. Appends candidates to the working file and stops for human selection. Does not write to the draft.

---

## Inputs

- `xx-yy-metaphors.md` — the human-reviewed working file
- `xx-yy-draft.md` — the current prose
- `xx-yy-zzz-storyboard.md` — for scene register, emotional tone, and POV
- `agents/voice.md` — for sentence rhythm and diction constraints

Workshop goes back to primary sources because candidate generation depends on constraints that cannot be inherited from a potentially flawed identify entry.

---

## Output

All output is appended directly below the WORKSHOP entry in `xx-yy-metaphors.md`. Nothing is written to the draft at any stage.

---

## Phase 1: Candidate Generation

### Before generating candidates

Read the entry's full identify record. Then read the flagged sentence in its paragraph in the draft, and the storyboard block for its beat.

If the human has added corrections or notes below the action word, those take precedence over the original identify fields. Apply them before doing any other analysis.

Establish internally, without outputting:

- What the line must do (its narrative and emotional job in the beat)
- What the original was trying to import (the borrowed property)
- What went wrong (the uninvited properties that caused the flag)
- The surrounding paragraph's diction level and figurative density
- What image families are already active in the chapter

On the last point: scan the chapter for recurring image families before generating. For this chapter they include cloth and thread, household procedure, pressure and containment, the body as instrument, architecture and enclosure, light and glass. Candidates should draw from these families where possible. A figure that fits the chapter's existing vocabulary will feel inevitable; one that doesn't will feel imported.

### Generating candidates

Produce candidates in three groups. Append them below the WORKSHOP entry:

```markdown
### Workshop Candidates

**Group 1 — Restrained (3 candidates)**
Each candidate imports the borrowed property the original was after, without the uninvited properties that caused the flag. Short. Close to the original sentence's length.

A. "[candidate sentence]"
   - Vehicle: [what it compares to]
   - Borrowed property: [what it imports]
   - Uninvited properties: [what it brings that wasn't asked for]

B. "[candidate sentence]"
   - Vehicle:
   - Borrowed property:
   - Uninvited properties:

C. "[candidate sentence]"
   - Vehicle:
   - Borrowed property:
   - Uninvited properties:

**Group 2 — Image-family (3 candidates)**
Each candidate draws from one of the chapter's active image families.

D. "[candidate sentence]"
   - Vehicle:
   - Borrowed property:
   - Uninvited properties:
   - Family: [cloth and thread | household procedure | pressure and containment | body as instrument | architecture and enclosure | light and glass]

E. "[candidate sentence]"
   - Vehicle:
   - Borrowed property:
   - Uninvited properties:
   - Family:

F. "[candidate sentence]"
   - Vehicle:
   - Borrowed property:
   - Uninvited properties:
   - Family:

**Group 3 — Near-literal (2 candidates)**
One step above a flatten. For when the beat may not need the weight of a full figure.

G. "[candidate sentence]"
   - Vehicle:
   - Borrowed property:
   - Uninvited properties:

H. "[candidate sentence]"
   - Vehicle:
   - Borrowed property:
   - Uninvited properties:
```

Do not recommend a candidate. Do not signal preference.

### Stop.

After candidates are appended, stop. Do not proceed to Phase 2 without human selection.

---

## Phase 2: Integration

The human will respond with one of:

- A letter (selecting a candidate)
- A modified version of a candidate
- A rejection with feedback

**If a candidate is selected or a modified version supplied:**

Treat the selected or modified sentence as the target image and proceed as `metaphor-replace.md`. Produce three integration versions (minimal, balanced, fuller) embedded in the paragraph. Append them below the candidates:

```markdown
### Integration Options
- **Selected:** "[chosen candidate]"
- **Version A (minimal):** "[paragraph with rewritten sentence]"
- **Version B (balanced):** "[paragraph with rewritten sentence]"
- **Version C (fuller):** "[paragraph with rewritten sentence]"
```

Stop. Do not select a version. The human deletes the versions not wanted and leaves one.

**If all candidates are rejected:**

Ask what the candidates got wrong — uninvited properties that appeared, borrowed property that was missing, or direction to move in. Generate a second round of 8 candidates adjusted for that feedback, appended below the first round. Stop again.

---

## Constraints

- Do not combine candidates or blend two without human instruction.
- Do not import the uninvited properties of the original into any candidate.
- Do not generate candidates requiring a significantly longer sentence unless the beat warrants it — note it explicitly if so.
- Preserve POV. The perceiving mind is Louise's, thirteen years old.
- Candidates in the same group must use different vehicle classes.

---

## Anti-Patterns

**Ignoring human corrections.** Corrections below the action word override the original identify fields. Apply them before generating candidates.

**Signaling a preferred candidate.** Present all candidates neutrally.

**Proceeding to integration before selection.** Phase 1 ends when candidates are appended. Do not write integration versions until the human has chosen.

**Generating candidates that all use the same vehicle class.** Force variety across groups and within them.

**Ignoring the chapter's image vocabulary.** Anchor Group 2 candidates to families already present in the chapter.

**Treating rejection as failure.** A second round is normal. Use the feedback to narrow, not to restate.
