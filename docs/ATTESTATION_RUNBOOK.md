# Troptions UCC Attestation Runbook (Apostle/Core + 700M NST Pledge)

This runbook describes the end-to-end process to:
1. Hash a new legal / collateral packet (starting with the canonical NST 700M USD cash pledge).
2. Register the document hash on-chain (DocumentHashRegistry).
3. Attest the reserve / collateral value (TroptionsReserveRegistry).
4. Verify and record the evidence.

**Primary rail**: Apostle (UnyKorn sovereign control plane, chain 7332).  
**First reserve object**: 700,000,000.00 USD cash pledged by Newpoint Statutory Trust (DE reg. 6985669, pledgor) to Troptions (secured party), custody at Scotia Bank Canada, per Schedule A of the executed Master Asset Pledge Security Agreement (~2025-12-30).

**External mirrors** (Polygon 137 / Base 8453) receive the same hashes and metadata later for visibility and partner access. They are **not** the canonical authority.

## Prerequisites

- The registries have been deployed on Apostle via the production pack (`scripts/deploy-apostle.ps1`) and ownership transferred to the production Safe (see `deploy/SAFE-ADMIN-TRANSFER-CHECKLIST.md` and signer manifest).
- You have the deployed contract addresses (recorded in `registry/addresses.md`).
- The backend hasher is available (`cd backend; npm run dev` or the CLI).
- You have access to the exact source PDFs in controlled storage (`11-Downloads/NST T pledge agreement 2025-12-30_150719.pdf` and `NST CIS 2025-12-28_225418.pdf` — these are the bytes that matter).
- Human approval + preflight have been obtained for any Apostle transactions (critical system).
- You are using a controlled environment with the appropriate registrar/attestor key or Safe execution path.

## Step 1 — Compute Reproducible Hashes (Off-Chain)

Use the backend hasher (recommended for consistency with the on-chain expectation).

```powershell
cd $HOME\dev\troptions-ucc\backend

# For the pledge agreement (primary legal instrument)
npm run hash -- --file "C:\Users\Kevan\OneDrive - FTH Trading\11-Downloads\NST T pledge agreement 2025-12-30_150719.pdf"

# For the CIS (trust details)
npm run hash -- --file "C:\Users\Kevan\OneDrive - FTH Trading\11-Downloads\NST CIS 2025-12-28_225418.pdf"
```

Record both the `sha256` (preferred for legal packets) and the `keccak256` stand-in. The on-chain registries accept `bytes32`; use the value that matches your deployment configuration (the contracts are hash-agnostic; document your choice in the registry entry).

Also hash any additional exhibits, officer certificates, or signatory packets that form the complete legal packet for this pledge.

**Rule**: Hashes must be reproducible from the exact original bytes. Re-compute and compare if there is any doubt.

## Step 2 — (Optional but recommended) Prepare Signature Packet

If the packet requires multiple legal signers:

Use the backend:

```powershell
# Example (adjust signers, metadata, sourceRef to your actual executed packet)
curl -X POST http://localhost:4110/signature-packet `
  -H "Content-Type: application/json" `
  -d '{
    "docHash": "0x<sha256 or keccak from step 1>",
    "name": "NST-T-Pledge-Agreement-2025-12-30",
    "version": 1,
    "signers": [
      {"name": "Authorized signatory for Newpoint Statutory Trust", "role": "Pledgor", "signedAt": "2025-12-30T..."},
      {"name": "Authorized signatory for Troptions", "role": "Secured Party", "signedAt": "2025-12-30T..."}
    ],
    "metadata": {"declaredValue": "700000000.00", "asset": "USD cash", "custody": "Scotia Bank Canada"},
    "sourceRef": "OneDrive: 11-Downloads/NST T pledge agreement 2025-12-30_150719.pdf"
  }'
```

Store the returned `packetRef` with your evidence. This creates an auditable bundle before on-chain registration.

## Step 3 — Register the Document Hash (on Apostle)

From an authorized registrar (or via Safe execution for high-value items):

Use `cast` (Foundry) or your approved interface:

```bash
# Example (replace with real values)
cast send $DOCUMENT_HASH_REGISTRY_ADDRESS \
  "registerDocument(string,uint8,bytes32,string)" \
  "NST-T-Pledge-Agreement-2025-12-30" 1 \
  0x<the keccak or chosen hash> \
  "OneDrive: 11-Downloads/NST T pledge agreement 2025-12-30_150719.pdf + exhibits" \
  --rpc-url $APOSTLE_RPC \
  --private-key $REGISTRAR_KEY   # or use Safe for production
```

Repeat for the CIS and any other component documents under clear, versioned names (e.g., "NST-CIS-2025-12-28", version 1).

Verify the event was emitted and the record is queryable via `getRecord(name, version)` or `getByHash`.

## Step 4 — Attest the Reserve (700M USD Cash)

From an authorized attestor:

```bash
cast send $TROPTIONS_RESERVE_REGISTRY_ADDRESS \
  "attestReserve(string,string,string,string,bytes32,string)" \
  "NST-T-2025-12-30-700M" "schedule-a-usd-cash" \
  "USD" "700000000.00" \
  0x<supporting document hash from Step 3> \
  "Scotia Bank Canada custody per Schedule A; first-priority security interest per Master Asset Pledge Security Agreement; Troptions authorized to file UCC-1" \
  --rpc-url $APOSTLE_RPC \
  --private-key $ATTESTOR_KEY   # or Safe execution
```

This creates the on-chain record linking the exact pledged amount, asset class, custody reference, and the supporting legal document hash.

## Step 5 — Verify, Record, and Evidence

- Query the contracts (`getLatest`, `getRecord`, `getHistoryEntry`, events) to confirm.
- Record in `registry/addresses.md`:
  - Document hash registration tx(s) + block(s)
  - Reserve attestation tx + block
  - The exact hashes used
  - Links to the source PDFs (by filename + storage location)
- Store a complete evidence package (tx receipts, event logs, Safe execution proofs if used, re-computed hashes, and the original PDFs) in the operator vault.
- Cross-reference in any active `investigations/nst-700m-pledge/` artifacts (per AGENTS.md forensic posture).

## Subsequent Updates

- New executed amendments, UCC-1 filings, officer certificates, or collateral substitutions → new document version + new hash registration.
- Periodic re-attestation or valuation updates → new `attestReserve` entry (history is preserved).
- All changes should be accompanied by updated legal packet material and Safe / approver sign-off per the manifest.

## XRPL, Polygon, Base

- XRPL: Primarily for loan/credit products that may reference this pledge as collateral or PoF. Adapter specs added later.
- Polygon / Base: Deploy mirrors of the same two contracts (identical schema). Register the same document hashes and mirrored reserve attestations there for external visibility, Safe partner access, and wallet compatibility. The canonical 700M reserve object and policy remain on the Apostle core.

## Security & Compliance Reminders

- Never register a hash or attest a value without the corresponding executed source document in controlled storage.
- High-value attestations (full 700M position or material changes) should use the full Safe threshold where practical.
- All privileged actions (owner transfers, registrar/attestor management) must follow the SAFE-ADMIN-TRANSFER-CHECKLIST and the current signer manifest.
- This runbook produces an immutable event-sourced audit trail. Combine it with the off-chain legal originals for a complete evidence board.

**The 700M NST pledge is the first concrete use case for this system. Treat every step with the rigor appropriate to a 700 million USD collateral position under a perfected security interest.**

See also: root `README.md`, `QUICKSTART.md`, `deploy/README.md`, `registry/addresses.md`, `multisig/SAFE-PLAN.md`, and the full Multi-Chain Topology document.