# troptions-ucc

**UCC Collateral Governance & Reserve Attestation Layer for TROPTIONS pledged assets.**

This repository provides the on-chain and off-chain tooling to anchor, attest, and govern collateral associated with the Newpoint Statutory Trust (NST) pledge arrangements (the "700M pledge").

## Scope

- Immutable on-chain registration of **document hashes** for the canonical legal instruments (pledge agreement, CIS, UCC filings, amendments, signatory packets).
- **Reserve / collateral attestations** linked to specific pledge instruments, with amount, asset class, valuation timestamp, and supporting doc hash.
- Off-chain packet router + hasher (backend) used by legal/ops to prepare signature packets and compute reproducible hashes before on-chain registration.
- Governance surface for authorized attestors (initially multisig / SAFE-controlled).

This is **not** the TROPTIONS L1 chain itself. It is the collateral control and proof layer sitting above the pledged instruments.

## Canonical Source Documents (do not edit here)

All hashes and attestations in this system must be traceable to these files (stored in the operator's controlled OneDrive):

- `11-Downloads/NST T pledge agreement 2025-12-30_150719.pdf`
- `11-Downloads/NST CIS 2025-12-28_225418.pdf`

Additional UCC-1, amendments, officer's certificates, and signatory packets will be added with new hashes as they are executed.

**Rule**: A hash only becomes authoritative once it is registered on-chain via the authorized attestor path **and** the corresponding source PDF is preserved with its original metadata and signatures.

## Architecture

```
legal/                         # Human legal drafts and references
  UCC1-COLLATERAL-DRAFT.md
compliance/
  CHECKLIST.md
multisig/
  SAFE-PLAN.md                 # Control of attestor keys / roles
contracts/src/
  DocumentHashRegistry.sol     # bytes32 hash → (name, version, registrant, ts, uri)
  TroptionsReserveRegistry.sol # pledgeId / collateralId → (asset, amount, docHash, attestor, ts)
backend/
  src/server.ts                # PDF hashing + signature packet routing (prepare before on-chain)
scripts/
  setup.ps1                    # Windows one-shot post-clone (node deps + checks)
  push.ps1                     # Reusable add/commit/push helper
```

## Quick Start (Windows / PowerShell)

```powershell
cd $HOME\dev
git clone https://github.com/FTHTrading/troptions-ucc.git
cd .\troptions-ucc

# One-time (or after any scaffold change)
.\scripts\setup.ps1

# Normal workflow after edits
.\scripts\push.ps1 -Message "Add executed UCC-1 and first reserve attestation"
```

See `scripts/setup.ps1` for exactly what it does (git remote validation, backend `npm install`, node version check, next-step guidance).

## Contracts

Both contracts are intentionally minimal and auditable:

- `DocumentHashRegistry`: append-only (or versioned) registration of keccak256 (or sha256) of legal PDFs and packets. Emits events for every registration.
- `TroptionsReserveRegistry`: records reserve/collateral attestations against a pledge identifier. Amount is stored as string to avoid precision loss (u128 semantic). Links to a document hash.

Deployments (when performed) will be recorded here with chain, address, and deployer.

Initial attestor role will be a 2-of-3 or 3-of-5 multisig (see `multisig/SAFE-PLAN.md`).

## Backend (Signature Packet + Hash Service)

The backend is a lightweight Node/TS service:

- `POST /hash` — accepts file or JSON content, returns sha256 + optional keccak256.
- `POST /signature-packet` — accepts a bundle (docHash, signers, metadata, packetRef). Can persist or forward to storage / email / on-chain prep.
- Future: submit-ready payload for the two registries.

Run locally after setup:

```powershell
cd backend
npm run dev
```

## Legal / Compliance / Ops

- `legal/UCC1-COLLATERAL-DRAFT.md` — working draft language and collateral description for the UCC-1 financing statement(s) covering the pledged assets under the NST agreement.
- `compliance/CHECKLIST.md` — adapted from stablecoin/treasury due-diligence checklists. Covers issuance/redemption analogs for pledge, reserve match, control of attestor keys, proof quality, etc.
- `multisig/SAFE-PLAN.md` — key management, signer set, threshold, ceremony notes, and emergency procedures for the contracts' privileged roles.

## Evidence & Audit Posture (per AGENTS.md)

Every registration emits events. Off-chain hashes are reproducible from the exact bytes of the source PDFs in OneDrive. This creates a two-layer (legal PDF + on-chain event) evidence board for the 700M-class collateral position.

When new executed documents appear in `11-Downloads`, the workflow is:

1. Run hash via backend (or `scripts/hash.ps1` if added later).
2. Prepare signature packet.
3. Authorized attestor calls `registerDocument` / `attestReserve`.
4. Record tx hash + block in the relevant investigation or ops log.

## Next Actions (after first commit)

- Add foundry.toml + basic test harness for the two registries.
- Wire backend to a real object store (R2 / S3) or IPFS for packet artifacts (hashes stay on-chain).
- Deploy first version to a testnet (or directly to a controlled L2/mainnet with the SAFE).
- Register this system in `sovereign-control-plane/registry/systems.yaml` (human sign-off required).
- Create `investigations/nst-700m-pledge/` artifacts once first on-chain registrations exist (forensic timeline, flow of collateral, risk register).

## License & Control

Proprietary to FTH Trading / TROPTIONS operator. All contracts and tooling are operator-controlled. No public token or public sale associated with this repo.

---

**This repo exists to make the NST pledge collateral verifiable, attestable, and governance-grade on-chain without moving the underlying legal instruments off their controlled storage.**
