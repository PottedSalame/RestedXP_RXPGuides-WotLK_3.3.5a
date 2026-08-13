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

$temporarySource = $false
if (-not $SourceCatalog) {
    $SourceCatalog = Join-Path ([IO.Path]::GetTempPath()) `
        ('rxp-ui-source-' + [guid]::NewGuid().ToString('N') + '.json')
    $temporarySource = $true
    & (Join-Path $PSScriptRoot 'Export-TranslationUnits335.ps1') `
        -AddonRoot $RepoRoot -OutputPath $SourceCatalog -Scope all
}

try {
    $catalogs = @(Get-ChildItem (Join-RepoPath 'translations/imported') `
        -Filter '*.json' -File -ErrorAction SilentlyContinue | Where-Object {
            $document = Get-Content -LiteralPath $_.FullName -Raw |
                ConvertFrom-Json
            [string]$document.locale -eq $Locale
        } | ForEach-Object { $_.FullName })
    if ($catalogs.Count -lt 1) {
        throw "No imported translation catalogs were found for $Locale."
    }

    $coverageText = (& (Join-Path $PSScriptRoot `
            'Get-TranslationCoverage335.ps1') `
        -SourceCatalog $SourceCatalog -TranslationCatalog $catalogs `
        -RepoRoot $RepoRoot -Locale $Locale | Out-String)
    $coverage = $coverageText | ConvertFrom-Json
    $summary = $coverage.summary.ui
    [pscustomobject]@{
        locale = $Locale
        total = [int]$summary.total
        reviewed = [int]$summary.reviewed
        machine = [int]$summary.machine
        official = [int]$summary.official
        neutral = [int]$summary.neutral
        internal = [int]$summary.internal
        fallback = [int]$summary.fallback
        resolvedPercent = [double]$summary.resolvedPercent
        sourceRevision = [string]$coverage.sourceRevision
    }

    # Completed locales intentionally have no ordinary UI fallbacks. Keep a
    # bounded diagnostic list useful while authoring a future catalog.
    if ($Top -gt 0 -and [int]$summary.fallback -gt 0) {
        $source = Get-Content -LiteralPath $SourceCatalog -Raw |
            ConvertFrom-Json
        $covered = @{}
        foreach ($path in $catalogs) {
            $document = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
            foreach ($unit in @($document.units)) {
                if ([string]$unit.domain -in @('ui','both')) {
                    $covered[[string]$unit.english] = $true
                }
            }
        }
        $source.units | Where-Object {
            [int]$_.uiOccurrences -gt 0 -and
            -not $covered.ContainsKey([string]$_.english) -and
            ([string]$_.message -replace '\{[a-z_]+\}', '') -match '\p{L}'
        } | Sort-Object @{Expression='uiOccurrences';Descending=$true}, english |
            Select-Object -First $Top uiOccurrences, english, message, tokens
    }
} finally {
    if ($temporarySource -and (Test-Path -LiteralPath $SourceCatalog)) {
        Remove-Item -LiteralPath $SourceCatalog -Force
    }
}
