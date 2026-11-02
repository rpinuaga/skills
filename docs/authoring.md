# Authoring guide: turning your work into skills

This repo converts your notes, tools, and security-consulting knowledge into
**OpenCode skills** — reusable instruction sets the agent loads on demand
instead of you re-explaining your methodology every session.

A skill is not documentation for humans first. It is a **playbook the agent
executes**: a trigger condition, a workflow, the files it must read, and the
commands it may run.

---

## 1. Where things live

```text
skills/                 ← the shared library as a TREE (see rules below)
  index.json            ← HTTP catalog manifest (auto-generated, do not edit by hand)
  <group>/…/<leaf>/     ← leaf directory = one skill, self-contained
    SKILL.md            ← the playbook (frontmatter + body)
    scripts/            ← runnable helpers the skill invokes
    references/         ← deeper material the skill reads on demand
templates/skill/        ← skeleton copied by the scaffold script
scripts/                ← repo tooling (scaffold, catalog build)
docs/                   ← this guide and other long-form material
```

Rules of thumb:

- **The library is a tree of practice areas, then a per-practice key.**
  Look at the existing tree in the root `README.md` before adding; extend it;
  don't invent a parallel structure. Within a practice area, choose the
  organizing key that matches how the work actually differs:
  - **black-box style skills** (external-only) split by *asset class* —
    the underlying target technology rarely changes the technique;
  - **white-box style skills** (privileged access) split by *technology* —
    each cloud/directory/platform stack enumerates exposure differently
    (e.g. `aws-whitebox` vs `azure-whitebox` vs `gcp-whitebox`);
  - where a vendor's white-box discovery surface is thin (classic enterprise
    suites), the black-box sibling is the default route; note that in the
    white-box skill, not as a duplicate skill.
- **Only leaf directories contain `SKILL.md`.** A directory with `SKILL.md`
  makes OpenCode stop searching *inside* it, so intermediate/group nodes hold
  human navigation (`README.md`) only. Depth limit: keep leaves ≤ 5
  directories below `skills/` (OpenCode searches up to six).
- **One skill, one leaf directory.** The skill ID is the leaf directory name —
  lowercase kebab-case, `^[a-z0-9]+(-[a-z0-9]+)*$`, unique across the whole
  tree (IDs are what the agent references; the frontmatter `name` is only a
  display label). Name leaves `<subject>` plus a qualifier when two halves
  need the same subject externally (e.g. `dns-blackbox` under a black-box
  branch, `aws-whitebox` under a technology split).
- **Genericity.** Skills are written for security work generally (consulting
  and authorized testing alike), never for a specific engagement:
  no client, program, or target names; CLI examples use `example.com` /
  `ORG-XXXX-RIPE` style placeholders; no program-specific headers, hosts, or
  naming conventions. Techniques must be ones the maintainer has actually
  used and verified in practice — reference methodology material for the
  *shape* (phases, loops, asset classes), never as a technique source.
- **`skills/` must stay clean.** OpenCode scans that root: root-level `*.md`
  files become flat skills, so nothing else belongs there. Hidden/scratch
  files are ignored; drafts live under `skills/<leaf>/_draft/` or outside the
  tree.
- **Everything a skill needs ships inside its directory.** Supporting files are
  resolved relative to `SKILL.md`. Reference sibling skills by ID (`@skill-id`).
- **Learners of methodology read `README.md`**; agents read skills. Keep the
  root README tree in sync when adding skills (descriptions: one line each).

## 2. Frontmatter

```markdown
---
name: Recon Report
description: >-
  Produce an external recon report for a domain: surface inventory, live hosts,
  email/security posture, and a client-ready executive summary.
---

body = instructions for the agent (no frontmatter in it)
```

- `name` — display name. Optional.
- `description` — **the most important field.** OpenCode only advertises the
  ID, name, and description to the model. Write it as a trigger: who/when/what
  should make the agent reach for this skill. Skills without a description are
  never advertised.
- `disable-model-invocation: true` — keep a skill registered but hidden from
  the model (e.g. only you invoke it explicitly). Optional.

## 3. What goes in the body

Keep it short and imperative. Every skill `SKILL.md` in this repo follows the
template structure:

1. **Purpose / when to use** — one or two lines restating the trigger.
2. **Inputs** — what the agent must ask the user for or find (domain, repo
   path, prior report, tool output).
3. **Workflow** — numbered steps the agent executes in order. Put hard rules as
   steps ("Run X only after the user approves Y").
4. **Output format** — exact section names/structure if the deliverable is a
   document (reports, findings lists, PR descriptions). Templates belong in
   `references/` so the body stays lean.
5. **Safety rules** — for security work: authorization checks, redaction, and
   anything that must never leave the machine (see §6).

Guidelines:

- Target ≤ 150 lines in `SKILL.md`. Anything bigger belongs in `references/`.
- Paths inside the skill are relative to the skill directory — write
  `references/notes.md`, never absolute paths.
- Reference *other* skills by ID (`@skill-id`) when there is overlap rather
  than duplicating their content.
- Write `scripts/` helpers for anything involving parsing, templating, or
  repetitive commands. The agent is better at reading clean scripts than at
  reconstructing long command chains correctly.
