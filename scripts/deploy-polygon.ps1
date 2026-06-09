<#
.SYNOPSIS
  PowerShell-native deployment script for the Troptions Reserve & Document Hash Registries **mirror** on Polygon PoS (chain 137).

.DESCRIPTION
  Deploys the *same logical contracts* as the Apostle/core version (DocumentHashRegistry + TroptionsReserveRegistry) as mirrors.
  Primary authority and the 700M NST pledge reserve object remain on the Apostle sovereign control plane.
  Polygon is for external EVM reach, Safe multisig governance, wallet compatibility, and mirrored attestations.

  Shares the same reserve schema and Safe-governance pattern as Apostle; only network config differs.

.PARAMETER EnvFile
  Path to environment file (copy from deploy/environments/polygon.env.example).

.PARAMETER Verify
  Run forge verify if API key present.

.PARAMETER DryRun
  Simulate only.

.EXAMPLE
  .\scripts\deploy-polygon.ps1 -EnvFile .env.polygon

.NOTES
  - Requires forge.
  - After deploy: transfer admin to a dedicated Polygon Safe (see per-chain Safe manifest coordination with core).
  - Record in registry/addresses.md under Polygon section.
  - Use cross-chain attestation consistency checklist after mirroring the first 700M pledge attestations.
  - Human approval required (even for mirrors, as part of the overall reserve governance).
#>
[CmdletBinding()]
param(
    [string]$EnvFile = ".env.polygon",
    [switch]$Verify,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

Write-Host "=== troptions-ucc Polygon Mirror Deployment (chain 137) ===" -ForegroundColor Cyan
Write-Host "Timestamp: $(Get-Date -Format o)"
Write-Host "EnvFile  : $EnvFile"
Write-Host "DryRun   : $DryRun"
Write-Host "NOTE: This is a MIRROR. Canonical 700M NST pledge reserve authority is on Apostle/core."
Write-Host ""

if (-not (Test-Path $EnvFile)) {
    Write-Error "Environment file not found: $EnvFile. Copy deploy/environments/polygon.env.example and fill (never commit the real file)."
}

$envVars = @{}
Get-Content $EnvFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith('#')) {
        $parts = $line -split '=', 2
        if ($parts.Count -eq 2) { $envVars[$parts[0].Trim()] = $parts[1].Trim() }
    }
}

$rpcUrl     = $envVars['POLYGON_RPC_URL']
$privateKey = $envVars['POLYGON_PRIVATE_KEY']
$chainId    = if ($envVars['POLYGON_CHAIN_ID']) { $envVars['POLYGON_CHAIN_ID'] } else { '137' }

if (-not $rpcUrl) { Write-Error "POLYGON_RPC_URL is required in $EnvFile" }
if (-not $privateKey -and -not $DryRun) { Write-Error "POLYGON_PRIVATE_KEY is required for broadcast (or use -DryRun)" }

Write-Host "Checking prerequisites..."
$forgeVersion = & forge --version 2>$null
if (-not $forgeVersion) { Write-Error "Foundry (forge) not found in PATH." }
Write-Host "  Forge: $forgeVersion"

Write-Host ""
Write-Host "Building contracts..."
Push-Location (Join-Path $PSScriptRoot '..')
& forge build --root . 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Error "Forge build failed." }
Write-Host "  Build successful."

Write-Host ""
Write-Host "Deploying DocumentHashRegistry (Polygon mirror)..."
$docCmd = @('forge', 'create', 'contracts/src/DocumentHashRegistry.sol:DocumentHashRegistry', '--rpc-url', $rpcUrl, '--private-key', $privateKey, '--chain-id', $chainId)
if ($DryRun) { $docCmd += '--simulate' }
$docOutput = & $docCmd 2>&1
Write-Host ($docOutput | Out-String)
$docAddr = ($docOutput | Select-String -Pattern 'Deployed to: (0x[0-9a-fA-F]{40})').Matches.Groups[1].Value
if ($docAddr) { Write-Host "  DocumentHashRegistry (Polygon): $docAddr" -ForegroundColor Green }

Write-Host ""
Write-Host "Deploying TroptionsReserveRegistry (Polygon mirror)..."
$reserveCmd = @('forge', 'create', 'contracts/src/TroptionsReserveRegistry.sol:TroptionsReserveRegistry', '--rpc-url', $rpcUrl, '--private-key', $privateKey, '--chain-id', $chainId)
if ($DryRun) { $reserveCmd += '--simulate' }
$reserveOutput = & $reserveCmd 2>&1
Write-Host ($reserveOutput | Out-String)
$reserveAddr = ($reserveOutput | Select-String -Pattern 'Deployed to: (0x[0-9a-fA-F]{40})').Matches.Groups[1].Value
if ($reserveAddr) { Write-Host "  TroptionsReserveRegistry (Polygon): $reserveAddr" -ForegroundColor Green }

if ($Verify -and -not $DryRun) {
    $key = $envVars['POLYGON_ETHERSCAN_API_KEY']
    if ($key -and $docAddr) { & forge verify-contract --chain-id $chainId --etherscan-api-key $key $docAddr contracts/src/DocumentHashRegistry.sol:DocumentHashRegistry --rpc-url $rpcUrl }
    if ($key -and $reserveAddr) { & forge verify-contract --chain-id $chainId --etherscan-api-key $key $reserveAddr contracts/src/TroptionsReserveRegistry.sol:TroptionsReserveRegistry --rpc-url $rpcUrl }
}

Write-Host ""
Write-Host "=== POST-DEPLOYMENT NEXT STEPS (Polygon Mirror) ===" -ForegroundColor Yellow
Write-Host "1. Record addresses in registry/addresses.md (Polygon section)."
Write-Host "2. Transfer admin to a dedicated Polygon Safe (coordinate signers with core manifest)."
Write-Host "3. Mirror the first 700M NST pledge document hashes and reserve attestation from Apostle."
Write-Host "4. Run cross-chain consistency checks (see deploy/CROSS_CHAIN_CONSISTENCY_CHECKLIST.md)."
Write-Host ""
if ($docAddr) { Write-Host "  DocumentHashRegistry (Polygon):   $docAddr" }
if ($reserveAddr) { Write-Host "  TroptionsReserveRegistry (Polygon): $reserveAddr" }
Write-Host ""
Write-Host "Polygon mirror deployment complete. Canonical authority remains on Apostle." -ForegroundColor Cyan

Pop-Location
