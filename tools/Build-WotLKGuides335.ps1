param(
    [string]$ZygorRoot = (Join-Path $PSScriptRoot "..\..\ZygorGuidesViewerRM"),
    [string]$OutputRoot = (Join-Path $PSScriptRoot "..\Guides\WotLK"),
    [string]$GroupPrefix = ''
)

$ErrorActionPreference = "Stop"
$utf8NoBom = New-Object Text.UTF8Encoding($false)
$guidePattern = [regex]'(?ms)ZygorGuidesViewer:RegisterGuide\("[^"]*\\Northrend \((70-72|72-74|74-76|76-78|78-80)\)",\[\[(.*?)\]\]\)'
$convertedSourceStepCount = 0

function Get-FlightLookups([string]$Faction) {
    $path = Join-Path $PSScriptRoot '..\DB\wotlk\flightData.lua'
    $text = [IO.File]::ReadAllText($path)
    $start = $text.IndexOf("addon.flightPath[`"$Faction`"]")
    if ($start -lt 0) { throw "Unable to find $Faction flight paths" }
    $other = if ($Faction -eq 'Alliance') { 'Horde' } else { 'FPDB' }
    $end = if ($Faction -eq 'Alliance') {
        $text.IndexOf('addon.flightPath["Horde"]', $start + 1)
    } else {
        $text.IndexOf('addon["FPDB"]', $start + 1)
    }
    if ($end -lt 0) { throw "Unable to find the end of $Faction flight paths" }
    $section = $text.Substring($start, $end - $start)
    $byFull = @{}
    $byBase = @{}
    foreach ($match in [regex]::Matches($section, '\[\d+\]\s*=\s*"([^"]+)"')) {
        $full = $match.Groups[1].Value
        $byFull[$full.ToLowerInvariant()] = $full
        $base = ($full -split ',')[0].Trim().ToLowerInvariant()
        if (-not $byBase.ContainsKey($base)) {
            $byBase[$base] = $full
        } elseif ($byBase[$base] -ne $full) {
            $byBase[$base] = $null
        }
    }
    return [pscustomobject]@{ Full = $byFull; Base = $byBase }
}

function Resolve-FlightName([string]$Name, $Lookup) {
    if (-not $Name) { return $null }
    $key = $Name.Trim().TrimEnd('.').ToLowerInvariant()
    $aliases = @{
        'westfall brigade encampment' = 'westfall brigade'
        "moa'ki harbor" = "moa'ki"
    }
    if ($aliases.ContainsKey($key)) { $key = $aliases[$key] }
    if ($Lookup.Full.ContainsKey($key)) { return $Lookup.Full[$key] }
    if ($Lookup.Base.ContainsKey($key) -and $Lookup.Base[$key]) { return $Lookup.Base[$key] }
    $partial = @($Lookup.Full.Values | Where-Object {
        $candidate = $_.ToLowerInvariant()
        $candidate.StartsWith($key) -or $candidate.Contains(", $key")
    } | Select-Object -Unique)
    if ($partial.Count -eq 1) { return $partial[0] }
    return $null
}

function Normalize-Zone([string]$Zone) {
    $zone = $Zone.Trim()
    switch ($zone) {
        'Storm Peaks' { return 'The Storm Peaks' }
        'Crystalsong' { return 'Crystalsong Forest' }
        default { return $zone }
    }
}

function Get-QuestReference([string]$Line) {
    $match = [regex]::Match($Line, '\|q\s*(\d+)(?:/(\d+))?')
    if (-not $match.Success) { return $null }
    return [pscustomobject]@{
        Id = [int]$match.Groups[1].Value
        Objective = if ($match.Groups[2].Success) { [int]$match.Groups[2].Value } else { $null }
    }
}

function Clean-EntityName([string]$Text) {
    $value = $Text -replace '\|.*$', ''
    $value = $value -replace '##\d+', ''
    $value = $value -replace '^\s*\d+\s+', ''
    $value = $value -replace '\+$', ''
    return $value.Trim()
}

function Clean-Narrative([string]$Text) {
    $value = $Text.Trim()
    $value = $value -replace '^\.+', ''
    $value = $value -replace "^'\s*", ''
    $value = $value -replace '\|tip\s*', ' - '
    $value = $value -replace '\|q\s*\d+(?:/\d+)?', ''
    $value = $value -replace '\|goto\s+[^|]*', ''
    $value = $value -replace '\|use\s+[^|]*', ''
    $value = $value -replace '\|buy\s+[^|]*', ''
    $value = $value -replace '\|collect\s+[^|]*', ''
    $value = $value -replace '\|goal\s+[^|]*', ''
    $value = $value -replace '\|kill\s+[^|]*', ''
    $value = $value -replace '\|get\s+[^|]*', ''
    $value = $value -replace '\|petaction\s+[^|]*', ''
    $value = $value -replace '\|havebuff\s+[^|]*', ''
    $value = $value -replace '\|nobuff\s+[^|]*', ''
    $value = $value -replace '\|script\s+[^|]*', ''
    $value = $value -replace '\|only\s+.*$', ''
    $value = $value -replace '\|(?:invehicle|outvehicle|noway|instant|sticky|future|n|c)\b', ''
    $value = $value -replace '##\d+', ''
    $value = $value -replace '\s+', ' '
    return $value.Trim(' ', '.', "`t")
}

function Add-GotoFromValue([Collections.Generic.List[string]]$Lines, [string]$Value, [ref]$CurrentZone, [switch]$AsZone) {
    $value = $Value.Trim()
    if ($value -match '^(-?\d+(?:\.\d+)?),\s*(-?\d+(?:\.\d+)?)(.*)$') {
        if (-not $CurrentZone.Value) { throw "Coordinate has no inherited zone: $Value" }
        $Lines.Add(".goto $($CurrentZone.Value),$($Matches[1]),$($Matches[2])$($Matches[3])")
        return
    }
    if ($value -match '^(.+?),\s*(-?\d+(?:\.\d+)?),\s*(-?\d+(?:\.\d+)?)(.*)$') {
        $zone = Normalize-Zone $Matches[1]
        $CurrentZone.Value = $zone
        $Lines.Add(".goto $zone,$($Matches[2]),$($Matches[3])$($Matches[4])")
        return
    }
    $zone = Normalize-Zone (($value -split ',')[0])
    if ($zone) {
        $CurrentZone.Value = $zone
        if ($AsZone) { $Lines.Add(".zone $zone") }
    }
}

function Add-QuestObjective([Collections.Generic.List[string]]$Lines, $Quest) {
    if ($Quest -and $null -ne $Quest.Objective) {
        $directive = ".complete $($Quest.Id),$($Quest.Objective)"
        if (-not $Lines.Contains($directive)) { $Lines.Add($directive) }
        return $true
    }
    return $false
}

function Add-PetActionMacros([Collections.Generic.List[string]]$Lines, [string]$SourceLine) {
    foreach ($match in [regex]::Matches($SourceLine, '\|petaction\s+([^|]+)')) {
        $action = $match.Groups[1].Value.Trim()
        if (-not $action) { continue }
        # RXP's active macro button is hardware-triggered and therefore safe on
        # 3.3.5.  /cast by localized action name works for pet and vehicle bars
        # without importing or executing any Zygor Lua snippets.
        $label = ($action -replace ',', '').Trim()
        $Lines.Add(".macro $label,134400 >>/cast $action")
    }
}

function Finalize-Step([Collections.Generic.List[string]]$Output, [Collections.Generic.List[string]]$StepLines) {
    if ($null -eq $StepLines) { return }
    $hasProgress = $false
    foreach ($line in $StepLines) {
        if ($line -match '^\.(?:accept|turnin|complete|collect|xp|zone|fp|fly|home|hs|vehicle|exitvehicle|aura|goto)\b') {
            $hasProgress = $true
            break
        }
    }
    if (-not $hasProgress) {
        for ($i = 0; $i -lt $StepLines.Count; $i++) {
            if ($StepLines[$i] -match '^>>(.*)$') {
                $StepLines[$i] = '+' + $Matches[1]
                break
            }
        }
    }
    $Output.Add('step')
    foreach ($line in $StepLines) { if ($line) { $Output.Add($line) } }
}

function Convert-Guide([string]$Body, [string]$Faction, [string]$LevelRange, $FlightLookup) {
    $output = New-Object 'Collections.Generic.List[string]'
    $stepLines = $null
    $currentZone = $null

    foreach ($raw in ($Body -split '\r?\n')) {
        $line = $raw.Trim()
        if (-not $line) { continue }
        if ($line.StartsWith('//')) { continue }
        if ($line -match '^step\b') {
            Finalize-Step $output $stepLines
            $stepLines = New-Object 'Collections.Generic.List[string]'
            continue
        }
        if ($null -eq $stepLines) { continue }

        $plain = $line -replace '^\.+', ''
        if ($plain -match '^goto\s+(.+)$') {
            $value = ($Matches[1] -split '\|')[0].Trim()
            Add-GotoFromValue $stepLines $value ([ref]$currentZone)
            continue
        }
        if ($plain -match '^accept\s+(.+?)##(\d+)') {
            $stepLines.Add(".accept $($Matches[2]) >> Accept $($Matches[1].Trim())")
            continue
        }
        if ($plain -match '^turnin\s+(.+?)##(\d+)') {
            $stepLines.Add(".turnin $($Matches[2]) >> Turn in $($Matches[1].Trim())")
            continue
        }
        if ($plain -match '^talk\s+(.+?)(?:##\d+)?$') {
            $stepLines.Add(".target $(Clean-EntityName $Matches[1])")
            continue
        }
        if ($plain -match '^fpath\s+(.+)$') {
            $requested = (($Matches[1] -split '\|')[0]).Trim()
            $resolved = Resolve-FlightName $requested $FlightLookup
            if (-not $resolved) { throw "Unknown or ambiguous $Faction flight path: $requested" }
            $stepLines.Add(".fp $resolved >> Get the $requested flight path")
            continue
        }
        if ($plain -match '^home\s+(.+)$') {
            $stepLines.Add(".home $($Matches[1].Trim()) >> Set your Hearthstone to $($Matches[1].Trim())")
            continue
        }
        if ($plain -match '^ding\s+(\d+)') {
            $stepLines.Add(".xp $($Matches[1])")
            continue
        }
        if ($plain -match '^use\s+.+?##(\d+)') {
            $stepLines.Add(".use $($Matches[1])")
            continue
        }
        if ($plain -match '^collect\s+(?:(\d+)\s+)?(.+?)##(\d+)') {
            $quantity = if ($Matches[1]) { [int]$Matches[1] } else { 1 }
            $itemId = [int]$Matches[3]
            $quest = Get-QuestReference $line
            $questId = if ($quest) { $quest.Id } else { 0 }
            $stepLines.Add(".collect $itemId,$quantity,$questId >> Collect $quantity $($Matches[2].Trim())")
            if ($line -match '\|future\b') { $stepLines.Insert(0, '#optional') }
            if ($line -match '\|sticky\b') { $stepLines.Insert(0, '#sticky') }
            continue
        }
        if ($plain -match '^buy\s+(.+)$') {
            $quest = Get-QuestReference $line
            $text = Clean-Narrative $plain
            if ($quest -and $null -ne $quest.Objective) { Add-QuestObjective $stepLines $quest | Out-Null }
            if ($text) { $stepLines.Add(">>Buy $text") }
            continue
        }
        if ($plain -match '^(kill|get|goal)\s+(.+)$') {
            $kind = $Matches[1]
            $subject = $Matches[2]
            $quest = Get-QuestReference $line
            Add-QuestObjective $stepLines $quest | Out-Null
            $name = Clean-EntityName $subject
            if ($kind -eq 'kill' -and $name) { $stepLines.Add(".mob $name") }
            $verb = if ($kind -eq 'kill') { 'Kill' } elseif ($kind -eq 'get') { 'Collect' } else { 'Complete' }
            if ($name) { $stepLines.Add(">>$verb $name") }
            continue
        }
        if ($plain -match '^from\s+(.+)$') {
            $name = Clean-EntityName $Matches[1]
            if ($name) {
                $stepLines.Add(".mob $name")
                $stepLines.Add(">>Kill $name")
            }
            continue
        }
        if ($plain -match '^info\s+(.+)$') {
            if ($line -match "\|only if skill\('([^']+)'\)>0") {
                $stepLines.Add(".skill $($Matches[1].ToLowerInvariant()),<1,1")
            }
            $text = Clean-Narrative $Matches[1]
            if ($text) { $stepLines.Add(">>$text") }
            continue
        }

        if ($plain.StartsWith("'")) {
            $quest = Get-QuestReference $line
            $gotoMatch = [regex]::Match($line, '\|goto\s+([^|]+)')
            $flyName = $null
            if ($line -match "(?i)^\.*'\s*Fly to\s+([^|]+)") {
                $flyName = Resolve-FlightName $Matches[1].Trim() $FlightLookup
            }
            if ($gotoMatch.Success) {
                if ($flyName) {
                    $stepLines.Add(".fly $flyName >> Fly to $($Matches[1].Trim())")
                    Add-GotoFromValue (New-Object 'Collections.Generic.List[string]') $gotoMatch.Groups[1].Value ([ref]$currentZone) -AsZone
                } else {
                    Add-GotoFromValue $stepLines $gotoMatch.Groups[1].Value ([ref]$currentZone) -AsZone
                }
            }
            foreach ($useMatch in [regex]::Matches($line, '\|use\s+[^|#]*##(\d+)')) {
                $itemId = [int]$useMatch.Groups[1].Value
                if ($itemId -eq 6948 -and $line -match "(?i)^\.*'\s*Hearth to\s+([^|]+)") {
                    $stepLines.Add(".hs >> Hearth to $($Matches[1].Trim())")
                } else {
                    $stepLines.Add(".use $itemId")
                }
            }
            foreach ($collectMatch in [regex]::Matches($line, '\|collect\s+(?:(\d+)\s+)?[^|#]*##(\d+)')) {
                $quantity = if ($collectMatch.Groups[1].Success) { [int]$collectMatch.Groups[1].Value } else { 1 }
                $questId = if ($quest) { $quest.Id } else { 0 }
                $stepLines.Add(".collect $($collectMatch.Groups[2].Value),$quantity,$questId")
            }
            if ($line -match '\|buy\s+1\s+Overcharged Capacitor') {
                $stepLines.Add('.collect 39682,1 >> Buy an Overcharged Capacitor')
            }
            if ($line -match '\|(?:goal|kill|get)\s+' -or $line -match '\|havebuff\s+') {
                Add-QuestObjective $stepLines $quest | Out-Null
            }
            if ($line -match '\|havebuff\s+INV_Misc_Head_Murloc_01') { $stepLines.Add('.aura 45278') }
            if ($line -match '\|nobuff\s+INV_Misc_Head_Murloc_01') { $stepLines.Add('.aura -45278') }
            Add-PetActionMacros $stepLines $line
            if ($line -match '\|invehicle\b') { $stepLines.Add('.vehicle') }
            if ($line -match '\|outvehicle\b' -or $line -match '\|script\s+VehicleExit\(\)') { $stepLines.Add('.exitvehicle') }
            if ($line -match '\|future\b') { $stepLines.Insert(0, '#optional') }
            if ($line -match '\|sticky\b') { $stepLines.Insert(0, '#sticky') }
            $text = Clean-Narrative $line
            if ($text) { $stepLines.Add(">>$text") }
            continue
        }

        if ($line -match '\|goto\s+([^|]+)') {
            Add-GotoFromValue $stepLines $Matches[1] ([ref]$currentZone)
            $text = Clean-Narrative $line
            if ($text) { $stepLines.Add(">>$text") }
            continue
        }

        throw "Unconverted Zygor line in $Faction $LevelRange`: $line"
    }
    Finalize-Step $output $stepLines
    return $output
}

function Build-FactionFile([string]$Faction, [string]$SourceFile) {
    $short = if ($Faction -eq 'Alliance') { 'A' } else { 'H' }
    $text = [IO.File]::ReadAllText($SourceFile)
    $matches = @($guidePattern.Matches($text))
    if ($matches.Count -ne 5) { throw "$Faction expected five Northrend guides, found $($matches.Count)" }
    $lookup = Get-FlightLookups $Faction
    $parts = New-Object 'Collections.Generic.List[string]'
    $parts.Add('-- Converted from the GPL-licensed ZygorGuidesViewerRM 3.3.5 leveling routes.')
    $parts.Add('-- This guide-data file remains GPL-licensed; conversion is offline and creates no runtime dependency.')
    for ($i = 0; $i -lt $matches.Count; $i++) {
        $range = $matches[$i].Groups[1].Value
        $body = $matches[$i].Groups[2].Value
        $converted = Convert-Guide $body $Faction $range $lookup
        $sourceSteps = [regex]::Matches($body, '(?m)^\s*step\b').Count
        $outputSteps = @($converted | Where-Object { $_ -eq 'step' }).Count
        if ($sourceSteps -ne $outputSteps) {
            throw "$Faction $range lost source steps during conversion ($sourceSteps -> $outputSteps)"
        }
        $script:convertedSourceStepCount += $sourceSteps
        $parts.Add('RXPGuides.RegisterGuide([[')
        $parts.Add('#wotlk')
        $parts.Add('#ac335')
        $parts.Add('#version 1')
        $parts.Add("#group ${GroupPrefix}RestedXP WotLK Guide ($short)")
        $parts.Add('#subgroup Northrend 70-80')
        $parts.Add("<< $Faction")
        $parts.Add("#name $range Northrend")
        if ($i -lt $matches.Count - 1) {
            $nextRange = $matches[$i + 1].Groups[1].Value
            $parts.Add("#next $nextRange Northrend")
        }
        foreach ($line in $converted) { $parts.Add($line) }
        $parts.Add(']]);')
    }
    $path = Join-Path $OutputRoot "$Faction-Leveling.lua"
    [IO.File]::WriteAllText($path, (($parts -join "`n") + "`n"), $utf8NoBom)
}

[IO.Directory]::CreateDirectory($OutputRoot) | Out-Null
Build-FactionFile 'Alliance' (Join-Path $ZygorRoot 'Guides\Leveling\ZygorGuidesAlliance.lua')
Build-FactionFile 'Horde' (Join-Path $ZygorRoot 'Guides\Leveling\ZygorGuidesHorde.lua')

if ($convertedSourceStepCount -ne 3426) {
    throw "Expected 3426 WotLK source steps, converted $convertedSourceStepCount"
}

$generated = [IO.File]::ReadAllText((Join-Path $OutputRoot 'Alliance-Leveling.lua')) + [IO.File]::ReadAllText((Join-Path $OutputRoot 'Horde-Leveling.lua'))
if ($generated -match '\|(?:q|goto|tip|use|goal|kill|get|petaction|havebuff|nobuff|script|invehicle|outvehicle)\b' -or $generated -match '##\d+') {
    throw 'Generated WotLK guides still contain Zygor syntax'
}
Write-Host 'Generated ten native WotLK 70-80 guides.'
