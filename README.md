# skills

Reusable [OpenCode](https://opencode.ai/v2/docs/skills) skills for
[rpinuaga](https://github.com/rpinuaga). This repo turns notes, tools, and
security-consulting knowledge into agent playbooks that can be reused across
every project and machine — instead of re-explaining methodology to the agent
each session.

## Layout

```text
opencode.json      registers ./skills, so skills also work inside this repo
skills/            the shared library — one self-contained directory per skill
  index.json       generated HTTP-catalog manifest (CI-refreshed)
  skill-factory/   meta-skill: converts your material into new skills
templates/         skeleton copied by the scaffold script
scripts/           repo tooling (scaffold, catalog build)
docs/authoring.md  conventions + security/redaction checklist for new skills
```

## Using these skills elsewhere

Clone this repo once per machine (e.g. `~/git/skills`), then pick a pattern:

**1. Global source — recommended.** Available in every project:

```jsonc
// ~/.config/opencode/opencode.json
{
  "$schema": "https://opencode.ai/config.json",
  "skills": ["~/git/skills/skills"]
}
```

**2. Per-project source / submodule.** For a repo that needs the skills even
without your global config, either vendor it as a git submodule and point at
the `skills/` directory, or clone it anywhere and reference that path:

```jsonc
// <project>/opencode.json
{ "skills": ["../skills/skills"] }
```

Project-local skills (`.opencode/skills/` in any repo) take precedence and win
on ID conflicts — use those for client-specific knowledge that must not leave a
private repo.

**3. HTTP catalog — zero-clone consumption.** `skills/index.json` is a ready
[OpenCode catalog](https://opencode.ai/v2/docs/skills); point any machine at:

```jsonc
{ "skills": ["https://raw.githubusercontent.com/rpinuaga/skills/main/skills"] }
```

CI regenerates `index.json` (file lists + cache-busting version) on every push
touching `skills/`, so GitHub Pages/raw URLs stay current. Never edit it by
hand.

## Creating a skill

```powershell
./scripts/new-skill.ps1 -Name recon-report -Description "External recon report for a domain"
./scripts/build-catalog.ps1   # refreshes index.json
git add skills/recon-report && git commit -m "skill: recon-report — domain recon report"
```

The fastest way to convert existing material is simply to ask the agent:

> @skill-factory — turn this methodology note into a skill

`skill-factory` reads `docs/authoring.md`, classifies the material, proposes a
shape, redacts client-sensitive content, and scaffolds everything.

## Conventions (summary)

- Skill ID = directory name, lowercase kebab-case; frontmatter `description`
  is the discovery trigger, so write it as "when the agent should use this".
- `SKILL.md` stays a lean playbook (purpose → inputs → workflow → output →
  safety rules); long-form content goes in `references/`, repeated commands in
  `scripts/` (PowerShell-first).
- Full rules and the mandatory confidentiality/redaction checklist:
  **[docs/authoring.md](docs/authoring.md#6-security--confidentiality-checklist-apply-to-every-skill)**.
- Client-bound knowledge is never centralized here — it lives as
  project-local skills in the client's own repo.
