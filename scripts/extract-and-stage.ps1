<#
.SYNOPSIS
  Extract a troptions-ucc scaffold archive (tar.gz) and stage the files into the local repo directory.

.DESCRIPTION
  Uses native Windows tar (available on Win10 1803+ / Server 2019+) to unpack the archive produced by prior scaffold generation.
  Copies contents into the target repo dir (e.g. $HOME\dev\troptions-ucc), skipping .git and other VCS artifacts so your clone history is preserved.
  Handles the common case where the archive contains an inner folder named "troptions-ucc-repo".

  This is the Windows/PowerShell-native equivalent of the "drop the scaffold archive" step.

.PARAMETER ArchivePath
  Full path to the troptions-ucc-repo.tar.gz (or .tgz). Default looks in Downloads.

.PARAMETER RepoDir
  Target local repo directory (must already be a git clone of https://github.com/FTHTrading/troptions-ucc.git or will be created as empty dir).
  Default: $HOME\dev\troptions-ucc

.EXAMPLE
  .\scripts\extract-and-stage.ps1 -ArchivePath "$HOME\Downloads\troptions-ucc-repo.tar.gz" -RepoDir "$HOME\dev\troptions-ucc"

.NOTES
  After this, cd into RepoDir, run git status, then use push.ps1 or manual add/commit/push.
  The pledge facts (Troptions secured party, Newpoint Statutory Trust pledgor, 700M USD cash at Scotia Bank Canada, DE reg 6985669) should already be reflected in the staged README and legal docs.
#>
[CmdletBinding()]
param(
    [string]$ArchivePath = "$HOME\Downloads\troptions-ucc-repo.tar.gz",
    [string]$RepoDir = "$HOME\dev\troptions-ucc"
)

$ErrorActionPreference = 'Stop'

Write-Host "=== troptions-ucc extract-and-stage ===" -ForegroundColor Cyan
Write-Host "Archive : $ArchivePath"
Write-Host "Target  : $RepoDir"

if (-not (Test-Path $ArchivePath)) {
    Write-Error "Archive not found at $ArchivePath. Place troptions-ucc-repo.tar.gz in your Downloads (or pass -ArchivePath)."
}

# Ensure target dir exists (do not init git here — the caller should have cloned)
if (-not (Test-Path $RepoDir)) {
    Write-Host "Creating target directory..."
    New-Item -ItemType Directory -Path $RepoDir -Force | Out-Null
}

# Verify it looks like (or will become) the right repo
$gitDir = Join-Path $RepoDir '.git'
if (-not (Test-Path $gitDir)) {
    Write-Warning "No .git directory found in $RepoDir. This script stages files into an *existing* clone of https://github.com/FTHTrading/troptions-ucc.git. Run setup.ps1 or git clone first if needed."
}

$tempRoot = Join-Path $env:TEMP ("troptions-ucc-extract-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
    Write-Host "Extracting archive with tar -xzf (native Windows tar)..."
    & tar -xzf $ArchivePath -C $tempRoot 2>&1 | Out-String | Write-Verbose

    # Find the inner folder (usually "troptions-ucc-repo" or the root contents if flat)
    $children = Get-ChildItem -Path $tempRoot -Force
    $inner = $children | Where-Object { $_.PSIsContainer -and ($_.Name -like '*troptions-ucc*' -or $_.Name -like '*troptions*ucc*') } | Select-Object -First 1

    if (-not $inner) {
        # Fall back to the temp root itself if the archive was flat
        $inner = Get-Item $tempRoot
    }

    $source = $inner.FullName
    Write-Host "Staging contents from $source ..."

    Get-ChildItem -Path $source -Force | ForEach-Object {
        $name = $_.Name
        if ($name -eq '.git' -or $name -eq '.gitmodules' -or $name -eq '.github' -and $_.PSIsContainer) {
            Write-Host "  Skipping VCS item: $name" -ForegroundColor DarkGray
            return
        }

        $dest = Join-Path $RepoDir $name
        if ($_.PSIsContainer) {
            Copy-Item -Path $_.FullName -Destination $dest -Recurse -Force
        } else {
            Copy-Item -Path $_.FullName -Destination $dest -Force
        }
        Write-Host "  + $name"
    }

    Write-Host ""
    Write-Host "Staging complete into $RepoDir" -ForegroundColor Green
    Write-Host "Next:"
    Write-Host "  cd $RepoDir"
    Write-Host "  git status"
    Write-Host "  # then use .\scripts\push.ps1 or manual commit"
}
finally {
    if (Test-Path $tempRoot) {
        Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
