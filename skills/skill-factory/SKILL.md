---
name: Skill Factory
description: >-
  Convert notes, tools, or consulting knowledge into a reusable OpenCode skill
  in this repo. Use whenever the user wants to capture a workflow, save a tool
  for reuse, or turn material from another repo into a skill.
---

## Purpose

Turn raw material (a note, a tool, a repeated workflow, a checklist) into a
new skill under `skills/`, following this repo's conventions. The full
conventions live in `../../docs/authoring.md` — read it before writing the skill.

## Inputs

Ask the user for what is missing:

1. The raw material: inline notes/files, a path to material in the working
   project, or a pointer to another of the user's repos.
2. Skill ID direction (a few lowercase-kebab words), or propose one and confirm.
3. Whether the material contains client-specific or sensitive content. If it
   does, generalize it per the checklist in `../../docs/authoring.md` §6 before
   writing anything.

## Workflow

1. Read `../../docs/authoring.md` (especially §2–§4 and the tree rules in §1).
2. Analyze the material and classify it per the table in §4 (workflow skill,
   tool skill, note split, checklist reference).
3. Propose to the user, before creating files:
   - the tree placement (which group; black-box/white-box variant if the
     existing tree defines such pairs — reuse sibling IDs' shaping),
   - the skill ID and one-line trigger description,
   - the skill shape (what goes in the body vs `references/` vs `scripts/`),
   - any generalizations/redactions made to sensitive material.
4. After approval, scaffold:
   ```powershell
   ./scripts/new-skill.ps1 -Name <skill-id> -Description "<description>"
   ```
5. Write `SKILL.md` following the template structure (§3): purpose, inputs,
   numbered workflow ending in a "feed the loop" step, output format, safety
   rules. Move long-form content and document templates into `references/`,
   and repetitive/parsing commands into `scripts/`.
6. Enforce genericity: every real client/program/target name — including in
   CLI examples and file names — is replaced by placeholders (`example.com`,
   `ORG-XXXX-RIPE`); program-specific headers/conventions are dropped or
   generalized; only techniques verified in practice are included, and any
   adaptations are marked as candidate improvements, not presented as tested.
7. Write `scripts/` helpers in PowerShell (Windows is the user's primary
   environment) unless the skill explicitly targets Linux systems.
8. Regenerate the catalog:
   ```powershell
   ./scripts/build-catalog.ps1
   ```
9. Validate: the leaf directory name matches the skill ID kebab-case pattern
   and is unique in the tree, no parent/group directory gained a `SKILL.md`,
   depth ≤ 5 below `skills/`, the description is a proper trigger, all paths
   inside `SKILL.md` are relative to the skill directory, and `index.json`
   lists the new skill.
10. Keep the root `README.md` skill tree in sync (add one indexed line), then
   commit with a message like `skill: <id> — <one-liner>`.

## Output

A committed skill directory under `skills/<id>/` plus an updated
`skills/index.json`. Report what was redacted or generalized, if anything.

## Safety rules

- Never copy client names, findings text, credentials, or captured requests
  into the skill. Redact at authoring time (§6 checklist).
- If the source material looks too sensitive to publish in this repo even
  generalized, say so and propose a private/client-local location instead.
