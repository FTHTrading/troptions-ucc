# Safe Admin Transfer Checklist — Troptions UCC Registries (Apostle/Core First)

**Use this immediately after any initial deployment of DocumentHashRegistry and TroptionsReserveRegistry on Apostle (or mirrors).**

The contracts deploy with the EOA deployer as `owner`. Production use requires transferring that ownership (and configuring registrars/attestors) to a proper multisig/Safe controlled per `multisig/SAFE-PLAN.md` and the signer manifest.

**This is a high-privilege action on a critical system (Apostle chain). Obtain explicit human approval and run preflight before execution.**

## Prerequisites (do these first)

- [ ] The deployment script (`scripts/deploy-apostle.ps1` or manual forge) has succeeded and you have the exact deployed addresses.
- [ ] You have recorded the addresses in `registry/addresses.md`.
- [ ] The target Safe has already been created on Apostle (threshold and signer set per the filled signer-manifest.template.yaml).
- [ ] You have the Safe address and have verified it controls the intended signers.
- [ ] You have the deployer private key (only for the transfer tx) and it has sufficient gas on Apostle.
- [ ] Legal/security review of the contracts and the 700M NST pledge structure is complete (or explicitly waived for testnet-style dry run).

## Step-by-Step Transfer (Apostle)

1. **Verify current owner**
   - Use `cast` or the explorer / RPC to call `owner()` on both deployed contracts.
   - Confirm it matches the EOA used for deployment.

2. **Prepare the Safe transaction(s)**
   - In the Safe UI (or approved interface for Apostle), create a transaction to call `transferOwnership(newOwner)` on **DocumentHashRegistry**.
   - Create a second transaction (or batch if supported) for `transferOwnership(newOwner)` on **TroptionsReserveRegistry**.
   - `newOwner` = the primary Safe address from the signer manifest.
   - Use the highest practical threshold for these admin transfers (ideally the full 3-of-5 or equivalent).

3. **Execute the Safe transaction(s)**
   - Collect the required signatures from the listed signers.
   - Broadcast on Apostle.
   - Wait for confirmation and record the Safe execution tx hash + block.

4. **Verify post-transfer state**
   - Call `owner()` on both contracts again — it must now return the Safe address.
   - (Optional but recommended) Call `addRegistrar` and `addAttestor` (from the new Safe owner) for the operational addresses listed in the signer manifest.
   - Test a low-stakes `registerDocument` and `attestReserve` (e.g., a test hash) from an authorized registrar/attestor.

5. **Record everything**
   - Update `registry/addresses.md` with:
     - Final owner = Safe address
     - Tx hashes for the transfer(s)
     - Registrar / attestor addresses that were added
   - Update the signer manifest with actual addresses (if they were still placeholders).
   - Store the full evidence (tx links, Safe UI screenshots, manifest) in the operator vault.

6. **Revoke / rotate the original deployer key**
   - The original deployment EOA should no longer have privileged access.
   - If it was a hot key, rotate or destroy it after the transfer is confirmed.

## Polygon / Base (future mirrors)

Repeat the same checklist on each chain after deploying the identical contract bytecode:
- Separate Safe per chain (or coordinated via the sovereign control plane).
- Same threshold and approval matrix.
- Record in the same `registry/addresses.md` under the respective chain sections.

## Rollback / Incident

- If a transfer tx is executed in error or to the wrong address, the new owner (the incorrect Safe) would need to call `transferOwnership` back (or to the correct address). This is why the signer manifest and approval matrix must be reviewed before any admin action.
- For emergency removal of a registrar/attestor (without full owner transfer), the current owner Safe can call `removeRegistrar` / `removeAttestor`.

## Evidence & Audit Trail

Every admin action on these contracts emits events. Treat the combination of:
- Signed legal PDFs (OneDrive, exact bytes)
- Document hash registration tx + event
- Reserve attestation tx + event
- Safe execution tx for ownership / role changes

...as the complete forensic package for the 700M pledge collateral.

**Never perform this checklist or any Apostle transaction without prior preflight and explicit human approval.** 

After successful transfer on Apostle, the registries are ready for the first real pledge document hash registration and the 700,000,000.00 USD cash reserve attestation.