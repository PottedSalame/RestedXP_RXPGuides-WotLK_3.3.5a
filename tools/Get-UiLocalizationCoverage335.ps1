[CmdletBinding()]
param(
    [ValidateSet('deDE','esES','frFR','koKR','ruRU','zhCN','zhTW')]
    [string]$Locale = 'zhCN',
    [string]$RepoRoot,
    [string]$SourceCatalog,
    [int]$Top = 40
)

$ErrorActionPreference = 'Stop'
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent $PSScriptRoot }
function Join-RepoPath([string]$Relative) {
    $native = $Relative -replace '[\\/]', [IO.Path]::DirectorySeparatorChar
    return Join-Path $RepoRoot $native
}
$utf8 = New-Object Text.UTF8Encoding($false, $true)
$temporarySource = $false
if (-not $SourceCatalog) {
    $SourceCatalog = Join-Path ([IO.Path]::GetTempPath()) `
        ('rxp-ui-source-' + [guid]::NewGuid().ToString('N') + '.json')
    $temporarySource = $true
    & (Join-Path $PSScriptRoot 'Export-TranslationUnits335.ps1') `
        -AddonRoot $RepoRoot -OutputPath $SourceCatalog -Scope ui
}

try {
    $source = [IO.File]::ReadAllText($SourceCatalog, $utf8) |
        ConvertFrom-Json
    $reviewed = @{}
    $localePath = Join-RepoPath "locale/$Locale.lua"
    if (Test-Path -LiteralPath $localePath -PathType Leaf) {
        $localeText = [IO.File]::ReadAllText($localePath, $utf8)
        foreach ($entry in [regex]::Matches($localeText,
                '(?m)^\s*L\["((?:\\.|[^"\\])*)"\]\s*=\s*"((?:\\.|[^"\\])*)"')) {
            $reviewed[$entry.Groups[1].Value] = $entry.Groups[2].Value
        }
    }

    $backportPath = Join-RepoPath 'locale/Backport.lua'
    if (Test-Path -LiteralPath $backportPath -PathType Leaf) {
        $backport = [IO.File]::ReadAllText($backportPath, $utf8)
        $localeBlock = [regex]::Match($backport,
            ('(?s)\n\s*' + [regex]::Escape($Locale) +
             '\s*=\s*\{(.*?)(?=\n\s*[a-z][a-z][A-Z][A-Z]\s*=\s*\{|\n\s*\}\s*$)'))
        if ($localeBlock.Success) {
            foreach ($entry in [regex]::Matches($localeBlock.Groups[1].Value,
                    '\["((?:\\.|[^"\\])*)"\]\s*=\s*"((?:\\.|[^"\\])*)"')) {
                $reviewed[$entry.Groups[1].Value] = $entry.Groups[2].Value
            }
        }
    }

    $missing = @($source.units | Where-Object {
        -not $reviewed.ContainsKey([string]$_.english)
    } | Sort-Object @{Expression='occurrences';Descending=$true}, english)
    [pscustomobject]@{
        locale = $Locale
        total = [int]$source.unitCount
        reviewed = [int]$source.unitCount - $missing.Count
        missing = $missing.Count
        sourceRevision = [string]$source.sourceRevision
    }
    if ($Top -gt 0) {
        $missing | Select-Object -First $Top occurrences, english, message, tokens
    }
} finally {
    if ($temporarySource -and (Test-Path -LiteralPath $SourceCatalog)) {
        Remove-Item -LiteralPath $SourceCatalog -Force
    }
}
