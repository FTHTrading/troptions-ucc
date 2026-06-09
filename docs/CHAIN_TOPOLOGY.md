# Troptions / UnyKorn Chain Topology & Repo Architecture Map

**Date**: 2026-06 (initial)
**Context**: Collateral governance for the Newpoint Statutory Trust (NST) 700M USD cash pledge (secured party Troptions, pledgor NST Delaware statutory trust reg. 6985669, asset USD cash 700,000,000.00 at Scotia Bank Canada, Troptions authorized to file UCC-1). See `QUICKSTART.md`, `legal/`, `README.md`, and the canonical PDFs in `11-Downloads`.

This document formalizes the system design recommendation: **do not birth Troptions as a Polygon-first or Base-first public chain project**. Treat the existing UnyKorn-native control plane (Avalanche L1 + Apostle chain 7332 + x402) as the canonical brain, with Polygon + Base as external execution/distribution rails and XRPL as the specialized lending/credit rail.

The `troptions-ucc` repo (this repository) is the on-chain attestation surface (DocumentHashRegistry + TroptionsReserveRegistry) + legal packet tooling for the specific 700M pledge collateral. It lives primarily on the core rail.

## Three-Layer Model

| Layer                          | Role                                      | Rationale & Current Evidence |
|--------------------------------|-------------------------------------------|--------------------------------|
| **Core (UnyKorn / Avalanche L1 + Apostle/X7332 + x402)** | Canonical operating rail, identity, orchestration, and capital control plane | Live internal primitives: `x402-gateway` (gateway.unykorn.org, live x402 + ATP), `apostle` (chain 7332), `troptions-bot`, `fth-mcp-hub`, `donk-agent`. Platform Hub shows 343 properties / 22 systems with dedicated buckets for x402/Payments, OPTKAS/Capital, RWA/Tokenization, Explorer/Chain, USDF/FTH Pay, and TROPTIONS. Public commerce routes through `donkai.org`; x402 and Apostle are explicitly supporting backend rails. |
| **XRPL / XRPL lending surfaces** | Credit and loan-native rail | XRPL lending protocol is oriented around vaults, loan brokers, and off-chain underwriting for fixed-term institutional lending — a closer fit to the pledge/UCC posture than generic DeFi liquidation. Aligns with existing `xrplloans` namespace concepts in the inventory. |
| **Polygon + Base (external EVM)** | Settlement, token access, multisigs, partner visibility, liquidity | EVM-friendly, excellent wallet/metamask compatibility, standardized Safe multisigs, easy contract mirroring. Used for *distribution and external attestation visibility*, not as the policy/identity brain. x402 EVM tooling already supports configurable chains, so these plug in as adapters without forcing a center-of-gravity shift. |

**Guiding principle**: Sovereign center (UnyKorn/Apostle/x402/MCP) first. External rails (Polygon/Base/XRPL) for reach and specialization. Consolidation and routing discipline over new standalone surfaces.

## Normalized System Roles (using live UnyKorn names)

- **`x402-gateway` / `gateway.unykorn.org`** — Payments ingress, machine-to-machine settlement, ATP on Apostle. Primary on-ramp for agentic and API usage. Live.
- **`apostle` (chain 7332)** — Sovereign ledger for ATP, agent registration, heartbeats, and (via troptions-ucc) collateral/reserve attestations. Live.
- **`fth-mcp-hub`** (port 9077) — Central orchestrator / tool bus. Integrates email, SMS, treasury, agents, CRM. The "nervous system".
- **`troptions-bot` / `donk-agent`** — Operational automation and commerce surfaces (DONK/public routes via donkai.org).
- **`brokerdealer.unykorn.org` + OPTKAS** — Institutional onboarding, capital formation, proceeds routing. Part of the existing institutional capital structure inside the UnyKorn topology.
- **XRPL loans surface** (future `xrplloans.*` or equivalent) — Lending/loan product interface aligned to XRPL vault + broker + off-chain underwriting model.
- **Polygon/Base mirrors** — Contract deployments of (or adapters to) the reserve attestation and document hash logic, Safe multisigs for external parties, liquidity venues, and wallet-visible attestations. Not the source of truth for policy or the pledge ledger.
- **Explorer / Chain control pages** — One canonical view per major rail (Apostle primary, with links to XRPL and EVM mirrors).

`troptions-ucc` itself is the specialized governance/attestation module for the NST pledge. Its two registries and backend packet hasher should be deployed first on the Apostle/Un yKorn core (with the SAFE or equivalent attestor set), then mirrored/adapted outward.

## One Capital Ledger Model (the 700M Pledge as the motivating instrument)

