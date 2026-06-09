<#
.SYNOPSIS
  Reusable add / commit / push helper for troptions-ucc (Windows).

.PARAMETER Message
  Commit message. Default: "Update troptions-ucc scaffold"

.EXAMPLE
  .\scripts\push.ps1 -Message "Register first executed pledge PDF hash + initial 700M reserve attestation"
#>
[CmdletBinding()]
param(
    [string]$Message = "Update troptions-ucc scaffold"
)

$ErrorActionPreference = 'Stop'

Write-Host "=== troptions-ucc push helper ===" -ForegroundColor Cyan

git status
Write-Host ""

$changes = git status --porcelain
if (-not $changes) {
    Write-Host "No changes to commit." -ForegroundColor Yellow
    exit 0
}

git add .
git commit -m $Message
git push -u origin main

Write-Host ""
Write-Host "Pushed: $Message" -ForegroundColor Green
