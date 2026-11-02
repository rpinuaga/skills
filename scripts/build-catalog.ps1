# Regenerates skills/index.json (the OpenCode HTTP catalog manifest).
# Scans skills/ for directories containing SKILL.md and lists their files.
# The version is an epoch timestamp so OpenCode always treats the catalog as fresh.
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$skillsRoot = Join-Path $repoRoot "skills"

$entries = @()

Get-ChildItem -Directory -Path $skillsRoot | ForEach-Object {
    $skillFile = Join-Path $_.FullName "SKILL.md"
    if (-not (Test-Path $skillFile)) { return }

    $files = @()
    $skillDir = Join-Path $skillsRoot $_.Name
    Get-ChildItem -Recurse -File -Path $_.FullName | ForEach-Object {
        # Catalog paths are relative to the skill directory:
        # OpenCode downloads them from <base-url>/<name>/<file>.
        $rel = $_.FullName.Substring($skillDir.Length).TrimStart('\', '/').Replace('\', '/')
        if ($rel -ne "index.json") { $files += $rel }
    }

    if ($files -notcontains "SKILL.md") {
        throw "Skill '$($_.Name)' has no SKILL.md."
    }

    $entries += [ordered]@{
        name    = $_.Name
        version = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds().ToString()
        files   = $files
    }
}

$catalog = [ordered]@{ skills = $entries }
$json = ConvertTo-Json -InputObject $catalog -Depth 5

# Keep output stable-ish: ConvertTo-Json already emits consistent formatting.
Set-Content -Path (Join-Path $skillsRoot "index.json") -Value $json -Encoding UTF8

Write-Host "Wrote skills/index.json with $($entries.Count) skill(s)."
Write-Host "Base URL when served: /skills/<name>/<file>"
