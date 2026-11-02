---
name: GCP Attack Surface — White Box
description: >-
  Enumerate the GCP estate of a target with authorized credentials:
  organization/project inventory and the GCP-specific way to enumerate
  publicly reachable services (external IPs, forwarding rules, allUsers
  invokers, public buckets, SQL authorized networks). Use when the
  engagement grants GCP IAM access; use @cloud-blackbox when it does not.
---

## Purpose

Same goal as `@aws-whitebox`/`@azure-whitebox`, run in GCP's structure:
organization → folders → projects, exposing surface answered through IAM
members (allUsers/allAuthenticatedUsers named bindings) and network facts.

## Inputs

Ask for: organization/folder/project inventory in scope, read-only roles
(viewer, or security reviewer style), org-policy visibility if available,
prior posture reports, CMDB/register.

## Workflow

1. **Project inventory.** `gcloud projects list` across the org, folder
   structure, purposes/owners, prod/pre/dev project splits.
2. **Access hygiene.** Confirm read-only grant; validate effective
   permissions with a harmless describe/get call.
3. **Posture audit pass.** Per project, open-source multi-cloud posture
   tooling or GCP-native; keep dated reports per scope.
4. **Internet exposure audit — GCP-specific enumeration.**
   - IAM members flattened everywhere: project, resource, and bucket/job
     bindings mentioning public members are the core "is this exposed?"
     fact — unlike AWS policies, bindings name the public principals
     directly.
   - Compute: external IPs, firewall rules allowing all-source on real ports.
   - Load balancing: external forwarding rules, their routing schemes.
   - Serverless: Cloud Run/Functions invoker bindings (public member =
     unauthenticated).
   - Storage: bucket IAM bindings + uniform bucket access; websites served
     straight from public buckets.
   - SQL: public-IP instances plus authorized networks including any
     0.0.0.0/0.
   - App Engine / Firebase hosting: default domains reachable with standard
     serving configs; check their auth/serving configuration.
5. **Environment parity.** prod vs pre/dev projects; org policies
   (differences in allowed bindings or public-IP policies are the real
   story where configured).
6. **Declared vs deployed reconciliation** against CMDB/docs: shadow
   projects, shared service projects, unclaimed folders are findings.
7. **Report.** Exposure matrix (project × resource → exposure → evidence),
   parity findings, remediation priorities.
8. **Feed the loop.** Externally visible hostnames/app domains hand off to
   `@ip-blackbox`/`@dns-blackbox`; new projects feed this sweep.

## Output format

Per-project exposure matrix with per-row evidence (the named public binding
for each exposed resource); parity table; reconciliation list.

## Safety rules

- Read-only posture; org-policy changes are out of scope.
- Paste-exports of IAM bindings are confidential: aggregate in deliverables.
- Minimize data pulled from buckets: presence/binding evidence only.
- Scope discipline: enumerate only granted projects/orgs.
