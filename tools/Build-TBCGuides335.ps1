param(
    [Parameter(Mandatory = $true)]
    [string]$SourceRoot,
    [string]$OutputRoot = (Join-Path $PSScriptRoot "..\Guides\TBC"),
    [string]$GroupPrefix = ''
)

$ErrorActionPreference = "Stop"
$culture = [Globalization.CultureInfo]::InvariantCulture
$utf8NoBom = New-Object Text.UTF8Encoding($false)

function Get-GuideBlocks([string]$Path) {
    $text = [IO.File]::ReadAllText($Path)
    $pattern = [regex]'(?ms)RXPGuides\.RegisterGuide\(\[\[(.*?)\]\]\)\s*;?'
    foreach ($match in $pattern.Matches($text)) {
        $content = $match.Groups[1].Value.Trim("`r", "`n")
        $group = [regex]::Match($content, '(?m)^#group\s+(.+?)\s*$').Groups[1].Value.Trim()
        $name = [regex]::Match($content, '(?m)^#name\s+(.+?)\s*$').Groups[1].Value.Trim()
        [pscustomobject]@{ Group = $group; Name = $name; Content = $content }
    }
}

function Get-MapBounds([string]$Path) {
    $rows = @{}
    $values = @{}
    $name = $null
    $instance = $null
    foreach ($line in [IO.File]::ReadLines($Path)) {
        if ($line -match '^\s*(-?\d+(?:\.\d+)?)\s*,\s*-- \[([1-4])\]') {
            $values[[int]$Matches[2]] = [double]::Parse($Matches[1], $culture)
        } elseif ($line -match '\["name"\]\s*=\s*"([^"]+)"') {
            $name = $Matches[1]
        } elseif ($line -match '\["instance"\]\s*=\s*(\d+)') {
            $instance = [int]$Matches[1]
        } elseif ($line -match '^\s*\},\s*-- \[\d+\]' -and $name -and $values.Count -eq 4) {
            $key = "$instance|$name"
            if (-not $rows.ContainsKey($key) -and $values[1] -gt 0 -and $values[2] -gt 0) {
                $rows[$key] = [pscustomobject]@{
                    Width = $values[1]
                    Height = $values[2]
                    Left = $values[3]
                    Top = $values[4]
                }
            }
            $values = @{}
            $name = $null
            $instance = $null
        }
    }
    return $rows
}

$mapNames = @{
    1419 = 'Blasted Lands'
    1423 = 'Eastern Plaguelands'
    1435 = 'Swamp of Sorrows'
    1445 = 'Dustwallow Marsh'
    1446 = 'Tanaris'
    1451 = 'Silithus'
    1944 = 'Hellfire Peninsula'
    1946 = 'Zangarmarsh'
    1948 = 'Shadowmoon Valley'
    1949 = "Blade's Edge Mountains"
    1951 = 'Nagrand'
    1952 = 'Terokkar Forest'
    1953 = 'Netherstorm'
    1955 = 'Shattrath City'
}

$bounds = Get-MapBounds (Join-Path $SourceRoot 'DB\cata\db.lua')
# Cataclysm split the legacy Barrens map.  These are the original 3.3.5
# WorldMapArea bounds, reconstructed from the bundled Astrolabe map geometry.
$bounds['1|The Barrens'] = [pscustomobject]@{
    Width = 10133.44231353798
    Height = 6756.201888541853
    Left = 2622.75920036053
    Top = 1612.479166666667
}
$worldCoordinateCount = 0

function Resolve-WorldCoordinateZone([int]$MapId, [double]$WorldX, [double]$WorldY) {
    if ($mapNames.ContainsKey($MapId)) { return $mapNames[$MapId] }
    if ($MapId -eq 1414) {
        # The selected continent-level points are the RFK and RFD entrances.
        return 'The Barrens'
    }
    if ($MapId -eq 1415) {
        if ($WorldY -gt 0) { return 'Tirisfal Glades' }
        if ($WorldX -gt -2700) { return 'Loch Modan' }
        return 'Badlands'
    }
    throw "No 3.3.5 world-coordinate override exists for map $MapId ($WorldX, $WorldY)"
}

