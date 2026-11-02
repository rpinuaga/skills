---
name: SaaS Attack Surface — White Box
description: >-
  Map the SaaS tenant estate from inside: identity-provider app inventory,
  OAuth grants and API tokens, shadow SaaS from SSO/egress logs, and tenant
  configuration hygiene. Use when an engagement provides IdP or admin
  visibility. Use the black-box variant when nothing is provided.
---

## Purpose

With tenant/IdP visibility, turn "what SaaS might they use" into a verified
tenant map: what is connected, with which identity, at what data scope — and
what connects *around* the controls.

**Provider-maturity rule.** White-box depth here depends entirely on the
vendor's own admin/API surface. Modern SaaS with admin APIs and SSO
integration supports real enumeration; classic enterprise suites (ERP/CRM
platforms and similar) often expose almost nothing tenant-side for
discovery — those are usually approached black-box (`@saas-blackbox`) with
this skill as auxiliary. Decide per vendor before planning the enumeration.

## Inputs

Ask for: IdP (SSO) admin visibility or app-inventory export, tenant admin
access for the SaaS platforms in scope, identity OAuth-consent data,
proxy/egress logs, and ITSM/procurement vendor lists.

## Workflow

1. **IdP application inventory.** Export the SSO app catalog: app, protocol
   (SAML/OIDC), users/groups assigned, admin status, age. An app assigned to
   *everyone* is a different risk class than one pilot group.
2. **OAuth grants and tokens.** Enumerate consent grants (per user and
   tenant-wide) and registered API integrations: scopes are the story — list
   over-scoped grants, grants to unknown apps, and personal-consent apps
   where tenant-wide should have applied.
3. **Tenant configuration hygiene.** For each tenant in scope with admin
   access: MFA enforcement and recovery channels, external sharing defaults,
   admin isolation and audit, session/token lifetimes, service accounts with
   long-lived static keys.
4. **Shadow SaaS.** From SSO logs (apps used that bypass SSO), egress/proxy
   logs (tenant domains never routed through IdP), and mailbox mail-flows
   (`@email-whitebox` support), build the shadow-SaaS list; reconcile with
   procurement to classify "stale", "unmanaged-but-legal", and "unsanctioned".
5. **Reconciliation.** Merge black-box data (`@saas-blackbox`: externally
   visible vendors/aliases) with the tenant inventory; conflicts (visible but
   unknown internally, or internally known but externally invisible) are
   findings themselves.
6. **Report.** Tenant map (app → owner → identity flow → data scope →
   hygiene status), grant/token risk table, shadow-SaaS register with
   recommended governance actions (cycle: SSO onboarding, deprovisioning),
   prioritized fixes.
7. **Feed the loop.** Every vendor confirmed here seeds checks in the other
   skills: externally visible aliases → `@saas-blackbox` verification; vendor
   mailers → `@email-whitebox`; vendor-hosted infrastructure →
   `@cloud-blackbox`/`@ip-blackbox` probes. Conflicts between tenant reality
   and external enumeration re-open the loop for the affected asset class.

## Output format

- Tenant map + grants/tokens table with scope justification per row.
- Shadow-SaaS register with evidence source and a governance action each.
- Prioritized remediation list distinguishing identity fixes (IdP-side) from
  tenant configuration fixes (vendor-side consoles).

## Safety rules

- Read-only exports; never modify tenant configuration, grants, or app
  registrations during discovery.
- Consent/OAuth data is sensitive: aggregate over user counts, redact
  individual accounts in deliverables.
- Credentials/access brokers stay inside the engagement; exports must never
  land in public repos (redaction checklist in `../../../../docs/authoring.md`).
- Third-party tenant logs often contain user-level PII from *other* vendors:
  touch them only when scope justifies; prefer summaries.
