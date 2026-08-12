[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceCatalog,
    [Parameter(Mandatory = $true)]
    [ValidateSet('deDE','esES','frFR','koKR','ruRU','zhCN','zhTW')]
    [string]$Locale,
    [string[]]$ExistingCatalog,
    [string]$OutputPath,
    [ValidateSet('all','guides','ui')]
    [string]$Scope = 'all',
    [int]$Limit = 0
)

$ErrorActionPreference = 'Stop'
$utf8Strict = New-Object Text.UTF8Encoding($false, $true)
$utf8 = New-Object Text.UTF8Encoding($false)
$source = [IO.File]::ReadAllText([IO.Path]::GetFullPath($SourceCatalog),
    $utf8Strict) | ConvertFrom-Json
if ([int]$source.schema -ne 1) { throw 'Unsupported source catalog schema.' }
if (-not $OutputPath) {
    $OutputPath = Join-Path (Split-Path -Parent $SourceCatalog) "$Locale-draft.json"
}
$covered = @{}
foreach ($catalogPath in @($ExistingCatalog)) {
    if (-not $catalogPath) { continue }
    $catalog = [IO.File]::ReadAllText([IO.Path]::GetFullPath($catalogPath),
        $utf8Strict) | ConvertFrom-Json
    if ([string]$catalog.locale -ne $Locale) { continue }
    foreach ($unit in $catalog.units) {
        if ($unit.english) { $covered[[string]$unit.english] = $true }
    }
}

$candidates = @($source.units | Where-Object {
    ($Scope -eq 'all' -or
     ($Scope -eq 'guides' -and $_.guideOccurrences -gt 0) -or
     ($Scope -eq 'ui' -and $_.uiOccurrences -gt 0)) -and
    -not $covered.ContainsKey([string]$_.english)
} | Sort-Object @{Expression='occurrences';Descending=$true}, english)
if ($Limit -gt 0) { $candidates = @($candidates | Select-Object -First $Limit) }
$units = foreach ($unit in $candidates) {
    [ordered]@{
        id = $unit.id
        english = $unit.english
        message = $unit.message
        translation = ''
        status = 'machine'
        domain = if ($Scope -eq 'ui') { 'ui' } elseif ($Scope -eq 'guides') {
            'guide'
        } else { 'both' }
        tokenized = $true
        occurrences = $unit.occurrences
        contexts = $unit.contexts
    }
}
$document = [ordered]@{
    schema = 1
    locale = $Locale
    sourceRevision = $source.sourceRevision
    revision = "draft-$($source.sourceRevision)"
    source = 'Unreviewed offline machine-translation draft'
    units = @($units)
}
$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}
[IO.File]::WriteAllText($OutputPath,
    ($document | ConvertTo-Json -Depth 8), $utf8)
Write-Host ("Created {0} frequency-ranked {1} draft units for {2}." -f `
    $document.units.Count, $Scope, $Locale)
