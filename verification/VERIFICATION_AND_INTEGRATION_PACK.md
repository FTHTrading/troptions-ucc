# ABI + Verification + Cross-Chain Integration Pack

**Status**: Ready for legal and security review. This pack provides the artifacts needed to move from review to deployable integrations on Apostle (core), Polygon/Base (mirrors), and XRPL (lending rail) without assuming production readiness.

## 1. ABIs

Compiled ABIs for the two core contracts (generated from source for verification and integration).

- [DocumentHashRegistry.json](../abi/DocumentHashRegistry.json) — For registering and querying legal document hashes (pledge, UCC-1s, etc.).
- [TroptionsReserveRegistry.json](../abi/TroptionsReserveRegistry.json) — For attesting reserve/collateral values linked to the 700M NST/Troptions pledge.

These can be used with web3.js, ethers.js, viem, cast, or any EVM tool for calling the contracts on Apostle, Polygon, or Base.

## 2. Contract Verification Instructions & Checklist

### For EVM Chains (Polygon 137, Base 8453)

1. Deploy the contracts using the provided scripts (`deploy-polygon.ps1` or `deploy-base.ps1`).
2. After deployment, use the explorer (Polygonscan, Basescan) "Verify Contract" feature:
   - Upload the exact source from `contracts/src/`.
   - Compiler: 0.8.20
   - Optimization: enabled, 200 runs (or match your foundry.toml).
   - Constructor args: none.
3. For automated: use `forge verify-contract` with the appropriate API key in the env file.
4. Record the verification status and URL in `registry/addresses.md`.

### For Apostle (chain 7332)

Apostle may use a custom explorer or Blockscout-compatible instance. Use the same source + compiler settings. If no automated verifier, publish the source + ABI + deployment tx on the project site or sovereign docs for transparency.

**Checklist**:
- [ ] ABI matches the on-chain bytecode (use `cast code` or explorer to compare).
- [ ] Events are indexed as in the source (critical for off-chain indexers and the site).
- [ ] Owner is transferred to the intended Safe immediately after deploy.
- [ ] Registrars/attestors added via Safe tx (record the tx hashes).
- [ ] First document hash registration + 700M reserve attestation executed and verified against the source PDFs.
- [ ] Cross-chain consistency checklist executed for any mirrored attestations.

## 3. Sample Integration Payloads (Apostle ↔ Polygon/Base ↔ XRPL)

The core idea: an attestation on Apostle (canonical) is referenced on mirrors and in XRPL flows for the 700M pledge.

### Cross-EVM Example Payload (for off-chain systems or bridges)

```json
{
  "pledgeId": "NST-T-2025-12-30-700M",
  "collateralId": "schedule-a-usd-cash",
  "asset": "USD",
  "amount": "700000000.00",
  "supportingDocHash": "0x<keccak256 of exact pledge PDF bytes>",
  "apostleAttestTx": "0x<tx hash on Apostle>",
  "apostleBlock": 123456,
  "polygonMirrorAttestTx": "0x<if mirrored>",
  "baseMirrorAttestTx": "0x<if mirrored>",
  "evidenceUri": "https://<your-pages-site>/ or raw GitHub pledge PDF"
}
```

Use this payload in:
- Backend services (e.g., the existing troptions-ucc-backend hasher + packet router).
- Policy engines on the UnyKorn/Apostle control plane.
- Partner dashboards or x402 metered calls.

### XRPL Integration Example (from the XRPL pack)

Memo data (hex-encoded JSON or structured):

```
Pledge: NST-T-2025-12-30-700M
DocHash: 0x<from DocumentHashRegistry on Apostle>
AttestTx: 0x<Apostle tx for the 700M attestation>
Amount: 700000000.00 USD
Custody: Scotia Bank Canada
SecuredParty: Troptions
Evidence: <link to site or pledge PDF>
```

See `xrpl/XRPL_INTEGRATION.md` and `xrpl/xrpl-adapter.js` (below) for a reference implementation that turns an attestation into XRPL-ready memo/URI data.

## 4. xrpl-adapter.js (Reference Implementation)

A small, executable Node script to demonstrate turning an Apostle attestation into XRPL-compatible reference data. Place this in your XRPL loan broker or underwriting service.

```js
// xrpl/xrpl-adapter.js
// Usage: node xrpl-adapter.js <pledgeId> <docHash> <attestTx> <amount> <custodyNote>
// Outputs XRPL memo data ready for a loan reference tx.

const args = process.argv.slice(2);
if (args.length < 5) {
  console.error('Usage: node xrpl-adapter.js <pledgeId> <docHash> <attestTx> <amount> <custodyNote>');
  process.exit(1);
}

const [pledgeId, docHash, attestTx, amount, custodyNote] = args;

const reference = {
  pledgeId,
  docHash,
  attestTx,
  amount,
  custody: custodyNote,
  securedParty: "Troptions",
  evidence: "https://<your-pages-site> or raw pledge PDF link",
  source: "troptions-ucc repo + Apostle attestation"
};

const memoData = Buffer.from(JSON.stringify(reference)).toString('hex').toUpperCase();

console.log('XRPL Memo Data (hex for MemoData field):');
console.log(memoData);
console.log('\nFull reference object:');
console.log(JSON.stringify(reference, null, 2));
console.log('\nExample XRPL tx fragment:');
console.log(`Memos: [{ Memo: { MemoType: "PledgeReference", MemoData: "${memoData}" } }]`);
```

Install deps if needed: `npm install xrpl` (for full tx building later).

This turns the XRPL integration guide into something you can run immediately after an attestation.

## 5. wrangler.toml (Cloudflare Pages Config for the Site)

Place in the repo root or `site/wrangler.toml` for repo-native Pages deployment.

```toml
name = "troptions-ucc"
compatibility_date = "2024-01-01"

[site]
bucket = "./site"
entry-point = "site"

[build]
command = ""   # static site, no build step
```

Deploy with: `wrangler pages deploy site --project-name=troptions-ucc` (or connect via dashboard with output dir `site`).

This makes the review site (legal facts, contract downloads, all packs including XRPL, governance docs) deployable directly from the repo.

## 6. How to Use This Pack

1. After legal/security review and approvals, deploy contracts on Apostle (core) using the existing scripts.
2. Verify contracts using the instructions above.
3. Generate ABIs (already provided) for any off-chain or cross-chain callers.
4. Execute first 700M pledge attestations on Apostle.
5. Use the sample payloads + xrpl-adapter.js to create XRPL references for loan products.
6. Mirror to Polygon/Base and run cross-chain consistency checks.
7. Update the Pages site (or its wrangler deploy) with any live tx examples.
8. Wire into the broader UnyKorn/Apostle/x402 policy engine so that the attested 700M reserve can gate issuance or lending activity.

All artifacts remain "ready for legal and security review." The site serves as the single portal.

## Review Notes

- ABIs are derived directly from the reviewed source contracts.
- Payloads and adapter are illustrative but executable starting points.
- Everything ties back to the executed NST/Troptions 700M pledge documents (canonical in controlled storage).
- No production deployment or reliance until counsel sign-off on UCC perfection, control agreements, and the full reserve structure.

This pack completes the bridge from the static review site to practical, multi-rail integrations while respecting the review-first, core-first topology. 

Next after this (if desired): full XRPL broker integration code, or production deployment runbooks once approvals are in place.