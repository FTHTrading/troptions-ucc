# Cross-Chain Attestation Consistency Checklist (Polygon + Base Mirrors)

**Use after deploying the mirror registries on Polygon (137) and/or Base (8453) and after mirroring the first 700M NST pledge attestations from Apostle/core.**

Goal: Ensure that document hashes and reserve metadata for the 700,000,000.00 USD cash pledge (Troptions secured party, Newpoint Statutory Trust pledgor, Scotia Bank Canada custody, DE reg. 6985669) are identical (or appropriately versioned) across the canonical Apostle rail and the external EVM mirrors.

This checklist is part of the Polygon/Base mirror pack.

## Prerequisites

- [ ] Apostle/core registries deployed, Safe-owned, and the initial pledge document hashes + 700M reserve attestation have been executed and recorded in `registry/addresses.md` (Apostle section) and `docs/ATTESTATION_RUNBOOK.md`.
- [ ] Polygon and/or Base mirror registries deployed via `scripts/deploy-polygon.ps1` / `scripts/deploy-base.ps1`.
- [ ] Per-chain Safes have taken ownership on the mirrors.
- [ ] The same document hashes (computed from the exact OneDrive PDFs) will be registered on the mirrors.
- [ ] Human approval obtained for mirror operations.

## Consistency Checks

1. **Document Hash Registry**
   - On Apostle: Query `getRecord("NST-T-Pledge-Agreement-2025-12-30", 1)` (and CIS, any other components).
   - On Polygon/Base: Query the equivalent `getRecord` / `getByHash` on the mirror contracts.
   - Confirm: `contentHash`, `name`, `version`, `timestamp`, and `uri` (or equivalent metadata) match exactly.
   - Record any tx hashes for the mirror registrations.

2. **Reserve Registry (700M Pledge)**
   - On Apostle: `getLatest("NST-T-2025-12-30-700M", "schedule-a-usd-cash")` (or the collateralId used).
   - On mirrors: Same query.
   - Confirm: `pledgeId`, `collateralId`, `asset`, `amount` ("700000000.00"), `supportingDocHash`, `timestamp`, and `note` (including Scotia Bank Canada custody and first-priority security interest language) are consistent.
   - History length should be at least 1 on all chains for the initial attestation.

3. **Supporting Evidence**
   - Re-compute the SHA-256 (and chosen on-chain hash) of the exact source PDFs (`11-Downloads/NST T pledge agreement 2025-12-30_150719.pdf` and CIS) on the deployment machine.
   - Confirm the on-chain `contentHash` / `supportingDocHash` values match the off-chain computation on *all* chains.
   - Confirm the `sourceRef` or `uri` (if used) points to the same controlled storage location.

4. **Governance / Admin Consistency**
   - Owner on Apostle: the core Safe (per signer-manifest).
   - Owner on Polygon: the dedicated Polygon Safe.
   - Owner on Base: the dedicated Base Safe.
   - Note any coordinated signers across the manifests.
   - Thresholds for high-value actions (reserve changes, admin) should be equivalent or stricter on mirrors where policy is mirrored.

5. **Event & Tx Audit**
   - Pull the registration and attestation events from Apostle (canonical).
   - Pull the corresponding events from Polygon and Base.
   - Confirm event data (hashes, amounts, attestors, timestamps) is consistent with the Apostle events.
   - Record block numbers and tx hashes for all three (or more) chains in `registry/addresses.md` and the evidence package.

6. **Post-Mirror Attestation**
   - If re-attesting or adding new versions on Apostle, repeat the mirror registrations/attestations on Polygon/Base within the same operational window (or document the lag and reason).
   - Update the cross-chain section of `registry/addresses.md`.

## Failure / Drift Handling

- If hashes or metadata diverge: Pause further issuance/distribution on the drifted chain. Re-register the correct values from the canonical Apostle data (or the legal packet). Investigate root cause (config error, manual tx, etc.).
- Never treat a mirror as authoritative for the 700M pledge reserve status. Escalate any material drift to the core policy engine (Apostle/x402/MCP) and legal team.

## Evidence Package

For each mirrored attestation:
- Apostle tx + event log
- Polygon tx + event log (if deployed)
- Base tx + event log (if deployed)
- Re-computed hashes from the exact PDFs
- Safe execution proofs for any admin/registration actions
- Link to the source PDFs in controlled storage
- Timestamp of the consistency check

Store in the operator vault alongside the legal originals.

## Next After This Checklist

- Update `registry/addresses.md` with mirror addresses and cross-chain tx references.
- If all checks pass, the mirrors are ready for external partner review, wallet visibility, and any governed distribution on those rails.
- Continue with XRPL loan adapter specs only after the EVM mirrors are stable and the core + mirrors are consistent for the 700M pledge.

**Canonical truth for the 700M NST pledge reserve and document hashes remains on the Apostle/Un yKorn sovereign control plane.** Mirrors exist for reach and interoperability only.

Run this checklist after every significant mirrored attestation or after deploying new mirrors.