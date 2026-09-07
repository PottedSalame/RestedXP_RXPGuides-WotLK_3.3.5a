param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot '..\GuideList_335.xml'),
    [string]$QuestDbPath = (Join-Path $PSScriptRoot '..\..\ZygorGuidesViewerRM\ZygorQuestDB.lua'),
    [int]$MaxErrors = 200
)

$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$errors = New-Object 'Collections.Generic.List[string]'
$warnings = New-Object 'Collections.Generic.List[string]'
$regexOptions = [Text.RegularExpressions.RegexOptions]::Compiled -bor
    [Text.RegularExpressions.RegexOptions]::CultureInvariant
$regexOptionsIgnoreCase = $regexOptions -bor
    [Text.RegularExpressions.RegexOptions]::IgnoreCase
$guidePattern = [regex]::new(
    '(?ms)RXPGuides\.RegisterGuide\(\[\[(.*?)\]\]\)\s*;?', $regexOptions)
$guideMetadataHeaderPattern = [regex]::new(
    '(?m)^#(?<header>group|name|subgroup|xprate|defaultfor)\s+(?<value>.+?)\s*$',
    $regexOptions)
$firstStepPattern = [regex]::new('(?m)^step\b', $regexOptionsIgnoreCase)
$topConditionPattern = [regex]::new('(?m)^<<\s*(.+?)\s*$', $regexOptions)
$nextHeaderPattern = [regex]::new('^#next\s+(.+?)\s*$', $regexOptions)
$stepLinePattern = [regex]::new('^step\b', $regexOptionsIgnoreCase)
$headerLinePattern = [regex]::new('^#([A-Za-z][A-Za-z0-9_]*)', $regexOptions)
$missingDotDirectivePattern = [regex]::new(
    '^(accept|acceptmultiple|turnin|turninmultiple|complete|abandon|goto|groundgoto|flygoto|waypoint|pin|zone|zoneskip|subzone|subzoneskip|hs|use|target|mob)\b',
    $regexOptionsIgnoreCase)
$directiveLinePattern = [regex]::new('^\.([A-Za-z][A-Za-z0-9_]*)\b', $regexOptions)
$guardAcceptPattern = [regex]::new(
    '^\.(isOnQuest|isQuestComplete|accept)\s+(-?\d+)\b', $regexOptionsIgnoreCase)
$completeObjectivePattern = [regex]::new(
    '^\.complete\s+-?(?<quest>\d+)\s*,\s*(?<objective>\d+)(?<tail>.*)$',
    $regexOptionsIgnoreCase)
$objectiveTargetPattern = [regex]::new(
    '^\.(?:mob|unitscan|target)\s+\+?\S', $regexOptionsIgnoreCase)
$objectiveCommentPattern = [regex]::new('--\s*\S', $regexOptions)
$conditionPattern = [regex]::new('<<\s*(.*?)(?=\s*>>|$)', $regexOptions)
$excluded335Pattern = [regex]::new(
    '(^|\s)(?:!ac335|!wotlk|skip)(\s|$)', $regexOptionsIgnoreCase)
$tbcConditionPattern = [regex]::new('(^|\s)tbc(\s|$)', $regexOptionsIgnoreCase)
$wotlkConditionPattern = [regex]::new('(^|\s)wotlk(\s|$)', $regexOptionsIgnoreCase)
$unsupportedRacePattern = [regex]::new(
    '^\s*!?(?:Worgen|Goblin)(?:\s+!?(?:Worgen|Goblin))*\s*$',
    $regexOptionsIgnoreCase)
$flightEntryPattern = [regex]::new('\[\d+\]\s*=\s*\x22([^\x22]+)\x22', $regexOptions)
$coordinateDirectives = @{ goto=$true; groundgoto=$true; flygoto=$true; waypoint=$true; pin=$true }
$runtimeCoordinateDirectives = @{ goto=$true; groundgoto=$true; flygoto=$true }
$zoneDirectives = @{ zone=$true; zoneskip=$true }
$areaDirectives = @{ subzone=$true; subzoneskip=$true; bindlocation=$true }
$hearthDirectives = @{ hs=$true; hsbatching=$true }
$fileTextCache = @{}

function Add-Error([string]$Message) { $errors.Add($Message) }

function Normalize-Group([string]$Group) {
    $group = ($Group -replace '\s*<<.*$', '').Trim().TrimStart('*')
    if ($group -match '^RestedXP Alliance') { return 'RestedXP Speedrun Guide (A)' }
    if ($group -match '^RestedXP Horde') { return 'RestedXP Speedrun Guide (H)' }
    return $group
}