- Word scripts/commands for Windows + PowerShell unless the skill is explicitly
  about Linux targets, since that is your primary environment.
- Every technique carried in a skill is field-tested and marked as such by its
  confident wording; anything plausible-but-unverified is written as
  "candidate technique; verify in the field before relying on it". Update the
  wording when real testing settles it.

## 4. From raw material to skill — recommended conversion flow

| You have…                          | Skill shape                                                                                   |
| ---------------------------------- | --------------------------------------------------------------------------------------------- |
| A repeated consulting workflow (recon, report writing, threat modeling) | Workflow skill: numbered agent steps + a `references/` template of the deliverable        |
| A tool or script you always use    | Tool skill: short `SKILL.md` explaining when/why + the tool in `scripts/` with usage in the body |
| A long note or methodology doc     | Split: a thin `SKILL.md` pointing to the full text in `references/`, plus a distilled workflow  |
| Checklists / policies              | `references/` only, invoked by a workflow skill's "read and verify" step                        |
| Client-specific knowledge          | **Do not centralize.** Keep it private (see §6) or as project-local skills in the client repo    |

When converting a note, do not copy it verbatim. Extract: (a) the trigger
(when would future-you want this), (b) the ordered procedure, (c) the
artifacts/format, (d) hard rules. Kill everything else.

## 5. Using this repo alongside your other GitHub repos

Three supported integration patterns, choose per consuming repo:

1. **Global source (recommended).** Clone this repo once per machine, then add
   it to `~/.config/opencode/opencode.json`:

   ```jsonc
   {
     "$schema": "https://opencode.ai/config.json",
     "skills": ["~/git/skills/skills"]
   }
   ```

   Every skill is then available in *all* your projects. Project-local skills
   in each repo use higher precedence and win on ID conflicts.

2. **Project entry / submodule.** In a specific repo, add `skills` entries
   pointing at a local clone (or vendor this repo as a git submodule and point
   at `<submodule>/skills`). Use this when a project should have skills even
   where your global config is absent.

3. **HTTP catalog (no clone needed).** `skills/index.json` is a ready-made
   OpenCode HTTP catalog. Point any machine at:

   ```jsonc
   { "skills": ["https://raw.githubusercontent.com/rpinuaga/skills/main/skills"] }
   ```

   Catalog entries carry a `version`; bump it when files change so OpenCode
   refreshes its cache. `scripts/build-catalog.ps1` regenerates both the file
   list and version automatically — never edit `index.json` by hand.

Also document cross-repo material mapping: if a skill consumes artifacts from
one of your other repos (templates, wordlists, prior reports), record the
expected location of those artifacts either in the skill's body as an input
step ("ask the user for the path to …") or in its `references/`.
That way a skill never silently breaks when you sit at another checkout.

## 6. Security & confidentiality checklist (apply to every skill)

You store security-consulting knowledge here, so make redaction part of
authoring, not an afterthought:

- [ ] No client names, project names, report text, or findings tied to a client.
- [ ] No credentials: internal URLs with secrets, tokens, VPN details,
      `Authorization` headers from captured requests, Burp session state.
- [ ] Tools/commands are generic and replaceable (document a target class of
      system, not a specific engagement's infrastructure).
- [ ] If source material must be generalized to be publishable, work from a
      copy and never commit the original.
- [ ] Explicitly client-bound knowledge stays out of this repo: put it in the
      client's own repo as a project-local skill (`.opencode/skills/`), or in a
      private repo referenced via per-project `opencode.json`.
- [ ] Before making this repo public (if it is not already), re-read every new
      skill against this list.

## 7. Creating a skill (quick reference)

```powershell
# from the repo root
./scripts/new-skill.ps1 -Name recon-report -Description "External recon report for a domain"
```

Then edit `skills/recon-report/SKILL.md`, and afterwards regenerate the
catalog:

```powershell
./scripts/build-catalog.ps1
```

CI regenerates the catalog on every push that touches `skills/`, so if you
forget, the push itself will finish the job.

## 8. The improvement loop — real testing feeds the library

The purpose of this repo is to accumulate **field-tested knowledge** and break
the cycle where hard-won experience dies inside reports, scratch notes, or
session logs. Make the round trip the default behavior:

1. **Capture in-session.** When real testing verifies, refutes, or extends
   something the skills taught, invoke `@skill-improve` in the same session
   (or as the session's wrap-up step) with the observation.
2. **Classify, don't copy.** `skill-improve` labels each item as tested /
   candidate / correction, applies the genericity and redaction checklist,
   and lands the change in the skill that owns the subject — one home, no
   duplicate copies across sibling skills.
3. **Corrections outrank additions.** When field results contradict an
   existing step, rewrite that step; the field-tested truth replaces the
   prior wording, and the commit message records the refutation.
4. **Propagate worthiness checks.** Unverified ideas enter the library only
   as candidates marked for first-verified confirmation — the next engagement
   that exercises them should explicitly report back via this loop.
5. **Grow the tree, not the leaves.** A repeated stream of new knowledge that
   doesn't fit any existing leaf signals a new skill (`@skill-factory`), not
   a bloated one; keep every leaf under the ~150-line guidance.

Agents working *with* the user on security tasks should treat this loop as a
closing step of any session that produced verified knowledge — ask the user
whether to record it before wrapping up.
