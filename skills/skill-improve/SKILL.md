---
name: Skill Improve
description: >-
  Capture new tested knowledge (real engagement or testing results) into the
  skills tree. Use whenever the user reports a verified finding, a tool
  behavior learned during real testing, a corrected assumption, or a
  technique that worked/failed in practice — so the learning survives the
  session and lands in the library.
---

## Purpose

Real-world testing produces knowledge that must not die in session logs or
scratch notes. Turn each verified experience into an update to the exact
skill(s) that own the subject, so "work → library" is the default path. This
repo's purpose is to accumulate field-tested knowledge, not generic theory.

## Inputs

Ask the user for what is missing:

1. What was observed/verified in real testing (what worked, what didn't, tool
   behavior, defensive-layer behavior, false leads worth recording).
2. Which engagement/ground it came from (for provenance and redaction review
   only — never to be written verbatim into the skill).
3. Confirm subject mapping: which skill(s) in the tree own this knowledge;
   propose one if the tree has no home yet (then this becomes a
   `@skill-factory` job for a new skill instead of an update).

## Workflow

1. Read `docs/authoring.md` (especially the tree rules and the confidential
   checklist in §6) and load the target skill(s) via the `skill` tool.
2. Classify the knowledge:
   - **Tested** — verified in the field this session/engagement: it may be
     written as a workflow step or rule with confident wording.
   - **Candidate** — plausible but unverified yet: keep it, but mark it,
     e.g. "candidate technique; verify in the field before relying on it",
     so future-you distinguishes the two.
   - **Correction** — an existing skill said something the field proven
     wrong: rewrite the affected step/rules and note the refinement in the
     commit message.
3. Make the update minimal and durable:
   - Prefer adding/rewording steps in the skill that is its true home; avoid
     duplicating the same knowledge across sibling skills — reference by
     `@skill-id` instead.
   - Keep the skill generic: replace any real client/program/target details
     with placeholders (`example.com`, `ORG-XXXX-RIPE`); drop
     program-specific headers or conventions entirely.
   - Keep the skill lean: if the knowledge is a full new methodology rather
     than a step, propose a new skill via `@skill-factory` (sibling variant,
     correct branch) instead of bloating a leaf skill.
   - If the observation produced a reusable script/helper, put it in the
     skill's `scripts/` and reference it from the workflow.
4. Sync plumbing: root `README.md` tree line if descriptions changed,
   `./scripts/build-catalog.ps1` for the manifest (CI also refreshes it).
5. Commit with a message naming the provenance class:
   `skill: ip-blackbox — add <technique> (tested, <date>)` or
   `skill: dns-blackbox — correct <claim> — field refuted it (<date>)`.

## Output

An updated skill (or a proposed new skill when no owner exists in the tree),
with the knowledge labeled tested vs candidate, redacted to genericity
rules, catalog refreshed, and committed. Report what was changed and where.

## Safety rules

- Client-identifying data (names, hostnames, findings tied to an
  organization, captured requests) never enters the tree — generalize before
  writing; when generalization loses the point, keep the skill abstract and
  offer the user a private, client-local location for the specifics.
- Never weave misinformation into a skill: if unsure whether something was
  truly verified or just assumed, label it candidate.
- One knowledge item, one home: no cross-skill content duplication.
