[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceCatalog,
    [Parameter(Mandatory = $true)]
    [string]$TranslationMap,
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$utf8Strict = New-Object Text.UTF8Encoding($false, $true)
$utf8 = New-Object Text.UTF8Encoding($false)

function Read-Json([string]$Path) {
    try {
        return [IO.File]::ReadAllText([IO.Path]::GetFullPath($Path),
            $utf8Strict) | ConvertFrom-Json
    } catch {
        throw "Invalid UTF-8/JSON document '$Path': $($_.Exception.Message)"
    }
}

$source = Read-Json $SourceCatalog
$map = Read-Json $TranslationMap
if ([int]$source.schema -ne 1 -or [int]$map.schema -ne 1) {
    throw 'Unsupported translation schema.'
}
$locale = [string]$map.locale
if ($locale -notin @('deDE','esES','frFR','koKR','ruRU','zhCN','zhTW')) {
    throw "Unsupported translation locale '$locale'."
}
$defaultStatus = [string]$map.status
if ($defaultStatus -notin @('reviewed','machine')) {
    throw 'Translation-map status must be reviewed or machine.'
}
$byEnglish = @{}
foreach ($unit in $source.units) { $byEnglish[[string]$unit.english] = $unit }
$seen = @{}
$units = New-Object Collections.Generic.List[object]
foreach ($entry in @($map.units)) {
    $english = [string]$entry.english
    $sourceUnit = $byEnglish[$english]
    if (-not $sourceUnit) { throw "Unknown or stale English source: '$english'." }
    if ($seen.ContainsKey($english)) { throw "Duplicate translation: '$english'." }
    $seen[$english] = $true
    $translation = [string]$entry.translation
    if ([string]::IsNullOrWhiteSpace($translation)) {
        throw "Empty translation: '$english'."
    }
    $expectedTokens = @($sourceUnit.tokens | Sort-Object)
    $actualTokens = @([regex]::Matches($translation, '\{([a-z_]+)\}') |
        ForEach-Object { $_.Groups[1].Value } | Sort-Object)
    if (($expectedTokens -join [char]31) -ne ($actualTokens -join [char]31)) {
        throw "Named-token signature changed: '$english'."
    }
    $status = if ($entry.status) { [string]$entry.status } else { $defaultStatus }
    if ($status -notin @('reviewed','machine')) {
        throw "Invalid status for '$english'."
    }
    $units.Add([ordered]@{
        id = $sourceUnit.id
        english = $english
        translation = $translation
        status = $status
        domain = if ($entry.domain) {
            [string]$entry.domain
        } elseif ($map.domain) { [string]$map.domain } else { 'both' }
        tokenized = $true
        attribution = if ($entry.attribution) {
            [string]$entry.attribution
        } else { [string]$map.source }
    })
}
$document = [ordered]@{
    schema = 1
    locale = $locale
    sourceRevision = [string]$source.sourceRevision
    revision = [string]$map.revision
    source = [string]$map.source
    units = $units
}
if (-not $OutputPath) {
    $OutputPath = Join-Path (Split-Path -Parent $TranslationMap) `
        "$locale-imported.json"
}
$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}
[IO.File]::WriteAllText([IO.Path]::GetFullPath($OutputPath),
    ($document | ConvertTo-Json -Depth 7), $utf8)
Write-Host ("Imported {0} validated {1} translation-map entries for {2}." -f `
    $units.Count, $defaultStatus, $locale)
