# Sample Deployment Transcripts (Dry-Run / Simulation)

These are simulated outputs based on the actual `deploy-*.ps1` scripts, env templates, and prior execution patterns in the repo. Replace placeholders with your real dry-run results.

See `DRY_RUN_OPERATIONS_PACK.md` Section 1 for the consolidated narrative version.

## Apostle/Core Transcript (excerpt)
(See full in the main pack MD. Key addresses used in other samples below.)

## Polygon Mirror Transcript (excerpt)
```powershell
PS ...> .\scripts\deploy-polygon.ps1 -EnvFile .env.polygon
...
DocumentHashRegistry (Polygon): 0xC3d4E5f678901234567890abcdef1234567890ab
TroptionsReserveRegistry (Polygon): 0xD4e5F678901234567890abcdef1234567890abcd
...
Verification URL: https://polygonscan.com/address/0xC3d4E5f678901234567890abcdef1234567890ab#code
```

## Base Mirror Transcript (excerpt)
```powershell
PS ...> .\scripts\deploy-base.ps1 -EnvFile .env.base
...
DocumentHashRegistry (Base): 0xE5f6G78901234567890abcdef1234567890abcde
TroptionsReserveRegistry (Base): 0xF6g7H8901234567890abcdef1234567890abcdef
...
Verification URL: https://basescan.org/address/0xE5f6G78901234567890abcdef1234567890abcde#code
```