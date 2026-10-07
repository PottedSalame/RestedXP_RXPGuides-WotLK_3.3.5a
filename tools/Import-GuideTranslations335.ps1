[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$UpstreamRoot,
    [string]$Locale = 'zhCN',
    [ValidateSet('reviewed','machine')]
    [string]$Status = 'reviewed',
    [string]$SourceVersion = 'unspecified',
    [string]$AddonRoot,
    [string]$SourceCatalog,
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
if ($Locale -notin @('deDE','esES','frFR','koKR','ruRU','zhCN','zhTW')) {
    throw "Unsupported guide locale '$Locale'."
}
if (-not $AddonRoot) { $AddonRoot = Split-Path -Parent $PSScriptRoot }
function Join-NativePath([string]$Root, [string]$Relative) {
    $native = $Relative -replace '[\\/]', [IO.Path]::DirectorySeparatorChar
    return Join-Path $Root $native
}
if (-not $SourceCatalog) {
    $SourceCatalog = Join-Path $env:TEMP 'rxp-translation-source-335.json'
    & (Join-Path $PSScriptRoot 'Export-TranslationUnits335.ps1') `
        -AddonRoot $AddonRoot -OutputPath $SourceCatalog -Scope guides
}
if (-not $OutputPath) {
    $OutputPath = Join-NativePath $AddonRoot "translations/imported/$Locale-upstream.json"
}
$utf8Strict = New-Object Text.UTF8Encoding($false, $true)
$utf8 = New-Object Text.UTF8Encoding($false)
$englishRoot = Join-Path $UpstreamRoot 'Guides'
$translatedRoot = Join-NativePath $UpstreamRoot "lang/Guides-$Locale"
if (-not (Test-Path -LiteralPath $englishRoot -PathType Container)) {
    throw "Missing upstream English guide directory: $englishRoot"
}
if (-not (Test-Path -LiteralPath $translatedRoot -PathType Container)) {
    throw "Missing upstream $Locale guide directory: $translatedRoot"
}

function Get-VisibleText([string]$Line) {
    $line = [regex]::Replace($Line, '\s*<<\s*(.+)$', '')
    $match = [regex]::Match($line, '>>\s*(.*?)\s*$')
    if ($match.Success -and $match.Groups[1].Value) {
        return $match.Groups[1].Value
    }
    $match = [regex]::Match($line, '^\s*[+*]\s*(.+?)\s*$')
    if ($match.Success) { return $match.Groups[1].Value }
    return $null
}

function Get-LineSignature([string]$Line) {
    $line = $Line -replace '\s*--.*$',''
    $line = [regex]::Replace($line, '\s*<<\s*(.+)$', '')
    if ($line -match '^\s*\.([a-zA-Z0-9_]+)\s+([^>]*)>>') {
        $tag = $Matches[1].ToLowerInvariant()
        $id = ([regex]::Match($Matches[2], '-?\d+')).Value
        return "directive:${tag}:$id"
    }
    if ($line -match '^\s*>>') { return 'continuation' }
    if ($line -match '^\s*\+') { return 'plus' }
    if ($line -match '^\s*\*') { return 'star' }
    return $null
}

function Get-SortedMatches([string]$Text, [string]$Pattern) {
    return @([regex]::Matches($Text, $Pattern) |
        ForEach-Object { $_.Value } | Sort-Object)
}

function Test-SameSignature([string]$English, [string]$Translated) {
    if ($Translated.TrimStart().StartsWith('.') -or
        $Translated -match '<<|^#|RXPGuides\.RegisterGuide') { return $false }
    if ($Locale -in @('zhCN','zhTW') -and
        $Translated -notmatch '[\u3400-\u9fff]') { return $false }
    if ($Locale -eq 'koKR' -and $Translated -notmatch '[\uac00-\ud7af]') {
        return $false
    }
    if ($Locale -eq 'ruRU' -and $Translated -notmatch '[\u0400-\u04ff]') {
        return $false
    }
    foreach ($pattern in @('\|cRXP_[A-Z]+_','\|r','\|T','\|t','\|H','\|h',
            '-?\d+(?:\.\d+)?')) {
        $left = @(Get-SortedMatches $English $pattern) -join [char]31
        $right = @(Get-SortedMatches $Translated $pattern) -join [char]31
        if ($left -ne $right) {
            return $false
        }
    }
    return $true
}

function Add-Candidate([hashtable]$Candidates, [hashtable]$Conflicts,
                       [string]$English, [string]$Translated) {
    if (-not $English -or -not $Translated -or $English -eq $Translated) { return }
    if (-not (Test-SameSignature $English $Translated)) { return }
    if (-not $Candidates.ContainsKey($English)) {
        $Candidates[$English] = @{}
    }
    $votes = $Candidates[$English]
    $votes[$Translated] = 1 + [int]$votes[$Translated]
    if ($votes.Count -gt 1) { $Conflicts[$English] = $true }
}

function Resolve-Candidates([hashtable]$Candidates,
                            [hashtable]$Conflicts) {
    $resolved = @{}
    $rejected = 0
    foreach ($english in $Candidates.Keys) {
        $ranked = @($Candidates[$english].GetEnumerator() | Sort-Object `
            @{Expression = {[int]$_.Value}; Descending = $true}, `
            @{Expression = {[string]$_.Key}; Descending = $false})
        if ($ranked.Count -eq 1 -or
            [int]$ranked[0].Value -gt [int]$ranked[1].Value) {
            $resolved[$english] = [string]$ranked[0].Key
        } else {
            $rejected++
        }
    }
    return [pscustomobject]@{ Values = $resolved; Rejected = $rejected }
}

function Get-StepBlocks([string[]]$Lines) {
    $steps = New-Object Collections.Generic.List[object]
    $current = $null
    function Finish-Step($Step) {
        if (-not $Step) { return }
        $Step.fingerprint = $Step.parts -join '|'
        $steps.Add($Step)
    }
    for ($index = 0; $index -lt $Lines.Count; $index++) {
        if ($Lines[$index] -match '^\s*step(?:\s|$)') {
            Finish-Step $current
            $current = [pscustomobject]@{
                entries = New-Object Collections.Generic.List[object]
                parts = New-Object Collections.Generic.List[string]
                fingerprint = ''
            }
        }
        if (-not $current) { continue }
        $operational = [regex]::Replace($Lines[$index], '\s*>>.*$', '')
        $operational = [regex]::Replace($operational, '\s*--.*$', '')
        $directive = [regex]::Match($operational,
            '^\s*\.([a-zA-Z0-9_]+)\s*(.*)$')
        if ($directive.Success) {
            $numbers = @([regex]::Matches($directive.Groups[2].Value,
                '-?\d+(?:\.\d+)?') | ForEach-Object { $_.Value })
            $current.parts.Add(($directive.Groups[1].Value.ToLowerInvariant() +
                ':' + ($numbers -join ',')))
        }
        $visible = Get-VisibleText $Lines[$index]
        if ($visible) {
            $current.entries.Add([pscustomobject]@{
                text = $visible
                signature = Get-LineSignature $Lines[$index]
            })
        }
    }
    Finish-Step $current
    return $steps
}

function Align-DifferentFiles([string[]]$EnglishLines,
                              [string[]]$TranslatedLines,
                              [hashtable]$Candidates,
                              [hashtable]$Conflicts) {
    $englishSteps = Get-StepBlocks $EnglishLines
    $translatedSteps = Get-StepBlocks $TranslatedLines
    $translatedIndex = 0
    for ($stepIndex = 0; $stepIndex -lt $englishSteps.Count; $stepIndex++) {
        $leftStep = $englishSteps[$stepIndex]
        if (-not $leftStep.fingerprint) { continue }
        $matchedStep = -1
        for ($candidateStep = $translatedIndex;
             $candidateStep -lt $translatedSteps.Count; $candidateStep++) {
            if ($translatedSteps[$candidateStep].fingerprint -eq
                $leftStep.fingerprint) {
                $matchedStep = $candidateStep
                break
            }
        }
        if ($matchedStep -lt 0) { continue }
        $translatedIndex = $matchedStep + 1
        $left = $leftStep.entries
        $right = $translatedSteps[$matchedStep].entries
        $rightIndex = 0
        for ($leftIndex = 0; $leftIndex -lt $left.Count; $leftIndex++) {
            $source = $left[$leftIndex]
            $matchIndex = -1
            $limit = [math]::Min($right.Count - 1, $rightIndex + 8)
            for ($candidateIndex = $rightIndex;
                 $candidateIndex -le $limit; $candidateIndex++) {
                if ($right[$candidateIndex].signature -eq $source.signature) {
                    $matchIndex = $candidateIndex
                    break
                }
            }
            if ($matchIndex -lt 0) { continue }
            Add-Candidate $Candidates $Conflicts $source.text `
                $right[$matchIndex].text
            $rightIndex = $matchIndex + 1
        }
    }
}

