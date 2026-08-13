[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceCatalog,
    [string[]]$TranslationCatalog,
    [string]$RepoRoot,
    [ValidateSet('deDE','esES','frFR','koKR','ruRU','zhCN','zhTW')]
    [string]$Locale,
    [string]$OutputPath,
    [string]$FallbackAllowlistPath
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false, $true)
function Join-RepoPath([string]$Relative) {
    $native = $Relative -replace '[\\/]', [IO.Path]::DirectorySeparatorChar
    return Join-Path $RepoRoot $native
}
$source = [IO.File]::ReadAllText([IO.Path]::GetFullPath($SourceCatalog),
    $utf8) | ConvertFrom-Json
$status = @{ guide = @{}; ui = @{} }
$translationRank = @{ machine = 1; reviewed = 2 }
function Set-TranslationStatus([string]$Domain, [string]$English,
                               [string]$Value) {
    if ($Domain -notin @('guide','ui') -or
        $Value -notin @('reviewed','machine')) { return }
    $old = $status[$Domain][$English]
    if (-not $old -or $translationRank[$Value] -gt $translationRank[$old]) {
        $status[$Domain][$English] = $Value
    }
}

function Get-PlainSource([object]$Unit) {
    $value = [string]$Unit.english
    $value = [regex]::Replace($value, '\|H.*?\|h(.*?)\|h', '$1')
    $value = [regex]::Replace($value, '\|T.*?\|t', '')
    $value = [regex]::Replace($value, '\|cRXP_[A-Z]+_', '')
    $value = [regex]::Replace($value, '\|c[0-9a-fA-F]{8}', '')
    return ([regex]::Replace($value, '\|r', '')).Trim()
}

