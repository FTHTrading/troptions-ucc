# troptions-ucc — PowerShell Quickstart (Windows)

This repo is designed for fast, native Windows/PowerShell operation from empty remote to first committed scaffold (and subsequent updates).

The full helper pack lives in `scripts/`:
- `setup.ps1` — clone/remote validation + Node backend deps
- `extract-and-stage.ps1` — unpack a prior `troptions-ucc-repo.tar.gz` scaffold archive with native `tar -xzf` and copy cleanly into your local clone (preserves .git)
- `push.ps1` — git add + commit + push to origin/main

## Exact recommended sequence

From PowerShell (adjust paths as needed; use `-ExecutionPolicy Bypass` if your policy requires it):

```powershell
# 1. Ensure the repo exists and is on the right remote (setup can be run from a parent dir or inside)
powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1

# 2. If you have the scaffold archive from a prior generation (the tar.gz), extract & stage it
powershell -ExecutionPolicy Bypass -File .\scripts\extract-and-stage.ps1 `
    -ArchivePath "$HOME\Downloads\troptions-ucc-repo.tar.gz" `
    -RepoDir "$HOME\dev\troptions-ucc"

# 3. Move into the repo and push the initial (or updated) state
cd $HOME\dev\troptions-ucc
powershell -ExecutionPolicy Bypass -File .\scripts\push.ps1 -Message "Initialize troptions-ucc collateral governance scaffold"
```

After the first push your GitHub repo will contain the full structure (contracts for DocumentHashRegistry + TroptionsReserveRegistry, backend hasher/packet router, legal/compliance/multisig scaffolding, Windows helper pack, ABI + verification pack, XRPL integration, and the dry-run operations pack).

Deploy the static review site (in `site/`) to Cloudflare Pages (output directory `site`) for the live DD portal. See `site/DEPLOY_TO_PAGES.md`. Once live, set the URL in the repo About (Website) and update links here and in README.md.

## What the 700M pledge actually is (for context while you work)

From the canonical source documents (OneDrive `11-Downloads`):

- **Master Asset Pledge Security Agreement** (NST T pledge agreement 2025-12-30_150719.pdf):
  - Secured Party: **Troptions**
  - Pledgor: **Newpoint Statutory Trust**
  - Troptions is authorized to file UCC-1 financing statements.
  - Schedule A: USD cash, declared value **700,000,000.00**, custody/location **Scotia Bank Canada**.

- **Newpoint Statutory Trust CIS** (NST CIS 2025-12-28_225418.pdf):
  - Delaware statutory trust, registration number **6985669**.

All document hashes you register on-chain and all reserve attestations must be reproducible from the exact bytes of these (and future executed) PDFs. The on-chain registries exist to create an immutable, event-sourced governance and audit layer on top of the legal instruments.

## After the first commit

- Update `legal/UCC1-COLLATERAL-DRAFT.md`, `compliance/CHECKLIST.md`, and `multisig/SAFE-PLAN.md` with counsel-validated details.
- Add real executed PDFs (or their hashes) and run them through `backend` (`npm run hash` or the `/hash` endpoint) before on-chain registration.
- When ready for contracts: add `foundry.toml`, deploy the two registries with a SAFE as owner, wire the attestor set per `multisig/SAFE-PLAN.md`.
- The primary control plane for this collateral work (and the broader Troptions capital system) is the existing UnyKorn / Avalanche L1 + Apostle (chain 7332) + x402 stack. Polygon and Base are treated as external EVM mirrors/adapters for distribution and wallet compatibility (see `docs/CHAIN_TOPOLOGY.md`).

## Caution (non-negotiable)

This tooling makes the repo operational and the on-chain attestation path reproducible on Windows. It does **not** complete legal closing, perfection, or production deployment.

Before filing any UCC-1, attesting the full 700M position on-chain, or using the contracts in a live setting:
- Counsel must validate debtor names, pledgor authority, secured party details, perfection mechanics (UCC-1 + any control/blocked account requirements), and filing jurisdictions.
- The Solidity and backend still require security review.
- The source PDFs in controlled OneDrive storage remain the legal originals.

See the disclaimers in `legal/UCC1-COLLATERAL-DRAFT.md` and `compliance/CHECKLIST.md`.

## One-command smoke test (after setup + extract)

```powershell
cd $HOME\dev\troptions-ucc\backend
npm run hash -- --text "Troptions secured party / NST pledgor 700M USD cash pledge test"
```

Or point it at one of the real PDFs for a reproducible hash you can later register.

---

Run the sequence above, push, and the repo is live with the correct Windows-native flow and the pledge facts wired into the documentation.

## The Review Site

The static review portal lives in `site/` (full portal with all facts, contracts, packs including dry-run, XRPL, etc.).

**Deploy options (after `git push -u origin main`):**
- Cloudflare Pages (recommended): Connect repo, `main` branch, output dir `site`. See `site/DEPLOY_TO_PAGES.md` and `site/wrangler.toml`.
- GitHub Pages (fallback): Repo Settings → Pages → Source = GitHub Actions (the included `.github/workflows/deploy-site.yml` deploys from the `site/` subdir). Live at https://fthtrading.github.io/troptions-ucc/.

Once live, set the URL in the repo About (Website) and update links here/README if needed. Circulate as the official DD portal. The site uses specific raw file links for all downloads.