- **Single reserve object** — The attested 700,000,000.00 USD cash pledge (source PDFs + on-chain doc hash + reserve attestation in TroptionsReserveRegistry, linked via supportingDocHash to DocumentHashRegistry).
- **One issuance / collateral policy engine** — Lives on the core rail (Apostle + x402 + MCP/orchestrator).
- **Chain adapters** — Separate on-chain balances / mirrors for Avalanche/Apostle (primary), XRPL (credit products), Polygon, and Base. The policy and the authoritative attestation of the pledge remain unified.
- **troptions-ucc role** — Provides the reproducible off-chain hasher + packet router (for legal sign-off bundles) and the minimal, event-sourced on-chain registries. Every registration is an auditable event that can be cross-referenced to the exact bytes of the NST pledge PDFs and future UCC filings.

This matches the "one capital ledger" pattern already implied by the Platform Hub's institutional capital buckets (OPTKAS, RWA, brokerdealer, settlement rails) and the existing live x402 + Apostle rails.

## Stop Duplicating Public / Operator Surfaces

Current inventory shows many partial, stub, or bulk-ingested properties across x402/payments and capital categories. The hub explicitly calls out the need for consolidation.

**Canonical endpoints (target state)**:
- Public Troptions capital portal (one)
- x402 gateway (`gateway.unykorn.org`)
- Brokerdealer / OPTKAS capital console
- XRPL loan / credit UI
- Chain explorer + control page (Apostle primary, with cross-rail links)
- This repo (`troptions-ucc`) + its future deployment dashboard for the pledge attestations

All other surfaces should route through or be clearly subordinated to these.

## What To Do Next (prioritized)

1. **Declare the canonical source of truth**
   - UnyKorn / Avalanche L1 + Apostle/X7332 + x402 + MCP stack = the brain for Troptions collateral-backed capital and identity.
   - Polygon + Base = mirrored execution environments for Safe multisigs, external attestations, liquidity, and partner/wallet reach.
   - XRPL = lending/credit specialization.

2. **Normalize roles and routing**
   - Wire `troptions-ucc` attestations (the 700M pledge hash + reserve) as a first-class capital object inside the core ledger.
   - Make x402 the metering/settlement layer for any agent or service usage of the capital surfaces.
   - Ensure DONK/public commerce stays on donkai.org and does not leak into the sovereign rails as primary entry points.

3. **Implement the one capital ledger**
   - Use the existing `troptions-ucc` contracts (or their Apostle deployment) as the reserve + document layer for this pledge.
   - Build thin adapters for the other chains (balance views, mirrored doc hashes, cross-chain event relays) rather than full duplicate policy engines.
   - One policy, multiple rails.

4. **Consolidate surfaces + publish the map**
   - Reduce the long tail of partial properties.
   - Publish and maintain this topology document (and the related system contracts in sovereign-control-plane).
   - Register `troptions-ucc` itself in the sovereign registry once the first on-chain registrations or key legal hashes are live (human sign-off required).

## How `troptions-ucc` Fits the Topology

- **Primary deployment target**: Apostle (chain 7332) or the UnyKorn L1 control plane contracts area. Owner = Troptions-controlled SAFE / multisig. Attestors = the set defined in `multisig/SAFE-PLAN.md`.
- **On-chain artifacts**: Document hashes of the NST pledge PDFs, UCC-1s, signatory packets; reserve attestations for the 700M USD cash (amount as string, linked doc hash, attestor, timestamp, note).
- **External rails**: Future Polygon/Base deployments or oracles that surface the same hashes/attestations for external Safes, dashboards, or liquidity partners. These are *views*, not the source of truth.
- **XRPL interaction**: Primarily for related credit/loan products that can reference the same pledge as collateral or PoF; not the home of the USD cash reserve attestation itself.
- **Off-chain**: The backend hasher + packet router (plus future `scripts/hash.ps1` etc.) lives wherever legal/ops runs it (Windows dev machine or hardened operator host). Hashes are reproducible from the exact OneDrive PDFs.

## Disclaimers

- Legal perfection (UCC-1 filing, control agreements, authority, debtor/pledgor details) is outside the scope of this repo and these scripts. Counsel validation is required before any filing or enforcement reliance.
- The contracts require security review before mainnet or high-value use.
- The 700M pledge remains governed by the executed PDFs and any amendments; the on-chain layer is an attestation and governance tool, not a replacement for the legal instruments.

---

**This topology keeps Troptions born as a UnyKorn-native capital and control system with the 700M NST pledge as a concrete, high-value first instrument.** External chains are powerful tools for reach — they are not the center. The `troptions-ucc` repo is the precise, auditable on-chain expression of that instrument's collateral facts.

Update this document as adapters are built, registries are deployed, and the first attestations are live. Cross-reference with sovereign-control-plane registry entries and any active `investigations/nst-700m-pledge/` artifacts.
