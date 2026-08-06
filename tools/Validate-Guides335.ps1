param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot '..\GuideList_335.xml'),
    [string]$QuestDbPath = (Join-Path $PSScriptRoot '..\..\ZygorGuidesViewerRM\ZygorQuestDB.lua'),
    [int]$MaxErrors = 200
)

$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$errors = New-Object 'Collections.Generic.List[string]'
$warnings = New-Object 'Collections.Generic.List[string]'
$guidePattern = [regex]'(?ms)RXPGuides\.RegisterGuide\(\[\[(.*?)\]\]\)\s*;?'

function Add-Error([string]$Message) { $errors.Add($Message) }

function Normalize-Group([string]$Group) {
    $group = ($Group -replace '\s*<<.*$', '').Trim().TrimStart('*')
    if ($group -match '^RestedXP Alliance') { return 'RestedXP Speedrun Guide (A)' }
    if ($group -match '^RestedXP Horde') { return 'RestedXP Speedrun Guide (H)' }
    return $group
}

function Get-GuideHeader([string]$Content, [string]$Name) {
    $match = [regex]::Match($Content, "(?m)^#" + [regex]::Escape($Name) + "\s+(.+?)\s*$")
    if ($match.Success) { return ($match.Groups[1].Value -replace '\s*<<.*$', '').Trim() }
    return $null
}

