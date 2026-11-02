# skills

Reusable [OpenCode](https://opencode.ai/v2/docs/skills) skills for
[rpinuaga](https://github.com/rpinuaga). Notes, tools, and security-consulting
knowledge, converted into agent playbooks that are reused across projects,
machines, and repositories.

## Using these skills elsewhere

Clone once per machine (e.g. `~/git/skills`), then pick a pattern from the
section below.

## Skill tree

Skills live in a directory tree by surface type and knowledge level. Every
**leaf directory that contains `SKILL.md` is a skill**; intermediate
directories are grouping/navigation only (their `README.md` files are not
picked up by OpenCode). The content of every skill comes from the maintainer's
tested, verified practice — never copied methodology decks.

```text
skills/
├── skill-factory                     create new skills from notes/tools/knowledge
├── skill-improve                     capture real-testing results into the tree
└── attack-surface/                   … mapping what an organization exposes
    ├── blackbox/                     external-only; split by asset class
    │   ├── ip-blackbox               IP space, ASNs, ports, vhost/origin probing
    │   ├── dns-blackbox              CT logs, passive sources, naming-convention mining
    │   ├── email-blackbox            SPF/DMARC/DKIM, MX, senders, lookalikes
    │   ├── cloud-blackbox            Storage/gateway/CDN fingerprinting, artifact mining
    │   └── saas-blackbox             Third-party vendors, aliases, impersonation
    └── whitebox/                     privileged access; split by technology
        ├── aws-whitebox              Accounts, buckets/gateways/function URLs, snapshots
        ├── azure-whitebox            Subscriptions, public IPs/NSGs, App Service, storage rules
        ├── gcp-whitebox              Org/projects, allUsers bindings, forwarding rules, SQL
        ├── ip-whitebox               IP registers reconciled via console access
        ├── dns-whitebox              Zone exports vs. reality reconciliation
        ├── email-whitebox            Gateway/tenant-side sender reconciliation
        └── saas-whitebox             IdP/tenant sourcing; provider-maturity fallback to blackbox
```

How variants relate: **black-box** = external-only perspective (public data +
polite probing); **white-box** = engagement access (consoles, exports,
credentials). Every discovery skill follows the same shape: enumerate →
verify live → fingerprint/classify → hand off to sibling skills ("feed the
loop") → iterate until two passes bring nothing new.

The library grows only from field verification: when real testing verifies,
refutes, or extends what a skill says, `@skill-improve` records it into that
skill (tested / candidate / correction labeling) — see
[docs/authoring.md §8](docs/authoring.md#8-the-improvement-loop--real-testing-feeds-the-library).

## Layout

```text
opencode.json      registers ./skills, so skills also load inside this repo
skills/            the shared library (tree above)
  index.json       generated HTTP-catalog manifest (CI-refreshed)
templates/         skeleton copied by the scaffold script
scripts/           repo tooling (scaffold, catalog build)
docs/authoring.md  conventions + security/redaction checklist for new skills
```

## Using these skills elsewhere

**1. Global source — recommended.** Available in every project:

```jsonc
// ~/.config/opencode/opencode.json
{
  "$schema": "https://opencode.ai/config.json",
  "skills": ["~/git/skills/skills"]
}
```

**2. Per-project source / submodule.** Vendor this repo as a git submodule and
point the project's `opencode.json` at its `skills/` directory, or reference a
local clone:

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
touching `skills/`. Never edit it by hand.

## Creating a skill

```powershell
./scripts/new-skill.ps1 -Name recon-report -Description "External recon report for a domain"
./scripts/build-catalog.ps1   # refreshes index.json
git add skills/ && git commit -m "skill: recon-report — domain recon report"
```

The fastest way to convert existing material is via the meta-skill:

> @skill-factory — turn this methodology note into a skill

`skill-factory` places the skill in the tree, classifies the material, redacts
client-sensitive content, and scaffolds everything.

## Conventions (summary)

- Skill ID = leaf directory name (unique, lowercase kebab-case); intermediate
  directories are grouping only and must **not** contain `SKILL.md` (OpenCode
  would stop searching below them). Depth ≤ ~5 directories below `skills/`.
- Frontmatter `description` is the discovery trigger: write it as "when the
  agent should use this".
- `SKILL.md` is a lean playbook (purpose → inputs → workflow → output →
  safety rules); long-form content goes in `references/`, repeated commands in
  `scripts/` (PowerShell-first).
- Full rules: **[docs/authoring.md](docs/authoring.md)** — including the
  confidentiality checklist: skills are product-agnostic security knowledge
  (no client names, no program-specific data, `example.com` only in
  examples), tested-in-practice techniques only.
- Client-bound knowledge is never centralized here — project-local skills in
  the client's own repo take precedence on conflicts.
