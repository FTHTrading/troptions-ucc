# UCC-1 Collateral Draft — TROPTIONS / NST Pledge

**Status**: Working draft. Not filed.  
**Related Source (canonical)**: `11-Downloads/NST T pledge agreement 2025-12-30_150719.pdf` and `NST CIS 2025-12-28_225418.pdf`

## Purpose

This document supports the preparation and filing of one or more UCC-1 financing statements perfecting a security interest in the collateral pledged by the TROPTIONS interests to Newpoint Statutory Trust (or its designated trustee) under the December 2025 pledge arrangement (the "Pledge").

The on-chain `DocumentHashRegistry` and `TroptionsReserveRegistry` exist to create a parallel, immutable, event-sourced record of the exact documents and the attested reserve/collateral values.

## Collateral Description (high-level, to be refined from executed Pledge)

Collateral includes (but is not limited to):

- All right, title, and interest of Pledgor in and to the assets, instruments, securities, real property interests, receivables, and other property more particularly described in Schedule A to the Pledge Agreement dated 2025-12-30 between [Pledgor entities] and Newpoint Statutory Trust (the "Pledged Collateral").
- All proceeds, products, offspring, rents, and profits of the foregoing.
- All books and records relating to the foregoing.
- Any after-acquired property of the same type that becomes subject to the Pledge.

**Exact collateral schedule, debtor names, secured party details, and filing jurisdictions must be taken verbatim from the executed Pledge and any officer's certificates or exhibits.**

## Key Filing Considerations

- Debtor legal names (exact, including any trade names / DBAs) — pull from the Pledge and CIS.
- Secured party: Newpoint Statutory Trust (or the exact name and address appearing on the agreement).
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

- [ ] Exact debtor legal names and addresses
- [ ] Exact secured party / trustee details for NST
- [ ] Schedule A collateral description (full text or exhibit reference)
- [ ] Any specific representations, warranties, or carve-outs that affect the UCC description
- [ ] Filing office(s) and authorized signer(s) for the UCC-1
- [ ] Any control agreements, blocked account agreements, or other perfection steps outside of UCC-1

**Do not file any UCC-1 using language from this draft until the above items are verified against the executed originals in the operator's OneDrive.**

## Relationship to Reserve Attestation

The `TroptionsReserveRegistry` is intended to hold the current attested value of the pledged collateral (or material subsets). The UCC-1 perfects the security interest; the on-chain registry provides a real-time (or periodic) view of the economic coverage of that security interest for governance and due diligence purposes.

---

**Next step after execution**: produce the final PDF(s), hash them, register the hashes, then attest the initial reserve position(s).
