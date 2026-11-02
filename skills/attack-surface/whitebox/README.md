# White-box discovery

Privileged enumeration: the engagement provides some access, so techniques
split by **technology**, not by asset class — each stack has its own way to
answer "what is exposed":

| Leaf skill        | Technology                                                         |
| ----------------- | ------------------------------------------------------------------ |
| `aws-whitebox`    | Accounts via Organizations; buckets/gateways/function URLs/snapshots |
| `azure-whitebox`  | Subscriptions/tenants; public IPs/NSGs, App Service/Front Door, storage network rules |
| `gcp-whitebox`    | Org/folders/projects; allUsers bindings, forwarding rules, SQL networks |
| `ip-whitebox`     | IP registers reconciled via console access                          |
| `dns-whitebox`    | Zone exports vs. reality reconciliation (DNS is largely provider-agnostic) |
| `email-whitebox`  | Mail platform / tenant-side sender reconciliation                   |
| `saas-whitebox`   | IdP/tenant sourcing; see the provider-maturity rule inside — vendors with thin admin APIs (ERP/CRM suites) usually fall back to `../blackbox/saas-blackbox` |

If techniques diverge further inside a provider over time (differing control
planes and data-plane surfaces), the leaf may split accordingly; the
provider grouping stays the stable branch.

Human navigation only — skills are the `SKILL.md` leaf directories.
