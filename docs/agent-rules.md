# Agent rules — security work with the skills tree

Standing rules for every session that works on security tasks with the
[RPU skill library](https://github.com/rpinuaga/skills). These apply
everywhere, not only inside the library's own repo.

## 1. Work from the skills, return to the skills

- Attack-surface work starts from the matching skill (`@ip-blackbox`,
  `@dns-whitebox`, `@aws-whitebox`, …) rather than from improvised
  methodology — the tree encodes field-verified techniques.
- If no skill owns the task, check the tree for the nearest sibling and
  propose a new skill placement via the tree rules in the library's
  `docs/authoring.md` before inventing an ad-hoc workflow.

## 2. The improvement loop is a session-closing step (mandatory)

The library exists to accumulate real-testing knowledge. Therefore:

- **Before wrapping up any session that produced verified results** (a
  technique that worked or failed, tool behavior observed in the field, a
  correction to what a skill assumed, a defensive-layer reaction), propose
  recording it with `@skill-improve`. Do not end the session without
  offering this.
- **Do not wait for a summary request.** If a concrete discovery verified or
  refuted skill knowledge mid-session, raise the capture at the natural
  break point.

- Corrections outrank additions: if field results contradict a skill,
  `@skill-improve` rewrites that step and labels the refutation; the skill
  must end up consistent with what the field showed.
- New knowledge reads as **tested** (confidence-worded) only when genuinely
  field-verified; everything else enters as **candidate** with an explicit
  "verify in the field" note, and later testing must report back through the
  same loop.
- One knowledge item, one home: update the skill that owns the subject;
  reference siblings by `@id` instead of duplicating content. A stream of
  knowledge that fits no leaf means a new skill (`@skill-factory`), never a
  bloated one.

## 3. Genericity and confidentiality at all times

- No client, program, target, or site-specific details enter the library —
  generalize with placeholders (`example.com`, `ORG-XXXX-RIPE`) before
  writing; drop program-specific headers/conventions.
- Engagement exports and findings stay inside the engagement; the library
  holds generalized technique only.
- If an observation is too specific to generalize without losing its value,
  keep it out of the library entirely and say so.

(Rules maintained as part of the library; latest version wins on pull.)
