$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$errors = New-Object 'Collections.Generic.List[string]'
function Add-Error([string]$Message) { $errors.Add($Message) }

$tocPath = Join-Path $root 'RXPGuides.toc'
$toc = [IO.File]::ReadAllText($tocPath)
$modules = @(
    'RoadmapCore.lua','GuideHub.lua','Diagnostics.lua','Recovery.lua',
    'CompatibilityPacks.lua','PartySync.lua','Supplies.lua','GearAdvisor.lua',
    'ActivityPlanner.lua','Accessibility.lua','GuideRecorder.lua'
)
$lastOffset = -1
foreach ($module in $modules) {
    $path = Join-Path $root $module
    if (-not [IO.File]::Exists($path)) { Add-Error "Missing roadmap module: $module"; continue }
    $offset = $toc.IndexOf($module, [StringComparison]::OrdinalIgnoreCase)
    if ($offset -lt 0) { Add-Error "3.3.5 manifest does not load $module" }
    elseif ($offset -le $lastOffset) { Add-Error "Roadmap module load order is invalid at $module" }
    $lastOffset = $offset
}

$coreText = [IO.File]::ReadAllText((Join-Path $root 'RXPGuides.lua'))
if ($coreText -notmatch 'local cacheVersion\s*=\s*32\b') {
    Add-Error 'Guide metadata cache version must be 32 for the roadmap migration.'
}

$settingsText = [IO.File]::ReadAllText((Join-Path $root 'SettingsPanel.lua'))
foreach ($command in @('guides','diagnose','backup','supplies','gear','dailies','record')) {
    if ($settingsText -notmatch ('input\s*==\s*"' + [regex]::Escape($command) + '"')) {
        Add-Error "Missing /rxp $command command routing."
    }
}

$forbidden = @(
    '\bTargetUnit\s*\(', '\bloadstring\s*\(', '\bdofile\s*\(',
    '\bdebug\s*\.', '\bReadProcessMemory\b', '\bOpenProcess\b',
    '\bCreateRemoteThread\b'
)
foreach ($module in $modules) {
    $path = Join-Path $root $module
    if (-not [IO.File]::Exists($path)) { continue }
    $text = [IO.File]::ReadAllText($path)
    foreach ($pattern in $forbidden) {
        if ($text -match $pattern) { Add-Error "$module contains forbidden runtime pattern $pattern" }
    }
    $personalPatterns = @(
        '(?i)(?<![A-Za-z0-9])[A-Z]:\\(?:[^\\\r\n]+\\)+',
        '(?i)/(?:Users|home)/[^/]+',
        '(?i)\.claude[/\\]projects'
    )
    foreach ($personal in $personalPatterns) {
        if ($text -match $personal) { Add-Error "$module contains a personal filesystem path." }
    }
}

if ($errors.Count -gt 0) {
    foreach ($message in $errors) { Write-Host "ERROR: $message" -ForegroundColor Red }
    throw "Roadmap validation failed with $($errors.Count) error(s)."
}
Write-Host "Roadmap validation passed: $($modules.Count) staged modules and all command/privacy guards." -ForegroundColor Green
