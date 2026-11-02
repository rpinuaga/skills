---
name: Cloud Attack Surface — White Box
description: >-
  Enumerate the cloud estate of a target with authorized cloud credentials:
  account inventory, public-facing resource policies, environment parity, and
  reconciliation of declared vs deployed. Use when an engagement grants
  console/CLI access. Use the black-box variant when no credentials exist.
---

## Purpose

With authorized access, enumerate what the client actually runs, what is
publicly reachable, and where environments drift (pre/dev looser than prod) —
the drift is usually where the exposure lives.

## Inputs

Ask for: cloud account inventory (org/tenant root or the account list with
scope), read-only role/permissions to assume, CSPM or prior audit reports, and
the asset/environment register to reconcile against.

## Workflow

1. **Account/tenant inventory.** Enumerate org units, accounts, providers
   per account, and account aliases/owners; note which are in engagement
   scope.
2. **Assume-role hygiene.** Establish read-only runtime access per account;
   confirm effective permissions before acting on findings (don't trust
   configured policy docs — verify with a harmless describe/list call set).
3. **Posture audit pass.** Run an open-source posture auditor
   (e.g. ScoutSuite for multi-cloud) or the provider's posture tool per
   account; keep reports per account with the run date.
4. **Internet exposure audit (the core deliverable).** For each account:
   load-balancer listeners/ingress rules, object-storage ACLs and resource
   policies, gateway resource policies (per stage), function-URL auth
   settings, distributions with direct origins, database/snapshot publicity
   (`--include-public`-style checks). Query everything, not just the
   "production" pattern — filter personal sandboxes for a separate finding.
5. **Environment parity.** Compare prod vs pre vs dev configuration per
   service family: who can invoke, what's public, monitoring/actuator
   exposure, gateway permissiveness. Laxer pre/dev fronts exposed to the
   internet are a top finding class.
6. **Declared vs deployed reconciliation.** Compare with the client's CMDB
   and architecture docs: shadow accounts/resources, undocumented
   environments, resources in regions nobody claimed.
7. **Report.** Exposure matrix (account × service → exposure → policy
   evidence), parity findings, and remediation priorities tied to business
   impact, not scanner severity alone.

## Output format

- Per-account exposure matrix with policy/document evidence per row.
- Environment-parity findings (table: service, prod setting, pre setting,
  delta, risk verdict).
- Reconciliation list declared-vs-deployed with owner/attribution questions
  flagged for the client.

## Safety rules

- Read-only posture: no resource modification, no tagging "helpfully" on the
  way; every action through the provided roles.
- Minimize data pulled from buckets/snapshots: presence and policy-level
  evidence, not bulk export of customer data.
- Assume-role chains stay in scope accounts; lateral listing beyond the
  granted scope is out of bounds even if technically readable.
- Handle configuration exports (policies, IAM internals) as confidential:
  aggregate in client deliverables, nothing leaves the engagement area.
