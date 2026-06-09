<#
.SYNOPSIS
  PowerShell-native deployment script for the Troptions Reserve & Document Hash Registries on Apostle (UnyKorn sovereign control plane, chain 7332).

.DESCRIPTION
  - Validates Foundry (forge), RPC, and deployer key (from env only — never hardcoded).
  - Builds the contracts from contracts/src/.
  - Deploys DocumentHashRegistry and TroptionsReserveRegistry to the configured Apostle RPC.
  - Outputs the deployed addresses and suggested next commands (add registrars/attestors, transfer to Safe).
  - Designed for the first deployment of the 700M NST pledge collateral attestation layer (Troptions secured party).

  This is the Apostle/core production entry point per the Multi-Chain Topology. Polygon/Base mirrors come later.

.PARAMETER EnvFile
  Path to environment file (copy from deploy/environments/apostle.env.example). Must contain APOSTLE_RPC_URL and APOSTLE_PRIVATE_KEY (or equivalent).

.PARAMETER Verify
  If present, run forge verify (if block explorer API key is configured in the env).

.PARAMETER DryRun
  If present, perform build + simulation only; do not broadcast.

.EXAMPLE
  .\scripts\deploy-apostle.ps1 -EnvFile .env.apostle -Verify

.NOTES
  - Requires: forge (Foundry) in PATH.
  - Apostle RPC/chain details come from your controlled environment (never commit real keys).
  - After deployment: immediately follow deploy/SAFE-ADMIN-TRANSFER-CHECKLIST.md and update registry/addresses.md.
  - Human approval required before any Apostle transaction (critical system).
  - First use case: register hashes of the NST 700M pledge PDFs + attest the USD 700,000,000.00 cash reserve (Scotia Bank Canada custody).
#>
[CmdletBinding()]
param(
    [string]$EnvFile = ".env.apostle",
    [switch]$Verify,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

Write-Host "=== troptions-ucc Apostle/Core Deployment ===" -ForegroundColor Cyan
Write-Host "Timestamp: $(Get-Date -Format o)"
Write-Host "EnvFile  : $EnvFile"
Write-Host "DryRun   : $DryRun"
Write-Host ""

# 1. Load environment (simple key=value parser; supports # comments)
if (-not (Test-Path $EnvFile)) {
    Write-Error "Environment file not found: $EnvFile. Copy deploy/environments/apostle.env.example and fill real values (never commit the real file)."
}
$envVars = @{}
Get-Content $EnvFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith('#')) {
        $parts = $line -split '=', 2
        if ($parts.Count -eq 2) {
            $envVars[$parts[0].Trim()] = $parts[1].Trim()
        }
    }
}

$rpcUrl     = $envVars['APOSTLE_RPC_URL']
$privateKey = $envVars['APOSTLE_PRIVATE_KEY']
$chainId    = if ($envVars['APOSTLE_CHAIN_ID']) { $envVars['APOSTLE_CHAIN_ID'] } else { '7332' }

if (-not $rpcUrl) { Write-Error "APOSTLE_RPC_URL is required in $EnvFile" }
if (-not $privateKey -and -not $DryRun) { Write-Error "APOSTLE_PRIVATE_KEY is required for broadcast (or use -DryRun)" }

# 2. Prerequisites
Write-Host "Checking prerequisites..."
$forgeVersion = & forge --version 2>$null
if (-not $forgeVersion) {
    Write-Error "Foundry (forge) not found in PATH. Install with: curl -L https://foundry.paradigm.xyz | bash ; foundryup"
}
Write-Host "  Forge: $forgeVersion"

# 3. Build
Write-Host ""
Write-Host "Building contracts (contracts/src/*.sol)..."
Push-Location (Join-Path $PSScriptRoot '..')
& forge build --root . 2>&1 | Tee-Object -Variable buildOutput | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Forge build failed. See output above."
}
Write-Host "  Build successful."