function Get-FlightData([string]$Faction) {
    $path = Join-Path $root 'DB\wotlk\flightData.lua'
    $text = [IO.File]::ReadAllText($path)
    $start = $text.IndexOf("addon.flightPath[`"$Faction`"]")
    $end = if ($Faction -eq 'Alliance') {
        $text.IndexOf('addon.flightPath["Horde"]', $start + 1)
    } else {
        $text.IndexOf('addon["FPDB"]', $start + 1)
    }
    $full = @{}
    $base = @{}
    foreach ($match in [regex]::Matches($text.Substring($start, $end - $start), '\[\d+\]\s*=\s*"([^"]+)"')) {
        $name = $match.Groups[1].Value
        $full[$name.ToLowerInvariant()] = $name
        $baseName = ($name -split ',')[0].Trim().ToLowerInvariant()
        if (-not $base.ContainsKey($baseName)) { $base[$baseName] = $name }
        elseif ($base[$baseName] -ne $name) { $base[$baseName] = $null }
    }
    return [pscustomobject]@{ Full = $full; Base = $base }
}

function Resolve-Flight([string]$Name, $Data) {
    $key = $Name.Trim().ToLowerInvariant()
    if ($Data.Full.ContainsKey($key)) { return $Data.Full[$key] }
    if ($Data.Base.ContainsKey($key) -and $Data.Base[$key]) { return $Data.Base[$key] }
    $partial = @($Data.Full.Values | Where-Object {
        $_.ToLowerInvariant().Contains($key)
    } | Select-Object -Unique)
    if ($partial.Count -eq 1) { return $partial[0] }
    return $null
}

function Get-GuideCondition([string]$Line) {
    $match = [regex]::Match($Line, '<<\s*(.*?)(?=\s*>>|$)')
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    return ''
}

function Test-ExcludedOn335([string]$Condition) {
    if (-not $Condition) { return $false }
    if ($Condition -match '(^|\s)!ac335(\s|$)') { return $true }
    if ($Condition -match '(^|\s)!wotlk(\s|$)') { return $true }
    if ($Condition -match '(^|\s)skip(\s|$)') { return $true }
    if ($Condition -match '(^|\s)tbc(\s|$)' -and $Condition -notmatch '(^|\s)wotlk(\s|$)') { return $true }
    if ($Condition -match '^\s*!?(?:Worgen|Goblin)(?:\s+!?(?:Worgen|Goblin))*\s*$') { return $true }
    return $false
}

$manifest = [IO.File]::ReadAllText([IO.Path]::GetFullPath($ManifestPath))
$files = New-Object 'Collections.Generic.List[string]'
foreach ($match in [regex]::Matches($manifest, '<Script\s+file="([^"]+)"\s*/>')) {
    $relative = $match.Groups[1].Value -replace '\\', [IO.Path]::DirectorySeparatorChar
    $path = [IO.Path]::GetFullPath((Join-Path $root $relative))
    if (-not [IO.File]::Exists($path)) { Add-Error "Manifest file is missing: $relative"; continue }
    $files.Add($path)
}

# Compatibility packs are resolver-time data, but they can still make an
# otherwise valid guide unusable. Validate the bundled data-only baseline next
# to the guide manifest so CI cannot ship an executable or malformed pack.
$packPath = Join-Path $root 'DB\wotlk\compatibilityPacks_335.lua'
if (-not [IO.File]::Exists($packPath)) {
    Add-Error 'Bundled compatibility-pack baseline is missing.'
} else {
    $packInfo = Get-Item -LiteralPath $packPath
    $packText = [IO.File]::ReadAllText($packPath)
    if ($packInfo.Length -gt 262144) { Add-Error 'Bundled compatibility pack exceeds 256 KB.' }
    if ($packText -match '(?m)\b(?:load|string\.dump|loadstring|dofile|require|setfenv|getfenv)\s*\(') {
        Add-Error 'Compatibility packs must be data-only and cannot execute or load Lua.'
    }
    if ($packText -notmatch '(?m)^\s*schema\s*=\s*1\s*,?\s*$') { Add-Error 'Compatibility pack schema must be 1.' }
    if ($packText -notmatch '(?m)^\s*id\s*=\s*"[a-z0-9][a-z0-9._-]{0,79}"\s*,?\s*$') { Add-Error 'Compatibility pack ID is missing or malformed.' }
    if ($packText -notmatch '(?m)^\s*version\s*=\s*[1-9]\d*\s*,?\s*$') { Add-Error 'Compatibility pack version is missing or malformed.' }
    $allowedPackFields = @{
        schema=$true; id=$true; name=$true; version=$true; core=$true; minAddon=$true
        questPrerequisites=$true; questAvailability=$true; targetAliases=$true; flightAliases=$true
        mapAliases=$true; guideOverrides=$true; eventQuirks=$true; resetPolicy=$true
    }
    foreach ($match in [regex]::Matches($packText, '(?m)^\s{4}([A-Za-z][A-Za-z0-9]*)\s*=')) {
        $field = $match.Groups[1].Value
        if (-not $allowedPackFields.ContainsKey($field)) {
            Add-Error "Unknown compatibility-pack root field: $field"
        }
    }
}

$mapNames = @{}
$mapIds = @{}
foreach ($line in [IO.File]::ReadLines((Join-Path $root 'DB\wotlk\db.lua'))) {
    if ($line -match '^\s*\["([^"]+)"\]\s*=\s*(\d+)') {
        $mapNames[$Matches[1].ToLowerInvariant()] = [int]$Matches[2]
        $mapIds[[int]$Matches[2]] = $true
    }
}

# 3.3.5a has no C_Map.GetAreaInfo API. The compatibility bridge therefore
# ships the AreaTable names used by loaded guides; fail validation when new
# guide content references an area that was not added to that bridge.
$areaIds = @{}
$areaText = [IO.File]::ReadAllText((Join-Path $root 'libs\HBD335\HereBeDragons-335.lua'))
$areaBlock = [regex]::Match($areaText, '(?s)local legacyAreaNames\s*=\s*\{(.*?)\n\}')
foreach ($match in [regex]::Matches($areaBlock.Groups[1].Value, '\[(\d+)\]\s*=\s*"')) {
    $areaIds[[int]$match.Groups[1].Value] = $true
}

$functionNames = @{}
foreach ($line in [IO.File]::ReadLines((Join-Path $root 'functions.lua'))) {
    if ($line -match 'addon\.functions(?:\.|\[["''])([A-Za-z0-9_]+)') { $functionNames[$Matches[1]] = $true }
}
foreach ($name in @('goto','subzone','turn','talent','scenario')) { $functionNames[$name] = $true }

$knownHeaders = @{}
foreach ($name in @(
    'ac335','ah','aldor','cata','chapter','classic','completewith','completewithTBTurnins',
    'defaultfor','disabled','displayname','era','flyable','fresh','group','groupweight','hardcore',
    'hardcoreserver','hidewindow','icon','ignorecorpse','include','internal','label','level','level20',
    'loop','map','maxLevel','minLevel','mop','name','next','noflyable','optional','order','phase',
    'qremove','questguide','require','requires','reset','retail','scryer','season','softcore',
    'softcoreserver','som','ssf','sticky','subgroup','subweight','tbc','timer','tip','title',
    'version','veteran','wotlk','xprate','EndIncludePrepGuide'
)) { $knownHeaders[$name] = $true }

$questIds = @{}
$questNames = @{}
if ([IO.File]::Exists($QuestDbPath)) {
    foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($QuestDbPath))) {
        if ($line -match '^\s*\[(\d+)\]\s*=') {
            $questId = [int]$Matches[1]
            $questIds[$questId] = $true
            if ($line -match '^\s*\[\d+\]\s*=\s*"(.*)",\s*$') {
                $questNames[$questId] = (($Matches[1] -replace '\\"', '"' -replace '\\\\', '\').Trim())
            }
        }
    }
} else {
    $warnings.Add("Quest reference not found; quest-ID validation skipped: $QuestDbPath")
}

$allianceFlights = Get-FlightData 'Alliance'
$hordeFlights = Get-FlightData 'Horde'
$guides = New-Object 'Collections.Generic.List[object]'
$keys = @{}
$guideCount = 0
$stepCount = 0

foreach ($file in $files) {
    $relative = $file.Substring($root.Length).TrimStart('\')
    $text = [IO.File]::ReadAllText($file)
    if ($text -match '(?m)^\s*print\s*\(') { Add-Error "$relative contains a debug print" }
    if ($text -match 'RXP\.enabledLocale') { Add-Error "$relative contains the unsupported modern guide-locale guard" }
    if ($text -match 'ZygorGuidesViewer:RegisterGuide|\|(?:q|goto|tip|petaction|havebuff|nobuff|script|invehicle|outvehicle)\b|##\d+') {
        Add-Error "$relative contains unconverted Zygor syntax"
    }
    foreach ($match in $guidePattern.Matches($text)) {
        $guideCount++
        $content = $match.Groups[1].Value -replace "`r`n", "`n"
        $groupRaw = Get-GuideHeader $content 'group'
        $name = Get-GuideHeader $content 'name'
        $subgroup = Get-GuideHeader $content 'subgroup'
        if (-not $groupRaw -or -not $name) { Add-Error "$relative contains a guide without #group or #name"; continue }
        $isOriginalSnapshot = $groupRaw.TrimStart('+', '*').StartsWith('Original Guides - ')
        $group = Normalize-Group $groupRaw
        $xprate = Get-GuideHeader $content 'xprate'
        $topCondition = ([regex]::Match($content, '(?m)^<<\s*(.+?)\s*$').Groups[1].Value).Trim()
        $signature = "$group|$subgroup|$name|$xprate|$topCondition"
        if ($keys.ContainsKey($signature)) { Add-Error "Duplicate guide key: $group / $subgroup / $name" }
        else { $keys[$signature] = $true }
        $aliases = @([regex]::Matches($content, '(?m)^#name\s+(.+?)\s*$') | ForEach-Object {
            ($_.Groups[1].Value -replace '\s*<<.*$', '').Trim()
        } | Select-Object -Unique)
        $guides.Add([pscustomobject]@{ Group = $group; Name = $name; Names = $aliases; Subgroup = $subgroup; RawGroup = $groupRaw; Content = $content; File = $relative })

        $skipAc335 = $false
        $stepCondition = ''
        $lineNumber = 0
        foreach ($lineRaw in ($content -split "`n")) {
            $lineNumber++
            $line = $lineRaw.Trim()
            if (-not $line) { continue }
            if ($line -match '^step\b') {
                $stepCount++
                $stepCondition = Get-GuideCondition $line
                $skipAc335 = Test-ExcludedOn335 $stepCondition
                continue
            }
            if ($line -match '^#([A-Za-z][A-Za-z0-9_]*)') {
                if (-not $knownHeaders.ContainsKey($Matches[1])) { Add-Error "$relative`:$lineNumber unknown header #$($Matches[1])" }
                continue
            }
            if ($line -match '^(accept|acceptmultiple|turnin|turninmultiple|complete|abandon|goto|groundgoto|flygoto|waypoint|pin|zone|zoneskip|subzone|subzoneskip|hs|use|target|mob)\b') {
                Add-Error "$relative`:$lineNumber directive .$($Matches[1]) is missing its leading dot"
                continue
            }
            if ($line -match '^\.([A-Za-z][A-Za-z0-9_]*)\b') {
                $directive = $Matches[1]
                if (-not $functionNames.ContainsKey($directive)) { Add-Error "$relative`:$lineNumber unknown directive .$directive"; continue }
                $lineCondition = Get-GuideCondition $line
                if ($skipAc335 -or (Test-ExcludedOn335 $lineCondition)) { continue }
                if (-not $isOriginalSnapshot -and $directive -eq 'accept' -and $line -notmatch '>>\s*\S') {
                    # Offered quests have no numeric ID in the 3.3.5 gossip API.
                    # Authored title text is the standalone fallback when the
                    # server has not cached the name before acceptance.
                    Add-Error "$relative`:$lineNumber .accept requires authored quest-title text on 3.3.5"
                }
                if (-not $isOriginalSnapshot -and $directive -eq 'accept' -and $line -match '^\.accept\s+(\d+)\b.*?>>\s*(.*?)(?:\s*<<.*)?(?:\s*--.*)?\s*$') {
                    $acceptQuestId = [int]$Matches[1]
                    $authoredTitle = ($Matches[2].Trim() -replace '^Accept\s+', '')
                    if ($questNames.ContainsKey($acceptQuestId) -and
                        $authoredTitle -cne $questNames[$acceptQuestId]) {
                        Add-Error "$relative`:$lineNumber .accept title '$authoredTitle' does not match quest $acceptQuestId ('$($questNames[$acceptQuestId])')"
                    }
                }
                if ($directive -in @('goto','groundgoto','flygoto','waypoint','pin')) {
                    if ($line -match '^\.(?:goto|groundgoto|flygoto|waypoint|pin)\s+([^,>]+),\s*(-?\d+(?:\.\d+)?),\s*(-?\d+(?:\.\d+)?)') {
                        $zone = (($Matches[1].Trim() -split ',')[0]).Trim()
                        $x = [double]$Matches[2]
                        $y = [double]$Matches[3]
                        if ($zone -match '/') { Add-Error "$relative`:$lineNumber contains an unconverted world-space coordinate" }
                        elseif ($zone -match '^\d+$') {
                            if (-not $mapIds.ContainsKey([int]$zone)) { Add-Error "$relative`:$lineNumber unknown numeric map $zone" }
                        } elseif (-not $mapNames.ContainsKey($zone.ToLowerInvariant())) {
                            Add-Error "$relative`:$lineNumber unknown map alias $zone"
                        }
                        if ($x -lt 0 -or $x -gt 100 -or $y -lt 0 -or $y -gt 100) { Add-Error "$relative`:$lineNumber coordinate outside 0-100: $x,$y" }
                    } elseif ($line -match '^\.(?:goto|groundgoto|flygoto|waypoint|pin)\s+\d+/\d+,') {
                        Add-Error "$relative`:$lineNumber contains an unconverted world-space coordinate"
                    } else {
                        Add-Error "$relative`:$lineNumber malformed .$directive coordinate"
                    }
                }
                if ($directive -in @('zone','zoneskip')) {
                    if ($line -match '^\.(?:zone|zoneskip)\s+(.+?)(?=\s*>>|\s*<<|$)') {
                        $zone = (($Matches[1].Trim() -split ',')[0]).Trim()
                        if ($zone -match '^\d+$') {
                            if (-not $mapIds.ContainsKey([int]$zone)) { Add-Error "$relative`:$lineNumber unknown numeric .$directive map $zone" }
                        } elseif (-not $mapNames.ContainsKey($zone.ToLowerInvariant())) {
                            Add-Error "$relative`:$lineNumber unknown .$directive map $zone"
                        }
                    } else {
                        Add-Error "$relative`:$lineNumber malformed .$directive map"
                    }
                }
                if ($directive -in @('subzone','subzoneskip','bindlocation')) {
                    if ($line -match '^\.(?:subzone|subzoneskip|bindlocation)\s+(\d+)') {
                        $areaId = [int]$Matches[1]
                        if (-not $areaIds.ContainsKey($areaId)) {
                            Add-Error "$relative`:$lineNumber unknown 3.3.5 area ID $areaId for .$directive"
                        }
                    } else {
                        Add-Error "$relative`:$lineNumber malformed .$directive area ID"
                    }
                }
                if ($line -match '^\.line\s+([^,]+),(.*?)(?:\s*<<|\s*>>|$)') {
                    $zone = $Matches[1].Trim()
                    $values = @($Matches[2].Split(',') | ForEach-Object { $_.Trim() })
                    if ($values.Count -lt 4 -or ($values.Count % 2) -ne 0) { Add-Error "$relative`:$lineNumber malformed .line coordinate pairs" }
                    else {
                        foreach ($value in $values) {
                            $number = 0.0
                            if (-not [double]::TryParse($value, [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$number) -or $number -lt 0 -or $number -gt 100) {
                                Add-Error "$relative`:$lineNumber malformed .line value $value"
                            }
                        }
                    }
                    if ($zone -match '^\d+$') {
                        if (-not $mapIds.ContainsKey([int]$zone)) { Add-Error "$relative`:$lineNumber unknown numeric .line map $zone" }
                    } elseif (-not $mapNames.ContainsKey($zone.ToLowerInvariant())) {
                        Add-Error "$relative`:$lineNumber unknown .line map $zone"
                    }
                }
                if (-not $isOriginalSnapshot -and $directive -eq 'loop') {
                    if ($line -match '^\.loop\s+[+*@]?\d+(?:\.\d+)?,\s*([^,]+),(.*?)(?:\s*<<|\s*>>|$)') {
                        $loopZone = $Matches[1].Trim()
                        $loopValues = @($Matches[2].Split(',') | ForEach-Object { $_.Trim() })
                        if ($loopValues.Count -lt 4 -or ($loopValues.Count % 2) -ne 0) {
                            Add-Error "$relative`:$lineNumber malformed .loop coordinate pairs"
                        } else {
                            foreach ($value in $loopValues) {
                                $number = 0.0
                                if (-not [double]::TryParse($value, [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$number) -or $number -lt 0 -or $number -gt 100) {
                                    Add-Error "$relative`:$lineNumber malformed .loop value '$value'"
                                }
                            }
                        }
                        if ($loopZone -match '^\d+$') {
                            if (-not $mapIds.ContainsKey([int]$loopZone)) { Add-Error "$relative`:$lineNumber unknown numeric .loop map $loopZone" }
                        } elseif (-not $mapNames.ContainsKey($loopZone.ToLowerInvariant())) {
                            Add-Error "$relative`:$lineNumber unknown .loop map $loopZone"
                        }
                    } else {
                        Add-Error "$relative`:$lineNumber malformed .loop route"
                    }
                }
                if (-not $isOriginalSnapshot -and $questIds.Count -gt 0 -and $line -match '^\.(accept|turnin|complete|abandon|isOnQuest|isNotOnQuest|isQuestAvailable|isQuestComplete|isQuestNotComplete|isQuestTurnedIn|skipOnQuest|acceptmultiple)\s+([^>]+)') {
                    $questDirective = $Matches[1]
                    $questArgs = ($Matches[2] -replace '\s*--.*$', '')
                    $numbers = @([regex]::Matches($questArgs, '(?<![.\d])\d+(?![.\d])') | ForEach-Object { [int]$_.Value })
                    if ($questDirective -notin @('isQuestAvailable','acceptmultiple') -and $numbers.Count -gt 1) { $numbers = @($numbers[0]) }
                    foreach ($questId in $numbers) {
                        if ($questId -gt 0 -and -not $questIds.ContainsKey($questId)) { Add-Error "$relative`:$lineNumber quest $questId is absent from the 3.3.5 reference" }
                    }
                }
                if (-not $isOriginalSnapshot -and $line -match '^\.(fp|fly)\s+(.+?)(?:\s*>>|\s*<<|$)') {
                    $destination = $Matches[2].Trim()
                    if (-not $destination -or $destination.StartsWith('>>')) { continue }
                    $activeCondition = "$stepCondition $lineCondition"
                    $factions = if ($activeCondition -match '\bAlliance\b' -and $activeCondition -notmatch '\bHorde\b') {
                        @('Alliance')
                    } elseif ($activeCondition -match '\bHorde\b' -and $activeCondition -notmatch '\bAlliance\b') {
                        @('Horde')
                    } elseif ($group -match '\(A\)$' -or $topCondition -match '\bAlliance\b') {
                        @('Alliance')
                    } elseif ($group -match '\(H\)$' -or $topCondition -match '\bHorde\b') {
                        @('Horde')
                    } else {
                        @('Alliance','Horde')
                    }
                    foreach ($faction in $factions) {
                        $data = if ($faction -eq 'Alliance') { $allianceFlights } else { $hordeFlights }
                        if (-not (Resolve-Flight $destination $data)) { Add-Error "$relative`:$lineNumber unresolved or ambiguous $faction flight destination: $destination" }
                    }
                }
            }
        }
    }
}

$guideIndex = @{}
foreach ($guide in $guides) {
    foreach ($guideName in $guide.Names) { $guideIndex["$($guide.Group)|$guideName"] = $true }
}
foreach ($guide in $guides) {
    if ($guide.RawGroup.TrimStart('+', '*').StartsWith('Original Guides - ')) { continue }
    foreach ($match in [regex]::Matches($guide.Content, '(?m)^#next\s+(.+?)\s*$')) {
        $rawNext = $match.Groups[1].Value
        $condition = ([regex]::Match($rawNext, '<<\s*(.+)$').Groups[1].Value).Trim()
        if ($condition -match '!wotlk|\bcata\b|\bmop\b') { continue }
        $nextValue = ($rawNext -replace '\s*<<.*$', '').Trim()
        foreach ($candidateRaw in ($nextValue -split ';')) {
            $candidate = $candidateRaw.Trim()
            if (-not $candidate) { continue }
            if ($guide.RawGroup -match '^RestedXP (Alliance|Horde)' -and
                $candidate -notmatch '^RestedXP (?:TBC|WotLK) Guide \([AH]\)\\') {
                $candidate = $candidate -replace '^.*?\\', ''
            }
            if ($candidate -match '^(.*?)\\(.+)$') { $targetGroup = Normalize-Group $Matches[1]; $targetName = $Matches[2].Trim() }
            else { $targetGroup = $guide.Group; $targetName = $candidate }
            if (-not $guideIndex.ContainsKey("$targetGroup|$targetName")) { Add-Error "$($guide.File) dangling #next from $($guide.Name) to $targetGroup / $targetName" }
        }
    }
}

foreach ($warning in $warnings) { Write-Warning $warning }
if ($errors.Count -gt 0) {
    foreach ($errorText in ($errors | Select-Object -First $MaxErrors)) { Write-Host "ERROR: $errorText" -ForegroundColor Red }
    if ($errors.Count -gt $MaxErrors) { Write-Host "... $($errors.Count - $MaxErrors) additional error(s) omitted." -ForegroundColor Red }
    throw "Guide validation failed with $($errors.Count) error(s)."
}
Write-Host "Guide validation passed: $($files.Count) files, $guideCount guides, $stepCount steps." -ForegroundColor Green
