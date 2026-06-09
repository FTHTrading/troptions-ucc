# Note: Sovereign Control Plane Registration

This repo (`troptions-ucc`) was scaffolded under `dev/troptions-ucc` per the standard FTH / TROPTIONS project layout.

**It is not yet registered** in `C:\Users\Kevan\sovereign-control-plane\registry\systems.yaml`.

Per sovereign rules:
- Never modify production asset registries without human sign-off.
- Run preflight before significant changes.

When ready (after first commit + initial on-chain deployments or key legal hashes registered), add an entry similar to:

```yaml
- id: troptions-ucc
  name: TROPTIONS UCC Collateral Governance
  path: C:\Users\Kevan\dev\troptions-ucc
  tier: production
  status: pre-production
  last_verified: "2026-06-09"
  port: null
  contract: null
  skill: null
  start_cmd: "cd C:\\Users\\Kevan\\dev\\troptions-ucc && echo 'See scripts/setup.ps1 and contracts/'"
  depends_on: []
  risk_class: high
  human_approval_for: [contract_deploy, attestor_set_change, reserve_attestation]
  notes: >
    On-chain DocumentHashRegistry + TroptionsReserveRegistry for NST 700M pledge collateral.
    Legal sources live in operator OneDrive (11-Downloads/NST T pledge... and NST CIS...).
    Backend provides reproducible hashing + signature packet prep.
```

After adding to the registry, run inventory-sync and update RESTART-HERE as needed.

Do not edit the scp registry from this repo — do it from the sovereign-control-plane context with explicit approval.
