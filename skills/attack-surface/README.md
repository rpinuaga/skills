# Attack Surface Discovery

Skills that map what an organization exposes, before any testing begins.
The tree splits by surface type, and each surface splits by knowledge level:

- **black-box** — external-only perspective: public data, probing, OSINT. No
  access to the target's internal systems or records.
- **white-box** — engagement with access: client-provided inventories, console
  access, zone exports. Recon of what we can enumerate with credentials.

> Note for agents: these README.md files are human navigation only and are NOT
> discovered as skills. The actual skills are the leaf directories containing
> `SKILL.md`, referenced by ID (e.g. `@dns-blackbox`).

Subtrees: `internet/` (ip, dns, email), `cloud/`, `saas/`.

Source methodology: the user's private notes vault, generalized — techniques
only, no client-specific findings, names, or program data.
