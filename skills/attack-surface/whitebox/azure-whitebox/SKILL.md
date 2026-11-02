---
name: Azure Attack Surface — White Box
description: >-
  Enumerate the Azure estate of a target with authorized credentials:
  subscription/tenant inventory and the Azure-specific way to enumerate
  publicly reachable services (public IPs/NSGs, App Service/Front Door,
  storage network rules, function-app auth levels, AKS API exposure). Use
  when the engagement grants Azure portal or CLI access; use @cloud-blackbox
  when it does not.
---

## Purpose

Same goal as `@aws-whitebox`, run in Azure's structure: tenant/subscriptions,
resource groups, and the exposure question answered with Azure's own
control-plane facts (network rules, firewalls, auth levels instead of
policies-and-stages).

## Inputs

Ask for: subscription list / management-group scope, reader role on the
scoped subscriptions, Entra ID directory visibility if available, prior
posture reports, and the CMDB/register.

## Workflow

1. **Tenant inventory.** `az account list` across tenants, management-group
   hierarchy, subscription purposes and owners; tag prod/pre/dev splits.
2. **Access hygiene.** Confirm reader role set; wherever conditional
   access/PIM exists, work within it; a harmless read registry proves
   effective permissions.
3. **Posture audit pass.** Per subscription across Azure regions (Azure
   gates services per region, so sweep regions, not just the default one);
   keep dated reports per scope.
4. **Internet exposure audit — Azure-specific enumeration.**
   - Public IPs and their NSG rules (which ports actually come in, per
     resource, not per subscription summary).
   - App Service / Front Door: which apps are publicly routable, auth
     configuration, custom domains resurrecting on other apps.
   - Storage accounts: network rules (`default action`, virtual network
     exemptions) and public access settings — Azure answers "is this open?"
     in the storage resource, not in policy documents.
   - Function Apps: HTTP-trigger auth levels as the public/not-public fact.
   - SQL/logical servers: firewall rules including any "allow all" row.
   - AKS: API server endpoint visibility (public cluster vs. private).
   - Container registries and key vaults: network restrictions.
5. **Environment parity.** prod vs pre/dev subscriptions and resource
   groups: same checks; note shared infra (e.g. shared vNets) that changes
   blast radius.
6. **Declared vs deployed reconciliation** against CMDB/architecture docs;
   subscriptions nobody owns and regions nobody claimed are findings.
7. **Report.** Exposure matrix (subscription × resource → exposure →
   evidence), parity findings, remediation priorities.
8. **Feed the loop.** Externally visible hostnames (App Service custom
   domains etc.) hand off to `@ip-blackbox`/`@dns-blackbox`; new scopes feed
   this sweep.

## Output format

Per-subscription exposure matrix with per-row evidence; parity table;
reconciliation list.

## Safety rules

- Read-only posture; PIM activation is a change — use only existing standing
  grants unless the client approves more.
- Storage/log data: presence and configuration evidence, not bulk export.
- Scope discipline: enumerate only granted subscriptions; tenant-wide graph
  reads only where the field engagement includes them.
- Configuration exports stay in the engagement area.
