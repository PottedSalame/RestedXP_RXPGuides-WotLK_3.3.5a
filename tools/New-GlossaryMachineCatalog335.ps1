[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceCatalog,
    [Parameter(Mandatory = $true)]
    [string]$Rules,
    [string[]]$ExistingCatalog,
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$utf8Strict = New-Object Text.UTF8Encoding($false, $true)
$utf8 = New-Object Text.UTF8Encoding($false)
function Read-Json([string]$Path) {
    return [IO.File]::ReadAllText([IO.Path]::GetFullPath($Path), $utf8Strict) |
        ConvertFrom-Json
}

$source = Read-Json $SourceCatalog
$rulesDocument = Read-Json $Rules
if ([int]$source.schema -ne 1 -or [int]$rulesDocument.schema -ne 1) {
    throw 'Unsupported glossary translation schema.'
}
$locale = [string]$rulesDocument.locale
if ($locale -notin @('deDE','esES','frFR','koKR','ruRU','zhCN','zhTW')) {
    throw "Unsupported translation locale '$locale'."
}
$covered = @{}
foreach ($path in @($ExistingCatalog)) {
    if (-not $path) { continue }
    $catalog = Read-Json $path
    if ([string]$catalog.locale -ne $locale) { continue }
    foreach ($unit in $catalog.units) {
        $covered[[string]$unit.english] = $true
    }
}
$compiledRules = @($rulesDocument.rules | ForEach-Object {
    $pattern = [string]$_.pattern
    $options = [Text.RegularExpressions.RegexOptions]::CultureInvariant
    if ($pattern.StartsWith('(?i)')) {
        $pattern = $pattern.Substring(4)
        $options = $options -bor [Text.RegularExpressions.RegexOptions]::IgnoreCase
    }
    [pscustomobject]@{
        regex = New-Object Text.RegularExpressions.Regex(
            ('(?<![A-Za-z])(?:' + $pattern + ')(?![A-Za-z])'), $options)
        replacement = [string]$_.replacement
    }
})
$units = New-Object Collections.Generic.List[object]
foreach ($unit in $source.units) {
    if ([int]$unit.guideOccurrences -lt 1 -or
        $covered.ContainsKey([string]$unit.english)) { continue }
    $translation = [string]$unit.message
    foreach ($rule in $compiledRules) {
        $translation = $rule.regex.Replace($translation, $rule.replacement)
    }
    if ($translation -eq [string]$unit.message) { continue }
    if ($locale -in @('zhCN','zhTW') -and
        $translation -notmatch '[\u3400-\u9fff]') { continue }
    $expectedTokens = @($unit.tokens | Sort-Object)
    $actualTokens = @([regex]::Matches($translation, '\{([a-z_]+)\}') |
        ForEach-Object { $_.Groups[1].Value } | Sort-Object)
    if (($expectedTokens -join [char]31) -ne ($actualTokens -join [char]31)) {
        throw "Glossary changed named tokens: '$($unit.english)'."
    }
    $units.Add([ordered]@{
        id = $unit.id
        english = $unit.english
        translation = $translation
        status = 'machine'
        domain = 'guide'
        tokenized = $true
        attribution = [string]$rulesDocument.source
    })
}
$document = [ordered]@{
    schema = 1
    locale = $locale
    sourceRevision = [string]$source.sourceRevision
    revision = [string]$rulesDocument.revision
    source = [string]$rulesDocument.source
    units = $units
}
if (-not $OutputPath) {
    $OutputPath = Join-Path (Split-Path -Parent $Rules) `
        "$locale-guide-machine.json"
}
$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}
[IO.File]::WriteAllText([IO.Path]::GetFullPath($OutputPath),
    ($document | ConvertTo-Json -Depth 7), $utf8)
Write-Host ("Generated {0} structurally safe glossary-machine entries for {1}." -f `
    $units.Count, $locale)
