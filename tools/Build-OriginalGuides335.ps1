param(
    [Parameter(Mandatory = $true)]
    [string]$SourceRoot,
    [string]$OutputRoot = (Join-Path $PSScriptRoot '..\Guides\Original'),
    [string]$GroupPrefix = 'Original Guides - ',
    [switch]$LevelingOnly
)

$ErrorActionPreference = 'Stop'
$utf8NoBom = New-Object Text.UTF8Encoding($false)
$guidePattern = [regex]'(?ms)RXPGuides\.RegisterGuide\(\[\[(.*?)\]\]\)\s*;?'

function Get-GuideBlocks([string]$Path) {
    $text = [IO.File]::ReadAllText($Path)
    foreach ($match in $guidePattern.Matches($text)) {
        $match.Groups[1].Value.Trim("`r", "`n")
    }
}

function Get-Header([string]$Content, [string]$Name) {
    $match = [regex]::Match($Content, '(?m)^#' + [regex]::Escape($Name) + '\s+(.+?)\s*$')
    if ($match.Success) { return ($match.Groups[1].Value -replace '\s*<<.*$', '').Trim() }
    return $null
}

function Protect-UnsupportedQuestSteps([string]$Content) {
    $parts = [regex]::Split($Content, '(?m)(?=^step\b)')
    for ($index = 0; $index -lt $parts.Count; $index++) {
        $part = $parts[$index]
        if ($part -notmatch '^step\b') { continue }
        $unsupported = $false
        foreach ($match in [regex]::Matches($part, '(?m)^\s*\.(?:accept|turnin|complete|daily|dailyturnin)\s+(\d+)')) {
            $questId = [int]$match.Groups[1].Value
            if (($questId -ge 64028 -and $questId -le 64217) -or
                $questId -in @(65601, 65604, 65610)) {
                $unsupported = $true
                break
            }
        }
        if ($unsupported) {
            $parts[$index] = [regex]::Replace($part, '^step([^\r\n]*)', {
                param($match)
                $tail = $match.Groups[1].Value
                if ($tail -match '<<') { return 'step' + $tail + ' !ac335' }
                return 'step << !ac335' + $tail
            }, 1)
        }
    }
    return $parts -join ''
}

