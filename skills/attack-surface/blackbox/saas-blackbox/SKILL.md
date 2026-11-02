---
name: SaaS Attack Surface — Black Box
description: >-
  Identify third-party SaaS platforms an organization uses and their externally
  exposed surfaces using only outside signals: response fingerprints, CNAME
  patterns, portal styles, takeover-prone aliases, and impersonation
  detection. Use for external SaaS asset discovery.
---

## Purpose

Map the SaaS an organization depends on without any tenant access: vendors
fingerprinted from live properties, aliases that depend on vendor
provisioning, and lookalike/impersonation instances masquerading as the
organization. Verified in practice: corporate SaaS hosts fronting security
vendors, website builders, and identity providers.

## Inputs

Target domains/hostnames, the authorization covering verification of
discovered SaaS aliases (most checks are read-only GETs), prior recon
artifacts (CNAMEs lists, cert dumps).

## Workflow

1. **Vendor fingerprinting on live properties.** From headers, cookies, and
   CNAME chains, identify third-party platforms: site builders, delivery
   networks, identity layers, support portals, marketing/hosting stacks
   (cookie/header patterns are vendor-distinctive). Record vendor and app version/locale where visible. Domain→vendor mapping is primary output; note that
   multiple vendors may tag the same host (layered CDNs and identity
   vendors).
2. **CNAME alias classes.** From existing CNAME exports or DNS sweeps, group
   aliases by vendor TLD patterns; mark ones whose vendor-side provisioning
   status is unclear — those are *takeover-candidate* rows rather than
   confirmed misconfigs. A grep+content check distinguishes brand-owned
   content from vendor placeholders.
3. **Portal identification.** SSO/login redirects following the classic
   load-balancer default-vhost pattern should not be confused with the
   application itself — pure identity portals provide no app surface but do
   belong in the map (vendors: gateway/identity products have signature
   portals/cookies).
4. **Tenant/instance reachability.** For each identified vendor portal or
   known instance hostname: is admin/management reachable unauthenticated?
   Note version strings if offered. Don't brute-force; a banner + default
   redirect is enough to map.
5. **Impersonation detection.** Actively look for *bare* clones of the
   organization's properties on unrelated infrastructure (fresh stack,
   build folder structure, noindex). Verified pattern: phishing clones reuse
   real brand assets on unrelated infringing hosting with an admin panel the
   real property doesn't have. Classification, never interaction: report the
   impersonation instance to the organization's abuse/report channel with
   fingerprint evidence (project paths, build hashes); it is **out of scope
   for testing** — a clone is not the engagement's surface to attack.
6. **Multi-tenant gateways.** Where a gateway serves a mix of properties and
   third-party content (developer portals, partner APIs), capture the multi-
   tenant structure explicitly — it changes how findings attribute (shared
   root causes across tenants may collapse into one report).
7. **Feed the loop.** Discovered vendors typically re-enter discovery: vendor
   subdomains re-enter `@dns-blackbox` enumeration; new tenants feed back
   here; instance hostnames feed `@ip-blackbox` for origin verification.

## Output format

SaaS usage map: asset → vendor (with fingerprint evidence) → purpose-class
(identity/site/delivery/portal) → exposure notes → confidence. Separate list:
takeover-candidate aliases, impersonation observations (with evidence and
recommended report channel).

## Safety rules

- Read-only verification; no probing beyond what a normal user's browser
  session would produce.
- Never bypass or attack a vendor's multi-tenant control plane to reach info
  about your tenant — that belongs to the vendor's security team, not the
  engagement.
- Impersonation/phishing infrastructure is documented/resourced for reporting,
  not attacked; no credentials or session data should be entered anywhere
  related to it.
- Correlate with the client's own vendor list during white-box work — black-box
  vendor guesses can be *wrong*: confidence labels are mandatory, not optional.