function Resolve-GuideTransitionCandidate(
    [string]$SourceGroup,
    [string]$SourceRawGroup,
    [string]$CandidateRaw
) {
    $candidate = $CandidateRaw.Trim()
    if (-not $candidate) { return $null }

    # Every candidate is independent. In particular, an unqualified fallback
    # after a qualified candidate must resolve in the source guide's group.
    $targetGroup = $SourceGroup
    $targetName = $candidate
    if ($SourceRawGroup -match '^RestedXP (Alliance|Horde)' -and
        $candidate -notmatch '^RestedXP (?:TBC|WotLK) Guide \([AH]\)\\') {
        $candidate = $candidate -replace '^.*?\\', ''
        $targetName = $candidate
    }
    if ($candidate -match '^(.*?)\\(.+)$') {
        $targetGroup = Normalize-Group $Matches[1]
        $targetName = $Matches[2].Trim()
    }
    return [pscustomobject]@{
        Group = $targetGroup
        Name = $targetName
    }
}

function Normalize-NextHeader([string]$Header) {
    $value = $Header.Trim()
    $conditionMatch = [regex]::Match($value, '<<\s*(.+)$')
    $condition = if ($conditionMatch.Success) {
        ($conditionMatch.Groups[1].Value.Trim() -replace '\s+', ' ')
    } else {
        ''
    }
    $destination = ($value -replace '\s*<<.*$', '').Trim()
    if ($condition) { return ($destination + ' << ' + $condition) }
    return $destination
}

