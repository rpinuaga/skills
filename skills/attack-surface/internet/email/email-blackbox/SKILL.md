---
name: Email Attack Surface — Black Box
description: >-
  Assess the email attack surface of a domain from public DNS only: sender
  authentication posture (SPF/DMARC/DKIM), MX routing, third-party senders,
  dangling ESP aliases, and lookalike domains. Use for external email
  attack-surface mapping. Use the white-box variant when the engagement grants
  mail-platform visibility.
---

## Purpose

Map what an attacker could do with the target's email identity from outside:
who is allowed to send as it, who maps to receive it, and where the
authentication story breaks. External-only: public DNS, no test messages.

## Inputs

Target domain list and the authorization that covers lookalike-domain
registration checks (passive whois only by default).

## Workflow

1. **SPF posture.** Fetch TXT on the bare domain; flatten `include:` chains
   (recording nested providers); flag: exceeds DNS 10-lookup limit, `+all` or
   `?all` terminators, includes for decommissioned vendors, records so long
   that some resolvers truncate.
2. **DMARC posture.** Read the policy (p/sp/pct), aggregate-forensic report
   destinations (are they inside the org's domain? a vendor's?), and whether
   subdomains inherit enforcement. Note policies that look enforced but whose
   report destinations are unmonitored or off-domain — enforcement without
   visibility is not enforcement.
3. **DKIM discovery.** Probe signing keys on `<selector>._domainkey` for a
   curated selector wordlist (vendor-reported defaults first); map selectors
   to vendors via the CNAME/host shapes of the signing records (vendor mail
   stacks have distinctive DNS targets).
4. **MX & routing fingerprinting.** MX vendor (mail gateway suites are
   recognizable from host naming), spam-gateway CNAME-style double hops,
   internal-only routes exposed; if a management/portal hostname resolves,
   note, don't probe.
5. **Third-party senders.** From SPF includes + CNAME/TXT fingerprints, build
   the "sends-as-me" vendor list. Flag aliases that render to a vendor but
   don't appear usable/deliverable (deprovisioned) — takeover-risk flag, no
   claiming.
6. **Lookalike domains.** Passive-only check (no registration, no NXDOMAIN
   walks): exact-brand lookalikes on different TLDs and hyphen/typo variants
   using RIR whois and CT-log lookups (`ct-disco` with a `brandname` term not
   TLD-anchored also works). Confirm by TLS certificate issuer/owner — not by
   interacting with any host or mail system.
7. **Feed the loop.** New domains surfaced (acquisitions, newly announced
   subdomains, new sender vendors, lookalike observations) flow back into
   `@dns-blackbox` and into this skill's per-domain run for the widened
   portfolio; iterate until two consecutive passes bring no new surface.

## Output format

Per-domain email posture report: SPF summary (verdict + flagged includes),
DMARC policy assessment, discovered DKIM selectors/vendor map, senders table,
dangling-alias flags, lookalike-domain observations with evidence — severity
notes included.

## Safety rules

- **No email is sent without explicit authorization.** This skill is
  observation-only; even benign "are you real?" probes are out of scope here.
- No collecting or interacting with third-party mailboxes; whois/CT lookups
  stay passive.
- Report discovered third-party data (personal emails in SPF/DMARC report
  addresses) in aggregate, redacted.
- Registering, probing, or testing lookalike domains is out of scope without
  explicit, specific authorization.
