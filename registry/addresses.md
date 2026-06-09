# troptions-ucc — Contract Address Registry

**Purpose**: Single source of truth for deployed addresses of the reserve and document hash registries across all rails. Start with Apostle/core (sovereign control plane). Add Polygon, Base, and future rails as mirrors.

**First reserve object**: The 700,000,000.00 USD cash pledge (Newpoint Statutory Trust pledgor, Troptions secured party, Scotia Bank Canada custody, per Schedule A of the 2025-12-30 Master Asset Pledge Security Agreement, DE trust reg. 6985669).

All entries must include:
- Deploy tx hash + block
- Owner (should be a Safe after transfer)
- Initial registrars / attestors configured
- Link to the supporting legal packet hashes (computed from the exact OneDrive PDFs)

---

## Apostle / UnyKorn Sovereign Control Plane (chain 7332) — Canonical

| Contract                  | Address     | Deploy Tx / Block | Owner (post-transfer) | Notes |
|---------------------------|-------------|-------------------|-----------------------|-------|
| DocumentHashRegistry     | (pending)  | (pending)        | Primary Safe (from signer-manifest) | First registration target: NST pledge agreement + CIS hashes |
| TroptionsReserveRegistry | (pending)  | (pending)        | Primary Safe          | First attestation: 700000000.00 USD cash, Scotia custody, supporting doc hash from pledge PDFs |

**Deployment pack reference**: `deploy/` (scripts/deploy-apostle.ps1 + envs + checklists).  
**Signer manifest**: `deploy/signer-manifest.template.yaml` (fill and store in vault).  
**Status**: Awaiting human approval + preflight before any Apostle broadcast.

---

## Polygon PoS (chain 137) — Mirror (external EVM)

| Contract                  | Address | Deploy Tx / Block | Owner (Polygon Safe) | Notes |
|---------------------------|---------|-------------------|----------------------|-------|
| DocumentHashRegistry     | TBD    | TBD              | Separate Polygon Safe | Mirrored reserve schema + doc hashes for external visibility |
| TroptionsReserveRegistry | TBD    | TBD              | Separate Polygon Safe | Same 700M pledge metadata mirrored |

**Deploy after Apostle/core is live and transferred to Safe.** Use `deploy/environments/polygon.env.example`.

---

## Base (chain 8453) — Mirror (external EVM)

| Contract                  | Address | Deploy Tx / Block | Owner (Base Safe) | Notes |
|---------------------------|---------|-------------------|-------------------|-------|
| DocumentHashRegistry     | TBD    | TBD              | Separate Base Safe | Mirrored for app integrations and broader EVM reach |
| TroptionsReserveRegistry | TBD    | TBD              | Separate Base Safe | Same 700M pledge metadata mirrored |

**Deploy after Apostle/core.** Use `deploy/environments/base.env.example`.

---

## XRPL (future — lending / credit rail)

XRPL is the lending/credit specialization (vaults, brokers, off-chain underwriting). It does not host the primary USD cash reserve attestation for this pledge. Adapter specs and any XRPL-native objects will be added in a later phase.

---

## Update Process

1. After a successful deployment (Apostle first), run the Safe transfer checklist.
2. Fill the exact addresses + tx data here.
3. Update the signer manifest with real addresses.
4. Perform the first pledge document registration + 700M reserve attestation and record the txs here with links to events.
5. When Polygon/Base mirrors are deployed, add their sections with coordinated Safe addresses.
6. Never edit historical entries — append new versions or notes only.

**All attestations of the 700M pledge must remain traceable to the exact bytes of the source PDFs in controlled OneDrive storage + the on-chain events on the canonical (Apostle) rail.**

See `docs/ATTESTATION_RUNBOOK.md` and `deploy/README.md` for the operational steps.