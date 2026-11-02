---
name: IP Attack Surface — Black Box
description: >-
  Map the internet-facing IP space of a target using only external sources:
  RIR records, announced prefixes, cloud provider ranges, search engines, port
  probing and vhost origin fingerprinting. Use for black-box asset discovery
  of an external organization.
---

## Purpose

Find which IP space belongs to the target organization and what answers on it
— before touching anything the client didn't publish. External-only: no access
to the client's systems.

## Inputs

Ask the user for (or confirm): target domains and company legal names, the
authorization that covers the work (engagement contract / rules of engagement /
disclosed testing program), and any already-known hostnames/IPs to anchor
fingerprints. All examples in this skill use `example.com` as a placeholder.

## Workflow

1. **Identify the organization's own RIR space.** In RIPE/whois, distinguish
   two very different kinds of results:
   - Networks where the organization is the **registered organisation**
     (`org:` attribute / org handle) — safe to scan from an IP-space view.
   - Blocks where the name only appears in `netname`/`descr` because an ISP
     allocated it to the org as a customer — NOT the org's own space.
   Verify with an inverse lookup by org handle:
   `https://rest.db.ripe.net/search.json?query-string=ORG-XXXX-RIPE&inverse-attribute=org&type-filter=inetnum,inet6num,aut-num&flags=xB`
2. **Resolve announced prefixes** for the org's ASN (RIPEstat
   `announced-prefixes`, or BGP tools). Enterprise space announced via an ISP
   (reverse DNS named after the ISP) usually reads as corporate egress /
   remote-access infra — those VPN/SSO portals are rarely the engagement
   target and often out of scope; note them but don't probe deeply.
3. **Cloud-range matching.** Match inventory hostnames against cloud provider
   published ranges (e.g. AWS `ip-ranges.json`) to catch cloud-hosted assets
   that don't follow any naming convention. Save raw match data.
4. **Search engines of endpoints.** Use Censys/Shodan for certificates and
   hosts referencing the target. Beware the false-positive pattern: brand names
   matching in *page body hyperlinks* are unrelated third parties; only asset
   paths, build hashes, or header values are meaningful signals.
5. **Conservative port probing.** `nmap -Pn -p 80,443 --open -T3` (never `-T5`,
   never aggressive scripts on production). Note hostlists for later diffing.
6. **Vhost / origin fingerprinting.** For each live IP, probe with the target
   `Host` header and SNI (a six-way check: HTTP/HTTPS × each target hostname ×
   meaningful endpoints) and compare against **exact known app-level
   fingerprints** (distinctive `/health`-style bodies, exact 404 catch-all
   messages) — a generic `200` proves nothing. Repeat the set with an extended
   HTTP-method list (WebDAV-style verbs included) and with host-rewrite
   headers (`X-Forwarded-Host`, `X-Host`, `X-Original-Url`, `X-Rewrite-Url`)
   — tested origin-spoofing probes that fingerprint alternate routing layers.
   Only true app-fingerprint matches are origin candidates.
7. **Classify every match.** Check response headers for protection layer
   fingerprints (Akamai cookies (`_abck`, `bm_sz`), Cloudflare
   (`cfReqDur`, `Cf-Team`), F5 (`TS*`)) — a "bypass" behind a second WAF vendor
   is an alternate protected path, not an unprotected origin. Detect bare
   origins via absence of all CDN signatures + host-header-agnostic responses.
8. **Snare dev servers and phishing clones.** Bare origins with dev markers
   (`//localhost` OG tags, HMR client chunks, world-readable source maps,
   `/admin/login` on a fresh stack) are often developer VPSes or AI-generated
   brand clones. Phishing clones are **out of scope — never test them**; report
   to the organization's abuse channel with evidence (source map, build hash).
9. **Inventory.** Record everything into the engagement's recon area; keep a
   curated hostname/IP inventory file that is appended to, plus raw outputs,
   and diff on re-runs.
10. **Feed the loop.** Every confirmed finding re-enters discovery: new
    domains seen in certificate SANs → `@dns-blackbox`; new vendor/CDN
    fingerprints → `@saas-blackbox`; reachable storage/gateway endpoints →
    `@cloud-blackbox`. Iterate until two consecutive passes produce no new
    surface — discovery is a loop, not a phase.

## Output format

- An IP asset map: prefix → hosts → open ports → vhost classification
  (protected edge / alternate protected path / bare origin / third-party).
- Notes on protection layers per origin and the exact fingerprints used.

## Safety rules

- Confirm scope/authorization exists for every IP actually probed; ISP-labeled
  ranges and neighboring VPS owners are not in scope.
- Never send credentials or tokens over plaintext paths (HTTP-only ports,
  filtered TLS) discovered during this work.
- Do not test third-party or impersonation infrastructure; report instead.
- Keep port scanning polite on production: no `-T5`, no aggressive `-A` on
  sensitive targets.
- Secrets or personal data found incidentally are not to be downloaded or
  exfiltrated beyond what's needed to document the exposure.