# 4. Deploy DocumentHashRegistry (no constructor args)
Write-Host ""
Write-Host "Deploying DocumentHashRegistry to Apostle (chain $chainId)..."
$deployCmd = @(
    'forge', 'create',
    'contracts/src/DocumentHashRegistry.sol:DocumentHashRegistry',
    '--rpc-url', $rpcUrl,
    '--private-key', $privateKey,
    '--chain-id', $chainId
)
if ($DryRun) { $deployCmd += '--simulate' }

$docHashOutput = & $deployCmd 2>&1
Write-Host ($docHashOutput | Out-String)
$docHashAddress = ($docHashOutput | Select-String -Pattern 'Deployed to: (0x[0-9a-fA-F]{40})').Matches.Groups[1].Value
if (-not $docHashAddress) {
    if ($DryRun) { Write-Host "  (Dry run — no address expected)" }
    else { Write-Error "Failed to extract DocumentHashRegistry address from forge output." }
} else {
    Write-Host "  DocumentHashRegistry: $docHashAddress" -ForegroundColor Green
}

# 5. Deploy TroptionsReserveRegistry
Write-Host ""
Write-Host "Deploying TroptionsReserveRegistry to Apostle (chain $chainId)..."
$reserveCmd = @(
    'forge', 'create',
    'contracts/src/TroptionsReserveRegistry.sol:TroptionsReserveRegistry',
    '--rpc-url', $rpcUrl,
    '--private-key', $privateKey,
    '--chain-id', $chainId
)
if ($DryRun) { $reserveCmd += '--simulate' }

$reserveOutput = & $reserveCmd 2>&1
Write-Host ($reserveOutput | Out-String)
$reserveAddress = ($reserveOutput | Select-String -Pattern 'Deployed to: (0x[0-9a-fA-F]{40})').Matches.Groups[1].Value
if (-not $reserveAddress) {
    if ($DryRun) { Write-Host "  (Dry run — no address expected)" }
    else { Write-Error "Failed to extract TroptionsReserveRegistry address from forge output." }
} else {
    Write-Host "  TroptionsReserveRegistry: $reserveAddress" -ForegroundColor Green
}

# 6. Optional verify (if API key present in env)
if ($Verify -and -not $DryRun) {
    $etherscanKey = $envVars['APOSTLE_ETHERSCAN_API_KEY']  # or blockscout equivalent
    if ($etherscanKey -and $docHashAddress) {
        Write-Host ""
        Write-Host "Verifying DocumentHashRegistry..."
        & forge verify-contract --chain-id $chainId --etherscan-api-key $etherscanKey $docHashAddress contracts/src/DocumentHashRegistry.sol:DocumentHashRegistry --rpc-url $rpcUrl
    }
    if ($etherscanKey -and $reserveAddress) {
        Write-Host "Verifying TroptionsReserveRegistry..."
        & forge verify-contract --chain-id $chainId --etherscan-api-key $etherscanKey $reserveAddress contracts/src/TroptionsReserveRegistry.sol:TroptionsReserveRegistry --rpc-url $rpcUrl
    }
}

# 7. Post-deployment instructions
Write-Host ""
Write-Host "=== POST-DEPLOYMENT NEXT STEPS ===" -ForegroundColor Yellow
Write-Host "1. Record addresses in registry/addresses.md (Apostle section)."
Write-Host "2. Immediately follow deploy/SAFE-ADMIN-TRANSFER-CHECKLIST.md — transfer owner to production Safe."
Write-Host "3. Use the backend hasher (or scripts) to compute SHA-256/keccak of the canonical NST pledge PDFs."
Write-Host "4. Call registerDocument on the hash registry for the pledge agreement and CIS."
Write-Host "5. Call attestReserve on the reserve registry for the 700,000,000.00 USD cash (Scotia custody) using the supporting doc hash."
Write-Host "6. Verify events and record tx hashes + block numbers."
Write-Host ""
Write-Host "Addresses (for copy/paste into registry):"
if ($docHashAddress) { Write-Host "  DocumentHashRegistry:   $docHashAddress" }
if ($reserveAddress) { Write-Host "  TroptionsReserveRegistry: $reserveAddress" }
Write-Host ""
Write-Host "Deployment script complete. Review all output before any further actions on Apostle." -ForegroundColor Cyan

Pop-Location
