# UCC-1 Collateral Draft — TROPTIONS / NST Pledge

**Status**: Working draft. Not filed.  
**Related Source (canonical)**: `11-Downloads/NST T pledge agreement 2025-12-30_150719.pdf` and `NST CIS 2025-12-28_225418.pdf`

## Purpose

This document supports the preparation and filing of one or more UCC-1 financing statements perfecting a security interest in the collateral pledged by Newpoint Statutory Trust (the Pledgor / Delaware statutory trust, registration 6985669) to Troptions (the Secured Party) under the Master Asset Pledge Security Agreement / December 2025 pledge arrangement (the "Pledge"). Troptions is explicitly authorized to file UCC-1 financing statements with respect to the pledged collateral.

The on-chain `DocumentHashRegistry` and `TroptionsReserveRegistry` exist to create a parallel, immutable, event-sourced record of the exact documents and the attested reserve/collateral values.

## Collateral Description (high-level, to be refined from executed Pledge)

Collateral (per Schedule A of the executed Pledge):

- USD cash in the declared amount of 700,000,000.00 (seven hundred million United States Dollars).
- Custody / location: Scotia Bank Canada.
- All proceeds, products, and related rights as more particularly described in the Pledge and its schedules/exhibits.
- All books and records relating to the foregoing.

**Exact details, any sub-accounts, control arrangements, and after-acquired clauses must be taken verbatim from the executed Pledge (source: 11-Downloads/NST T pledge agreement 2025-12-30_150719.pdf).**

**Exact collateral schedule, debtor names, secured party details, and filing jurisdictions must be taken verbatim from the executed Pledge and any officer's certificates or exhibits.**

## Key Filing Considerations

- Debtor legal names (exact, including any trade names / DBAs) — pull from the Pledge and CIS.
- Secured party: Troptions (exact legal name and address as it appears on the Pledge; Troptions is the authorized filer of the UCC-1).
- Jurisdictions: primary place of business / formation of each debtor + any real property recording requirements.
- Collateral is "all assets" or "specific" — the Pledge is expected to be specific; draft the UCC-1 description to match or incorporate by reference the Pledge Schedule A.
- Duration / lapse dates, continuation statements, amendments for changes in name or collateral.

## Cross-Reference to On-Chain Records

When the final executed UCC-1 (or the authorization / pledge instrument) is signed:

1. Compute hash(es) via `backend` `/hash` endpoint (or equivalent reproducible script).
2. Register in `DocumentHashRegistry` under a clear name such as:
   - `NST-T-Pledge-Agreement-2025-12-30`
   - `UCC1-Filing-Collateral-[state]-[date]`
3. Record initial reserve attestation(s) in `TroptionsReserveRegistry` using the same supporting doc hash and the exact amount string from the Pledge (e.g. "700000000").

## Open Items (to be closed from the source PDFs)

- [ ] Exact debtor (Pledgor) legal names and addresses (Newpoint Statutory Trust, DE reg. 6985669, and any related entities)
- [ ] Exact secured party details for Troptions (including address for filing)
- [ ] Full Schedule A / collateral description verbatim from the executed Pledge (USD cash 700,000,000.00 at Scotia Bank Canada)
- [ ] Any specific representations, warranties, or carve-outs that affect the UCC description
- [ ] Filing office(s) and authorized signer(s) for the UCC-1
- [ ] Any control agreements, blocked account agreements, or other perfection steps outside of UCC-1

**Important caution**: This repo and these drafts do not complete legal closing or perfection by themselves. Before filing or treating the on-chain attestations as execution-ready for the 700M position, counsel must validate debtor naming, authority to pledge/file, perfection steps (including any control agreements or blocked account requirements in addition to UCC-1), and the contracts here still require security review before production deployment. Source PDFs in OneDrive are canonical.

## Relationship to Reserve Attestation

The `TroptionsReserveRegistry` is intended to hold the current attested value of the pledged collateral (or material subsets). The UCC-1 perfects the security interest; the on-chain registry provides a real-time (or periodic) view of the economic coverage of that security interest for governance and due diligence purposes.

---

**Next step after execution**: produce the final PDF(s), hash them, register the hashes, then attest the initial reserve position(s).
