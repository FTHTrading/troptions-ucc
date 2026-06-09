# troptions-ucc — Apostle / Core Production Deployment Pack

**Priority**: Apostle (UnyKorn sovereign control plane / chain 7332) **first**, per the Multi-Chain Topology.

This pack contains the minimal, production-oriented artifacts to deploy the two core registries (`DocumentHashRegistry.sol` and `TroptionsReserveRegistry.sol`) on the Apostle/Un yKorn control plane, configure governance, and prepare the first attestation for the **700,000,000.00 USD cash pledge** (Newpoint Statutory Trust as pledgor / Delaware statutory trust reg. 6985669; Troptions as secured party; custody Scotia Bank Canada; Schedule A per the executed Master Asset Pledge Security Agreement).

**External EVM rails (Polygon 137 / Base 8453) are mirrors only.** Do not treat them as the canonical reserve authority.

## Included Artifacts

**Apostle / Core (Sovereign Control Plane) — First Priority**
- `scripts/deploy-apostle.ps1` — PowerShell-native deployment script (uses Foundry/forge). Validates environment, builds, deploys the two contracts to Apostle, records addresses.
- `deploy/signer-manifest.template.yaml` — Template for the multisig / Safe signers that will control the registries (owner + registrars + attestors). Aligns with `multisig/SAFE-PLAN.md`.
- `deploy/SAFE-ADMIN-TRANSFER-CHECKLIST.md` — Step-by-step checklist for transferring ownership/admin from deployer EOA to a production Safe.
- `deploy/environments/` — `.env.example` files for Apostle/core (primary), with placeholders for Polygon and Base adapters.
- `registry/addresses.md` — Living contract address registry (start with Apostle/core; add mirrors later).
- `docs/ATTESTATION_RUNBOOK.md` — How to hash a new legal packet (including the NST pledge PDFs), register the document hash, attest the 700M reserve, and verify events. Ties directly to the canonical OneDrive PDFs.

**Polygon (137) + Base (8453) Mirror Pack — Next Wave (External EVM Rails)**
- `scripts/deploy-polygon.ps1` and `scripts/deploy-base.ps1` — Near-identical scripts for mirrored deployments (same contracts, different network config and per-chain Safes).
- Per-chain Safe manifest coordination notes (use the core template + dedicated Safes per chain).
- `deploy/CROSS_CHAIN_CONSISTENCY_CHECKLIST.md` — Post-mirror verification for document hashes and 700M reserve metadata consistency across Apostle (canonical) and the EVM mirrors.
- Environment examples already present in `deploy/environments/` (polygon.env.example, base.env.example).
- Registry sections in `registry/addresses.md` for mirrors (placeholders until deployed).

**ABI + Verification + Integration Pack (Bridges Review → Deployable Integrations)**
- `abi/` — Accurate JSON ABIs for both contracts (DocumentHashRegistry and TroptionsReserveRegistry) for web3/ethers/cast/etc.
- `verification/VERIFICATION_AND_INTEGRATION_PACK.md` — Full instructions/checklists for contract verification on explorers, sample cross-chain payloads (Apostle ↔ Polygon/Base ↔ XRPL), and guidance for using the attestations in off-chain systems or policy engines.
- `xrpl/xrpl-adapter.js` — Executable reference implementation that turns an Apostle attestation into XRPL-ready memo/URI data (demonstrates the XRPL pack in code).
- `site/wrangler.toml` — Cloudflare Pages config for the static review site (repo-native deployment).

