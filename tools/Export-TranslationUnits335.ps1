[CmdletBinding()]
param(
    [string]$AddonRoot,
    [string]$OutputPath,
    [ValidateSet('all','guides','ui')]
    [string]$Scope = 'all'
)

$ErrorActionPreference = 'Stop'
if (-not $AddonRoot) { $AddonRoot = Split-Path -Parent $PSScriptRoot }
$AddonRoot = [IO.Path]::GetFullPath($AddonRoot)
function Resolve-AddonPath([string]$Relative) {
    $native = $Relative -replace '[\\/]',
        [string][IO.Path]::DirectorySeparatorChar
    return Join-Path $AddonRoot $native
}
if (-not $OutputPath) {
    $OutputPath = Resolve-AddonPath 'translations/source/enUS-335.json'
}
$utf8Strict = New-Object Text.UTF8Encoding($false, $true)
$utf8 = New-Object Text.UTF8Encoding($false)

function Get-SourceSignature([string]$Value) {
    [uint64]$hash = 5381
    foreach ($byte in $utf8.GetBytes([string]$Value)) {
        $hash = (($hash * 33) + $byte) % 4294967296
    }
    return '{0:x8}' -f [uint32]$hash
}

function Get-A32([string]$Value) {
    [uint32]$a = 1
    [uint32]$b = 0
    foreach ($byte in $utf8.GetBytes($Value)) {
        $a = ($a + $byte) % 65521
        $b = ($b + $a) % 65521
    }
    [uint64]$unsigned = ([uint64]$b * 65536) + $a
    if ($unsigned -gt [int32]::MaxValue) {
        return [int64]$unsigned - 4294967296
    }
    return [int64]$unsigned
}

function Get-RuntimeGuideKey([string]$Group, [string]$Subgroup,
                             [string]$Name) {
    if ($Group -match 'RXP MoP 1-80') {
        $Group = $Group -replace 'RXP MoP 1-80','RXP MoP 1-60'
    } elseif ($Group -match 'RestedXP Alliance') {
        if (-not $Subgroup) {
            $Subgroup = $Group -replace 'RestedXP Alliance',
                'RXP Speedrun Guide'
        }
        $Group = 'RestedXP Speedrun Guide (A)'
    } elseif ($Group -match 'RestedXP Horde') {
        if (-not $Subgroup) {
            $Subgroup = $Group -replace 'RestedXP Horde',
                'RXP Speedrun Guide'
        }
        $Group = 'RestedXP Speedrun Guide (H)'
    }
    $Name = [regex]::Replace($Name, '^(\d)-(\d\d?)', {
        param($match)
        '0' + $match.Groups[1].Value + '-' +
            $match.Groups[2].Value.PadLeft(2, '0')
    })
    return "$Group|$Subgroup|$Name"
}

function Get-AlphaIndex([int]$Value) {
    $output = ''
    do {
        $digit = $Value % 26
        $output = [char](97 + $digit) + $output
        $Value = [math]::Floor($Value / 26) - 1
    } while ($Value -ge 0)
    return $output
}

function Protect-TranslationText([string]$Value) {
    $script:tokenIndex = 0
    $tokens = New-Object Collections.Generic.List[string]
    function Replace-Atoms([string]$InputText, [string]$Pattern,
                           [string]$Kind) {
        return [regex]::Replace($InputText, $Pattern,
            [Text.RegularExpressions.MatchEvaluator]{
                param($match)
                $name = $Kind + '_' + (Get-AlphaIndex $script:tokenIndex)
                $script:tokenIndex++
                $tokens.Add($name)
                return '{' + $name + '}'
            })
    }
    $value = Replace-Atoms $Value '\|H.*?\|h.*?\|h' 'link'
    $value = Replace-Atoms $value '\|T.*?\|t' 'texture'
    $value = Replace-Atoms $value '\|cRXP_FRIENDLY_.*?\|r' 'friendly'
    $value = Replace-Atoms $value '\|cRXP_ENEMY_.*?\|r' 'enemy'
    $value = Replace-Atoms $value '\\n' 'newline'
    $value = Replace-Atoms $value "`r?`n" 'newline'
    $value = Replace-Atoms $value '\|cRXP_[A-Z]+_' 'rxpcolor'
    $value = Replace-Atoms $value '\|c[0-9a-fA-F]{8}' 'color'
    $value = Replace-Atoms $value '\|r' 'colorend'
    $value = Replace-Atoms $value '%[0-9.\-+]*[sdif]' 'format'
    $value = Replace-Atoms $value '-?\d+(?:\.\d+)?' 'number'
    return [ordered]@{
        text = $value
        tokens = @($tokens | Sort-Object)
    }
}

