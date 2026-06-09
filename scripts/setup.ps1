<#
.SYNOPSIS
  Windows-native post-clone setup for troptions-ucc.

.DESCRIPTION
  - Validates git remote and branch (must be on the troptions-ucc origin).
  - Checks Node.js >= 20.
  - Installs backend dependencies (npm install in ./backend).
  - Optional: detects Foundry (for future contract builds).
  - Prints clear next steps for the first commit / push.

.USAGE
  cd $HOME\dev\troptions-ucc
  .\scripts\setup.ps1
  .\scripts\setup.ps1 -Verify   # run extra validation only
#>

[CmdletBinding()]
param(
    [switch]$Verify,
    [switch]$SkipBackendInstall,
    [string]$CloneParent = "$HOME\dev",
    [string]$RepoName = "troptions-ucc"
)

$ErrorActionPreference = 'Stop'

Write-Host "=== troptions-ucc Windows Setup (helper pack) ===" -ForegroundColor Cyan
Write-Host "Timestamp: $(Get-Date -Format o)" -ForegroundColor DarkGray

# Optional clone support so this script can be the entry point for the full pack
# (matches the documented "setup.ps1 clones" flow when invoked from a parent directory)
$currentDir = (Get-Location).Path
$expectedRepoRoot = Join-Path $CloneParent $RepoName

if (-not (Test-Path (Join-Path $currentDir '.git'))) {
    if ((Test-Path $expectedRepoRoot) -and (Test-Path (Join-Path $expectedRepoRoot '.git'))) {
        Write-Host "Repo already exists at $expectedRepoRoot — cd'ing there."
        Set-Location $expectedRepoRoot
    } else {
        Write-Host "No local git repo detected here. Cloning into $expectedRepoRoot ..."
        if (-not (Test-Path $CloneParent)) { New-Item -ItemType Directory -Path $CloneParent -Force | Out-Null }
        Push-Location $CloneParent
        git clone https://github.com/FTHTrading/troptions-ucc.git
        Pop-Location
        Set-Location $expectedRepoRoot
    }
}

# 1. Git context
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
$remote = (git remote get-url origin 2>$null).Trim()
$status = git status --porcelain 2>$null

Write-Host ""
Write-Host "Git:" -ForegroundColor Yellow
Write-Host "  Branch : $branch"
Write-Host "  Remote : $remote"

if ($remote -notlike '*troptions-ucc*') {
    Write-Warning "Remote does not look like the troptions-ucc repo. Expected https://github.com/FTHTrading/troptions-ucc.git"
}

if ($branch -ne 'main') {
    Write-Warning "Not on 'main' branch. The standard flow uses main."
}

# 2. Node / backend
Write-Host ""
Write-Host "Node / Backend:" -ForegroundColor Yellow

$node = $null
try { $node = node --version 2>$null } catch { }
if (-not $node) {
    Write-Error "Node.js not found in PATH. Install Node 20+ (https://nodejs.org) then re-run."
}

$nodeMajor = [int]($node -replace 'v','' -split '\.')[0]
if ($nodeMajor -lt 20) {
    Write-Warning "Node $node detected. Recommended: Node >= 20."
} else {
    Write-Host "  Node   : $node (OK)"
}

$backendPkg = Join-Path $PSScriptRoot '..\backend\package.json' | Resolve-Path -ErrorAction SilentlyContinue
if ($backendPkg) {
    Write-Host "  Backend package.json found."
    if (-not $SkipBackendInstall) {
        Push-Location (Split-Path $backendPkg)
        Write-Host "  Running npm install in backend/ ..."
        npm install
        Pop-Location
        Write-Host "  Backend deps installed." -ForegroundColor Green
    } else {
        Write-Host "  (Skipped backend npm install per -SkipBackendInstall)"
    }
} else {
    Write-Warning "backend/package.json not found. Scaffold may be incomplete."
}

# 3. Optional: Foundry (for contracts later)
$forge = $null
try { $forge = forge --version 2>$null } catch { }
if ($forge) {
    Write-Host ""
    Write-Host "Foundry detected: $forge" -ForegroundColor DarkGray
    Write-Host "  (You can add foundry.toml and run 'forge build' under contracts/ in the future.)"
} else {
    Write-Host ""
    Write-Host "Foundry not detected (optional for now). Install via: curl -L https://foundry.paradigm.xyz | bash" -ForegroundColor DarkGray
}

# 4. Verification (light)
if ($Verify) {
    Write-Host ""
    Write-Host "Verification checks:" -ForegroundColor Yellow
    if (Test-Path (Join-Path $PSScriptRoot '..\backend\node_modules')) {
        Write-Host "  backend/node_modules : present"
    } else {
        Write-Warning "  backend/node_modules missing — re-run without -SkipBackendInstall"
    }
    Write-Host "  (Add more checks here: contract compile, hash service smoke test, etc.)"
}

# 5. Next steps (full pack)
Write-Host ""
Write-Host "=== Next Steps (Windows helper pack) ===" -ForegroundColor Green
Write-Host "If you have the scaffold tar.gz from a prior generation:"
Write-Host "  .\scripts\extract-and-stage.ps1 -ArchivePath \"`$HOME\Downloads\troptions-ucc-repo.tar.gz\" -RepoDir \"`$HOME\dev\troptions-ucc\""
Write-Host ""
Write-Host "After any changes (or after extract-and-stage):"
Write-Host "  git status"
Write-Host "  git add ."
Write-Host '  git commit -m "Initialize troptions-ucc collateral governance scaffold"'
Write-Host "  git push -u origin main"
Write-Host ""
Write-Host "Or use the helper:"
Write-Host "  .\scripts\push.ps1 -Message 'Your commit message here'"
Write-Host ""
Write-Host "See QUICKSTART.md for the exact sequence with the Troptions/NST 700M pledge facts."
Write-Host "Backend dev server (after setup):"
Write-Host "  cd backend; npm run dev"
Write-Host ""
Write-Host "Setup complete." -ForegroundColor Cyan
