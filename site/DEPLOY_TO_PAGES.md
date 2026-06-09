# Deploying the Troptions UCC Governance Site to Cloudflare Pages (or GitHub Pages)

## Recommended: Cloudflare Pages (aligns with FTH/UnyKorn stack)

1. Go to Cloudflare Dashboard → Pages → Create a project.
2. Connect your GitHub account and select the `troptions-ucc` repository.
3. In the build settings:
   - **Build command**: (leave empty — this is a static site)
   - **Build output directory**: `site`
   - **Root directory**: (leave as repo root)
4. Add environment variables if needed (none required for the current static version).
5. Save and deploy.

The site at `site/index.html` is fully self-contained (Tailwind via CDN + Font Awesome) and will work immediately.

### Custom Domain / Production
- Once deployed, add your desired domain (e.g. `ucc.troptions.org` or `governance.unykorn.org`).
- The site is designed to be the public face for the 700M pledge collateral governance, contract downloads, multisig docs, legal review package, and status.

## Alternative: GitHub Pages (quick)

1. In the repo Settings → Pages.
2. Source: Deploy from a branch → `main` / `site` folder.
3. GitHub will publish at `https://fthtrading.github.io/troptions-ucc/`.

## What the Site Contains (for reviewers / partners)

- Full pledge facts from the executed documents (Troptions secured party, NST pledgor, 700M USD cash at Scotia Bank Canada).
- Direct downloads of the two production smart contracts.
- Complete deployment packs (Apostle/core first + Polygon/Base mirrors).
- Multisig / Safe docs and checklists.
- Legal/UCC draft with strong disclaimers.
- Attestation runbook tied to the actual 700M pledge.
- Clear status (UCC1 = draft/not filed; contracts = source ready; deployment = pending approvals).
- "What else is needed" checklist.
- Precise explanation of how the attestation layer supports "our end" capital/minting/issuance activities (no mint functions here — the on-chain reserve is an input to policy on the sovereign control plane).

## After Deployment

Update the root `README.md` and `QUICKSTART.md` to point partners to the live site.

All content in the site is pulled from the canonical artifacts in this repo and is consistent with the UnyKorn/Troptions Multi-Chain Topology (Apostle core first).

## Next Steps After Site Is Live

1. Legal + security review (as documented in the site).
2. Human approvals for Apostle deployment.
3. Dry-run → real deployment of contracts.
4. First hash registrations + 700M reserve attestation.
5. File UCC-1 (counsel-led).
6. Add the system to the sovereign-control-plane registry.

The site makes the entire package (contracts + infrastructure + legal + multisig + status) downloadable and reviewable in one place.