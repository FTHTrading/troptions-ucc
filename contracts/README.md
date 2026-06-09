# Contracts

Solidity source for the two core registries:

- `src/DocumentHashRegistry.sol` — versioned, event-sourced registration of legal / collateral document hashes.
- `src/TroptionsReserveRegistry.sol` — pledge-linked reserve / collateral attestations with full history and supporting document hash.

## Usage (when ready)

Option A — Foundry (recommended for auditability)
```bash
# from repo root
forge init --force   # or just add foundry.toml + lib/ if you prefer
forge install
forge build
```

Option B — Hardhat / other
Add your preferred framework. The .sol files are standard and have no external imports (no OpenZeppelin dependency in v1 for maximum simplicity and minimal attack surface).

## Deployment notes

- Deploy with the primary SAFE / multisig as `owner`.
- Immediately call `addRegistrar` / `addAttestor` for operational addresses as defined in `../multisig/SAFE-PLAN.md`.
- Record deployment addresses, chain, and tx hashes in the root README and in any active investigation under `investigations/`.

## Audit / forensic posture

Both contracts are intentionally small (< 300 LOC combined) and emit rich events on every state change. The event log + the exact source PDFs (in controlled OneDrive storage) together form the evidence layer for the NST pledge collateral.
