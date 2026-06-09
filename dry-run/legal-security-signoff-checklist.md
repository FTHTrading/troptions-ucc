# Legal / Security Signoff Checklist — Before Any Live Apostle Transaction

**Critical**: Complete this checklist (with real sign-offs) before the first live deployment or attestation on Apostle (chain 7332 — critical risk system). Re-run preflight and obtain fresh approvals for material changes.

This is the execution-focused version from the Dry-Run Operations Pack. Cross-reference the full `deploy/SAFE-ADMIN-TRANSFER-CHECKLIST.md`, `verification/VERIFICATION_AND_INTEGRATION_PACK.md`, and `multisig/SAFE-PLAN.md`.

## Pre-Deployment
- [ ] Legal review of executed pledge agreement + CIS + amendments complete (exact debtor names, authority to pledge/file, perfection steps including any control agreements, filing jurisdictions).
- [ ] UCC-1 draft finalized by counsel and ready for filing (Troptions as authorized filer per the pledge).
- [ ] Security audit of contracts, `deploy-*.ps1` scripts, backend hasher, and `xrpl-adapter.js` complete (or explicitly waived for this dry-run rehearsal only).
- [ ] Production Safes created on Apostle (core) and planned for Polygon/Base per the filled signer manifest and SAFE-PLAN.
- [ ] Signer manifest (real addresses) stored in operator vault (never committed to repo).
- [ ] Environment files reviewed; secrets handled via sovereign-control-plane patterns only.
- [ ] Sovereign preflight run (appropriate scope, e.g. troptions or sovereign-control-plane) and passed.
- [ ] Explicit human approvals obtained and documented for: Apostle deployment + first 700M attestation (list approvers, date, exact scope).

## Deployment & Immediate Post-Deploy
- [ ] Dry-run transcripts reviewed and match expected patterns (see sample-deployment-transcripts.md).
- [ ] Contracts deployed on Apostle (DocumentHashRegistry + TroptionsReserveRegistry).
- [ ] Safe admin transfer executed and verified (owner() returns the Safe on both contracts).
- [ ] Registrars/attestors added via Safe tx (record tx hashes).
- [ ] Contracts verified on available explorers (or source + ABI published for transparency).
- [ ] Addresses + verification metadata recorded in `registry/addresses.md`.

## First Attestations (700M Pledge — the canonical record)
- [ ] Hashes computed from the **exact bytes** of the source PDFs in controlled storage (reproducible via backend hasher).
- [ ] Document registrations executed (pledge agreement v1 + CIS v1).
- [ ] Reserve attestation executed ("700000000.00" USD, Scotia custody note, supporting doc hash).
- [ ] Events verified on-chain and match the example payloads.
- [ ] Tx hashes, blocks, and event data recorded.

## Mirrors, XRPL, and Consistency
- [ ] Mirrors deployed to Polygon + Base (after Apostle success).
- [ ] Cross-chain consistency report generated using the mock format (see mock-cross-chain-consistency-reports.md) and reviewed (all hashes/amounts/custody notes match the Apostle canonical).
- [ ] XRPL references generated via `xrpl/xrpl-adapter.js` (or equivalent) for sample loan/vault terms.
- [ ] Mock XRPL consistency notes added to the report.

## Governance, Evidence, and Close-Out
- [ ] Full evidence package assembled and stored in operator vault (PDFs, tx receipts, Safe executions, consistency reports, signer approvals, preflight output).
- [ ] Site updated with any live (or dry-run) examples if appropriate for the audience.
- [ ] System registered/updated in sovereign-control-plane registry (human sign-off).
- [ ] UCC-1 filed (Troptions as filer) and filing details recorded.
- [ ] Policy engine (Apostle/x402/MCP) updated to consume the attested reserve status for issuance/lending gating decisions.
- [ ] Rollback/incident procedures exercised (Safe can remove/rotate attestors/registrars; test in dry-run).

## Sign-Off Block (Required)
- Legal Counsel: ______________________________ Date: ________ Scope: ________
- Security Reviewer: ______________________________ Date: ________ Scope: ________
- Primary Operator: ______________________________ Date: ________ Scope: ________
- Preflight ID/Scope: ______________________________
- Explicit Approval for Live Apostle Actions: Yes / No (document approvers + any conditions)

**Any "No", open item, or failed check blocks live Apostle transactions.** Re-complete the checklist and obtain fresh sign-offs before proceeding.

Store the signed version of this checklist with the rest of the 700M pledge evidence package.