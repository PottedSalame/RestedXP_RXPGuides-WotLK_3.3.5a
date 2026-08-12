[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceCatalog,
    [Parameter(Mandatory = $true)]
    [ValidateSet('deDE','esES','frFR','koKR','ruRU','zhCN','zhTW')]
    [string]$Locale,
    [string]$RepoRoot,
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent $PSScriptRoot }
function Join-RepoPath([string]$Relative) {
    $native = $Relative -replace '[\\/]', [IO.Path]::DirectorySeparatorChar
    return Join-Path $RepoRoot $native
}
$utf8Strict = New-Object Text.UTF8Encoding($false, $true)
$utf8 = New-Object Text.UTF8Encoding($false)
$source = [IO.File]::ReadAllText([IO.Path]::GetFullPath($SourceCatalog),
    $utf8Strict) | ConvertFrom-Json
if ([int]$source.schema -ne 1) { throw 'Unsupported source catalog schema.' }

function Convert-LuaString([string]$Value) {
    return [regex]::Replace($Value, '\\([\\"nrt])', {
        param($match)
        switch ($match.Groups[1].Value) {
            '\' { return '\' }
            '"' { return '"' }
            'n' { return "`n" }
            'r' { return "`r" }
            't' { return "`t" }
        }
    })
}

$sourceByEnglish = @{}
foreach ($unit in $source.units) {
    if ([int]$unit.uiOccurrences -gt 0) {
        $sourceByEnglish[[string]$unit.english] = $unit
    }
}
$texts = New-Object Collections.Generic.List[string]
$localePath = Join-RepoPath "locale/$Locale.lua"
if (Test-Path -LiteralPath $localePath -PathType Leaf) {
    $texts.Add([IO.File]::ReadAllText($localePath, $utf8Strict))
}
$backportPath = Join-RepoPath 'locale/Backport.lua'
if (Test-Path -LiteralPath $backportPath -PathType Leaf) {
    $backport = [IO.File]::ReadAllText($backportPath, $utf8Strict)
    $block = [regex]::Match($backport,
        ('(?s)\n\s*' + [regex]::Escape($Locale) +
         '\s*=\s*\{(.*?)(?=\n\s*[a-z][a-z][A-Z][A-Z]\s*=\s*\{|\n\s*\}\s*$)'))
    if ($block.Success) { $texts.Add($block.Groups[1].Value) }
}
$translations = @{}
$rejected = 0
foreach ($text in $texts) {
    foreach ($match in [regex]::Matches($text,
            '\["((?:\\.|[^"\\])*)"\]\s*=\s*"((?:\\.|[^"\\])*)"')) {
        $english = Convert-LuaString $match.Groups[1].Value
        $translated = Convert-LuaString $match.Groups[2].Value
        if (-not $sourceByEnglish.ContainsKey($english)) { continue }
        $signatureMatches = $true
        foreach ($pattern in @('\|cRXP_[A-Z]+_','\|r','\|T','\|t','\|H','\|h',
                '%[0-9.\-+]*[sdif]','-?\d+(?:\.\d+)?')) {
            $left = @([regex]::Matches($english, $pattern) |
                ForEach-Object { $_.Value } | Sort-Object) -join [char]31
            $right = @([regex]::Matches($translated, $pattern) |
                ForEach-Object { $_.Value } | Sort-Object) -join [char]31
            if ($left -ne $right) { $signatureMatches = $false; break }
        }
        if (-not $signatureMatches) { $rejected++; continue }
        if ($translations.ContainsKey($english) -and
            $translations[$english] -ne $translated) {
            throw "Conflicting reviewed $Locale UI translation: '$english'."
        }
        $translations[$english] = $translated
    }
}
$units = foreach ($english in @($translations.Keys | Sort-Object)) {
    $unit = $sourceByEnglish[$english]
    [ordered]@{
        id = $unit.id
        english = $english
        translation = $translations[$english]
        status = 'reviewed'
        domain = 'ui'
        tokenized = $false
        attribution = "Existing RXPGuides $Locale AceLocale catalog"
    }
}
$document = [ordered]@{
    schema = 1
    locale = $Locale
    sourceRevision = [string]$source.sourceRevision
    revision = "$Locale-ui-reviewed-1"
    source = "Existing RXPGuides $Locale AceLocale catalog"
    units = @($units)
}
if (-not $OutputPath) {
    $OutputPath = Join-RepoPath `
        "translations/imported/$Locale-ui-reviewed.json"
}
$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}
[IO.File]::WriteAllText([IO.Path]::GetFullPath($OutputPath),
    ($document | ConvertTo-Json -Depth 7), $utf8)
Write-Host ("Imported {0} reviewed AceLocale UI translations for {1}; rejected {2} unsafe signatures." -f `
    $document.units.Count, $Locale, $rejected)
