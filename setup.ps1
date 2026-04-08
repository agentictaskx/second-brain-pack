$ErrorActionPreference = "Stop"

# Resolve vault path: SECOND_BRAIN_PATH env var first, default second
if ($env:SECOND_BRAIN_PATH) {
    $VaultDir = $env:SECOND_BRAIN_PATH
} else {
    $VaultDir = Join-Path $env:USERPROFILE "second-brain"
}
$SkillDir = Join-Path $env:USERPROFILE ".claude\skills\second-brain"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateDir = Join-Path $ScriptDir "vault-template"

Write-Host "=== Second Brain Setup ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Vault path: $VaultDir"
Write-Host ""

if (Test-Path $VaultDir) {
    Write-Host "Existing vault found at $VaultDir - running migration..."
    Write-Host ""

    # Check schema version drift
    $currentVersion = "0"
    $claudeMdPath = Join-Path $VaultDir "CLAUDE.md"
    if (Test-Path $claudeMdPath) {
        $match = Select-String -Path $claudeMdPath -Pattern 'Schema version: (\d+)' -ErrorAction SilentlyContinue
        if ($match) { $currentVersion = $match.Matches[0].Groups[1].Value }
    }
    $templateVersion = "0"
    $templateClaudeMd = Join-Path $TemplateDir "CLAUDE.md"
    if (Test-Path $templateClaudeMd) {
        $match = Select-String -Path $templateClaudeMd -Pattern 'Schema version: (\d+)' -ErrorAction SilentlyContinue
        if ($match) { $templateVersion = $match.Matches[0].Groups[1].Value }
    }

    if ($currentVersion -ne $templateVersion) {
        Write-Host "  WARNING: Schema version drift detected!" -ForegroundColor Yellow
        Write-Host "  Your vault:  version $currentVersion"
        Write-Host "  This pack:   version $templateVersion"
        Write-Host ""
        Write-Host "  Your CLAUDE.md is outdated. Action required:"
        Write-Host "  Compare your CLAUDE.md with vault-template\CLAUDE.md and merge changes."
        Write-Host ""
    }

    # Backfill any new files from template that don't exist in the vault
    $backfilled = 0
    $templateFiles = Get-ChildItem -Path $TemplateDir -Recurse -File
    foreach ($file in $templateFiles) {
        $relPath = $file.FullName.Substring($TemplateDir.Length + 1)
        $targetPath = Join-Path $VaultDir $relPath
        if (-not (Test-Path $targetPath)) {
            $targetDir = Split-Path -Parent $targetPath
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }
            Copy-Item -Path $file.FullName -Destination $targetPath
            Write-Host "  + Added missing file: $relPath"
            $backfilled++
        }
    }

    if ($backfilled -eq 0) {
        Write-Host "  All template files present - no backfill needed."
    } else {
        Write-Host "  Backfilled $backfilled file(s)."
    }
    Write-Host ""
    Write-Host "Note: Existing files were NOT overwritten. To pick up schema changes,"
    Write-Host "compare your CLAUDE.md with vault-template\CLAUDE.md manually."
} else {
    Write-Host "Creating vault at $VaultDir..."
    Copy-Item -Path $TemplateDir -Destination $VaultDir -Recurse
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

# Create wiki subdirectories required by schema
Write-Host "Creating wiki directories..."
$wikiDirs = @("projects", "reviews", "overviews")
foreach ($dir in $wikiDirs) {
    $path = Join-Path $VaultDir "wiki\$dir"
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}
$templatesDir = Join-Path $VaultDir "templates"
if (-not (Test-Path $templatesDir)) {
    New-Item -ItemType Directory -Path $templatesDir -Force | Out-Null
}

# Install skill
Write-Host "Installing skill to $SkillDir..."
if (-not (Test-Path $SkillDir)) {
    New-Item -ItemType Directory -Path $SkillDir -Force | Out-Null
}
Copy-Item -Path (Join-Path $ScriptDir "skill\SKILL.md") -Destination (Join-Path $SkillDir "SKILL.md") -Force

# Persist vault path in config
$ConfigFile = Join-Path $env:USERPROFILE ".claude\second-brain.json"
Write-Host "Saving vault path to $ConfigFile..."
$config = @{ vault_path = $VaultDir } | ConvertTo-Json
Set-Content -Path $ConfigFile -Value $config

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Vault location: $VaultDir"
Write-Host "Skill location: $SkillDir\SKILL.md"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Edit $VaultDir\CLAUDE.md - fill in the 'About You' section"
Write-Host "  2. Open Claude Code and say: /second-brain ingest this: [paste something]"
Write-Host ""
if ($env:SECOND_BRAIN_PATH) {
    Write-Host "Using custom vault path from SECOND_BRAIN_PATH=$env:SECOND_BRAIN_PATH"
    Write-Host "Make sure this env var is set in every terminal session."
    Write-Host ""
}
