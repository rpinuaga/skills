# Creates a new skill directory from the template.
# Usage: ./scripts/new-skill.ps1 -Name <skill-id> [-Description "..."] [-Force]
param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$Description = "",

    [switch]$Force
)

$ErrorActionPreference = "Stop"

if ($Name -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') {
    throw "Skill ID '$Name' is not lowercase kebab-case (pattern: ^[a-z0-9]+(-[a-z0-9]+)*$)."
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$skillDir = Join-Path $repoRoot "skills" $Name
$template = Join-Path $repoRoot "templates" "skill"
$skillFile = Join-Path $skillDir "SKILL.md"

if (Test-Path $skillFile) {
    if (-not $Force) {
        throw "Skill '$Name' already exists at $skillDir. Use -Force to overwrite."
    }
    Remove-Item -Recurse -Force $skillDir
}

New-Item -ItemType Directory -Path (Join-Path $skillDir "scripts") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $skillDir "references") -Force | Out-Null

# Display name from ID: "recon-report" -> "Recon Report"
$displayName = ($Name -split '-' | ForEach-Object {
    if ($_.Length -gt 0) { $_.Substring(0, 1).ToUpper() + $_.Substring(1) } else { $_ }
}) -join ' '

if (-not $Description -or $Description -eq "") {
    $Description = "TODO: one or two sentences on when the agent should use this skill (trigger)."
}

$content = Get-Content -Raw -Path (Join-Path $template "SKILL.md")
$content = $content.Replace("{{NAME}}", $displayName).Replace("{{DESCRIPTION}}", $Description)
Set-Content -Path $skillFile -Value $content -Encoding UTF8 -NoNewline

Write-Host "Created skill '$Name' at skills/$Name/"
Write-Host "Next: edit skills/$Name/SKILL.md, then run ./scripts/build-catalog.ps1"
