# Multisig / SAFE Control Plan — Troptions UCC Registries

**Purpose**: Define who controls the privileged roles on `DocumentHashRegistry` and `TroptionsReserveRegistry` (owner, registrars, attestors) and how that control is exercised in practice.

## Initial Posture (recommended for first deployment)

- **Contract owner**: A 3-of-5 or 2-of-3 SAFE (or Gnosis Safe) controlled by FTH / TROPTIONS operator principals + one independent or counsel seat if required for the pledge.
- **Registrars** (can call `registerDocument`): Same as owner + one or two operational / legal roles (can be EOAs or additional Safe signers) for day-to-day hash registration.
- **Attestors** (can call `attestReserve`): Strictly limited. Start with the owner Safe + one or two designated treasury / collateral officers.

Thresholds should be high enough to prevent unilateral action on material collateral attestations while still allowing timely registration of executed documents.

## Recommended Signer Composition (example — adjust to actual parties)

1. Kevan (operator / FTH)
2. Designated FTH principal or family office
3. Independent counsel or trustee representative (for NST-related matters)
4. (Optional) Technical operator / infra lead
5. (Optional) Second independent or rotating seat

For a 3-of-5: any three of the above.

For day-to-day document hashing and routine attestations, a lower-threshold "ops sub-safe" or explicit EOA registrars/attestors can be used, with the main Safe retaining owner power to add/remove and to perform emergency actions.

## Key Ceremony & Setup Steps

1. Create the Safe on the target chain (or use an existing FTH/TROPTIONS-controlled Safe if policy allows reuse).
2. Record the Safe address and signer list (with addresses and roles) in this file and in sovereign-control-plane registry notes.
3. Deploy the two registries with the Safe as initial `owner`.
4. Call `addRegistrar` / `addAttestor` for any additional operational addresses (never for the full signer set unless necessary).
5. Test a document hash registration + reserve attestation from an authorized address.
6. Verify events are emitted and queryable.
7. Document the deployment txs and block numbers here.

## Emergency & Rotation Procedures

- **Lost signer**: Remaining signers execute Safe transaction to replace the lost address. Then call `removeAttestor` / `removeRegistrar` if the old address was authorized, followed by `add*` for the replacement.
- **Compromise suspected**: Immediately pause new attestations if possible (owner can remove the compromised attestor). Re-key the affected Safe signers. Re-attest any material positions from the new set with fresh supporting doc hashes if integrity is in question.
- **Contract upgrade / migration**: Because the current registries are non-upgradeable by design (simplicity + forensic clarity), migration would involve deploying new registries and having the owner attest a "superseding" record in the new contracts pointing back to the old history. Plan this only if a material flaw is discovered.

## Operational Security Notes

- Never store Safe private keys or seed phrases in this repo or any shared drive.
- Use hardware wallets or institutional key management for all signer devices.
- Maintain an offline, printed, sealed copy of the Safe address, signer addresses, and threshold.
- All on-chain actions by the Safe should be executed via the Safe UI or a verified interface — avoid raw `execTransaction` calls from un-audited scripts.
- For high-value attestations (full 700M position or large changes), require explicit multi-party confirmation outside the on-chain transaction (recorded in an evidence log or signed memo).

## Mapping to On-Chain Roles

| Role on Contract          | Who should hold                  | Change frequency | Notes |
|---------------------------|----------------------------------|------------------|-------|
| owner                     | Primary Safe (3-of-5)            | Very low         | Can add/remove everything |
| registrars                | Safe + 1-2 legal/ops EOAs        | Low              | Day-to-day document registration |
| attestors                 | Safe + 1-2 collateral officers   | Low              | Reserve / collateral value attestations |

After deployment, record the exact addresses here and in the root README.

## Post-Deployment Checklist

- [ ] Safe address added to this file and root README
- [ ] At least one test registration + attestation executed and events verified
- [ ] Owner powers tested (add/remove a test attestor)
- [ ] Emergency removal path exercised in a dry run (on testnet or a throwaway contract)
- [ ] Signer contact list + key rotation runbook stored in operator vault (not this repo)

---

**This control plan is part of the overall collateral governance package for the NST pledge. Changes to the attestor set or thresholds must be reflected both on-chain (via owner actions) and in the off-chain SAFE-PLAN.md + any investigation artifacts.**
