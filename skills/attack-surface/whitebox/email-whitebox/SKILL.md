---
name: Email Attack Surface — White Box
description: >-
  Audit the mail environment with engagement-provided visibility: MX topology,
  gateway tenant, DKIM selector inventory, DMARC aggregate reports, and the
  authorized-sender register. Use when mail-platform access or exports are
  provided. Use the black-box variant when no privileged visibility exists.
---

## Purpose

With real mail-platform visibility, reconcile who actually sends as the
domain, who is authorized but dead, and what the gateway sees but the DNS
posture doesn't fix.

## Inputs

Ask for: mail gateway / workspace tenant access or exports (accepted domains,
connectors, SPF/DKIM config), DMARC aggregate reports (rua XML), DKIM
selector inventory, and the business register of third-party senders if it
exists.

## Workflow

1. **Platform inventory.** Export accepted domains, in/outbound connectors,
   mail flows, and the gateway's SPF/DKIM/DMARC management state. Note manual
   overrides (whitelists that never expire).
2. **DKIM/SPF state as configured.** Enumerate actual signing selectors from
   the sending platform, comparing against what `@email-blackbox` finds
   publicly; each selector known internally but missing publicly (or the
   reverse) is a finding.
3. **DMARC aggregate reports.** For a ≥2-week window, parse rua XML and build
   the legitimate-sender table: source host, SPF/DKIM pass per source,
   alignment results. Anything failing *both* mechanisms is spoofing or a
   forgotten legitimate sender — classify each with the client.
4. **Third-party sender reconciliation.** Compare the vendor register
   (procurement/marketing) with the observed senders and the DNS findings
   (`@email-blackbox` step 5). Find senders signed with vendor defaults,
   senders missing from the register (shadow senders), and vendors still on
   record that no longer send.
5. **Gateway posture basics.** Check anti-spoof rules for internal-only
   domains (does the gateway accept spoofed own-domain inbound?), expiry and
   rotation of DMARC's `p=` escalation plan, and whether report destinations
   are watched at all.
6. **Report** the sender register as verified reality: who can send
   (and proves alignment), who could send (policy gaps), who shouldn't be able
   to but does — with cleanup actions folded into each recommendation.

## Output format

- Reconciled authorized-sender register (vendor → selector/SPF source →
  alignment status → in register?).
- Findings list with remediation steps per gateway/policy area.

## Safety rules

- Never modify settings from this skill; changes go through the client's own
  change process.
- Treat aggregate reports and mailbox-adjacent data as confidential:
  aggregate and redact in deliverables.
- Keep provided exports in the engagement working area only — never in public
  repos (redaction checklist in `../../../../../docs/authoring.md`).
