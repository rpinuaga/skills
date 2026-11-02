---
name: Cloud Attack Surface — Black Box
description: >-
  Fingerprint and map cloud-hosted attack surface (AWS/Azure/GCP) purely from
  the outside: storage endpoints, serverless and API gateways, resource-policy
  error leakage, account-identifier oracles, and bundle/mobile artifact
  mining. Use for external cloud reconnaissance of a target organization.
---

## Purpose

Find which cloud resources of the target are reachable from the internet
without any credentials, and how far unauthenticated responses leak account
and service identifiers. Techniques here come from tested engagements.

## Inputs

Target domains/hostnames, authorization covering unauthenticated probing of
discovered endpoints, and any prior recon artifacts (cert dumps, hostname
lists) to mine.

## Workflow

1. **Classify exposed-resource classes, then hunt each in parallel** (tested
   exposed classes): storage buckets/containers, serverless function URLs,
   API gateways, CDN distributions, container/ECR public registries, snapshot
   and AMI surfaces, queues/topics endpoints.
2. **Storage fingerprinting.** Signature map:
   - S3: `x-amz-request-id`-style headers + `NoSuchBucket`/`AccessDenied` XML,
     and `s3-website` variants (bucket-as-website endpoints).
   - Azure Blob: `x-ms-request-id`, `Microsoft-HTTPAPI/2.0` server, `Error`
     XML shape — note that some asset hosts front Azure through a CDN, so
     look at the *origin error shape*, not the edge headers.
   - Distinguish storage-origin errors from pure CDN-edge errors (generic
     edge error pages = origin unreachable/WAF, not open storage).
3. **Existence ≠ ownership.** Storage names are globally unique: a
   `403 AccessDenied` proves *someone* owns that name, not your target.
   Verify through content that identifies the target, or regional footprint
   consistency; document false positives (unrelated orgs with coincidental
   names are common).
4. **Name/format probes across regions.** Rotate the same candidate name
   across known provider region endpoint formats
   (`<name>.s3.<region>.amazonaws.com`, `<name>.s3-<region>.amazonaws.com`,
   `<name>.s3-website[-]<region>...`) — ownership/region often shows only in
   the right region. Keep a provider-region list for the rotation loop.
5. **Search dorks.** Index-based surfaces: aggregated bucket-content search
   engines, and provider-dork searches for the resource classes above
   (gateways, function URLs, distributions). Note free-tier filtering limits.
6. **Resource-policy error leakage.** Unauthenticated requests against
   gateway/function endpoints can leak identifiers in error bodies: region,
   partially masked account ID, API ID, stage, echoed method/path. Document
   precisely (provider-side masking is deliberate — report partial values,
   not overstatement).
7. **Mine app artifacts.** JS bundles (grep for storage hostnames, gateway
   IDs, KMS key ARNs, identity-pool UUID patterns) and mobile packages
   (decompile + string-search the same patterns + SDK-configuration files).
   When static grep misses runtime URLs (asset paths assembled at runtime),
   capture a real browser session's network log instead.
8. **Account-identifier oracles** (only when account IDs are needed for
   further mapping): provider-side condition-key side channels require an
   owned cloud account with an assumable role — that is infrastructure setup
   and a cost/rate decision, so **ask the user before configuring**, don't
   run inline. Several open-source oracles implement this; also note the
   identity-pool chain (unauthenticated get-id → session credentials →
   caller-identity) if a pool ID ever leaks in artifacts.
9. **Feed the loop.** New account IDs/API IDs/buckets feed candidate lists
   back into steps 4–5 and into `@dns-blackbox` (mining new internal naming
   from certificates); newly commissioned environments appear over time, so
   periodic re-runs are part of the workflow. Monitoring option: real-time
   certificate-transparency feeds (stream subscribers) — candidate tooling;
   verify before relying on it.

## Output format

Cloud asset map: endpoint → service class → region → exposure verdict →
evidence → confidence. Plus an identifier ledger (account fragments, API IDs,
distribution IDs) with how each was obtained.

## Safety rules

- Existence checks and fingerprinting only; exploitation (downloading stored
  data, overwriting, claiming names) is out of scope without separate approval.
- Respect explicit-deny resource policies: probing what they permit to *see*
  is fine; bypassing IAM condition enforcement is attacking the provider
  control plane, not the target app — do not.
- Never harvest or download target-customer data from exposed storage beyond
  the minimum needed to prove exposure; stop and report.
- Oracle setups with owned accounts need user approval on cost and blast
  radius; rate-limit and back off on provider-side throttling.
- Any rule engine/CDN-interference findings stay evidence-only; do not attempt
  active filter bypass as part of discovery.
