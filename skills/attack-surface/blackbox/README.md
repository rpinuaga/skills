# Black-box discovery

External-only attack-surface discovery: public data plus polite, scoped
probing. Skills here are split by **asset class**, not by technology — from
outside, the underlying stacks usually don't change the technique. Each leaf
carries the tested workflows for its class:

| Leaf skill     | Class                                                            |
| -------------- | ---------------------------------------------------------------- |
| `ip-blackbox`  | IP space, ASNs, ports, vhost/origin fingerprinting               |
| `dns-blackbox` | CT logs, passive sources, naming-convention mining               |
| `email-blackbox` | SPF/DMARC/DKIM, MX, third-party senders, lookalike domains     |
| `cloud-blackbox` | Storage/gateway/CDN fingerprinting, artifact mining, oracles   |
| `saas-blackbox` | Third-party vendors, aliases, impersonation detection           |

Where a target's technology *does* change the technique (deep provider
enumeration with credentials), that work lives in `../whitebox/`.

Human navigation only — skills are the `SKILL.md` leaf directories.
