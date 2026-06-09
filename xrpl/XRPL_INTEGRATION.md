# XRPL Integration Pack — Troptions UCC Collateral Governance

**Version**: 2026-06 (initial for the 700M NST/Troptions pledge)
**Status**: Ready for legal, security, and operational review. Not yet implemented in production XRPL flows.

This pack documents how the on-chain attestations from the Troptions UCC collateral layer (DocumentHashRegistry and TroptionsReserveRegistry on the sovereign control plane) can be used to support XRPL-native lending and credit products.

It aligns with the UnyKorn/Troptions Multi-Chain Topology:
- **Core (canonical)**: UnyKorn/Avalanche L1 + Apostle (chain 7332) + x402 + MCP for policy, orchestration, and the authoritative reserve attestations for the 700M pledge.
- **XRPL**: Specialized lending/credit rail using native XRPL primitives (single-asset vaults, loan brokers, off-chain underwriting for fixed-term institutional lending).
- **External EVM (Polygon 137 / Base 8453)**: Mirrored contracts for visibility and partner access (already covered in prior packs).

The 700M USD cash pledge (Newpoint Statutory Trust as pledgor, Troptions as secured party, Scotia Bank Canada custody, per the executed Master Asset Pledge Security Agreement and CIS) is the first concrete reserve object. XRPL products can reference the attested collateral as proof-of-funds (PoF), collateral backing, or for loan underwriting without moving the underlying cash.

**Critical**: This layer provides **attestation and evidence**, not direct minting, issuance, or on-ledger collateral movement. The legal security interest is perfected via UCC-1 (Troptions authorized filer). Actual loan decisions, underwriting, and any XRPL vault/loan creation remain subject to off-chain processes, KYC/AML, and the core policy engine on Apostle.

## Why XRPL for Lending/Credit

XRPL's lending protocol (as documented) is oriented around:
- Single-asset vaults for liquidity provision.
- Loan brokers and fixed-term lending.
- Emphasis on off-chain underwriting and institutional-grade flows rather than pure DeFi liquidation mechanics.

This fits the pledge/UCC posture (cash collateral at a traditional custodian, perfected security interest, governance via attestations) better than generic EVM lending primitives.

The on-chain hashes and reserve attestations from Apostle provide a verifiable, event-sourced bridge: an XRPL loan can reference the exact pledge document hash, the attestation tx, and the attested amount ("700000000.00" USD) as part of its terms or metadata.

## Integration Architecture

```
Legal pledge docs (OneDrive, executed PDFs)
          |
          v
DocumentHashRegistry + TroptionsReserveRegistry (Apostle/core — canonical)
          |
          +--> Event logs + tx hashes (immutable proof)
          |
          v
XRPL Loan / Vault (via broker or direct)
          - Memo / URI / Reference field contains:
            - Pledge ID (e.g. "NST-T-2025-12-30-700M")
            - Supporting doc hash (from DocumentHashRegistry)
            - Attestation tx hash / block (from TroptionsReserveRegistry)
            - Attested amount + asset + custody note
          - Off-chain underwriting uses the above + KYC from CIS
          - Vault/loan creation on XRPL references the evidence
```

Cross-chain consistency is enforced via the `CROSS_CHAIN_CONSISTENCY_CHECKLIST.md` (for EVM mirrors) and this pack for XRPL. The Apostle attestation is always the source of truth.

## Key Artifacts for XRPL Use

1. **Document Hash** (from backend hasher or `POST /hash`):
   - Use the exact bytes of `11-Downloads/NST T pledge agreement 2025-12-30_150719.pdf` and the CIS.
   - Register via `registerDocument` on Apostle (and mirrors).

2. **Reserve Attestation**:
   - `attestReserve("NST-T-2025-12-30-700M", "schedule-a-usd-cash", "USD", "700000000.00", <supportingDocHash>, "Scotia Bank Canada custody; first-priority security interest per Master Asset Pledge...")`
   - This creates the on-ledger record with rich events.

