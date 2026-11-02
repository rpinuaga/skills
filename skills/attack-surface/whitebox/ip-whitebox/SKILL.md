---
name: IP Attack Surface — White Box
description: >-
  Reconcile an organization's IP asset inventory (cloud consoles, CMDB,
  hosting contracts, network diagrams) against the IPs that actually exist and
  answer. Use when an engagement provides white-box access to infrastructure
  records or console access. Use the black-box variant when no privileged
  access exists.
---

## Purpose

Turn privileged visibility into a verified IP asset register: what the client
thinks it owns and exposes vs. what is really live outside. Find shadow IP
space, forgotten environments, and drift between records and reality.

## Inputs

Ask for whatever the engagement provides: cloud console / CLI read-only
credentials, CMDB or asset-management export, hosting and connectivity
contracts (which announced ISP ranges belong to which business unit), network
diagrams, firewall/CDN rule base. Work read-only by default.

## Workflow

1. **Enumerate declared space** from records: contracts (announced ISP-derived
   ranges and provider ASNs), CMDB subnets, cloud consoles (virtual private
   cloud subnets, reserved/elastic IPs, load-balancer frontends). Tag each with
   owner business unit and environment (prod / pre / dev).
2. **Passive-verify each range**: reverse DNS, certificate store lookups,
   conservative port probing of a sample set, SNI probing. Mirror the
   verification approach of `@ip-blackbox` (exact app-level fingerprints, not
   generic `200`s).
3. **Reconcile.** Build a deltas list:
   - declared but not answering (parked, filtered, decommissioned),
   - answering but undeclared (shadow infrastructure, personal dev servers,
     forgotten environments),
   - answering third parties on ranges assumed to be owned (registrant vs.
     ISP-labeled space, shared provider IP pools).
4. **Classify environment exposure.** Check with the client whether each
   environment should be internet-reachable at all; pre/dev environments
   exposed publicly are usually the highest-value finding class.
5. **Report** both directions: the verified asset register (prefix → owner →
   environment → exposed services → verification evidence) and the
   reconciliation findings, each with a recommendation.
6. **Feed the loop.** Undeclared-but-live assets found in reconciliation feed
   the discovery skills for deeper mapping (`@ip-blackbox` probing,
   `@dns-blackbox` for their names, `@aws-whitebox`/`@azure-whitebox`/
   `@gcp-whitebox` scoping for their accounts) — the internal register and
   the external probe loop converge until they agree.

## Output format

A verified IP asset register plus a deltas/reconciliation findings list. Each
entry carries: source of record, verification evidence (command + date +
output reference), and confidence.

## Safety rules

- Read-only unless explicitly authorized for changes; console actions only
  after approval.
- Deltas must be logged, not silently fixed: flag forgotten infrastructure to
  the client — do not shut anything down yourself.
- Respect data-handling rules on any CMDB export (typically internal-only
  material): keep it out of public repos and reports beyond redacted summaries.
- Confirm ownership of provider-managed IPs (shared pools) before attributing
  anything to the client.