$sourceDocument = [IO.File]::ReadAllText(
    [IO.Path]::GetFullPath($SourceCatalog), $utf8Strict) | ConvertFrom-Json
$sourceByEnglish = @{}
foreach ($unit in $sourceDocument.units) {
    if ($unit.kind -ne 'ui') { $sourceByEnglish[[string]$unit.english] = $unit }
}

$candidates = @{}
$conflicts = @{}
$alignedFiles = 0
$relaxedFiles = 0
foreach ($translatedFile in Get-ChildItem -LiteralPath $translatedRoot `
        -Recurse -Filter '*.lua' -File) {
    $relative = $translatedFile.FullName.Substring(
        $translatedRoot.Length).TrimStart('\', '/')
    $englishFile = Join-Path $englishRoot $relative
    if (-not (Test-Path -LiteralPath $englishFile -PathType Leaf)) { continue }
    $englishLines = [IO.File]::ReadAllLines($englishFile, $utf8Strict)
    $translatedLines = [IO.File]::ReadAllLines($translatedFile.FullName,
        $utf8Strict)
    if ($englishLines.Count -eq $translatedLines.Count) {
        $alignedFiles++
        for ($index = 0; $index -lt $englishLines.Count; $index++) {
            Add-Candidate $candidates $conflicts `
                (Get-VisibleText $englishLines[$index]) `
                (Get-VisibleText $translatedLines[$index])
        }
    } else {
        $relaxedFiles++
        Align-DifferentFiles $englishLines $translatedLines $candidates $conflicts
    }
}
$resolution = Resolve-Candidates $candidates $conflicts
$candidates = $resolution.Values

$units = New-Object Collections.Generic.List[object]
foreach ($english in @($candidates.Keys | Sort-Object)) {
    $sourceUnit = $sourceByEnglish[$english]
    if (-not $sourceUnit) { continue }
    $units.Add([ordered]@{
        id = $sourceUnit.id
        english = $english
        translation = $candidates[$english]
        status = $Status
        domain = 'guide'
        tokenized = $false
        attribution = "RestedXP upstream $Locale visible guide text ($SourceVersion)"
    })
}
$document = [ordered]@{
    schema = 1
    locale = $Locale
    sourceRevision = $sourceDocument.sourceRevision
    revision = "$SourceVersion-$Locale"
    source = "RestedXP upstream $Locale visible guide text"
    units = $units
}
$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}
[IO.File]::WriteAllText($OutputPath,
    ($document | ConvertTo-Json -Depth 7), $utf8)
Write-Host ("Imported {0} of {1} aligned {2} guide translations from {3} strict and {4} relaxed files; rejected {5} conflicts." -f `
    $units.Count, $candidates.Count, $Locale, $alignedFiles, $relaxedFiles,
    $resolution.Rejected)
