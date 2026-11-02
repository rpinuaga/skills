# Attack Surface Discovery

Skills that map what an organization exposes, before any testing begins.
The tree splits first by **knowledge level**, then applies a different
organizing key per half:

```text
attack-surface/
├── blackbox/    ← external-only. Split by ASSET CLASS (dns, ip, email, cloud, saas):
│                  from outside, the underlying technology usually doesn't change
│                  the technique.
└── whitebox/    ← privileged engagement access. Split by TECHNOLOGY
                   (aws, azure, gcp, mail platforms, IdPs): each stack has a
                   different control plane that answers "what is exposed".
```

Rules of thumb across both halves:

- Every skill follows the same shape: enumerate → verify live →
  fingerprint/classify → "feed the loop" hand-offs to sibling skills →
  iterate until two passes bring nothing new.
- White-box depth is vendor-dependent: technologies with thin discovery APIs
  (classic enterprise suites such as ERP/CRM platforms) default back to the
  black-box route.
- Prioritize low-visibility surface: secondary environments (pre/dev),
  forgotten assets, secondary brands/sub-brands, mobile-only or partner-only
  properties.

> Note for agents: these README.md files are human navigation only and are NOT
> discovered as skills. The actual skills are the leaf directories containing
> `SKILL.md`, referenced by ID (e.g. `@dns-blackbox`, `@aws-whitebox`).

Source methodology: the user's private notes vault, generalized — techniques
only, no client-specific findings, names, or program data.
