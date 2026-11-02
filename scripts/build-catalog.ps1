# Regenerates skills/index.json (the OpenCode HTTP catalog manifest).
# Scans skills/ for directories containing SKILL.md and lists their files.
# The version is an epoch timestamp so OpenCode always treats the catalog as fresh.
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$skillsRoot = Join-Path $repoRoot "skills"

$entries = @()

# Walk the tree like OpenCode does: intermediate directories may nest deeper
# skills, and a directory containing SKILL.md is a leaf (do not search inside).
$queue = New-Object System.Collections.Queue
$queue.Enqueue($skillsRoot)
while ($queue.Count -gt 0) {
    $dir = $queue.Dequeue()
    $skillFile = Join-Path $dir "SKILL.md"
    if (Test-Path $skillFile) {
        $skillDir = $dir
        $skillName = Split-Path -Leaf $dir
        $files = @()
        Get-ChildItem -Recurse -File -Path $skillDir | ForEach-Object {
            # Catalog paths are relative to the skill directory:
            # OpenCode downloads them from <base-url>/<name>/<file>.
            $rel = $_.FullName.Substring($skillDir.Length).TrimStart('\', '/').Replace('\', '/')
            if ($rel -ne "index.json") { $files += $rel }
        }

        if ($files -notcontains "SKILL.md") {
            throw "Skill '$skillName' has no SKILL.md."
        }

        $entries += [ordered]@{
            name    = $skillName
            version = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds().ToString()
            files   = $files
        }
    } else {
        Get-ChildItem -Directory -Path $dir | ForEach-Object { $queue.Enqueue($_.FullName) }
    }
}

$catalog = [ordered]@{ skills = $entries }
$json = ConvertTo-Json -InputObject $catalog -Depth 5

# Keep output stable-ish: ConvertTo-Json already emits consistent formatting.
Set-Content -Path (Join-Path $skillsRoot "index.json") -Value $json -Encoding UTF8

Write-Host "Wrote skills/index.json with $($entries.Count) skill(s)."
Write-Host "Base URL when served: /skills/<name>/<file>"