function Convert-WorldCoordinates([string]$Content) {
    $pattern = [regex]'(?m)^(\s*\.(?:goto|groundgoto|flygoto|waypoint)\s+)(\d+)/(\d+),(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)([^\r\n]*)$'
    return $pattern.Replace($Content, {
        param($match)
        $mapId = [int]$match.Groups[2].Value
        $instance = [int]$match.Groups[3].Value
        $worldX = [double]::Parse($match.Groups[4].Value, $culture)
        $worldY = [double]::Parse($match.Groups[5].Value, $culture)
        $zone = Resolve-WorldCoordinateZone $mapId $worldX $worldY
        $key = "$instance|$zone"
        if (-not $bounds.ContainsKey($key)) {
            throw "Missing map bounds for $zone (instance $instance)"
        }
        $map = $bounds[$key]
        $x = (($map.Left - $worldX) / $map.Width) * 100
        $y = (($map.Top - $worldY) / $map.Height) * 100
        if ($x -lt 0 -or $x -gt 100 -or $y -lt 0 -or $y -gt 100) {
            throw "Converted coordinate is outside $zone`: $x, $y from $mapId/$instance,$worldX,$worldY"
        }
        $script:worldCoordinateCount++
        $xText = $x.ToString('0.###', $culture)
        $yText = $y.ToString('0.###', $culture)
        return $match.Groups[1].Value + $zone + ',' + $xText + ',' + $yText + $match.Groups[6].Value
    })
}

function Set-HeaderValue([string]$Content, [string]$Header, [string]$Value) {
    $pattern = [regex]("(?m)^#" + [regex]::Escape($Header) + "\s+.*$")
    if ($pattern.IsMatch($Content)) {
        return $pattern.Replace($Content, "#$Header $Value", 1)
    }
    throw "Guide is missing #$Header"
}

function Add-GuideNamespace([string]$Content) {
    if ([string]::IsNullOrWhiteSpace($GroupPrefix)) { return $Content }
    $content = [regex]::Replace($Content, '(?m)^#group\s+(.+?)\s*$', {
        param($match)
        $group = $match.Groups[1].Value.Trim()
        $marker = if ($group.StartsWith('+') -or $group.StartsWith('*')) {
            $group.Substring(0, 1)
        } else { '' }
        if ($marker) { $group = $group.Substring(1) }
        return '#group ' + $marker + $GroupPrefix + $group
    }, 1)
    return [regex]::Replace($content, '(?m)^(#next\s+)(.+)$', {
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
            if ($separator -gt 0) {
                $group = $candidate.Substring(0, $separator)
                if (-not $group.StartsWith($GroupPrefix)) {
                    $candidate = $GroupPrefix + $candidate
                }
            }
            $candidate
        }
        return $match.Groups[1].Value + ($targets -join ';') + $condition
    })
}

