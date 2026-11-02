---
name: DNS Attack Surface — Black Box
description: >-
  Discover an organization's DNS records and hostnames using only external
  sources: certificate transparency logs, passive enumeration, learning the
  target's internal naming conventions, and code-hosting search. Use for
  black-box hostname/asset discovery tied to one or more target domains.
---

## Purpose

Build a complete-enough hostname inventory of a target domain from outside,
and — the high-value part — learn how the organization names its internal
infrastructure, so later guesses are informed rather than brute-force.

## Inputs

Target domain(s), the authorization covering enumeration and any probing of
discovered hosts, and any known hostnames to bootstrap.

## Workflow

1. **Passive enumeration.** Combine sources, dedupe, and keep each run's raw
   output:
   - CT log stores: `crt.sh` / Certspotter API (the latter rate-limits —
     pace requests, resume later rather than hammering) or direct CT log
     scanning, e.g. the user's own `ct-disco` tool (`python3 ct-disco.py -k
     example.com --log all --max 5000`).
   - Passive DNS via public aggregate sources, e.g.
     `subfinder -d example.com -silent`.
2. **Mine CT output for structure, not just names.** From observed hostnames,
   derive the organization's own naming convention: project/app codenames,
   environment suffixes (`pro`/`pre`/`dev` styles), cloud-provider tokens in
   the zone structure, region hints. This convention document is core output —
   real internal names are usually arbitrary project codes, so *generic*
   origin-name wordlists (`api-origin`, `www2`, …) rarely match.
3. **Informed dictionary probes.** Only after step 2, probe DNS names built
   from the observed convention: {app}.{env}.{cloud-token}.{zone} shapes,
   {app}-{env} hybrids, brand-relative variants of *confirmed* patterns.
   Record every probe batch (names tried, source, result counts) so dead ends
   are evidence, not wasted time.
4. **Hostnames written down, not linked.** Where general search engines fail
   (they don't index unlinked infrastructure), use code-hosting search:
   authenticated API queries for the target domain and for hero-segment
   token values; also blocklist-like aggregators as low-trust free sources.
   Respect rate limits (~1 query/minute) and space retries out.
5. **Cloud-managed-name leakage.** Grep all collections for anything that
   leaks provider-managed service hostnames or IDs: 12-digit numeric strings,
   `nlb-`, `*.elb.*.amazonaws.com`, `*.cache.amazonaws.com`, `deploy.local`
   style internal artifacts. Document partial identifiers (regions, IDs,
   masked account fragments) as discovery results.
6. **Origin candidates.** For every promising name, resolve and run vhost
   verification per `@ip-blackbox` (exact fingerprints; classify protection
   layer; most results will be CDN-fronted inert infrastructure).
7. **Sinkholes and deprovisioned names.** Flag names resolving to obvious
   sinkholes (`127.0.0.1`, parked pages) and aliases pointing at provisioned-
   nowhere hosting — both are finding candidates (the latter for takeover
   analysis, which is out of this skill: stop at flagging).
8. **Inventory hygiene.** Maintain ONE curated hostname inventory file per
   engagement, append-only across sessions; keep raw dumps separate. Note
   borderline assets (personal sandboxes, partner-hosted) in comments rather
   than mixing them silently into the main list.
9. **Feed the loop.** Every new finding seeds the next enumeration pass: new
   senders/domains from certificates → widen `@ip-blackbox` probing and
   `@email-blackbox` posture runs; new cloud-token/zone shapes seen → refine
   the convention model before the next probe batch. Iterate until two
   consecutive passes produce no new surface.

## Output format

- Curated hostname inventory (append-only + dated raw dumps).
- A naming-convention model: structure, env tokens, cloud tokens, observed
  codename families, with a confidence note on each element.
- Confirmed non-CDN paths list with the verification evidence rows.

## Safety rules

- Enumeration itself is safe; *probing* discovered hosts needs the
  authorization to cover them, especially pre/dev environments and anything
  looking like an individual's personal sandbox.
- Pace external CT/DNS APIs deliberately; treat their rate limits as a design
  constraint, not an obstacle to defeat.
- Never assume a resolved name is target-owned without corroboration
  (certificate, content, or convention fit) — shared cloud zones host other
  organizations' names too.
- Anything found that isn't the target (phishing lookalikes, other tenants')
  gets reported or documented, not tested.
