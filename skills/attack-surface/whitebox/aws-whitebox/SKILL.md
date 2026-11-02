---
name: AWS Attack Surface — White Box
description: >-
  Enumerate the AWS estate of a target with authorized cloud credentials:
  account inventory via Organizations, assumed-role audits, and the
  provider-specific way to enumerate publicly reachable services (buckets,
  gateways, function URLs, snapshots, load balancers). Use when the
  engagement grants AWS console or CLI access; use @cloud-blackbox when it
  does not.
---

## Purpose

With authorized access, enumerate what the client runs in AWS, what answers
from the internet, and where environments drift (pre/dev looser than pro) —
each of those questions has an AWS-specific technical answer that differs
from other providers.

## Inputs

Ask for: the AWS account list in scope (org-level or enumerated accounts),
read-only roles to assume per account, prior CSPM/scanner reports, and the
CMDB/register to reconcile against. Maintain a current region list under the
provider's reference material — enumerate per region, not just the default
one.

## Workflow

1. **Account inventory.** `aws organizations list-accounts`, aliases,
   contact/scope flags, tags; separate production/pre/dev into distinct
   accounts (that is *how* AWS engagements are scoped).
2. **Assume-role hygiene.** Establish the read-only role per account;
   confirm effective permissions with a harmless describe/list call before
   trusting either the provider's docs or the role's policies. Validate
   account identifiers from external artifacts against this inventory
   (e.g. ARN-style error messages from unauthenticated probes, as documented
   in `@cloud-blackbox`).
3. **Posture audit pass.** Per account across all regions: an open-source
   auditor (e.g. ScoutSuite) or AWS-native posture tools; store dated
   reports per account.
4. **Internet exposure audit — AWS-specific enumeration.**
   - Object storage: bucket policies/ACLs plus account-level public access
     blocks, per region `s3api get-*` flows.
   - API gateways: resource policies *per stage* (the pre/pro divergence
     shows here).
   - Lambda: function-URL auth type (unset auth = public).
   - Load balancers: listeners and target exposure; security-group ingress
     with 0.0.0.0/0 rules that the client cannot justify.
   - Snapshots/public images: database cluster/snapshot and AMI surfaces
     with public visibility switches toggled (`--include-public`-style).
   - Distributions/CDN origins and their origin-verify protections;
     container registries; DNS records feeding externally resolvable names.
5. **Environment parity.** Same service family across prod/pre/dev accounts:
   who can invoke, what's public, gateway permissiveness, backup/monitor
   entry points. Laxer pre/dev publicly reachable is a top finding class.
6. **Declared vs deployed reconciliation** against CMDB/architecture docs;
   shadow accounts and unclaimed regions are findings.
7. **Report.** Exposure matrix (account × service → exposure → evidence),
   parity findings, remediation priorities tied to business impact.
8. **Feed the loop.** Externally visible hostnames discovered here hand off
   to `@ip-blackbox`/`@dns-blackbox` for origin verification; new accounts
   feed this skill's own enumeration sweep until it stabilizes.

## Output format

Per-account exposure matrix with per-row policy/document evidence;
environment-parity table; reconciliation list with ownership questions.

## Safety rules

- Read-only posture; no resource or policy modification.
- Minimize data pulled from buckets/snapshots: presence and policy evidence.
- Assume-role stays in scoped accounts even where reads would succeed.
- Treat configuration exports (policies, IAM internals) as confidential;
  nothing leaves the engagement area.