function Get-AutomaticClassification([object]$Unit, [string]$Domain) {
    $message = [regex]::Replace([string]$Unit.message,
        '\{[a-z_]+\}', '')
    if ($message -notmatch '\p{L}') { return 'neutral' }

    $plain = Get-PlainSource $Unit
    if ($plain -match '^\[[^\]]+\]$') {
        # Bracket-only item/spell/entity display is resolved from the client
        # cache at render time. It is not authored English prose.
        return 'official'
    }
    if ($plain -eq 'test' -or $plain -match '^\|cRXP_[A-Z_]+$' -or
        $plain -match '^[A-Z]_\d+(?:_[A-Z]{2})?_[A-Za-z0-9_.-]+$' -or
        $plain -match '^[A-Za-z]+\d+$' -or
        $plain -match '^\d+(?:\.\d+)+(?:a)?$') {
        return 'internal'
    }
    return 'fallback'
}
$packLocale = $null
foreach ($path in @($TranslationCatalog)) {
    if (-not $path) { continue }
    $catalog = [IO.File]::ReadAllText([IO.Path]::GetFullPath($path),
        $utf8) | ConvertFrom-Json
    if (-not $packLocale) { $packLocale = [string]$catalog.locale }
    elseif ($packLocale -ne [string]$catalog.locale) {
        throw 'Coverage catalogs must target one locale.'
    }
    if ([string]$catalog.sourceRevision -ne [string]$source.sourceRevision) {
        throw "Stale catalog: $path"
    }
    foreach ($unit in $catalog.units) {
        $english = [string]$unit.english
        $domain = if ($unit.domain) { [string]$unit.domain } else { 'both' }
        if ($domain -in @('guide','both')) {
            Set-TranslationStatus 'guide' $english ([string]$unit.status)
        }
        if ($domain -in @('ui','both')) {
            Set-TranslationStatus 'ui' $english ([string]$unit.status)
        }
    }
}
if (-not $Locale) { $Locale = $packLocale }
if ($packLocale -and $Locale -ne $packLocale) {
    throw 'Requested locale does not match the translation catalogs.'
}
if ($RepoRoot -and $Locale) {
    $reviewed = @{}
    $localeFile = Join-RepoPath "locale/$Locale.lua"
    $backportFile = Join-RepoPath 'locale/Backport.lua'
    $texts = New-Object Collections.Generic.List[string]
    if (Test-Path -LiteralPath $localeFile -PathType Leaf) {
        $texts.Add([IO.File]::ReadAllText($localeFile, $utf8))
    }
    if (Test-Path -LiteralPath $backportFile -PathType Leaf) {
        $backport = [IO.File]::ReadAllText($backportFile, $utf8)
        $block = [regex]::Match($backport,
            ('(?s)\n\s*' + [regex]::Escape($Locale) +
             '\s*=\s*\{(.*?)(?=\n\s*[a-z][a-z][A-Z][A-Z]\s*=\s*\{|\n\s*\}\s*$)'))
        if ($block.Success) { $texts.Add($block.Groups[1].Value) }
    }
    foreach ($text in $texts) {
        foreach ($entry in [regex]::Matches($text,
                '\["((?:\\.|[^"\\])*)"\]\s*=\s*"((?:\\.|[^"\\])*)"')) {
            $english = $entry.Groups[1].Value.Replace('\"', '"').Replace('\\', '\')
            $translated = $entry.Groups[2].Value.Replace('\"', '"').Replace('\\', '\')
            if ($translated -ceq $english) {
                [void]$reviewed.Remove($english)
            } else {
                $reviewed[$english] = $true
            }
        }
    }
    foreach ($english in $reviewed.Keys) {
        Set-TranslationStatus 'ui' $english 'reviewed'
    }
    if ($Locale -eq 'zhCN') {
        $exactFile = Join-RepoPath 'locale/GuideExact.zhCN.lua'
        if (Test-Path -LiteralPath $exactFile -PathType Leaf) {
            $text = [IO.File]::ReadAllText($exactFile, $utf8)
            foreach ($entry in [regex]::Matches($text,
                    '\["((?:\\.|[^"\\])*)"\]\s*=\s*"')) {
                Set-TranslationStatus 'guide' $entry.Groups[1].Value 'reviewed'
            }
        }
    }
}
$summary = @{}
foreach ($domain in @('guide','ui')) {
    $summary[$domain] = [ordered]@{
        total = 0; reviewed = 0; machine = 0; official = 0
        neutral = 0; internal = 0; fallback = 0
        occurrences = [ordered]@{
            total = 0; reviewed = 0; machine = 0; official = 0
            neutral = 0; internal = 0; fallback = 0
        }
    }
}
$fallbackUnits = New-Object Collections.Generic.List[object]
foreach ($unit in $source.units) {
    $domains = @()
    if ($unit.guideOccurrences -gt 0) { $domains += 'guide' }
    if ($unit.uiOccurrences -gt 0) { $domains += 'ui' }
    foreach ($domain in $domains) {
        $value = $status[$domain][[string]$unit.english]
        if ($value -notin @('reviewed','machine')) {
            $value = Get-AutomaticClassification $unit $domain
        }
        $summary[$domain].total++
        $summary[$domain][$value]++
        $count = if ($domain -eq 'guide') {
            [int]$unit.guideOccurrences
        } else { [int]$unit.uiOccurrences }
        $summary[$domain].occurrences.total += $count
        $summary[$domain].occurrences[$value] += $count
        if ($domain -eq 'guide' -and $value -eq 'fallback') {
            $fallbackUnits.Add([ordered]@{
                id = [string]$unit.id
                english = [string]$unit.english
                occurrences = $count
                reason = 'Bespoke authored prose pending a structurally safe translation.'
            })
        }
    }
}
foreach ($domain in @('guide','ui')) {
    $total = [double]$summary[$domain].occurrences.total
    $fallback = [double]$summary[$domain].occurrences.fallback
    $summary[$domain].resolvedPercent = if ($total -gt 0) {
        [math]::Round((($total - $fallback) / $total) * 100, 4)
    } else { 100.0 }
}
$document = [ordered]@{
    schema = 1
    locale = $Locale
    sourceRevision = $source.sourceRevision
    summary = $summary
}
$json = $document | ConvertTo-Json -Depth 6
if ($OutputPath) {
    [IO.File]::WriteAllText([IO.Path]::GetFullPath($OutputPath), $json,
        (New-Object Text.UTF8Encoding($false)))
}
if ($FallbackAllowlistPath) {
    $allowlist = [ordered]@{
        schema = 1
        sourceType = 'fallbackAllowlist'
        locale = $Locale
        sourceRevision = $source.sourceRevision
        policy = 'These entries render visibly as [EN] until reviewed or structurally safe machine text is available.'
        units = @($fallbackUnits | ForEach-Object { $_ })
    }
    [IO.File]::WriteAllText(
        [IO.Path]::GetFullPath($FallbackAllowlistPath),
        ($allowlist | ConvertTo-Json -Depth 6),
        (New-Object Text.UTF8Encoding($false)))
}
$json
