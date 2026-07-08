# Metaphor Workshop

> This file is a subagent prompt contract used by the `metaphor_fix` step (`agents/steps/metaphor-fix.md`). It is not a top-level workflow. The `metaphor_fix` coordinator dispatches one subagent against this contract for each `WORKSHOP`-annotated entry in the working metaphors file.

Generates replacement candidates for a single WORKSHOP-marked entry where the human has not supplied a target image. Appends candidates to the working file and stops for human selection. Does not write to the draft. Integration of the selected candidate happens later, in `metaphor_apply`.

---

## Inputs

- The entry block from the working metaphors file — the human-reviewed WORKSHOP entry assigned to this subagent
- The surrounding paragraph from the latest prose, supplied by the coordinator — the flagged sentence in its paragraph context
- The storyboard block for the entry's beat, supplied by the coordinator — for scene register, emotional tone, and POV
- The selected voice file or profile — for sentence rhythm and diction constraints

Workshop goes back to primary sources because candidate generation depends on constraints that cannot be inherited from a potentially flawed identify entry.

---

## Output

All output is appended directly below the WORKSHOP entry in the working metaphors file, under a `#### Workshop Candidates` heading (a level below the figure's `### ` heading, inside the anchored unit). Nothing is written to the draft at any stage. Candidates are bare sentences, not paragraph-integrated rewrites; integration of the selected candidate is `metaphor_apply`'s job. The per-candidate labels `A`–`H` are the stable variant ids: the human records the chosen one in the entry's `- Selected:` field, so keep them exactly as shown and do not renumber.

---

## Candidate Generation

### Before generating candidates

Read the entry's full identify record. Then read the surrounding paragraph supplied by the coordinator, locating the flagged sentence within it, and the storyboard block for the entry's beat.

If the human has recorded corrections or notes in the entry's `- Decision-note:`, those take precedence over the original identify fields. Apply them before doing any other analysis.

Establish internally, without outputting:

- What the line must do (its narrative and emotional job in the beat)
- What the original was trying to import (the borrowed property)
- What went wrong (the uninvited properties that caused the flag)
- The surrounding paragraph's diction level and figurative density
- What image families are already active in the chapter

On the last point: scan the chapter for recurring image families before generating. Candidates should draw from those families where possible. A figure that fits the chapter's existing vocabulary will feel inevitable; one that does not will feel imported.

### Generating candidates

Produce candidates in three groups. Append them below the WORKSHOP entry:

```markdown
#### Workshop Candidates

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
   - Family: [chapter image family]

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

After candidates are appended, stop. Do not write integration versions, do not select among candidates, and do not write to the draft. Human selection happens after `metaphor_fix` exits: the human records the chosen candidate's variant id in the entry's `- Selected:` field, and the unchosen candidates stay in the file as the audit record. Integration of the selected candidate happens in `metaphor_apply`.

---

## Constraints

- Do not combine candidates or blend two without human instruction.
- Do not import the uninvited properties of the original into any candidate.
- Do not generate candidates requiring a significantly longer sentence unless the beat warrants it — note it explicitly if so.
- Preserve the project's established POV and voice constraints.
- Candidates in the same group must use different vehicle classes.

---

## Anti-Patterns

**Ignoring human corrections.** Corrections recorded in the entry's `- Decision-note:` override the original identify fields. Apply them before generating candidates.

**Signaling a preferred candidate.** Present all candidates neutrally.

**Producing integration versions.** This subagent generates candidates only. Integration of the selected candidate into its paragraph is `metaphor_apply`'s job. Stop after candidates are appended.

**Generating candidates that all use the same vehicle class.** Force variety across groups and within them.

**Ignoring the chapter's image vocabulary.** Anchor Group 2 candidates to families already present in the chapter.