function Repair-TBCGuide([pscustomobject]$Guide) {
    $content = $Guide.Content -replace "`r`n", "`n"
    if ($content -match '(?m)^#tbc\s*$' -and $content -notmatch '(?m)^#wotlk\s*$') {
        $content = [regex]::Replace($content, '(?m)^#tbc\s*$', "#tbc`n#wotlk", 1)
    }

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
    # The 3.3.5 taxi API exposes the actual node names rather than the broader
    # zone labels used by some newer guide revisions.  Keep these explicit so
    # the legacy resolver never has to guess between multiple nodes.
    $content = $content.Replace('.fly Stormwind City ', '.fly Stormwind ')
    $content = $content.Replace('.fly Arathi Highlands', '.fly Refuge Pointe')
    $content = $content.Replace(".fp Grom'Gol Base Camp", ".fp Grom'gol")
    $content = $content.Replace('.fly Spinebreaker Post', '.fly Spinebreaker Ridge')
    $content = $content.Replace('.fp Spinebreaker Post', '.fp Spinebreaker Ridge')
    $content = $content.Replace('.fly Westfall', '.fly Sentinel Hill')
    $content = $content.Replace('.fly Ashenvale', '.fly Astranaar')
    $content = $content.Replace('.fly Shattrath City', '.fly Shattrath')
    $content = $content.Replace('.fly Shatter >>', '.fly Shatter Point >>')
    $content = $content.Replace('.zoneskip Stranglethon Vale', '.zoneskip Stranglethorn Vale')
    $content = $content.Replace(".zoneskip 304`n.zoneskip 305", '.zoneskip Scarlet Monastery')
    $content = $content.Replace('.zoneskip 209,1', '.zoneskip Shadowfang Keep,1')
    $content = $content.Replace('.zone 721,2', '.zone Gnomeregan,2')
    $content = $content.Replace('.isQuestAvailable 6604,5168,5181,5211,,9474,5237,6389,5846', '.isQuestAvailable 6604,5168,5181,5211,9474,5237,6389,5846')
    $content = $content.Replace('39.01.71.93', '39.01,71.93')
    $content = $content.Replace('86.20.59.85', '86.20,59.85')
    $content = $content.Replace(".line Blade's Edge Mountains,49.97,69.43,50.57,67.81,50.08,65.67,48.66,65.94,47.78,64.49,46.99,65.61,45.59,65.53,44.78,63.27,42.36,59.99,40.75,59.12,39.01.71.93", ".line Blade's Edge Mountains,49.97,69.43,50.57,67.81,50.08,65.67,48.66,65.94,47.78,64.49,46.99,65.61,45.59,65.53,44.78,63.27,42.36,59.99,40.75,59.12,39.01,71.93")
    $content = $content.Replace('.line Netherstorm,39.60,75.42,40.71,74.80,41.38,72.83,42.74,72.23,43.55,70.62,44.81,70.24,45.88,68.86,46.63,67.11,47.97,66.75,48.98,65.40,50.25,65.17,51.08,63.88,52.76,63.45,54.26,61.78,55.45,61.68,56.47,60.20,58.16,60.54,59.27,59.54,61.23,60.22,62.07,59.52,63.13,60.16,65.27,59.68,66.80,60.52,68.54,60.30,70.08,59.35,72.20,59.83,73.34,59.37,74.82,60.47,76.23,60.28,77.36,59.20,78.54,59.37,79.76,58.35,81.07,58.68,82.39,57.91,83.78,58.58,85.06,58.07,86.20.59.85', '.line Netherstorm,39.60,75.42,40.71,74.80,41.38,72.83,42.74,72.23,43.55,70.62,44.81,70.24,45.88,68.86,46.63,67.11,47.97,66.75,48.98,65.40,50.25,65.17,51.08,63.88,52.76,63.45,54.26,61.78,55.45,61.68,56.47,60.20,58.16,60.54,59.27,59.54,61.23,60.22,62.07,59.52,63.13,60.16,65.27,59.68,66.80,60.52,68.54,60.30,70.08,59.35,72.20,59.83,73.34,59.37,74.82,60.47,76.23,60.28,77.36,59.20,78.54,59.37,79.76,58.35,81.07,58.68,82.39,57.91,83.78,58.58,85.06,58.07,86.20,59.85')
    $content = $content.Replace('.line Netherstorm,,56.15,19.69', '.line Netherstorm,56.15,19.69')

    if ($content -match '(?m)^#name\s+37-39 Dustwallow\s*$') {
        $content = Set-HeaderValue $content 'next' '39-42 Arathi Highlands;39-41 Arathi/Alterac'
    } elseif ($content -match '(?m)^#name\s+39-42 Arathi Highlands\s*$') {
        $content = Set-HeaderValue $content 'next' '43-46 STV part 2'
    } elseif ($content -match '(?m)^#name\s+43-46 STV part 2\s*$') {
        $content = Set-HeaderValue $content 'next' '46-47 STV/Swamp of Sorrows'
    } elseif ($content -match '(?m)^#name\s+50-51 Searing Gorge\s*$') {
        $content = Set-HeaderValue $content 'next' '51-52 Burning Steppes'
    } elseif ($content -match '(?m)^#name\s+65-67 Blade''s Edge Mts\s*$') {
        $content = [regex]::Replace($content, '(?m)^#next\s+67-67 Blade''s Edge Turn-ins\s*<<\s*!tbc\s*$', "#next 67-67 Blade's Edge Turn-ins")
        $content = [regex]::Replace($content, '(?m)^#next\s+67-69 Netherstorm\s*\r?\n', '')
    }

    if ($content -match '(?m)^#name\s+69-70 Shadowmoon Valley \((?:Aldor|Scryer)\)\s*$') {
        $faction = if ($Guide.Group -eq 'RestedXP TBC Guide (A)') { 'A' } else { 'H' }
        $next = "RestedXP WotLK Guide ($faction)\70-72 Northrend"
        if ($content -match '(?m)^#next\s+') {
            $content = Set-HeaderValue $content 'next' $next
        } else {
            $content = [regex]::Replace($content, '(?m)^(#name\s+.*)$', "`$1`n#next $next", 1)
        }
    }

    $content = [regex]::Replace($content, '(?m)^step\s*\r?\n#optional\s*\r?\n\.isOnQuest\s+64038\s*$', "step << !ac335`n#optional`n.isOnQuest 64038")
    $content = Convert-WorldCoordinates $content
    if ($content -match '(?m)^\.(?:goto|groundgoto|flygoto|waypoint)\s+\d+/\d+,') {
        throw "World-space coordinate remained in $($Guide.Group) / $($Guide.Name)"
    }
    return $content.Trim("`r", "`n")
}

