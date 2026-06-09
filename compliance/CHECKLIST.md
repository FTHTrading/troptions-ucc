# Compliance & Due Diligence Checklist — TROPTIONS UCC / NST Collateral

Adapted from stablecoin reserve, treasury, and pledge governance checklists (AGENTS.md style).

## 1. Issuance / Pledge Mechanics (analog)

- [ ] Pledge agreement fully executed by all parties (Pledgor(s) and Newpoint Statutory Trust).
- [ ] All schedules, exhibits, and officer certificates attached and consistent.
- [ ] Conditions precedent to effectiveness satisfied and documented.
- [ ] Any KYC/AML, accreditation, or investor qualification gates called for in the Pledge have been completed.
- [ ] Freeze / control / enforcement rights (analog to blacklist/freeze) clearly defined and who holds them.

## 2. Reserves / Collateral (Core)

- [ ] Reserve asset composition matches Schedule A / pledged collateral description.
- [ ] Initial attested amount matches the "700M" (or other stated) pledge value.
- [ ] Valuation methodology and any haircuts / discounts documented.
- [ ] Maturity / liquidity profile of collateral understood (real estate, securities, operating assets, etc.).
- [ ] Concentration risk (single asset class, single obligor, single jurisdiction) identified.
- [ ] Rehypothecation or further encumbrance rights (or prohibitions) stated.
- [ ] Custody / control arrangements (who physically or beneficially holds the collateral).
- [ ] Proof quality: original executed PDFs in controlled storage + on-chain hash registration.
- [ ] Reserve-to-pledge parity: attested on-chain amount vs. stated pledge amount.
- [ ] Mark-to-market or periodic re-valuation cadence defined.

## 3. Legal & Perfection

- [ ] UCC-1 financing statement(s) filed in all required jurisdictions (or authorization to file granted).
- [ ] Any required real property recordings, control agreements, or bailee letters executed.
- [ ] Continuation / amendment process defined.
- [ ] Choice of law and forum consistent across Pledge, UCC filings, and any security agreements.
- [ ] Intercreditor or subordination agreements (if any other liens) documented.

## 4. Governance / Control (Attestor Keys)

- [ ] Initial attestor set (multisig / SAFE signers) defined and documented in `multisig/SAFE-PLAN.md`.
- [ ] Threshold and signer overlap rules meet operational and risk requirements.
- [ ] Key ceremony completed (or scheduled) with evidence.
- [ ] Emergency / replacement procedures for lost signers or compromise.
- [ ] On-chain roles (owner, registrars, attestors) match the off-chain control plan.
- [ ] No single point of failure for attestor capability.

## 5. On-Chain / Technical Controls

- [ ] `DocumentHashRegistry` and `TroptionsReserveRegistry` deployed (or deployment plan with addresses).
- [ ] Only authorized attestors/registrars can write.
- [ ] All critical registrations emit events that are monitored / logged externally.
- [ ] Backend hashing service produces reproducible hashes matching on-chain expectations.
- [ ] Packet storage / artifact retention policy defined (how long raw signature packets are kept).

## 6. Failure / Stress Scenarios

- [ ] Pledge default or enforcement event — who can call what on-chain, who holds enforcement rights off-chain.
- [ ] Attestor key loss / compromise — rotation path without losing history.
- [ ] Collateral value decline — re-attestation and disclosure process.
- [ ] Dispute over document authenticity — how the two-layer (PDF + on-chain event) evidence is presented.
- [ ] Change of control of Pledgor or NST — impact on attestor set and filing maintenance.

## 7. Reporting & Transparency

- [ ] Periodic (monthly/quarterly) attestation cadence defined.
- [ ] Public or limited-audience dashboard / export of current attested reserves vs. pledge.
- [ ] Method for third-party auditors or counsel to verify hashes against source PDFs.
- [ ] Incident / variance reporting process (reserve shortfall, document amendment, key rotation).

## 8. Open Questions (log here until closed)

- Exact initial attested amount string and asset breakdown from the executed Pledge.
- Whether the Pledge is a single instrument or a facility with multiple draws / tranches.
- Any specific "700M" figure that is face vs. fair-market / discounted.
- Required frequency of re-attestation or collateral substitution rights.
- Interaction with any other TROPTIONS L1, XRPL, Stellar, or EVM treasury positions.

---

**Rule**: Treat every reserve claim or collateral description as unverified until it has both (1) a matching source PDF in controlled storage and (2) a corresponding on-chain attestation event with supporting doc hash.