$units = @{}
function Add-Unit([string]$English, [string]$Kind, [string]$Field,
                  [string]$File, [string]$GuideKey, [int]$StepLine,
                  [int]$SourceLine, $StableStepId) {
    if ([string]::IsNullOrWhiteSpace($English)) { return }
    $english = $English.Trim()
    if (-not $units.ContainsKey($english)) {
        $protected = Protect-TranslationText $english
        $units[$english] = [ordered]@{
            id = $null
            sourceSignature = Get-SourceSignature $english
            kind = $Kind
            field = $Field
            english = $english
            message = $protected.text
            tokens = $protected.tokens
            status = 'fallback'
            attribution = 'RXPGuides canonical English source'
            occurrences = 0
            guideOccurrences = 0
            uiOccurrences = 0
            contexts = New-Object Collections.Generic.List[object]
        }
    }
    $unit = $units[$english]
    $unit.occurrences++
    if ($Kind -eq 'ui') {
        $unit.uiOccurrences++
        if ($unit.guideOccurrences -gt 0) { $unit.kind = 'shared' }
    } else {
        $unit.guideOccurrences++
        if ($unit.uiOccurrences -gt 0) { $unit.kind = 'shared' }
    }
    if ($unit.contexts.Count -lt 24) {
        $relative = $File.Substring($AddonRoot.Length).TrimStart('\','/')
        $unit.contexts.Add([ordered]@{
            file = $relative.Replace('\','/')
            guideKey = $GuideKey
            stepSourceLine = if ($StepLine -gt 0) { $StepLine } else { $null }
            stableStepId = $StableStepId
            sourceLine = $SourceLine
            field = $Field
        })
    }
}

function Get-GuideFiles {
    $guideList = Join-Path $AddonRoot 'GuideList_335.xml'
    $xml = [IO.File]::ReadAllText($guideList, $utf8Strict)
    foreach ($match in [regex]::Matches($xml,
            '<Script\s+file="([^"]+\.lua)"')) {
        $path = Resolve-AddonPath $match.Groups[1].Value
        if (Test-Path -LiteralPath $path -PathType Leaf) { $path }
    }
}

function Export-GuideUnits {
    foreach ($file in Get-GuideFiles) {
        $content = [IO.File]::ReadAllText($file, $utf8Strict)
        $blocks = [regex]::Matches($content,
            '(?s)RegisterGuide\s*\(\s*\[(=*)\[(.*?)\]\1\]\s*\)')
        foreach ($blockMatch in $blocks) {
            $block = $blockMatch.Groups[2].Value
            $lines = $block -split "`r?`n"
            $group = ''
            $subgroup = ''
            $name = ''
            foreach ($line in $lines) {
                if ($line -match '^\s*#group\s+(.+?)(?:\s*<<.*)?\s*$') {
                    $group = $Matches[1].Trim()
                } elseif ($line -match '^\s*#subgroup\s+(.+?)(?:\s*<<.*)?\s*$') {
                    $subgroup = $Matches[1].Trim()
                } elseif ($line -match '^\s*#name\s+(.+?)(?:\s*<<.*)?\s*$') {
                    $name = $Matches[1].Trim()
                }
            }
            $guideKey = Get-RuntimeGuideKey $group $subgroup $name
            $guideId = Get-A32 $guideKey
            $stepLine = 0
            $stableStepId = $null
            $runtimeLine = 0
            for ($index = 0; $index -lt $lines.Count; $index++) {
                $raw = $lines[$index]
                if ($raw.Length -gt 0) { $runtimeLine++ }
                $lineNumber = $index + 1
                $line = [regex]::Replace($raw, '\s*<<\s*(.+)$', '')
                if ($line -match '^\s*step(?:\s|$)') {
                    $stepLine = $lineNumber
                    $stableStepId = $guideId + $runtimeLine
                    continue
                }
                $header = [regex]::Match($line,
                    '^\s*#(group|subgroup|name|title|somname|eraname|maptooltip|arrowtext)\s+(.+?)\s*$')
                if ($header.Success) {
                    $field = $header.Groups[1].Value
                    $kind = if ($field -in @('group','subgroup','name','somname','eraname')) {
                        'guideTitle'
                    } else { 'stepTitle' }
                    Add-Unit $header.Groups[2].Value $kind $field $file $guideKey `
                        $stepLine $lineNumber $stableStepId
                    continue
                }
                $visible = [regex]::Match($line, '>>\s*(.*?)\s*$')
                if (-not $visible.Success) {
                    $visible = [regex]::Match($line, '^\s*[+*]\s*(.+?)\s*$')
                }
                if (-not $visible.Success -or
                    [string]::IsNullOrWhiteSpace($visible.Groups[1].Value)) {
                    continue
                }
                $directive = [regex]::Match($line, '^\s*\.(\S+)')
                $field = if ($directive.Success) {
                    $directive.Groups[1].Value
                } else { $null }
                if (-not $field) { $field = 'prose' }
                Add-Unit $visible.Groups[1].Value 'guideText' $field $file `
                    $guideKey $stepLine $lineNumber $stableStepId
            }
        }
    }
}

function Get-ManifestLuaFiles {
    $seen = @{}
    $result = New-Object Collections.Generic.List[string]
    function Visit([string]$Path) {
        $full = [IO.Path]::GetFullPath($Path)
        if ($seen.ContainsKey($full) -or -not (Test-Path -LiteralPath $full)) {
            return
        }
        $seen[$full] = $true
        $extension = [IO.Path]::GetExtension($full).ToLowerInvariant()
        if ($extension -eq '.lua') { $result.Add($full); return }
        $base = Split-Path -Parent $full
        foreach ($line in [IO.File]::ReadAllLines($full, $utf8Strict)) {
            $value = $line.Trim()
            if (-not $value -or $value.StartsWith('#')) { continue }
            $match = [regex]::Match($value,
                '(?:file\s*=\s*")?([^"<>]+\.(?:lua|xml))')
            if ($match.Success) {
                $relative = $match.Groups[1].Value -replace '[\\/]',
                    [string][IO.Path]::DirectorySeparatorChar
                Visit (Join-Path $base $relative)
            }
        }
    }
    Visit (Join-Path $AddonRoot 'RXPGuides.toc')
    return $result
}

function Export-UiUnits {
    foreach ($file in Get-ManifestLuaFiles) {
        if ($file -match '[\\/]Guides[\\/]' -or
            $file -match '[\\/]libs[\\/]' -or
            $file -match '[\\/]locale[\\/]') { continue }
        $text = [IO.File]::ReadAllText($file, $utf8Strict)
        $patterns = @(
            'L\(\s*"((?:\\.|[^"\\])*)"\s*\)',
            "L\(\s*'((?:\\.|[^'\\])*)'\s*\)",
            'L\[\s*"((?:\\.|[^"\\])*)"\s*\]'
        )
        foreach ($pattern in $patterns) {
            foreach ($match in [regex]::Matches($text, $pattern)) {
                $english = $match.Groups[1].Value.Replace('\n', "`n")
                $line = 1 + ([regex]::Matches(
                    $text.Substring(0, $match.Index), "`n")).Count
                Add-Unit $english 'ui' 'ui' $file '' 0 $line $null
            }
        }
    }
}

if ($Scope -in @('all','guides')) { Export-GuideUnits }
if ($Scope -in @('all','ui')) { Export-UiUnits }

$sorted = @($units.Values | Sort-Object kind, @{Expression='occurrences';Descending=$true}, english)
foreach ($unit in $sorted) {
    $unit.id = Get-SourceSignature ("$($unit.kind)`0$($unit.english)")
}
$document = [ordered]@{
    schema = 1
    interface = 30300
    source = 'RXPGuides canonical English display text'
    sourceRevision = (Get-SourceSignature (($sorted | ForEach-Object {
        $_.sourceSignature
    }) -join "`n"))
    unitCount = $sorted.Count
    guideUnitCount = @($sorted | Where-Object { $_.guideOccurrences -gt 0 }).Count
    uiUnitCount = @($sorted | Where-Object { $_.uiOccurrences -gt 0 }).Count
    units = $sorted
}
$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}
[IO.File]::WriteAllText($OutputPath,
    ($document | ConvertTo-Json -Depth 8), $utf8)
Write-Host ("Exported {0} deterministic translation units ({1} guide, {2} UI)." -f `
    $document.unitCount, $document.guideUnitCount, $document.uiUnitCount)