function Write-GuideFile([string]$Name, [object[]]$Guides, [int]$ExpectedCount) {
    if ($Guides.Count -ne $ExpectedCount) {
        throw "$Name expected $ExpectedCount guides, found $($Guides.Count)"
    }
    $parts = @(
        '-- Generated from RXPGuides v4.10.20 by tools/Build-TBCGuides335.ps1.'
        '-- Curated for the standalone 3.3.5a backport; do not replace with the upstream aggregate file.'
    )
    foreach ($guide in $Guides) {
        $content = Add-GuideNamespace (Repair-TBCGuide $guide)
        $parts += "RXPGuides.RegisterGuide([[`n$content`n]]);"
    }
    $path = Join-Path $OutputRoot $Name
    [IO.File]::WriteAllText($path, (($parts -join "`n") + "`n"), $utf8NoBom)
}

$sourceGuidePath = Join-Path $SourceRoot 'Guides\tbc\The Burning Crusade.lua'
$all = @(Get-GuideBlocks $sourceGuidePath)
$alliance = @($all | Where-Object { $_.Group -eq 'RestedXP TBC Guide (A)' -and $_.Name -notmatch 'Dungeon Cleave' })
$horde = @($all | Where-Object { $_.Group -eq 'RestedXP TBC Guide (H)' -and $_.Name -notmatch 'Dungeon Cleave' })
$allianceDungeons = @($all | Where-Object { $_.Group -eq 'RXP Dungeon Quest Guides (A)' })
$hordeDungeons = @($all | Where-Object { $_.Group -eq 'RestedXP Dungeon Quest Guides (H)' })
$reputation = @($all | Where-Object { $_.Group -eq 'RXP TBC Reputation Guide' })
$attunements = @(Get-GuideBlocks (Join-Path $SourceRoot 'Guides\tbc\Attunements.lua'))

# The TBC aggregate points WotLK clients at this Alliance cleanup chapter, but
# v4.10.20 stores the chapter in its Cataclysm aggregate.  Import that one
# missing bridge explicitly and retarget it to the curated TBC group.
$bladeEdgeTurnins = @(Get-GuideBlocks (Join-Path $SourceRoot 'Guides\cata\Cataclysm.lua') | Where-Object {
    $_.Group -eq 'RXP Cataclysm 60-80 (A)' -and $_.Name -eq "67-67 Blade's Edge Turn-ins"
})
if ($bladeEdgeTurnins.Count -ne 1) {
    throw "Expected one Alliance Blade's Edge turn-in bridge, found $($bladeEdgeTurnins.Count)"
}
$turninContent = $bladeEdgeTurnins[0].Content -replace "`r`n", "`n"
$turninContent = [regex]::Replace($turninContent, '(?m)^#(?:cata|mop|defaultfor)\b.*\n?', '')
$turninContent = [regex]::Replace($turninContent, '(?m)^#version\s+.*\n?', '')
$turninContent = $turninContent.Replace('#group RXP Cataclysm 60-80 (A)', "#version 9`n#ac335`n#group RestedXP TBC Guide (A)`n#subgroup RestedXP Alliance 60-70")
$turninContent = [regex]::Replace($turninContent, '(?m)^#next\s+.*$', '#next 67-69 Netherstorm')
$turninGuide = [pscustomobject]@{
    Group = 'RestedXP TBC Guide (A)'
    Name = "67-67 Blade's Edge Turn-ins"
    Content = $turninContent
}
$allianceOutput = @($alliance) + @($turninGuide)

[IO.Directory]::CreateDirectory($OutputRoot) | Out-Null
Write-GuideFile 'Alliance-Leveling.lua' $allianceOutput 31
Write-GuideFile 'Horde-Leveling.lua' $horde 26
Write-GuideFile 'Alliance-Dungeons.lua' $allianceDungeons 31
Write-GuideFile 'Horde-Dungeons.lua' $hordeDungeons 31
Write-GuideFile 'Reputation.lua' $reputation 12
Write-GuideFile 'Attunements.lua' $attunements 5

$total = $alliance.Count + $horde.Count + $allianceDungeons.Count + $hordeDungeons.Count + $reputation.Count + $attunements.Count
if ($total -ne 135) { throw "Expected 135 curated guides, generated $total" }
Write-Host "Generated $total TBC guides plus the WotLK Blade's Edge turn-in bridge and converted $worldCoordinateCount world-space coordinates."