3. **XRPL Reference**:
   - In XRPL transactions (Payment, TrustSet, or custom for lending), use the `Memos` field or `URI` (for tokens/NFTs) or loan-specific fields to embed:
     ```
     Pledge: NST-T-2025-12-30-700M
     DocHash: 0x<keccak or sha256>
     AttestTx: <Apostle tx hash>
     Amount: 700000000.00 USD
     Custody: Scotia Bank Canada
     SecuredParty: Troptions
     Evidence: https://<pages-site>/ (or GitHub raw for the docs)
     ```
   - For XRPL lending (if using the protocol's vault/loan objects), attach the reference in the loan terms or broker metadata.

## Example XRPL Transaction Template (Memo Style)

Using xrpl.js (or equivalent):

```js
const xrpl = require('xrpl');

async function createLoanReference(client, wallet) {
  const tx = {
    TransactionType: "Payment", // or custom for loan
    Account: wallet.address,
    Destination: "r...", // broker or vault account
    Amount: "0", // or actual
    Memos: [
      {
        Memo: {
          MemoType: xrpl.convertStringToHex("PledgeReference"),
          MemoData: xrpl.convertStringToHex(JSON.stringify({
            pledgeId: "NST-T-2025-12-30-700M",
            docHash: "0x<from DocumentHashRegistry>",
            attestTx: "<Apostle tx hash for the 700M attestation>",
            amount: "700000000.00",
            asset: "USD",
            custody: "Scotia Bank Canada",
            securedParty: "Troptions",
            source: "https://raw.githubusercontent.com/FTHTrading/troptions-ucc/main/legal/UCC1-COLLATERAL-DRAFT.md" // or Pages URL
          }))
        }
      }
    ]
  };

  const prepared = await client.autofill(tx);
  const signed = wallet.sign(prepared);
  const result = await client.submitAndWait(signed.tx_blob);
  console.log("XRPL tx:", result);
  return result;
}
```

**Note**: This is an illustrative template. Adapt to the exact XRPL lending protocol objects (vaults, loans) once the broker/underwriting flow is defined. The key is cryptographic reference to the Apostle attestation.

## Using the 700M Pledge in XRPL Loans

- **Collateral/PoF**: The attested "700000000.00 USD" can serve as evidence of available collateral for an XRPL loan, with the security interest perfected off-ledger via the UCC.
- **Underwriting**: Brokers can pull the on-chain attestation + the legal packet (via the site or direct OneDrive access for authorized parties) to underwrite fixed-term loans.
- **Risk/Perfection**: The cash never leaves Scotia for the XRPL leg; the pledge agreement governs enforcement. XRPL records the reference for transparency and audit.
- **Cross-rail**: The same attestation can back EVM distribution (via mirrors) and XRPL lending simultaneously, subject to the core policy engine (no over-commitment of the 700M).

## Recommended XRPL Pack Contents (for Implementation)

- This `XRPL_INTEGRATION.md`.
- Updated `CHAIN_TOPOLOGY.md` (add detailed XRPL layer).
- Example payloads/templates (this file + any accompanying .js).
- Updates to the Pages site (new XRPL section with downloads and the 700M pledge as example collateral).
- Integration with existing `ATTESTATION_RUNBOOK.md` (extend the "subsequent updates" section for XRPL references).
- Notes for the backend hasher: ensure it can output formats suitable for XRPL hex/memo encoding.

## Open Items for Review

- Exact XRPL lending protocol objects/fields to use for the reference (confirm with XRPL docs or broker integration).
- Any on-ledger vs. off-ledger split for the loan terms.
- KYC/AML flow tying the CIS data to XRPL accounts.
- How XRPL loan events feed back into the Apostle policy engine (via x402 or MCP).
- Tax, regulatory, and custody implications of using a pledged USD cash position to back XRPL-denominated loans.

## Next Steps After Review

1. Legal/security sign-off on using the attestations for XRPL products.
2. Define the specific XRPL transaction types and memo/URI schema with brokers.
3. Implement a lightweight adapter (e.g., in the existing backend or a new xrpl/ service) that generates the reference payload from an Apostle attestation tx.
4. Test end-to-end: hash pledge docs → attest on Apostle → generate XRPL reference → create sample loan/vault on XRPL testnet.
5. Update the site and this doc with live examples/tx hashes.
6. Coordinate with the broader UnyKorn capital systems for policy gating.

## Disclaimers (Review-First Posture)

- All XRPL integration is subject to the same legal authority as the core: the executed pledge agreement, UCC filings (once submitted), and counsel validation of debtor names, authority, perfection, and enforcement.
- The contracts and attestations are "ready for legal and security review." No production deployment or reliance on XRPL flows until approvals.
- XRPL lending involves its own protocol risks, account setup, and off-chain underwriting. The Troptions attestations provide evidence; they do not replace it.
- Source PDFs in controlled storage remain canonical. On-chain records (Apostle + any XRPL references) must be reproducible from those exact bytes.

This pack completes the three-layer model for the 700M pledge: core attestations (Apostle), EVM mirrors, and XRPL lending specialization — all reviewable via the static Pages site.

For questions or to proceed to implementation (e.g., a sample xrpl-adapter script or wrangler.toml for the site), provide direction after review.