function Rewrite-NextTargets([string]$Content, [hashtable]$LoadedGroups) {
    return [regex]::Replace($Content, '(?m)^(#next\s+)(.+)$', {
        param($match)
        $value = $match.Groups[2].Value
        $condition = ''
        $conditionIndex = $value.IndexOf(' << ')
        if ($conditionIndex -ge 0) {
            $condition = $value.Substring($conditionIndex)
            $value = $value.Substring(0, $conditionIndex)
        }
        $targets = foreach ($target in ($value -split ';')) {
            $candidate = $target.Trim()
            $separator = $candidate.IndexOf('\')
            if ($separator -le 0) { $candidate; continue }
            $targetGroup = $candidate.Substring(0, $separator)
            $targetName = $candidate.Substring($separator + 1)
            if ($targetGroup -match '^RestedXP Alliance') {
                $mapped = if ($LoadedGroups.ContainsKey($targetGroup)) {
                    'RestedXP Speedrun Guide (A)'
                } else { 'RestedXP TBC Guide (A)' }
                $candidate = $GroupPrefix + $mapped + '\' + $targetName
            } elseif ($targetGroup -match '^RestedXP Horde') {
                $mapped = if ($LoadedGroups.ContainsKey($targetGroup)) {
                    'RestedXP Speedrun Guide (H)'
                } else { 'RestedXP TBC Guide (H)' }
                $candidate = $GroupPrefix + $mapped + '\' + $targetName
            } elseif ($LoadedGroups.ContainsKey($targetGroup)) {
                $candidate = $GroupPrefix + $candidate
            }
            $candidate
        }
        return $match.Groups[1].Value + ($targets -join ';') + $condition
    })
}

function Convert-Guide([string]$Content, [hashtable]$LoadedGroups) {
    $content = $Content -replace "`r`n", "`n"
    $content = $content.Replace('#compltewith', '#completewith')
    $content = $content.Replace('#completewity', '#completewith')
    $content = $content.Replace('#completewtih', '#completewith')
    $content = $content.Replace('#completwith', '#completewith')
    $content = $content.Replace('#competewith', '#completewith')
    $content = $content.Replace('#lable', '#label')
    $content = $content.Replace('#noflyasble', '#noflyable')
    $content = $content.Replace('#requries', '#requires')
    $content = $content.Replace('#requies', '#requires')
    $content = $content.Replace('#rqeuires', '#requires')
    $content = [regex]::Replace($content, '(?m)^#wrath\s*$', '#wotlk')
    # Preserve the upstream route while translating legacy parser hazards that
    # otherwise prevent the snapshot from loading on the 3.3.5 client.
    $content = $content.Replace('32.85,32.38,63.02', '32.85,63.02')
    $content = $content.Replace('52.24,54.38,', '52.24,54.38')
    $content = $content.Replace('44.43,38.36,,43.12', '44.43,38.36,43.12')
    $content = $content.Replace('27.9,81.3,,27.0', '27.9,81.3,27.0')
    $content = [regex]::Replace($content, '(?m)^(\s*)turnin\s+', '$1.turnin ')
    $content = $content.Replace('.subzone 4360', '.goto ScarletEnclave,60.0,77.0')
    $content = $content.Replace('.subzone 4281', '.goto ScarletEnclave,50.3,33.1')
    $content = $content.Replace('.subzoneskip 4281', '.goto ScarletEnclave,50.3,33.1')
    $content = $content.Replace('.goto 23/0,-5650.600,2375.500', '.goto Eastern Plaguelands,83.4,49.4')
    $content = $content.Replace('.goto 23/0,-5650.700,2375.400', '.goto Eastern Plaguelands,83.4,49.4')
    $content = $content.Replace('.goto 23/0,-5696.000,2348.200', '.goto ScarletEnclave,52.1,35.0')
    $content = $content.Replace('.goto 23/0,-5659.900,2324.400', '.goto ScarletEnclave,50.9,36.3')
    $content = [regex]::Replace($content, '(?m)^\s*\.goto 84/0,232\.200,-8363\.000\s*<<\s*cata/mop\s*$', '')
    $content = $content.Replace('.goto 23,', '.goto Eastern Plaguelands,')
    $content = $content.Replace('.waypoint 23,', '.waypoint Eastern Plaguelands,')
    $content = $content.Replace('.goto 126,', '.goto Dalaran,')
    $content = $content.Replace('.waypoint 126,', '.waypoint Dalaran,')
    $content = $content.Replace('.waypoint 107,', '.waypoint Nagrand,')
    $content = Protect-UnsupportedQuestSteps $content

    $rawGroup = Get-Header $content 'group'
    if (-not $rawGroup) { throw 'Original guide is missing #group' }
    $marker = if ($rawGroup.StartsWith('+') -or $rawGroup.StartsWith('*')) {
        $rawGroup.Substring(0, 1)
    } else { '' }
    $innerGroup = if ($marker) { $rawGroup.Substring(1) } else { $rawGroup }
    $canonicalGroup = $innerGroup
    $inferredSubgroup = $null
    if ($innerGroup -match '^RestedXP Alliance') {
        $canonicalGroup = 'RestedXP Speedrun Guide (A)'
        $inferredSubgroup = $innerGroup -replace '^RestedXP Alliance', 'RXP Speedrun Guide'
    } elseif ($innerGroup -match '^RestedXP Horde') {
        $canonicalGroup = 'RestedXP Speedrun Guide (H)'
        $inferredSubgroup = $innerGroup -replace '^RestedXP Horde', 'RXP Speedrun Guide'
    }
    $newGroup = $marker + $GroupPrefix + $canonicalGroup
    $content = [regex]::Replace($content, '(?m)^#group\s+.+?\s*$', '#group ' + $newGroup, 1)
    if ($inferredSubgroup -and $content -notmatch '(?m)^#subgroup\s+') {
        $content = [regex]::Replace($content, '(?m)^(#group\s+.+)$', "`$1`n#subgroup $inferredSubgroup", 1)
    }
    $content = Rewrite-NextTargets $content $LoadedGroups
    return $content.Trim("`r", "`n")
}

$levelingFiles = @(
    'RestedXP Alliance 1-11 NightElf.lua',
    'RestedXP Alliance 1-14 Human.lua',
    'RestedXP Alliance 1-14 Dwarf-Gnome.lua',
    'RestedXP Alliance 1-23 Draenei.lua',
    'RestedXP Alliance 11-23.lua',
    'RestedXP Alliance 23-30.lua',
    'RestedXP Alliance Boosted 58-60.lua',
    'RestedXP Horde 1-6 Undead.lua',
    'RestedXP Horde 1-10 Tauren.lua',
    'RestedXP Horde 1-13 Troll-Orc.lua',
    'RestedXP Horde 1-20 BloodElf.lua',
    'RestedXP Horde 13-23 Barrens.lua',
    'RestedXP Horde 20-30.lua',
    'RestedXP Horde Boosted 58-60.lua',
    'Deathknight.lua'
)
$sourceFiles = New-Object 'Collections.Generic.List[string]'
if ($LevelingOnly) {
    foreach ($relative in $levelingFiles) {
        $path = Join-Path (Join-Path $SourceRoot 'Guides') $relative
        if (-not [IO.File]::Exists($path)) {
            throw "Original guide file not found: Guides\$relative"
        }
        $sourceFiles.Add($path)
    }
} else {
    $manifestPath = Join-Path $SourceRoot 'Guides\GuideList.xml'
    if (-not [IO.File]::Exists($manifestPath)) {
        throw "Original guide manifest not found: $manifestPath"
    }
    $manifest = [IO.File]::ReadAllText($manifestPath)
    foreach ($match in [regex]::Matches($manifest, '<Script\s+file="([^"]+)"\s*/>')) {
        $relative = $match.Groups[1].Value -replace '/', [IO.Path]::DirectorySeparatorChar
        $path = Join-Path $SourceRoot $relative
        if (-not [IO.File]::Exists($path)) {
            throw "Original guide file not found: $relative"
        }
        if ([IO.Path]::GetFileName($path) -ne 'Import.lua') {
            $sourceFiles.Add($path)
        }
    }
}

$blocks = New-Object 'Collections.Generic.List[string]'
$loadedGroups = @{}
foreach ($path in $sourceFiles) {
    foreach ($block in (Get-GuideBlocks $path)) {
        $blocks.Add($block)
        $group = Get-Header $block 'group'
        if ($group) { $loadedGroups[($group.TrimStart('+', '*'))] = $true }
    }
}

[IO.Directory]::CreateDirectory($OutputRoot) | Out-Null
$parts = New-Object 'Collections.Generic.List[string]'
$parts.Add('-- Original RXPGuides v4.10.20 route snapshots.')
$parts.Add('-- Only namespacing and minimum 3.3.5 parser compatibility are applied.')
foreach ($block in $blocks) {
    $parts.Add('RXPGuides.RegisterGuide([[')
    $parts.Add((Convert-Guide $block $loadedGroups))
    $parts.Add(']]);')
}
$outputPath = Join-Path $OutputRoot 'Upstream-Classic-Wrath.lua'
[IO.File]::WriteAllText($outputPath, (($parts -join "`n") + "`n"), $utf8NoBom)
Write-Host "Generated $($blocks.Count) original Classic/Wrath guide snapshots."