function Get-FlightData([string]$Faction, [string]$Text) {
    $text = $Text
    $start = $text.IndexOf("addon.flightPath[`"$Faction`"]")
    $end = if ($Faction -eq 'Alliance') {
        $text.IndexOf('addon.flightPath["Horde"]', $start + 1)
    } else {
        $text.IndexOf('addon["FPDB"]', $start + 1)
    }
    $full = @{}
    $base = @{}
    foreach ($match in $flightEntryPattern.Matches($text.Substring($start, $end - $start))) {
        $name = $match.Groups[1].Value
        $full[$name.ToLowerInvariant()] = $name
        $comma = $name.IndexOf(',')
        $baseName = if ($comma -ge 0) { $name.Substring(0, $comma) } else { $name }
        $baseName = $baseName.Trim().ToLowerInvariant()
        if (-not $base.ContainsKey($baseName)) { $base[$baseName] = $name }
        elseif ($base[$baseName] -ne $name) { $base[$baseName] = $null }
    }
    return [pscustomobject]@{ Faction = $Faction; Full = $full; Base = $base; Cache = @{} }
}

function Resolve-Flight([string]$Name, $Data) {
    $key = $Name.Trim().ToLowerInvariant()
    if ($Data.Cache.ContainsKey($key)) {
        return $Data.Cache[$key]
    }
    if ($Data.Full.ContainsKey($key)) {
        $Data.Cache[$key] = $Data.Full[$key]
        return $Data.Full[$key]
    }
    if ($Data.Base.ContainsKey($key) -and $Data.Base[$key]) {
        $Data.Cache[$key] = $Data.Base[$key]
        return $Data.Base[$key]
    }
    $partial = $null
    foreach ($candidateKey in $Data.Full.Keys) {
        if (-not $candidateKey.Contains($key)) { continue }
        $candidate = $Data.Full[$candidateKey]
        if ($null -ne $partial -and $partial -ne $candidate) {
            $Data.Cache[$key] = $null
            return $null
        }
        $partial = $candidate
    }
    $Data.Cache[$key] = $partial
    if ($partial) { return $partial }
    return $null
}

function Get-GuideCondition([string]$Line) {
    $match = $conditionPattern.Match($Line)
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    return ''
}

function Test-ExcludedOn335([string]$Condition) {
    if (-not $Condition) { return $false }
    if ($excluded335Pattern.IsMatch($Condition)) { return $true }
    if ($tbcConditionPattern.IsMatch($Condition) -and
        -not $wotlkConditionPattern.IsMatch($Condition)) { return $true }
    if ($unsupportedRacePattern.IsMatch($Condition)) { return $true }
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

# The runtime surface is the authoritative directive and guide-key contract.
# Reading it here also captures handlers owned by database modules, which are
# intentionally outside Guide/Directives/Handlers.lua after the refactor.
$surfacePath = Join-Path $root 'tests/runtime-surface.json'
$surface = [IO.File]::ReadAllText($surfacePath) | ConvertFrom-Json
$functionNames = @{}
foreach ($name in @($surface.directives) + @($surface.directiveAliases)) {
    $functionNames[[string]$name] = $true
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

$flightDataText = [IO.File]::ReadAllText((Join-Path $root 'DB\wotlk\flightData.lua'))
$allianceFlights = Get-FlightData 'Alliance' $flightDataText
$hordeFlights = Get-FlightData 'Horde' $flightDataText
$guides = New-Object 'Collections.Generic.List[object]'
$keys = @{}
$guideCount = 0
$stepCount = 0
$guardErrors = New-Object 'Collections.Generic.List[string]'
$objectiveContext = @{}
$objectiveReferences = @{}

foreach ($file in $files) {
    $relative = $file.Substring($root.Length).TrimStart([char[]]@('\', '/'))
    $text = [IO.File]::ReadAllText($file)
    $fileTextCache[$file] = $text
    if ($text -match '(?m)^\s*print\s*\(') { Add-Error "$relative contains a debug print" }
    if ($text -match 'RXP\.enabledLocale') { Add-Error "$relative contains the unsupported modern guide-locale guard" }
    if ($text -match 'ZygorGuidesViewer:RegisterGuide|\|(?:q|goto|tip|petaction|havebuff|nobuff|script|invehicle|outvehicle)\b|##\d+') {
        Add-Error "$relative contains unconverted Zygor syntax"
    }
    foreach ($match in $guidePattern.Matches($text)) {
        $guideCount++
        $content = $match.Groups[1].Value -replace "`r`n", "`n"
        # Guide identity is defined only by the metadata preamble. Headers
        # inside steps (notably #xprate route branches) must not rename the
        # guide or alter its saved-progress compatibility signature.
        $firstStep = $firstStepPattern.Match($content)
        $metadata = if ($firstStep.Success) {
            $content.Substring(0, $firstStep.Index)
        } else {
            $content
        }
        $headers = @{}
        $aliases = New-Object 'Collections.Generic.List[string]'
        $aliasSet = @{}
        foreach ($headerMatch in $guideMetadataHeaderPattern.Matches($metadata)) {
            $headerName = $headerMatch.Groups['header'].Value
            $headerValue = $headerMatch.Groups['value'].Value.Trim()
            $conditionOffset = $headerValue.IndexOf('<<')
            if ($conditionOffset -ge 0) {
                $headerValue = $headerValue.Substring(0, $conditionOffset).Trim()
            }
            if (-not $headers.ContainsKey($headerName)) {
                $headers[$headerName] = $headerValue
            }
            if ($headerName -eq 'name' -and -not $aliasSet.ContainsKey($headerValue)) {
                $aliasSet[$headerValue] = $true
                $aliases.Add($headerValue)
            }
        }
        $groupRaw = $headers['group']
        $name = $headers['name']
        $subgroup = $headers['subgroup']
        if (-not $groupRaw -or -not $name) { Add-Error "$relative contains a guide without #group or #name"; continue }
        $isOriginalSnapshot = $groupRaw.TrimStart('+', '*').StartsWith('Original Guides - ')
        $group = Normalize-Group $groupRaw
        $xprate = $headers['xprate']
        $topCondition = ($topConditionPattern.Match($metadata).Groups[1].Value).Trim()
        $signature = "$group|$subgroup|$name|$xprate|$topCondition"
        if ($keys.ContainsKey($signature)) { Add-Error "Duplicate guide key: $group / $subgroup / $name" }
        else { $keys[$signature] = $true }
        $nextHeaders = New-Object 'Collections.Generic.List[string]'
        $guides.Add([pscustomobject]@{
            Group = $group; Name = $name; Names = $aliases; Subgroup = $subgroup
            RawGroup = $groupRaw; File = $relative
            Headers = $headers; NextHeaders = $nextHeaders
            TopCondition = $topCondition
        })

        $skipAc335 = $false
        $stepCondition = ''
        $lineNumber = 0
        $previousUnconditionalNext = $false
        $previousNextLine = 0
        $analysisStepIndex = 0
        $analysisStepActive = $false
        $analysisAccepts = $null
        $analysisOnQuestGuards = $null
        $analysisCompleteGuards = $null
        $analysisStepHasContext = $false
        $analysisPendingObjectiveKeys = $null
        foreach ($lineRaw in $content.Split([char]10)) {
            $lineNumber++
            $line = $lineRaw.Trim()
            $nextMatch = if ($line.StartsWith(
                '#next', [StringComparison]::OrdinalIgnoreCase)) {
                $nextHeaderPattern.Match($line)
            } else {
                $null
            }
            if ($null -ne $nextMatch -and $nextMatch.Success) {
                $nextHeaders.Add($nextMatch.Groups[1].Value)
            }
            # Conditional #next headers are ordered alternatives: the loader
            # uses the first one whose condition applies. Adjacent
            # unconditional headers are ambiguous and the latter is dead.
            if (-not $isOriginalSnapshot) {
                $isUnconditionalNext =
                    $null -ne $nextMatch -and $nextMatch.Success -and
                    -not (Get-GuideCondition $line)
                if ($isUnconditionalNext -and $previousUnconditionalNext) {
                    Add-Error (
                        '{0}: {1} has consecutive unconditional #next headers at guide lines {2} and {3}' -f
                        $relative, $name, $previousNextLine, $lineNumber)
                }
                $previousUnconditionalNext = $isUnconditionalNext
                $previousNextLine = if ($isUnconditionalNext) { $lineNumber } else { 0 }
            }
            if (-not $line) { continue }

            if ($line.StartsWith('step', [StringComparison]::OrdinalIgnoreCase) -and
                $stepLinePattern.IsMatch($line)) {
                if ($analysisStepActive) {
                    if ($analysisStepHasContext -and
                        $null -ne $analysisPendingObjectiveKeys) {
                        foreach ($objectiveKey in $analysisPendingObjectiveKeys) {
                            $objectiveContext[$objectiveKey] = $true
                        }
                    }
                    if ($null -ne $analysisAccepts) {
                        foreach ($questId in $analysisAccepts.Keys) {
                            if ($null -ne $analysisOnQuestGuards -and
                                $analysisOnQuestGuards.ContainsKey($questId)) {
                                $guardErrors.Add(
                                    "$relative`: $name step $analysisStepIndex .isOnQuest " +
                                    "$questId makes .accept $questId unreachable")
                            }
                            if ($null -ne $analysisCompleteGuards -and
                                $analysisCompleteGuards.ContainsKey($questId)) {
                                $guardErrors.Add(
                                    "$relative`: $name step $analysisStepIndex .isQuestComplete " +
                                    "$questId makes .accept $questId unreachable")
                            }
                        }
                    }
                }

                $stepCount++
                $analysisStepIndex++
                $stepCondition = Get-GuideCondition $line
                $skipAc335 = Test-ExcludedOn335 $stepCondition
                $analysisStepActive = -not $isOriginalSnapshot -and
                    -not (Test-ExcludedOn335 $line.Substring(4))
                $analysisAccepts = $null
                $analysisOnQuestGuards = $null
                $analysisCompleteGuards = $null
                $analysisStepHasContext = $false
                $analysisPendingObjectiveKeys = $null
                continue
            }

            if ($analysisStepActive -and -not $analysisStepHasContext -and
                ($line.Contains('>>') -and $line -match '>>\s*\S' -or
                    $objectiveTargetPattern.IsMatch($line))) {
                $analysisStepHasContext = $true
            }

            $firstChar = $line[0]
            if ($firstChar -eq '#') {
                $headerMatch = $headerLinePattern.Match($line)
                if ($headerMatch.Success -and
                    -not $knownHeaders.ContainsKey($headerMatch.Groups[1].Value)) {
                    Add-Error "$relative`:$lineNumber unknown header #$($headerMatch.Groups[1].Value)"
                }
                continue
            }
            if ($firstChar -ne '.') {
                $missingDotMatch = $missingDotDirectivePattern.Match($line)
                if ($missingDotMatch.Success) {
                    Add-Error (
                        "$relative`:$lineNumber directive " +
                        ".$($missingDotMatch.Groups[1].Value) is missing its leading dot")
                }
                continue
            }

            $directiveMatch = $directiveLinePattern.Match($line)
            if ($directiveMatch.Success) {
                $directive = $directiveMatch.Groups[1].Value
                $lineCondition = Get-GuideCondition $line

                if ($analysisStepActive) {
                    if (-not $lineCondition) {
                        $guardMatch = $guardAcceptPattern.Match($line)
                        if ($guardMatch.Success) {
                            $kind = $guardMatch.Groups[1].Value
                            $questId = [math]::Abs([int]$guardMatch.Groups[2].Value)
                            if ($kind -eq 'accept') {
                                if ($null -eq $analysisAccepts) { $analysisAccepts = @{} }
                                $analysisAccepts[$questId] = $true
                            } elseif ($kind -eq 'isOnQuest') {
                                if ($null -eq $analysisOnQuestGuards) {
                                    $analysisOnQuestGuards = @{}
                                }
                                $analysisOnQuestGuards[$questId] = $true
                            } else {
                                if ($null -eq $analysisCompleteGuards) {
                                    $analysisCompleteGuards = @{}
                                }
                                $analysisCompleteGuards[$questId] = $true
                            }
                        }
                    }

                    if ($directive -eq 'complete') {
                        $completeMatch = $completeObjectivePattern.Match($line)
                        if ($completeMatch.Success -and -not (Test-ExcludedOn335 (
                            Get-GuideCondition $completeMatch.Groups['tail'].Value))) {
                            $objectiveKey =
                                "$([int]$completeMatch.Groups['quest'].Value)," +
                                "$([int]$completeMatch.Groups['objective'].Value)"
                            if (-not $objectiveReferences.ContainsKey($objectiveKey)) {
                                $objectiveReferences[$objectiveKey] = "$relative`: $name"
                            }
                            if ($analysisStepHasContext -or
                                $objectiveCommentPattern.IsMatch(
                                    $completeMatch.Groups['tail'].Value)) {
                                $objectiveContext[$objectiveKey] = $true
                            } else {
                                if ($null -eq $analysisPendingObjectiveKeys) {
                                    $analysisPendingObjectiveKeys = New-Object `
                                        'Collections.Generic.List[string]'
                                }
                                $analysisPendingObjectiveKeys.Add($objectiveKey)
                            }
                        }
                    }
                }

                if (-not $functionNames.ContainsKey($directive)) { Add-Error "$relative`:$lineNumber unknown directive .$directive"; continue }
                if ($skipAc335 -or (Test-ExcludedOn335 $lineCondition)) { continue }
                if (-not $isOriginalSnapshot -and $directive -eq 'accept' -and $line -notmatch '>>\s*\S') {
                    # Offered quests have no numeric ID in the 3.3.5 gossip API.
                    # Authored title text is the standalone fallback when the
                    # server has not cached the name before acceptance.
                    Add-Error "$relative`:$lineNumber .accept requires authored quest-title text on 3.3.5"
                }
                if (-not $isOriginalSnapshot -and
                    $hearthDirectives.ContainsKey($directive) -and
                    $line -notmatch '>>\s*\S') {
                    Add-Error (
                        "$relative`:$lineNumber .$directive requires authored " +
                        'hearth destination text on 3.3.5')
                }
                if (-not $isOriginalSnapshot -and $directive -eq 'accept' -and $line -match '^\.accept\s+(\d+)\b.*?>>\s*(.*?)(?:\s*<<.*)?(?:\s*--.*)?\s*$') {
                    $acceptQuestId = [int]$Matches[1]
                    $authoredTitle = ($Matches[2].Trim() -replace '^Accept\s+', '')
                    if ($questNames.ContainsKey($acceptQuestId) -and
                        $authoredTitle -cne $questNames[$acceptQuestId]) {
                        Add-Error "$relative`:$lineNumber .accept title '$authoredTitle' does not match quest $acceptQuestId ('$($questNames[$acceptQuestId])')"
                    }
                }
                if ($coordinateDirectives.ContainsKey($directive)) {
                    if (-not $isOriginalSnapshot -and
                        $runtimeCoordinateDirectives.ContainsKey($directive)) {
                        $coordinateClause = ($line -replace '\s*(?:>>|<<|--).*$','').Trim()
                        $coordinatePayload = ($coordinateClause -replace '^\.[A-Za-z][A-Za-z0-9_]*\s+','')
                        if ($coordinatePayload.Split(',').Count -gt 5) {
                            Add-Error (
                                "$relative`:$lineNumber .$directive has more fields than " +
                                'the 3.3.5 runtime accepts (zone,x,y,radius,optional)')
                        }
                    }
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
                if ($zoneDirectives.ContainsKey($directive)) {
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
                if ($areaDirectives.ContainsKey($directive)) {
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
                    $values = $Matches[2].Split(',')
                    if ($values.Count -lt 4 -or ($values.Count % 2) -ne 0) { Add-Error "$relative`:$lineNumber malformed .line coordinate pairs" }
                    else {
                        foreach ($rawValue in $values) {
                            $value = $rawValue.Trim()
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
                        $loopValues = $Matches[2].Split(',')
                        if ($loopValues.Count -lt 4 -or ($loopValues.Count % 2) -ne 0) {
                            Add-Error "$relative`:$lineNumber malformed .loop coordinate pairs"
                        } else {
                            foreach ($rawValue in $loopValues) {
                                $value = $rawValue.Trim()
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
                    $numberMatches = [regex]::Matches($questArgs, '(?<![.\d])\d+(?![.\d])')
                    $numberLimit = if ($questDirective -eq 'isQuestAvailable' -or
                        $questDirective -eq 'acceptmultiple') {
                        $numberMatches.Count
                    } else {
                        [math]::Min(1, $numberMatches.Count)
                    }
                    for ($numberIndex = 0; $numberIndex -lt $numberLimit; $numberIndex++) {
                        $questId = [int]$numberMatches[$numberIndex].Value
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

        # Flush the final step; earlier steps are flushed when the next step
        # line is encountered. Buffering these diagnostics preserves their
        # existing post-parse ordering.
        if ($analysisStepActive) {
            if ($analysisStepHasContext -and
                $null -ne $analysisPendingObjectiveKeys) {
                foreach ($objectiveKey in $analysisPendingObjectiveKeys) {
                    $objectiveContext[$objectiveKey] = $true
                }
            }
            if ($null -ne $analysisAccepts) {
                foreach ($questId in $analysisAccepts.Keys) {
                    if ($null -ne $analysisOnQuestGuards -and
                        $analysisOnQuestGuards.ContainsKey($questId)) {
                        $guardErrors.Add(
                            "$relative`: $name step $analysisStepIndex .isOnQuest " +
                            "$questId makes .accept $questId unreachable")
                    }
                    if ($null -ne $analysisCompleteGuards -and
                        $analysisCompleteGuards.ContainsKey($questId)) {
                        $guardErrors.Add(
                            "$relative`: $name step $analysisStepIndex .isQuestComplete " +
                            "$questId makes .accept $questId unreachable")
                    }
                }
            }
        }
    }
}

foreach ($guardError in $guardErrors) { Add-Error $guardError }
foreach ($key in $objectiveReferences.Keys) {
    if (-not $objectiveContext.ContainsKey($key)) {
        Add-Error (
            "$($objectiveReferences[$key]) .complete $key has no authored " +
            'objective context for the 3.3.5 placeholder fallback.')
    }
}

# Guide group/name/condition signatures are part of the saved-progress
# compatibility surface. Structural counts alone would not catch a renamed key
# that silently orphaned an existing character checkpoint.
$sortedGuideKeys = [string[]]@($keys.Keys)
[Array]::Sort($sortedGuideKeys, [StringComparer]::Ordinal)
$serializedKeys = $sortedGuideKeys -join "`n"
$sha256 = [Security.Cryptography.SHA256]::Create()
try {
    $guideKeyHash = ($sha256.ComputeHash(
        [Text.Encoding]::UTF8.GetBytes($serializedKeys)) |
        ForEach-Object { $_.ToString('x2') }) -join ''
} finally {
    $sha256.Dispose()
}
if ($guideKeyHash -cne [string]$surface.guideKeyHash) {
    Add-Error (
        "Guide-key compatibility surface changed: $guideKeyHash. " +
        'Update tests/runtime-surface.json only for an intentional key migration.')
}
if ($files.Count -ne [int]$surface.guideFileCount -or
    $guideCount -ne [int]$surface.guideCount -or
    $stepCount -ne [int]$surface.guideStepCount) {
    Add-Error (
        "Guide baseline changed: $($files.Count) files, $guideCount guides, $stepCount steps. " +
        'Update tests/runtime-surface.json only for an intentional content integration.')
}

# Keep the transition resolver independent per semicolon-delimited candidate.
# This focused synthetic case catches the historical state leak where the
# second, unqualified candidate inherited the first candidate's group.
$transitionResolverRegression = @(
    Resolve-GuideTransitionCandidate `
        'Synthetic Source Group' 'Synthetic Source Group' `
        'Synthetic Qualified Group\Qualified Guide'
    Resolve-GuideTransitionCandidate `
        'Synthetic Source Group' 'Synthetic Source Group' `
        'Unqualified Guide'
)
if ($transitionResolverRegression.Count -ne 2 -or
    $transitionResolverRegression[0].Group -cne 'Synthetic Qualified Group' -or
    $transitionResolverRegression[1].Group -cne 'Synthetic Source Group' -or
    $transitionResolverRegression[1].Name -cne 'Unqualified Guide') {
    Add-Error 'Transition resolver leaked a qualified candidate group into an unqualified fallback.'
}

$guideIndex = @{}
foreach ($guide in $guides) {
    foreach ($guideName in $guide.Names) { $guideIndex["$($guide.Group)|$guideName"] = $true }
}
foreach ($guide in $guides) {
    if ($guide.RawGroup.TrimStart('+', '*').StartsWith('Original Guides - ')) { continue }
    foreach ($rawNext in $guide.NextHeaders) {
        $condition = Get-GuideCondition $rawNext
        if ($condition -match '!wotlk|\bcata\b|\bmop\b') { continue }
        $conditionOffset = $rawNext.IndexOf('<<')
        $nextValue = if ($conditionOffset -ge 0) {
            $rawNext.Substring(0, $conditionOffset).Trim()
        } else {
            $rawNext.Trim()
        }
        foreach ($candidateRaw in ($nextValue -split ';')) {
            $candidate = $candidateRaw.Trim()
            if (-not $candidate) { continue }
            $resolved = Resolve-GuideTransitionCandidate `
                $guide.Group $guide.RawGroup $candidate
            if (-not $resolved) { continue }
            $targetGroup = $resolved.Group
            $targetName = $resolved.Name
            if (-not $guideIndex.ContainsKey("$targetGroup|$targetName")) { Add-Error "$($guide.File) dangling #next from $($guide.Name) to $targetGroup / $targetName" }
        }
    }
}

# Pin the primary route chain. These fixtures intentionally validate authored
# order and conditions as well as destination existence: the loader selects
# the first applicable #next header and the first viable semicolon fallback.
$routeFixtures = @(
    [pscustomobject]@{
        Label = 'Human starter fallbacks'; Group = 'RestedXP Alliance 1-20'
        Name = '1-11 Elwynn Forest'; Exact = $true
        Expected = @(
            '11-12 Loch Modan;11-14 Darkshore;14-20 Bloodmyst << !Warlock'
            '12-14 Loch Modan;11-14 Darkshore;14-20 Bloodmyst << Warlock'
        )
    }
    [pscustomobject]@{
        Label = 'Gnome Warlock starter fallbacks'; Group = 'RestedXP Alliance 1-20'
        Name = '1-12 Dun Morogh'; Exact = $true
        Expected = @('12-14 Loch Modan Gnome;11-14 Darkshore;14-20 Bloodmyst')
    }
    [pscustomobject]@{
        Label = 'Orc/Troll Hunter starter handoff'; Group = 'RestedXP Horde 1-30'
        Name = '6-10 Durotar'; Exact = $true
        Expected = @(
            '10-13 Durotar << Warrior/Shaman/Orc Hunter/Troll Hunter'
            '10-12 Eversong Woods << !Warrior !Shaman !(Orc Hunter) !(Troll Hunter)'
        )
    }
    [pscustomobject]@{
        Label = 'Orc/Troll Hunter Barrens handoff'; Group = 'RestedXP Horde 1-30'
        Name = '10-13 Durotar'; Exact = $true
        Expected = @('13-22 The Barrens')
    }
    [pscustomobject]@{
        Label = 'Horde Barrens Hunter applicability'; Group = 'RestedXP Horde 1-30'
        Name = '13-22 The Barrens'; Exact = $true
        TopCondition = 'Horde Warrior/Horde Shaman/Horde Orc Hunter/Horde Troll Hunter'
        DefaultFor = 'Shaman/Warrior/Orc Hunter/Troll Hunter'
        Expected = @('22-25 Hillsbrad / South Barrens;22-25 Hillsbrad Foothills JJ')
    }
    [pscustomobject]@{
        Label = 'Alliance Classic Duskwood boundary'; Group = 'RestedXP Alliance 20-32'
        Name = '30-32 Duskwood/STV'; Exact = $true
        Expected = @('RestedXP TBC Guide (A)\32-33 Shimmering Flats')
    }
    [pscustomobject]@{
        Label = 'Alliance Classic Hillsbrad boundary'; Group = 'RestedXP Alliance 20-32'
        Name = '30-32 Hillsbrad'; Exact = $true
        Expected = @('RestedXP TBC Guide (A)\32-33 Shimmering Flats')
    }
    [pscustomobject]@{
        Label = 'Horde Classic normal boundary'; Group = 'RestedXP Horde 1-30'
        Name = '26-30 Ashenvale / Thousand Needles'; Exact = $true
        Expected = @('RestedXP TBC Guide (H)\30-33 Hillsbrad/Arathi part 1')
    }
    [pscustomobject]@{
        Label = 'Horde Classic JJ boundary'; Group = 'RestedXP Horde 1-30'
        Name = '28-30 Thousand Needles JJ'; Exact = $true
        Expected = @('RestedXP TBC Guide (H)\30-33 Hillsbrad/Arathi part 1')
    }
    [pscustomobject]@{
        Label = 'Alliance boosted boundary'; Group = 'RestedXP Alliance Boosted 58-60'
        Name = 'Boosted Character 58-60'; Exact = $true
        Expected = @('RestedXP TBC Guide (A)\59-61 Hellfire Peninsula')
    }
    [pscustomobject]@{
        Label = 'Horde boosted boundary'; Group = 'RestedXP Horde Boosted 58-60'
        Name = 'Boosted Character 58-60'; Exact = $true
        Expected = @('RestedXP TBC Guide (H)\59-61 Hellfire Peninsula')
    }
    [pscustomobject]@{
        Label = 'Death Knight WotLK boundaries'; Group = 'RestedXP Death Knight Start'
        Name = '55-58 The Scarlet Enclave'; Exact = $false
        Expected = @(
            'RestedXP TBC Guide (A)\59-61 Hellfire Peninsula << Alliance wotlk'
            'RestedXP TBC Guide (H)\59-61 Hellfire Peninsula << Horde wotlk'
        )
    }
)

foreach ($faction in @('A', 'H')) {
    foreach ($alignment in @('Aldor', 'Scryer')) {
        $routeFixtures += [pscustomobject]@{
            Label = $faction + ' ' + $alignment + ' WotLK boundary'
            Group = 'RestedXP TBC Guide (' + $faction + ')'
            Name = '69-70 Shadowmoon Valley (' + $alignment + ')'
            Exact = $true
            Expected = @(
                'RestedXP WotLK Guide (' + $faction + ')\70-72 Northrend')
        }
    }

    $wotlkRanges = @('70-72', '72-74', '74-76', '76-78', '78-80')
    for ($rangeIndex = 0; $rangeIndex -lt $wotlkRanges.Count; $rangeIndex++) {
        $expectedNext = if ($rangeIndex -lt ($wotlkRanges.Count - 1)) {
            @($wotlkRanges[$rangeIndex + 1] + ' Northrend')
        } else {
            @()
        }
        $routeFixtures += [pscustomobject]@{
            Label = $faction + ' WotLK ' + $wotlkRanges[$rangeIndex] + ' handoff'
            Group = 'RestedXP WotLK Guide (' + $faction + ')'
            Name = $wotlkRanges[$rangeIndex] + ' Northrend'
            Exact = $true
            Expected = $expectedNext
        }
    }
}

$routeGuideIndex = @{}
foreach ($guide in $guides) {
    if ($guide.RawGroup.TrimStart('+', '*').StartsWith('Original Guides - ')) {
        continue
    }
    $fixtureGroup = ($guide.RawGroup -replace '\s*<<.*$', '').Trim().TrimStart('+', '*')
    $fixtureKey = $fixtureGroup + '|' + $guide.Name
    if (-not $routeGuideIndex.ContainsKey($fixtureKey)) {
        $routeGuideIndex[$fixtureKey] = New-Object 'Collections.ArrayList'
    }
    [void]$routeGuideIndex[$fixtureKey].Add($guide)
}

foreach ($fixture in $routeFixtures) {
    $fixtureKey = $fixture.Group + '|' + $fixture.Name
    $fixtureGuides = @()
    if ($routeGuideIndex.ContainsKey($fixtureKey)) {
        $fixtureGuides = @($routeGuideIndex[$fixtureKey])
    }
    if ($fixtureGuides.Count -ne 1) {
        Add-Error (
            'Route fixture {0} matched {1} guides instead of one: {2} / {3}' -f
            $fixture.Label, $fixtureGuides.Count, $fixture.Group, $fixture.Name)
        continue
    }

    $fixtureGuide = $fixtureGuides[0]
    if ($null -ne $fixture.PSObject.Properties['TopCondition']) {
        $actualTopCondition = ($fixtureGuide.TopCondition -replace '\s+', ' ')
        if ($actualTopCondition -cne $fixture.TopCondition) {
            Add-Error (
                'Route fixture {0} top condition changed. Expected [{1}], got [{2}]' -f
                $fixture.Label, $fixture.TopCondition, $actualTopCondition)
        }
    }
    if ($null -ne $fixture.PSObject.Properties['DefaultFor']) {
        $actualDefaultFor = $fixtureGuide.Headers['defaultfor']
        $actualDefaultFor = ($actualDefaultFor -replace '\s+', ' ').Trim()
        if ($actualDefaultFor -cne $fixture.DefaultFor) {
            Add-Error (
                'Route fixture {0} #defaultfor changed. Expected [{1}], got [{2}]' -f
                $fixture.Label, $fixture.DefaultFor, $actualDefaultFor)
        }
    }

    $actualHeaderList = New-Object 'Collections.Generic.List[string]'
    foreach ($rawHeader in $fixtureGuide.NextHeaders) {
        $actualHeaderList.Add((Normalize-NextHeader ([string]$rawHeader)))
    }
    $actualHeaders = [string[]]$actualHeaderList
    $expectedHeaderList = New-Object 'Collections.Generic.List[string]'
    foreach ($expectedHeader in @($fixture.Expected)) {
        $expectedHeaderList.Add((Normalize-NextHeader ([string]$expectedHeader)))
    }
    $expectedHeaders = [string[]]$expectedHeaderList
    $mismatch = $false
    if ($fixture.Exact) {
        $mismatch = $actualHeaders.Count -ne $expectedHeaders.Count
        if (-not $mismatch) {
            for ($headerIndex = 0; $headerIndex -lt $expectedHeaders.Count; $headerIndex++) {
                if ($actualHeaders[$headerIndex] -cne $expectedHeaders[$headerIndex]) {
                    $mismatch = $true
                    break
                }
            }
        }
    } else {
        foreach ($expectedHeader in $expectedHeaders) {
            if ($actualHeaders -cnotcontains $expectedHeader) {
                $mismatch = $true
                break
            }
        }
    }
    if ($mismatch) {
        $expectedDisplay = if ($expectedHeaders.Count) {
            $expectedHeaders -join ' | '
        } else {
            '<terminal: no #next>'
        }
        $actualDisplay = if ($actualHeaders.Count) {
            $actualHeaders -join ' | '
        } else {
            '<terminal: no #next>'
        }
        Add-Error (
            'Route fixture {0} changed. Expected [{1}], got [{2}]' -f
            $fixture.Label, $expectedDisplay, $actualDisplay)
    }
}

# The playable Horde level-30 route contains recurring collection objectives.
# Each occurrence needs explicit target metadata; otherwise the objective can
# progress while Active Targets remains empty until a later duplicate step.
$hordeLevelingPath = Join-Path $root 'Guides\TBC\Horde-Leveling.lua'
if ([IO.File]::Exists($hordeLevelingPath)) {
    $hordeLevelingText = "`n" + $(if ($fileTextCache.ContainsKey($hordeLevelingPath)) {
        $fileTextCache[$hordeLevelingPath]
    } else {
        [IO.File]::ReadAllText($hordeLevelingPath)
    })
    $objectiveTargetFixtures = @(
        @{ Quest = 546; Objective = 1 },
        @{ Quest = 556; Objective = 1 },
        @{ Quest = 621; Objective = 1 }
    )
    $stepBlocks = [regex]::Matches(
        $hordeLevelingText,
        '(?ms)\nstep\s*\n(?<body>.*?)(?=\nstep\s*\n|\z)')
    foreach ($fixture in $objectiveTargetFixtures) {
        $objectivePattern = '(?m)^\.complete\s+' + $fixture.Quest + ',' +
            $fixture.Objective + '(?:\D|$)'
        foreach ($stepBlock in $stepBlocks) {
            $body = $stepBlock.Groups['body'].Value
            if ($body -notmatch $objectivePattern) { continue }
            if ($body -notmatch '(?m)^\.(?:mob|unitscan|target)\s+\S') {
                Add-Error (
                    "Horde 30-45 objective $($fixture.Quest),$($fixture.Objective) " +
                    'has no Active Targets metadata.')
            }
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