**Execution Order Reminder (from Topology)**
1. Apostle/core first (this pack's core artifacts).
2. Polygon + Base mirrors (the scripts + cross-chain checklist in this pack).
3. XRPL loan adapters / integration (use the verification pack + xrpl-adapter.js after EVM mirrors are consistent).
4. Public surfaces only after legal/security sign-off on the full reserve structure.

**Review-First Note**: All packs and the site are "ready for legal and security review." The contracts are intentionally minimal and auditable; no production deployment or reliance until counsel sign-off on UCC perfection, control agreements, and the reserve structure. The site (deployed to Cloudflare Pages with output dir `site`) is the single portal for all of the above.

## Critical Warnings (Sovereign Control Plane + AGENTS.md)

- **Apostle Chain (chain_id 7332) is critical risk.** Human approval is required for contract deployment, ownership transfer, attestor set changes, and any initial high-value attestations.
- **Never execute transactions on Apostle without explicit sign-off.**
- This pack produces **artifacts and scripts only**. It does **not** run deployments or sign transactions.
- Legal perfection (UCC-1 filing authority, control agreements, exact debtor/pledgor names) and security review of the contracts must be complete before any production use or public issuance.
- The 700M USD cash pledge (Scotia Bank Canada custody) is the first reserve object. All attestations must be reproducible from the exact bytes of the source PDFs in controlled storage.
- Do not commit real private keys, RPC secrets, or signer seeds. Use the `.env.example` pattern + sovereign-control-plane secrets loading where applicable.

## Recommended Execution Order (from Topology)

1. Push this repo (if not already done).
2. Complete legal/security review of the pledge packet and contracts.
3. Run preflight for the relevant scope (sovereign-control-plane or troptions) and obtain human approval for Apostle actions.
4. Use `scripts/deploy-apostle.ps1` (or manual forge) on a controlled machine with the deployer key.
5. Record addresses in `registry/addresses.md`.
6. Execute the Safe admin transfer checklist.
7. Perform the first document hash registration + 700M reserve attestation (using hashes computed from the backend hasher against the real PDFs).
8. Later: mirror to Polygon + Base using the same schema + separate Safes.
9. Only after the above, open public attestation/issuance surfaces.

## Quick Usage (Apostle)

```powershell
# From repo root (after review + approval)
cd $HOME\dev\troptions-ucc

# 1. Copy and fill the environment (never commit the real file)
cp deploy/environments/apostle.env.example .env.apostle

# 2. (Optional but recommended) source sovereign secrets pattern if you have one
# . "$HOME\sovereign-control-plane\scripts\load-genesis402-seeds.ps1" or equivalent

# 3. Run the deployment script
.\scripts\deploy-apostle.ps1 -EnvFile .env.apostle -Verify

# 4. Manually or via the script output: update registry/addresses.md
# 5. Follow deploy/SAFE-ADMIN-TRANSFER-CHECKLIST.md
```

## Post-Push Status (as of this commit)

Repo pushed to https://github.com/FTHTrading/troptions-ucc.git (main, upstream set).

Full packs now live:
- Windows helper pack (setup/extract-and-stage/push + QUICKSTART)
- Apostle/core production pack (78d0227)
- Polygon/Base mirror pack (3824dd3) — this commit

**Immediate safe sequence (per topology and review-first principle):**

1. Legal review of the pledge/UCC/perfection path using the corrected facts (Troptions secured party, NST pledgor DE reg. 6985669, 700M USD cash @ Scotia Bank Canada, Troptions UCC-1 authority).
2. Security review of the Apostle/core + mirror deployment scripts and registry contracts.
3. Dry-run `deploy-apostle.ps1` (and the mirror scripts) with env placeholders validated (use -DryRun).
4. Real deployment **only after explicit sign-off**, then immediate Safe admin transfer, address recording in `registry/addresses.md`, and first document-hash registration + 700M reserve attestation as described in `docs/ATTESTATION_RUNBOOK.md`.
5. For mirrors: deploy after core, run `deploy/CROSS_CHAIN_CONSISTENCY_CHECKLIST.md`.

**Critical**: All Apostle actions require human approval + fresh preflight. This repo produces artifacts only. The pledge PDFs in controlled OneDrive storage are the legal source of truth; on-chain registries publish bounded representations.

Preflight (sovereign-control-plane) was green before pack generation and push.

Next logical after mirrors (when ready): XRPL loan integration docs/adapters, then public surfaces after full legal/security sign-off on the reserve structure.

See also: root `QUICKSTART.md`, `docs/CHAIN_TOPOLOGY.md`, `docs/ATTESTATION_RUNBOOK.md`, `registry/addresses.md`.

See `docs/ATTESTATION_RUNBOOK.md` for the exact steps to register the NST pledge documents and attest the reserve after deployment.

## Foundry Prerequisites (on the deployment machine)

The script assumes Foundry (`forge`) is installed and in PATH (user machines in this environment have confirmed `forge --version`).

```powershell
# One-time
curl -L https://foundry.paradigm.xyz | bash
# then follow on-screen instructions and `foundryup`
```

The contracts have no constructor arguments and are intentionally minimal (no external deps) for auditability on the sovereign rail.

## Next Packs (after this one)

- Polygon + Base mirror deployment configs + Safe manifests (identical reserve + document schema, chain-specific RPC/addresses).
- XRPL loan adapter specs and integration docs.
- Public portal / issuance dashboard specs (only after legal + security sign-off on the reserve structure).

## References

- Canonical pledge facts and source PDFs: see root `README.md`, `QUICKSTART.md`, and `11-Downloads/NST T pledge agreement...` + `NST CIS...`.
- Topology: `docs/CHAIN_TOPOLOGY.md` (and the authoritative Google Drive version referenced in the full map).
- Legal scaffolding: `legal/`, `compliance/`, `multisig/`.
- On-chain contracts: `contracts/src/`.

This pack makes the 700M NST pledge the first concrete reserve object on the sovereign control plane.

**Push the repo, obtain approvals, then run the Apostle deployment.** All downstream mirrors and public surfaces follow.