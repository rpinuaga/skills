---
name: DNS Attack Surface — White Box
description: >-
  Reconcile the DNS zones an organization controls (zone exports, registrar and
  cloud DNS panels) against what is actually resolvable and exposed externally.
  Use when an engagement provides access to DNS management or zone exports.
  Use the black-box variant when no privileged access exists.
---

## Purpose

With visibility into the zones, find the records nobody remembers: stale
entries, dangling aliases, forgotten pre/dev zones, and the gap between
internal zones and what the outside world can see.

## Inputs

Ask for zone exports / provider console or API access (read-only), the domain
portfolio list, and any change-management artifacts that help date records.

## Workflow

1. **Enumerate every zone** the client controls: registrar account, cloud DNS
   services, legacy providers. Export record sets (A/AAAA/CNAME/TXT/MX/NS/SRV)
   per zone, noting provider, zone age and TTL distribution.
2. **Inventory record risk classes:**
   - aliases pointing at provisioned-elsewhere hosting (SaaS, storage, load
     balancers) — takeover candidates if the service is gone,
   - wildcards and their blast radius,
   - pre/dev/test zones resolvable from the public internet,
   - TXT/verification records revealing vendors, owner emails, internal
     project names,
   - deprecated name servers still registered or delegating stale zones.
3. **Test the real world for each record**: resolve every name today (fresh
   resolvers + resolvers in different regions), note non-answers, sinkholes
   (`127.0.0.1`-style), and alias chains ending in errors.
4. **Reconcile internal vs. external.** Compare the zone exports against
   externally visible enumeration (`@dns-blackbox`) to classify: public but
   unlisted internally (shadow), internal-only intended but publicly
   resolvable (exposure), and external records with no internal owner.
5. **Verify takeover candidates** without exploiting: confirm the dangling
   alias target is genuinely unclaimed/unprovisionable-before-claim, and stop
   there. Actual takeover belongs to an exploitation scope with approval.
6. **Report** per zone: findings with owner/env context, evidence, TTL/alias
   detail, and concrete cleanup recommendations (rotate, delete, redelegate,
   restrict). Separate "risk now" from "risk on next renewal".
7. **Feed the loop.** Any zone/record class exported here that isn't visible
   to `@dns-blackbox` enumeration is an internal-only lead — hand it to that
   skill's convention model as ground truth for future targeted probing.

## Output format

Per-zone reconciliation report: record inventory summary, findings list
(owner, evidence, risk), cleanup recommendations. Include the deltas matrix
(internal-yes/external-yes/no).

## Safety rules

- Read-only until explicitly authorized for changes; changing records is out
  of scope for this skill even if the user has write access.
- Confirm a takeover candidate's dangling state with evidence before
  reporting; false takeover reports are common (custom error pages, parked
  domains that are still claimed).
- Credentialed DNS API access stays within the provided tenant; never snowball
  into other zones/auth casual usage beyond the grant.
- Treat exported zones as internal-only material: aggregate in reports,
  don't publish raw exports.
