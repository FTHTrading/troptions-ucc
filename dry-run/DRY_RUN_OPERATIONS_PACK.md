# Dry-Run Operations Pack — Troptions UCC Collateral Governance

**Status**: Simulation / rehearsal material only.  
**Purpose**: Provide evidence-grade, reviewable examples of deployment, verification, attestation, and cross-chain consistency for the 700M NST/Troptions pledge collateral before any live Apostle transactions.  
**Audience**: Legal counsel, security reviewers, operators, integrators.  
**Scope**: Apostle (core), Polygon/Base (mirrors), XRPL references. All tied to the executed pledge documents (Troptions secured party, Newpoint Statutory Trust pledgor DE #6985669, USD 700,000,000.00 cash at Scotia Bank Canada custody).

**Review-First Reminder**: Nothing in this pack authorizes live deployment or transactions. All actions require explicit human approval, fresh sovereign-control-plane preflight, and completion of legal/security sign-off (see checklist below). Contracts and attestations remain "ready for legal and security review."

This pack complements the existing:
- `site/` review portal (pledge facts, contracts, infrastructure, XRPL integration, ABIs)
- `abi/`, `verification/`, `xrpl/`, `deploy/`, `docs/`, `registry/`

## 1. Sample Deployment Transcripts

Simulated outputs from the PowerShell deployment scripts (using the provided `deploy-*.ps1` and env templates). These assume a controlled environment with Forge, valid RPCs, and temporary deployer key (immediately rotated after Safe transfer).

### Apostle/Core (chain 7332) — First Priority

```powershell
PS C:\Users\Kevan\dev\troptions-ucc> .\scripts\deploy-apostle.ps1 -EnvFile .env.apostle -Verify
=== troptions-ucc Apostle/Core Deployment ===
Timestamp: 2026-06-10T14:22:31-04:00
EnvFile  : .env.apostle
DryRun   : False
NOTE: This is the CANONICAL deployment. External EVM mirrors and XRPL references come later.

Checking prerequisites...
  Forge: forge Version: 1.6.0-nightly ...

Building contracts...
  Build successful.

Deploying DocumentHashRegistry to Apostle (chain 7332)...
[⠊] Waiting for confirmation...
[✔] Deployment completed successfully.
  DocumentHashRegistry (Apostle): 0xA1b2C3d4E5f678901234567890abcdef12345678
  Transaction hash: 0xabc123... (block 1,234,567)

Deploying TroptionsReserveRegistry to Apostle (chain 7332)...
[✔] Deployment completed successfully.
  TroptionsReserveRegistry (Apostle): 0xB2c3D4e5F678901234567890abcdef1234567890
  Transaction hash: 0xdef456... (block 1,234,568)

Verifying DocumentHashRegistry...
  Verification submitted to explorer. URL: https://explorer.apostle.example/address/0xA1b2C3d4E5f678901234567890abcdef12345678#code

Verifying TroptionsReserveRegistry...
  Verification submitted to explorer. URL: https://explorer.apostle.example/address/0xB2c3D4e5F678901234567890abcdef1234567890#code

=== POST-DEPLOYMENT NEXT STEPS ===
1. Record addresses in registry/addresses.md (Apostle section).
2. Immediately follow deploy/SAFE-ADMIN-TRANSFER-CHECKLIST.md — transfer owner to production Safe.
3. Use the backend hasher against the exact OneDrive PDFs to obtain content hashes.
4. Call registerDocument on the hash registry for the pledge agreement and CIS.
5. Call attestReserve on the reserve registry for the 700,000,000.00 USD cash (Scotia custody) using the supporting doc hash.
6. Verify events and record tx hashes + block numbers.

Addresses (for copy/paste into registry):
  DocumentHashRegistry:   0xA1b2C3d4E5f678901234567890abcdef12345678
  TroptionsReserveRegistry: 0xB2c3D4e5F678901234567890abcdef1234567890

Deployment script complete. Review all output before any further actions on Apostle.
```

**Post-deploy Safe transfer transcript (simulated Safe UI / cast)**:
```
Safe tx #1 (DocumentHashRegistry transferOwnership):
  To: 0xA1b2C3d4E5f678901234567890abcdef12345678
  Data: transferOwnership(0xSafeApostleCore123...)
  Executed: 2026-06-10T15:05:00Z
  Tx hash: 0xsafe111...
  Signers: 3-of-5 (operator-1, operator-2, counsel-1)

Safe tx #2 (TroptionsReserveRegistry transferOwnership):
  ... similar ...
```

### Polygon (137) Mirror

```powershell
PS ...> .\scripts\deploy-polygon.ps1 -EnvFile .env.polygon
...
  DocumentHashRegistry (Polygon): 0xC3d4E5f678901234567890abcdef1234567890ab
  TroptionsReserveRegistry (Polygon): 0xD4e5F678901234567890abcdef1234567890abcd
...
```

(Repeat for Base 8453 with corresponding addresses.)

## 2. Example Verified-Contract Metadata

### Polygonscan / Basescan Style (after successful verification)

**DocumentHashRegistry (Polygon)**
- Contract Address: 0xC3d4E5f678901234567890abcdef1234567890ab
- Contract Name: DocumentHashRegistry
- Compiler Version: v0.8.20+commit.a1b2c3d4
- Optimization Enabled: Yes with 200 runs
- Constructor Arguments: (none)
- Source Code: Verified (exact match to repo `contracts/src/DocumentHashRegistry.sol`)
- ABI: [link to abi/DocumentHashRegistry.json]
- Contract Creation Tx: 0xpoly123... (block 52,345,678)
- Verification Tx / Timestamp: 2026-06-10 15:45 UTC
- Proxy: No
- Implementation: N/A
- Owner (post-Safe transfer): 0xSafePolygonMirror456... (3-of-5 Safe)

Similar for TroptionsReserveRegistry on Polygon and both contracts on Base.

**Apostle Explorer (if Blockscout-compatible)**
- Same metadata pattern, with chain-specific explorer URL.
- Note: Apostle verification may require manual source upload + ABI if no automated verifier.

Record these in `registry/addresses.md` and the site.

## 3. Example First-Attestation Payloads

For the 700M NST/Troptions pledge (using exact hashes computed from the canonical PDFs via the backend hasher or `xrpl-adapter.js` / verification tools).

### Document Registration (via backend or direct call)

**Payload for /signature-packet or direct registerDocument call (Apostle first):**
```json
{
  "docHash": "0x<keccak256-or-sha256-of-exact-pledge-pdf-bytes>",
  "name": "NST-T-Pledge-Agreement-2025-12-30",
  "version": 1,
  "signers": [
    {"name": "Troptions Authorized Signatory", "role": "Secured Party", "signedAt": "2025-12-30T..."},
    {"name": "Newpoint Statutory Trust Signatory", "role": "Pledgor", "signedAt": "2025-12-30T..."}
  ],
  "metadata": {
    "declaredValue": "700000000.00",
    "asset": "USD cash",
    "custody": "Scotia Bank Canada",
    "sourceRef": "OneDrive: 11-Downloads/NST T pledge agreement 2025-12-30_150719.pdf"
  },
  "sourceRef": "https://raw.githubusercontent.com/FTHTrading/troptions-ucc/main/legal/UCC1-COLLATERAL-DRAFT.md"
}
```

**On-chain call (example cast or ethers):**
```bash
cast send $DOCUMENT_HASH_REGISTRY "registerDocument(string,uint8,bytes32,string)" \
  "NST-T-Pledge-Agreement-2025-12-30" 1 \
  0x<docHash> \
  "OneDrive: 11-Downloads/NST T pledge agreement 2025-12-30_150719.pdf + exhibits" \
  --rpc-url $APOSTLE_RPC --private-key $REGISTRAR_KEY
```

Repeat for "NST-CIS-2025-12-28" v1.

### Reserve Attestation

**Payload:**
```json
{
  "pledgeId": "NST-T-2025-12-30-700M",
  "collateralId": "schedule-a-usd-cash",
  "asset": "USD",
  "amount": "700000000.00",
  "supportingDocHash": "0x<matching-doc-hash-from-above>",
  "note": "Scotia Bank Canada custody per Schedule A; first-priority security interest per Master Asset Pledge Security Agreement; Troptions authorized to file UCC-1"
}
```

**On-chain call:**
```bash
cast send $TROPTIONS_RESERVE_REGISTRY "attestReserve(string,string,string,string,bytes32,string)" \
  "NST-T-2025-12-30-700M" "schedule-a-usd-cash" \
  "USD" "700000000.00" \
  0x<supportingDocHash> \
  "Scotia Bank Canada custody per Schedule A; first-priority security interest..." \
  --rpc-url $APOSTLE_RPC --private-key $ATTESTOR_KEY
```

**Expected events (example logs):**
```
ReserveAttested(pledgeId=NST-T-2025-12-30-700M, collateralId=schedule-a-usd-cash, asset=USD, amount=700000000.00, supportingDocHash=0x..., attestor=0x..., timestamp=...)
```

Record tx hashes, blocks, and event data in `registry/addresses.md` and the site.

Mirror the same payloads to Polygon/Base after verification (using the mirror contracts).

## 4. Mock Cross-Chain Consistency Reports

**Example Report (Markdown table for the 700M pledge after mirroring):**

| Chain      | DocumentHashRegistry Address | TroptionsReserveRegistry Address | Pledge Doc Registered (name/version) | Supporting Doc Hash | Reserve Attested (amount) | Attest Tx Hash | Block | Consistency Check |
|------------|--------------------------------|------------------------------------|--------------------------------------|---------------------|---------------------------|----------------|-------|-------------------|
| Apostle (7332) | 0xA1b2C3... | 0xB2c3D4... | NST-T-Pledge-Agreement-2025-12-30 / 1 | 0x<exact> | 700000000.00 USD | 0xdef456... | 1,234,568 | Canonical |
| Polygon (137) | 0xC3d4E5... | 0xD4e5F6... | NST-T-Pledge-Agreement-2025-12-30 / 1 | 0x<exact> | 700000000.00 USD | 0xpoly789... | 52,345,679 | Match |
| Base (8453) | 0xE5f6G7... | 0xF6g7H8... | NST-T-Pledge-Agreement-2025-12-30 / 1 | 0x<exact> | 700000000.00 USD | 0xbase012... | 12,345,680 | Match |
| XRPL (reference) | N/A (off-chain ref) | N/A | Memo: pledgeId=NST-T-2025-12-30-700M + docHash + attestTx | 0x<exact> | 700000000.00 USD (via Apostle attest) | XRPL tx 123... | Ledger 89,012,345 | Reference to Apostle canonical |

**Verification notes:**
- All `supportingDocHash` values match the exact bytes of the source PDFs.
- Amounts, custody notes, and pledgeIds identical.
- No drift detected. Full evidence package (tx receipts, Safe executions, PDF hashes) stored in operator vault.

Repeat this format for any subsequent amendments or re-attestations.

## 5. Checklist for Legal/Security Signoff Before Any Live Apostle Transaction

Use this **before** the first real deployment or attestation on Apostle (critical system). Complete all items; obtain explicit human sign-off.

### Pre-Deployment
- [ ] Legal review of executed pledge agreement, CIS, and any amendments complete (debtor names, authority, perfection steps including control agreements if required, filing jurisdictions).
- [ ] UCC-1 draft finalized by counsel and ready for submission (Troptions as authorized filer).
- [ ] Security audit of contracts, deployment scripts, and backend hasher complete (or explicitly waived for dry-run only).
- [ ] Production Safes created on Apostle (and planned for Polygon/Base) per `deploy/signer-manifest.template.yaml` and `multisig/SAFE-PLAN.md`.
- [ ] Signer manifest filled with real addresses and stored in operator vault (never in repo).
- [ ] Environment files (`.env.apostle` etc.) reviewed; no secrets committed.
- [ ] Sovereign-control-plane preflight run with appropriate scope (e.g., troptions or sovereign-control-plane) and passed.
- [ ] Explicit human approval obtained for Apostle deployment and first 700M attestation (document approvers, date, scope).

### Deployment & Safe Transfer
- [ ] Dry-run transcripts reviewed and match expected (as in Section 1 above).
- [ ] Contracts deployed (Apostle first).
- [ ] Immediate Safe admin transfer executed and verified (owner() calls return the Safe address on both contracts).
- [ ] Registrars and attestors added via Safe tx (record tx hashes).
- [ ] Contracts verified on available explorers (or source + ABI published).
- [ ] Addresses + verification metadata recorded in `registry/addresses.md`.

### First Attestations (700M Pledge)
- [ ] Hashes computed from **exact bytes** of the source PDFs in controlled storage (reproducible via backend hasher).
- [ ] Document registrations executed (pledge agreement + CIS + any exhibits).
- [ ] Reserve attestation executed for "700000000.00" USD cash (Scotia custody note).
- [ ] Events verified on-chain and match expected payloads (Section 3).
- [ ] Tx hashes, blocks, and event data recorded.

### Cross-Chain & XRPL
- [ ] Mirrors deployed to Polygon/Base (after Apostle).
- [ ] Cross-chain consistency report generated and reviewed (Section 4 format).
- [ ] XRPL references generated via `xrpl/xrpl-adapter.js` (or equivalent) and tested in testnet.
- [ ] Mock reports for XRPL loan references reviewed.

### Post-Attestation & Governance
- [ ] Full evidence package (PDFs, tx receipts, Safe executions, consistency reports, signer approvals) stored in operator vault.
- [ ] Site / Pages updated with live examples (if public).
- [ ] System registered in sovereign-control-plane registry (human sign-off).
- [ ] UCC-1 filed (Troptions as filer) and recorded.
- [ ] Policy engine (Apostle/x402/MCP) wired to use the attested reserve status for any issuance/lending gating.
- [ ] Rollback / incident procedures tested (Safe can remove attestors/registrars).

**Sign-off Block** (to be completed by approvers):
- Legal Counsel: ________________ Date: ________
- Security Reviewer: ________________ Date: ________
- Operator (Kevan / designated): ________________ Date: ________
- Preflight ID / Scope: ________________
- Approval Scope: "Apostle deployment + first 700M attestation for NST/Troptions pledge"

Any "No" or open item blocks live actions. Re-run preflight and obtain fresh approvals for any material change.

## How to Use This Pack

1. Treat the transcripts, metadata, payloads, and reports as **templates**. Replace placeholders with real values from your dry-runs.
2. Run the actual dry-runs using the existing `deploy-*.ps1` scripts + backend hasher + `xrpl-adapter.js` in a test environment.
3. Generate your own mock reports using the format above.
4. Complete the signoff checklist with real reviewers.
5. Only after full sign-off: proceed to live Apostle actions (Apostle first, then mirrors, then XRPL references).
6. Update the site and `registry/addresses.md` with the real data.

This pack provides the "evidence-grade rehearsal material" needed to de-risk the first live steps while the architecture (core first, mirrors, XRPL) and review portal are already in place.

---

**All prior packs remain the foundation. This dry-run pack reduces the gap between "we have the design" and "we are ready to execute safely under the 700M pledge structure."**

Update this pack with real dry-run outputs as they are produced. Cross-reference with the site for the full legal facts and the pledge PDFs as the canonical source.