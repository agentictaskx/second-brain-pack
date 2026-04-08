$ErrorActionPreference = "Stop"

$VaultDir = Join-Path $env:USERPROFILE "second-brain"
$SkillDir = Join-Path $env:USERPROFILE ".claude\skills\second-brain"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Second Brain Setup ===" -ForegroundColor Cyan
Write-Host ""

# Create vault from template
if (Test-Path $VaultDir) {
    Write-Host "Vault already exists at $VaultDir - skipping copy to avoid overwriting."
    Write-Host "To start fresh, delete $VaultDir and re-run this script."
} else {
    Write-Host "Creating vault at $VaultDir..."
    Copy-Item -Path (Join-Path $ScriptDir "vault-template") -Destination $VaultDir -Recurse
}

# Create raw subdirectories
Write-Host "Creating raw source directories..."
$rawDirs = @("articles", "emails", "meetings", "chats", "channels", "documents", "books", "ideas", "assets", "projects")
foreach ($dir in $rawDirs) {
    $path = Join-Path $VaultDir "raw\$dir"
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

# Install skill
Write-Host "Installing skill to $SkillDir..."
if (-not (Test-Path $SkillDir)) {
    New-Item -ItemType Directory -Path $SkillDir -Force | Out-Null
}
Copy-Item -Path (Join-Path $ScriptDir "skill\SKILL.md") -Destination (Join-Path $SkillDir "SKILL.md") -Force

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Edit $VaultDir\CLAUDE.md - fill in the 'About You' section"
Write-Host "  2. Open Claude Code and say: /second-brain ingest this: [paste something]"
Write-Host ""
