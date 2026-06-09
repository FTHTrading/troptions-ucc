# Mock Cross-Chain Consistency Reports (Dry-Run / Simulation)

Use these as templates. Generate real reports after mirroring the first 700M attestations. Record in `registry/addresses.md` and the site.

## 700M Pledge — Post-Mirror Consistency Report (Example)

| Chain          | DocHashRegistry | ReserveRegistry | Pledge Doc (name/v) | Supporting Hash | Amount          | Attest Tx      | Block     | Status    |
|----------------|-----------------|-----------------|---------------------|-----------------|-----------------|----------------|-----------|-----------|
| Apostle (7332) | 0xA1b2C3...    | 0xB2c3D4...    | NST-T-Pledge... / 1 | 0x<exact>      | 700000000.00 USD | 0xdef456...   | 1234568  | Canonical |
| Polygon (137)  | 0xC3d4E5...    | 0xD4e5F6...    | NST-T-Pledge... / 1 | 0x<exact>      | 700000000.00 USD | 0xpoly789...  | 52345679 | Match     |
| Base (8453)    | 0xE5f6G7...    | 0xF6g7H8...    | NST-T-Pledge... / 1 | 0x<exact>      | 700000000.00 USD | 0xbase012...  | 12345680 | Match     |
| XRPL (ref)     | N/A (memo ref) | N/A            | Memo: pledgeId=... + docHash + attestTx | 0x<exact>      | 700000000.00 (via Apostle) | XRPL 123... | Ledger 89012345 | Reference to Apostle |

**Checks Performed**:
- All supportingDocHash values match exact bytes of source PDFs (recomputed on deployment machine).
- Amounts, custody notes ("Scotia Bank Canada"), pledgeIds, and secured-party language identical.
- No drift. Full evidence (txs, Safe executions, PDF hashes) in operator vault.

## Additional Mock (for a hypothetical amendment)
(Repeat the table format with version=2, new txs, etc.)

**Sign-off**: Operator + Reviewer initials + date on the real version of this report before relying on mirrors for any external flows.