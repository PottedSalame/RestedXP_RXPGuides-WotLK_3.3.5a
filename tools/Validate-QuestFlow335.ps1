param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot '..\GuideList_335.xml'),
    [string]$QuestTemplatePath = '',
    [int]$MaxErrors = 200,
    [switch]$FailOnEntryWarnings,
    [switch]$FailOnLifecycleWarnings,
    [string]$ReportPath = '',
    [switch]$InventoryOnly,
    [switch]$SkipLabelValidation,
    [switch]$SkipQuestValidation
)

$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$errors = New-Object 'Collections.Generic.List[string]'
$entryWarnings = @{}
$lifecycleWarnings = @{}
$lifecycleDetails = @{}
$conditionCache = @{}
$reachabilityCache = @{}
$xpRateCache = @{}
$levelRangeCache = @{}
$wantReport = -not [string]::IsNullOrWhiteSpace($ReportPath)
$guidePattern = [regex]'(?ms)RXPGuides\.RegisterGuide\(\[\[(.*?)\]\]\)\s*;?'

function Normalize-Group([string]$Group) {
    $group = ($Group -replace '\s*<<.*$', '').Trim().TrimStart('*')
    if ($group -match '^RestedXP Alliance') { return 'RestedXP Speedrun Guide (A)' }
    if ($group -match '^RestedXP Horde') { return 'RestedXP Speedrun Guide (H)' }
    return $group
}

function Get-Header([string]$Content, [string]$Name) {
    $match = [regex]::Match($Content, "(?m)^#" + [regex]::Escape($Name) + "\s+(.+?)\s*$")
    if ($match.Success) { return ($match.Groups[1].Value -replace '\s*<<.*$', '').Trim() }
    return $null
}

function Get-Condition([string]$Line) {
    $match = [regex]::Match($Line, '<<\s*(.*?)(?=\s*>>|$)')
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    return ''
}

function Test-Token([string]$Token, $Profile) {
    $negative = $Token.StartsWith('!')
    if ($negative) { $Token = $Token.Substring(1) }
    $upper = $Token.ToUpperInvariant()
    $value = switch ($upper) {
        '__TRUE__' { $true; break }
        '__FALSE__' { $false; break }
        'AC335' { $true; break }
        'WOTLK' { $true; break }
        'TBC' { $false; break }
        'CLASSIC' { $false; break }
        'CATA' { $false; break }
        'MOP' { $false; break }
        'RETAIL' { $false; break }
        'DF' { $false; break }
        'ERA' { $false; break }
        'SOM' { $false; break }
        'SOD' { $false; break }
        'HARDCORE' { $false; break }
        'SOFTCORE' { $true; break }
        'MALE' { $true; break }
        'FEMALE' { $true; break }
        'SKIP' { $false; break }
        'DK' { $Profile.Class -eq 'DEATHKNIGHT'; break }
        # UnitRace returns the stable token "Scourge" on 3.3.5 while guide
        # conditions traditionally call the race "Undead". Runtime applies()
        # treats those spellings as aliases, so validation must do the same.
        'UNDEAD' { $Profile.Race -eq 'Scourge'; break }
        default {
            $number = 0
            if ([int]::TryParse($Token, [ref]$number)) { $Profile.Level -ge $number }
            else {
                $upper -eq $Profile.Class -or $Token -eq $Profile.Race -or
                    $Token -eq $Profile.Faction
            }
        }
    }
    if ($negative) { return -not $value }
    return [bool]$value
}

function Test-Applies([string]$Condition, $Profile) {
    if ([string]::IsNullOrWhiteSpace($Condition)) { return $true }
    $profileKey = [string]$Profile.ConditionKey
    if (-not $profileKey) {
        $profileKey = "$($Profile.Faction)|$($Profile.Race)|$($Profile.Class)|$($Profile.Level)"
    }
    $cachedProfiles = $conditionCache[$Condition]
    if ($null -ne $cachedProfiles -and $cachedProfiles.ContainsKey($profileKey)) {
        return [bool]$cachedProfiles[$profileKey]
    }
    if ($null -eq $cachedProfiles) {
        $cachedProfiles = @{}
        $conditionCache[$Condition] = $cachedProfiles
    }
    $expression = $Condition.Trim()
    while ($expression -match '(!?)\(([^()]*)\)') {
        $whole = $Matches[0]
        $negative = $Matches[1] -eq '!'
        $value = Test-Applies $Matches[2] $Profile
        if ($negative) { $value = -not $value }
        $replacement = if ($value) { '__TRUE__' } else { '__FALSE__' }
        $expression = $expression.Replace($whole, $replacement)
    }
    foreach ($alternative in ($expression -split '/')) {
        $matches = $true
        foreach ($tokenMatch in [regex]::Matches($alternative, '!?[A-Za-z0-9_]+')) {
            if (-not (Test-Token $tokenMatch.Value $Profile)) { $matches = $false; break }
        }
        if ($matches) { $cachedProfiles[$profileKey] = $true; return $true }
    }
    $cachedProfiles[$profileKey] = $false
    return $false
}

function Test-XpRate([string]$Expression, [double]$Rate) {
    if ([string]::IsNullOrWhiteSpace($Expression)) { return $true }
    $cachedRates = $xpRateCache[$Expression]
    if ($null -ne $cachedRates -and $cachedRates.ContainsKey($Rate)) {
        return [bool]$cachedRates[$Rate]
    }
    if ($null -eq $cachedRates) {
        $cachedRates = @{}
        $xpRateCache[$Expression] = $cachedRates
    }
    $result = $true
    if ($Expression -match '^<\s*(\d+(?:\.\d+)?)') {
        $result = $Rate -lt [double]$Matches[1]
    } elseif ($Expression -match '^>\s*(\d+(?:\.\d+)?)') {
        $result = $Rate -gt [double]$Matches[1]
    } elseif ($Expression -match '^(\d+(?:\.\d+)?)\s*-\s*(\d+(?:\.\d+)?)') {
        $result = $Rate -ge [double]$Matches[1] -and $Rate -le [double]$Matches[2]
    } elseif ($Expression -match '^(\d+(?:\.\d+)?)$') {
        $result = $Rate -ge [double]$Matches[1]
    }
    $cachedRates[$Rate] = $result
    return $result
}

function Test-ConditionReachable335([string]$Condition) {
    if ([string]::IsNullOrWhiteSpace($Condition)) { return $true }
    if ($reachabilityCache.ContainsKey($Condition)) {
        return [bool]$reachabilityCache[$Condition]
    }
    foreach ($alternative in ($Condition -split '/')) {
        $positiveExpansions = @([regex]::Matches(
            $alternative,
            '(?i)(?<![!A-Za-z0-9_])(ac335|wotlk|tbc|classic|era|cata|mop|retail|df)(?![A-Za-z0-9_])') |
            ForEach-Object { $_.Groups[1].Value.ToLowerInvariant() })
        if ($alternative -match '(?i)(?<![!A-Za-z0-9_])skip(?![A-Za-z0-9_])') {
            continue
        }
        if ($positiveExpansions.Count -eq 0 -or
            $positiveExpansions -contains 'wotlk' -or
            $positiveExpansions -contains 'ac335') {
            $reachabilityCache[$Condition] = $true
            return $true
        }
    }
    $reachabilityCache[$Condition] = $false
    return $false
}

function Test-GuideConditions($Guide, $Profile) {
    if ($Guide.HasIncompatibleExpansion) { return $false }
    foreach ($condition in $Guide.BareConditions) {
        # A bare condition disables the whole guide. Conditional #name and
        # #group headers are alternatives selected by the parser, so a
        # non-matching alternative must not disable an otherwise valid guide.
        if (-not (Test-Applies $condition $Profile)) { return $false }
    }
    return $true
}

function Get-ApplicableHeaderValue(
    $Guide,
    [string]$Name,
    $Profile
) {
    $entries = $Guide.HeaderValues[$Name.ToLowerInvariant()]
    if ($null -eq $entries) { return $null }
    foreach ($entry in $entries) {
        if ($entry.Condition -and
            -not (Test-Applies $entry.Condition $Profile)) { continue }
        return $entry.Value
    }
    return $null
}

function Get-GuideLevelRange([string]$Name) {
    if ($levelRangeCache.ContainsKey($Name)) { return $levelRangeCache[$Name] }
    $match = [regex]::Match($Name, '(?<!\d)(\d{1,2})\s*-\s*(\d{1,2})(?!\d)')
    if (-not $match.Success) {
        $range = [pscustomobject]@{ Start = 0; End = 0 }
        $levelRangeCache[$Name] = $range
        return $range
    }
    $range = [pscustomobject]@{
        Start = [int]$match.Groups[1].Value
        End = [int]$match.Groups[2].Value
    }
    $levelRangeCache[$Name] = $range
    return $range
}

function Resolve-RouteCandidate(
    [string]$SourceGroup,
    [string]$CandidateRaw,
    [string]$Alignment
) {
    $candidate = $CandidateRaw.Trim()
    if (-not $candidate) { return $null }
    $targetGroup = $SourceGroup
    $targetName = $candidate
    if ($candidate -match '^(.*?)\\(.+)$') {
        $targetGroup = Normalize-Group $Matches[1]
        $targetName = $Matches[2].Trim()
    }
    # The runtime normalizes an authored Aldor/Scryer candidate before guide
    # lookup. Validate both valid reputation paths without depending on live
    # faction reputation data.
    if ($Alignment -eq 'Scryer' -and $targetName -match 'Aldor') {
        $targetName = $targetName -replace 'Aldor', 'Scryer'
    } elseif ($Alignment -eq 'Aldor' -and $targetName -match 'Scryer') {
        $targetName = $targetName -replace 'Scryer', 'Aldor'
    }
    return [pscustomobject]@{ Group = $targetGroup; Name = $targetName }
}

function Get-MissingPrerequisites($Specification, $TurnedIn, $Completed, $Accepted) {
    if (-not $Specification) { return @() }
    $bestMissing = $null
    foreach ($clause in $Specification.Clauses) {
        $missing = New-Object 'Collections.Generic.List[int]'
        foreach ($requirement in $clause.Requirements) {
            $id = [int]$requirement.Id
            $satisfied = switch ($requirement.State) {
                'R' { $TurnedIn.ContainsKey($id); break }
                'A' {
                    $TurnedIn.ContainsKey($id) -or
                        $Completed.ContainsKey($id) -or
                        $Accepted.ContainsKey($id)
                    break
                }
                'N' {
                    -not $TurnedIn.ContainsKey($id) -and
                        -not $Completed.ContainsKey($id) -and
                        -not $Accepted.ContainsKey($id)
                    break
                }
                default { $false }
            }
            if (-not $satisfied -and -not $missing.Contains($id)) {
                $missing.Add($id)
            }
        }
        if ($missing.Count -eq 0) { return @() }
        if ($null -eq $bestMissing -or $missing.Count -lt $bestMissing.Count) {
            $bestMissing = @($missing)
        }
    }
    return @($bestMissing)
}

$prerequisiteText = [IO.File]::ReadAllText((Join-Path $root 'DB\wotlk\questPrerequisites_335.lua'))
$encodedMatch = [regex]::Match($prerequisiteText, '(?s)local encoded\s*=\s*\[\[(.*?)\]\]')
$prerequisites = @{}
foreach ($match in [regex]::Matches($encodedMatch.Groups[1].Value, '(\d+)=([^;]+)')) {
    $questId = [int]$match.Groups[1].Value
    $clauses = New-Object 'Collections.Generic.List[object]'
    foreach ($clauseText in ($match.Groups[2].Value -split '\|')) {
        $requirements = New-Object 'Collections.Generic.List[object]'
        foreach ($requirementMatch in [regex]::Matches($clauseText, '([RAN])(\d+)')) {
            $requirements.Add([pscustomobject]@{
                State = $requirementMatch.Groups[1].Value
                Id = [int]$requirementMatch.Groups[2].Value
            })
        }
        if ($requirements.Count -gt 0) {
            $clauses.Add([pscustomobject]@{ Requirements = $requirements })
        }
    }
    if ($clauses.Count -gt 0) {
        $prerequisites[$questId] = [pscustomobject]@{ Clauses = $clauses }
    }
}
if ($prerequisites.ContainsKey(11286)) {
    $errors.Add(
        'Quest 11286 must remain directly available; 11287 is its breadcrumb, not a hard prerequisite.')
}

$autoCompleteQuests = @{}
if ($QuestTemplatePath) {
    $resolvedQuestTemplate = [IO.Path]::GetFullPath($QuestTemplatePath)
    if (-not [IO.File]::Exists($resolvedQuestTemplate)) {
        throw "AzerothCore quest_template reference not found: $resolvedQuestTemplate"
    }
    $quests = @{}
    foreach ($line in [IO.File]::ReadLines($resolvedQuestTemplate)) {
        if (-not $line.StartsWith('(')) { continue }
        $fields = $line.Substring(1).Split(',', 26)
        if ($fields.Count -lt 25) { continue }
        $id = 0; $method = 0; $previous = 0; $next = 0; $exclusive = 0
        if (-not [int]::TryParse($fields[0], [ref]$id)) { continue }
        [void][int]::TryParse($fields[1], [ref]$method)
        [void][int]::TryParse($fields[21], [ref]$previous)
        [void][int]::TryParse($fields[22], [ref]$next)
        [void][int]::TryParse($fields[23], [ref]$exclusive)
        if ($method -eq 0) { $autoCompleteQuests[$id] = $true }
        $quests[$id] = [pscustomobject]@{
            Id = $id; Previous = $previous; Next = $next; Exclusive = $exclusive
        }
    }

    $groups = @{}
    foreach ($quest in $quests.Values) {
        if ($quest.Exclusive -eq 0) { continue }
        if (-not $groups.ContainsKey($quest.Exclusive)) {
            $groups[$quest.Exclusive] = New-Object 'Collections.Generic.List[int]'
        }
        $groups[$quest.Exclusive].Add($quest.Id)
    }
    $candidates = @{}
    function Add-ValidatorCandidate([int]$QuestId, [int]$Candidate) {
        if ($QuestId -le 0 -or $Candidate -eq 0 -or
            [math]::Abs($Candidate) -eq $QuestId) { return }
        if (-not $candidates.ContainsKey($QuestId)) {
            $candidates[$QuestId] = New-Object 'Collections.Generic.List[int]'
        }
        if (-not $candidates[$QuestId].Contains($Candidate)) {
            $candidates[$QuestId].Add($Candidate)
        }
    }
    foreach ($quest in $quests.Values) {
        if ($quest.Previous -ne 0) {
            Add-ValidatorCandidate $quest.Id $quest.Previous
        }
        $nextId = [math]::Abs($quest.Next)
        if ($nextId -gt 0 -and $quests.ContainsKey($nextId)) {
            Add-ValidatorCandidate $nextId $quest.Id
        }
    }

    $exactPrerequisites = @{}
    foreach ($questId in $candidates.Keys) {
        $clauses = New-Object 'Collections.Generic.List[object]'
        $clauseKeys = @{}
        foreach ($candidate in $candidates[$questId]) {
            $predecessorId = [math]::Abs($candidate)
            if (-not $quests.ContainsKey($predecessorId)) { continue }
            $predecessor = $quests[$predecessorId]
            $requirements = New-Object 'Collections.Generic.List[object]'
            if ($candidate -gt 0) {
                if ($predecessor.Exclusive -lt 0 -and
                    $groups.ContainsKey($predecessor.Exclusive)) {
                    foreach ($groupId in @($groups[$predecessor.Exclusive] | Sort-Object)) {
                        $requirements.Add([pscustomobject]@{ State = 'R'; Id = $groupId })
                    }
                } else {
                    $requirements.Add([pscustomobject]@{ State = 'R'; Id = $predecessorId })
                }
            } else {
                $requirements.Add([pscustomobject]@{ State = 'A'; Id = $predecessorId })
                if ($predecessor.Exclusive -lt 0 -and
                    $groups.ContainsKey($predecessor.Exclusive)) {
                    foreach ($groupId in @($groups[$predecessor.Exclusive] | Sort-Object)) {
                        if ($groupId -ne $predecessorId) {
                            $requirements.Add([pscustomobject]@{ State = 'N'; Id = $groupId })
                        }
                    }
                }
            }
            $key = @($requirements | ForEach-Object { "$($_.State)$($_.Id)" } | Sort-Object -Unique) -join '+'
            if ($key -and -not $clauseKeys.ContainsKey($key)) {
                $clauseKeys[$key] = $true
                $clauses.Add([pscustomobject]@{ Requirements = $requirements })
            }
        }
        if ($clauses.Count -gt 0) {
            $exactPrerequisites[$questId] = [pscustomobject]@{ Clauses = $clauses }
        }
    }
    $prerequisites = $exactPrerequisites
}

$manifest = [IO.File]::ReadAllText([IO.Path]::GetFullPath($ManifestPath))
$guides = New-Object 'Collections.Generic.List[object]'
$questRequiredObjectives = @{}
foreach ($fileMatch in [regex]::Matches($manifest, '<Script\s+file="([^"]+)"\s*/>')) {
    $relative = $fileMatch.Groups[1].Value -replace '\\', [IO.Path]::DirectorySeparatorChar
    $path = [IO.Path]::GetFullPath((Join-Path $root $relative))
    if (-not [IO.File]::Exists($path)) { continue }
    $text = [IO.File]::ReadAllText($path)
    foreach ($guideMatch in $guidePattern.Matches($text)) {
        $content = $guideMatch.Groups[1].Value -replace "`r`n", "`n"
        $stepAt = $content.IndexOf("`nstep")
        $header = if ($stepAt -ge 0) { $content.Substring(0, $stepAt) } else { $content }
        $headerValues = @{}
        $bareConditions = New-Object 'Collections.Generic.List[string]'
        $hasExpansionHeader = $false
        $hasWotlkHeader = $false
        foreach ($rawHeaderLine in ($header -split "`n")) {
            $headerLine = $rawHeaderLine.Trim()
            if ($headerLine -match '^#(classic|tbc|wotlk|cata|mop|retail|df)\b') {
                $hasExpansionHeader = $true
                if ($Matches[1].ToLowerInvariant() -eq 'wotlk') {
                    $hasWotlkHeader = $true
                }
            }
            if ($headerLine -match '^<<\s*(.+)$') {
                $bareConditions.Add($Matches[1].Trim())
                continue
            }
            if ($headerLine -notmatch '^#([A-Za-z][A-Za-z0-9_]*)\s*(.*?)\s*$') {
                continue
            }
            $headerName = $Matches[1].ToLowerInvariant()
            $sourceValue = $Matches[2]
            $condition = Get-Condition $headerLine
            $value = ($sourceValue -replace '\s*<<.*$', '').Trim()
            if (-not $headerValues.ContainsKey($headerName)) {
                $headerValues[$headerName] = New-Object 'Collections.Generic.List[object]'
            }
            $headerValues[$headerName].Add([pscustomobject]@{
                Value = $value; SourceValue = $sourceValue; Condition = $condition
            })
        }
        $rawGroup = if ($headerValues['group']) { $headerValues['group'][0].Value } else { $null }
        $group = Normalize-Group $rawGroup
        $name = if ($headerValues['name']) { $headerValues['name'][0].Value } else { $null }
        if (-not $group -or -not $name) { continue }
        if ($rawGroup.TrimStart('+', '*').StartsWith('Original Guides - ')) { continue }
        $parsedEvents = New-Object 'Collections.Generic.List[object]'
        $routeEvents = New-Object 'Collections.Generic.List[object]'
        $labelRecords = New-Object 'Collections.Generic.List[object]'
        $stepCondition = ''
        $stepRate = ''
        $stepRateCondition = ''
        $stepId = 0
        $stepMetadata = [pscustomobject]@{ Id = 0; Optional = $false; Guards = @{}; Rates = [Collections.Generic.List[object]]::new() }
        $lineNumber = 0
        $contentLines = $content -split "`n"
        foreach ($rawLine in $contentLines) {
            $lineNumber++
            $line = $rawLine.Trim()
            if ($line -match '^step\b') {
                $stepId++
                $stepCondition = Get-Condition $line
                $stepRate = ''
                $stepRateCondition = ''
                $stepMetadata = [pscustomobject]@{ Id = $stepId; Optional = $false; Guards = @{}; Rates = [Collections.Generic.List[object]]::new() }
                continue
            }
            if ($line -match '^#(label|requires|completewith)\s+(\S+)') {
                $labelRecords.Add([pscustomobject]@{
                    Kind = if ($Matches[1] -eq 'label') { 'label' } else { 'reference' }
                    Name = $Matches[2]; Line = $lineNumber
                    StepCondition = $stepCondition; LineCondition = Get-Condition $line
                })
            }
            if ($line -match '^#optional\b') {
                $stepMetadata.Optional = $true
                continue
            }
            if ($line -match '^#xprate\s+(.+?)(?:\s*<<|$)') {
                $stepRate = $Matches[1].Trim()
                $stepRateCondition = Get-Condition $line
                $stepMetadata.Rates.Add([pscustomobject]@{ Expression = $stepRate; Condition = $stepRateCondition })
                continue
            }
            if ($line -match '^\.(?:isQuestTurnedIn|isQuestComplete|isOnQuest)\s+([^>]+)') {
                foreach ($guardId in @([regex]::Matches($Matches[1], '(?<![.\d])-?\d+(?![.\d])') |
                    ForEach-Object { [math]::Abs([int]$_.Value) })) {
                    $stepMetadata.Guards[$guardId] = $true
                }
            }
            if ($line -match '^\.(accept|acceptmultiple|daily|turnin|turninmultiple|dailyturnin|complete|abandon)\s+([^>]+)') {
                $directive = $Matches[1]
                $args = $Matches[2] -replace '\s*(?:--|<<).*$', ''
                $ids = @([regex]::Matches($args, '(?<![.\d])-?\d+(?![.\d])') | ForEach-Object { [int]$_.Value })
                $objective = if ($directive -eq 'complete' -and $ids.Count -gt 1) {
                    [math]::Abs([int]$ids[1])
                } else { 0 }
                if ($directive -notin @('acceptmultiple','daily','turninmultiple','dailyturnin') -and $ids.Count -gt 1) { $ids = @($ids[0]) }
                foreach ($id in $ids) {
                    $kind = if ($directive -in @('accept','acceptmultiple','daily')) { 1 }
                        elseif ($directive -in @('turnin','turninmultiple','dailyturnin')) { 2 }
                        elseif ($directive -eq 'complete') { 3 }
                        else { 4 }
                    $parsedEvent = [pscustomobject]@{
                        Kind = $kind; Directive = $directive; Quest = [math]::Abs($id); Objective = $objective; Line = $lineNumber;
                        SkipIfMissing = ($directive -eq 'turnin' -and $id -lt 0);
                        StepCondition = $stepCondition; LineCondition = Get-Condition $line;
                        XpRate = $stepRate; XpRateCondition = $stepRateCondition; Metadata = $stepMetadata
                    }
                    $parsedEvents.Add($parsedEvent)
                    $routeEvents.Add($parsedEvent)
                    if ($kind -eq 3 -and $objective -gt 0 -and
                        (Test-ConditionReachable335 $stepCondition) -and
                        (Test-ConditionReachable335 (Get-Condition $line))) {
                        $questId = [math]::Abs([int]$id)
                        if (-not $questRequiredObjectives.ContainsKey($questId)) {
                            $questRequiredObjectives[$questId] = @{}
                        }
                        $questRequiredObjectives[$questId][$objective] = $true
                    }
                }
                continue
            }
            if ($line -match '^\.collect\s+(-?\d+)\s*,\s*\d+\s*,\s*(-?\d+)\s*,\s*(\d+)') {
                $questId = [math]::Abs([int]$Matches[2])
                $objective = [int]$Matches[3]
                if ($questId -gt 0 -and $objective -gt 0) {
                    $lineCondition = Get-Condition $line
                    $routeEvents.Add([pscustomobject]@{
                        Kind = 5; Directive = 'collect'; Quest = $questId; Objective = $objective; Line = $lineNumber;
                        SkipIfMissing = $false; StepCondition = $stepCondition; LineCondition = $lineCondition;
                        XpRate = $stepRate; XpRateCondition = $stepRateCondition; Metadata = $stepMetadata
                    })
                    if ((Test-ConditionReachable335 $stepCondition) -and
                        (Test-ConditionReachable335 $lineCondition)) {
                        if (-not $questRequiredObjectives.ContainsKey($questId)) {
                            $questRequiredObjectives[$questId] = @{}
                        }
                        $questRequiredObjectives[$questId][$objective] = $true
                    }
                }
                continue
            }
            if ($line -match '^#qremove\s+(\d+)') {
                $parsedEvent = [pscustomobject]@{
                    Kind = 4; Directive = 'qremove'; Quest = [int]$Matches[1]; Objective = 0; Line = $lineNumber;
                    SkipIfMissing = $true; StepCondition = $stepCondition; LineCondition = Get-Condition $line;
                    XpRate = $stepRate; XpRateCondition = $stepRateCondition; Metadata = $stepMetadata
                }
                $parsedEvents.Add($parsedEvent)
                $routeEvents.Add($parsedEvent)
            }
        }
        $xpExpressions = New-Object 'Collections.Generic.List[string]'
        $xpExpressionSet = @{}
        foreach ($event in $parsedEvents) {
            foreach ($restriction in $event.Metadata.Rates) {
                $expression = $restriction.Expression
                if ($expression -and -not $xpExpressionSet.ContainsKey($expression)) {
                    $xpExpressionSet[$expression] = $true
                    $xpExpressions.Add($expression)
                }
            }
        }
        $guideXpRate = if ($headerValues['xprate']) { $headerValues['xprate'][0].Value } else { $null }
        if ($guideXpRate -and -not $xpExpressionSet.ContainsKey($guideXpRate)) {
            $xpExpressions.Add($guideXpRate)
        }
        $guides.Add([pscustomobject]@{
            File = $relative; Group = $group; Name = $name; Content = $content;
            RawGroup = $rawGroup;
            Header = $header; Level = [int](([regex]::Match($name, '^(\d+)').Groups[1].Value) -as [int])
            # Only the pre-step header controls guide visibility. Step-level
            # #xprate directives are evaluated independently below.
            XpRate = $guideXpRate
            HeaderValues = $headerValues; BareConditions = $bareConditions
            HasIncompatibleExpansion = $hasExpansionHeader -and -not $hasWotlkHeader
            XpExpressions = $xpExpressions; Lines = $contentLines
            LabelRecords = $labelRecords; Events = $parsedEvents; RouteEvents = $routeEvents
        })
    }
}

# Class/race profiles are also used to discard labels and references that only
# exist in disabled expansion branches (for example << tbc or << skip).
$profiles = New-Object 'Collections.Generic.List[object]'
$combinations = @(
    'Alliance|Human|WARRIOR,PALADIN,ROGUE,PRIEST,MAGE,WARLOCK,DEATHKNIGHT',
    'Alliance|Dwarf|WARRIOR,PALADIN,HUNTER,ROGUE,PRIEST,DEATHKNIGHT',
    'Alliance|NightElf|WARRIOR,HUNTER,ROGUE,PRIEST,DRUID,DEATHKNIGHT',
    'Alliance|Gnome|WARRIOR,ROGUE,MAGE,WARLOCK,DEATHKNIGHT',
    'Alliance|Draenei|WARRIOR,PALADIN,HUNTER,PRIEST,MAGE,SHAMAN,DEATHKNIGHT',
    'Horde|Orc|WARRIOR,HUNTER,ROGUE,SHAMAN,WARLOCK,DEATHKNIGHT',
    'Horde|Scourge|WARRIOR,ROGUE,PRIEST,MAGE,WARLOCK,DEATHKNIGHT',
    'Horde|Tauren|WARRIOR,HUNTER,SHAMAN,DRUID,DEATHKNIGHT',
    'Horde|Troll|WARRIOR,HUNTER,ROGUE,PRIEST,MAGE,SHAMAN,DEATHKNIGHT',
    'Horde|BloodElf|PALADIN,HUNTER,ROGUE,PRIEST,MAGE,WARLOCK,DEATHKNIGHT'
)
foreach ($combination in $combinations) {
    $parts = $combination -split '\|'
    foreach ($class in ($parts[2] -split ',')) {
        $profiles.Add([pscustomobject]@{
            Faction = $parts[0]; Race = $parts[1]; Class = $class;
            Level = 1; Rate = 1.0
            ConditionKey = "$($parts[0])|$($parts[1])|$class|1"
        })
    }
}

if ($InventoryOnly) { return }

# Follow every primary WotLK leveling route from its race/class-specific entry
# point to the terminal level-80 chapter. This is deliberately narrower than
# the general guide inventory: optional, dungeon, profession, farming, daily,
# Original-snapshot, and manually selected boosted guides are not automatic
# continuations for a fresh character and must not create false positives.
$primaryRouteGroups = @{
    'RestedXP Speedrun Guide (A)' = $true
    'RestedXP Speedrun Guide (H)' = $true
    'RestedXP TBC Guide (A)' = $true
    'RestedXP TBC Guide (H)' = $true
    'RestedXP WotLK Guide (A)' = $true
    'RestedXP WotLK Guide (H)' = $true
    'RestedXP Death Knight Start' = $true
}
$routeAlignments = @('Aldor', 'Scryer')
$routeIssues = @{}
$routeOpenCompletions = @{}
$routeMembership = @{}
$routeMatrixRuns = 0
$primaryRouteGuides = @($guides | Where-Object {
    $primaryRouteGroups.ContainsKey($_.Group)
})
$routeRateSet = @{}
foreach ($baseRate in @(1.0, 1.2, 1.5, 2.0)) {
    $routeRateSet[$baseRate.ToString(
        [Globalization.CultureInfo]::InvariantCulture)] = [double]$baseRate
}
# Preserve the explicitly supported rates above and also exercise both sides
# and the exact boundary of every guide-level XP-rate branch. Step-only rates
# do not choose the next guide and therefore remain in the event-flow tests.
foreach ($routeGuide in $primaryRouteGuides) {
    $routeRateEntries = $routeGuide.HeaderValues['xprate']
    if ($null -eq $routeRateEntries) { continue }
    foreach ($rateLine in $routeRateEntries) {
        foreach ($number in [regex]::Matches(
            $rateLine.SourceValue, '\d+(?:\.\d+)?')) {
            $threshold = [double]::Parse(
                $number.Value, [Globalization.CultureInfo]::InvariantCulture)
            foreach ($delta in @(-0.001, 0.0, 0.001)) {
                $candidateRate = [math]::Round($threshold + $delta, 3)
                if ($candidateRate -le 0) { continue }
                $rateKey = $candidateRate.ToString(
                    [Globalization.CultureInfo]::InvariantCulture)
                $routeRateSet[$rateKey] = $candidateRate
            }
        }
    }
}
$routeRates = [double[]]@($routeRateSet.Values | Sort-Object -Unique)

function Add-RouteIssue([string]$Message) {
    if ($Message) { $script:routeIssues[$Message] = $true }
}

function Get-RouteStart($Profile) {
    if ($Profile.Class -eq 'DEATHKNIGHT') {
        return [pscustomobject]@{
            Group = 'RestedXP Death Knight Start'
            Name = '55-58 The Scarlet Enclave'
        }
    }
    $group = if ($Profile.Faction -eq 'Alliance') {
        'RestedXP Speedrun Guide (A)'
    } else {
        'RestedXP Speedrun Guide (H)'
    }
    $name = switch ($Profile.Race) {
        'Human' { '1-11 Elwynn Forest'; break }
        'Dwarf' {
            if ($Profile.Class -eq 'HUNTER') { '1-11 Dun Morogh' }
            else { '1-6 Coldridge Valley' }
            break
        }
        'Gnome' {
            if ($Profile.Class -eq 'WARLOCK') { '1-12 Dun Morogh' }
            else { '1-6 Coldridge Valley' }
            break
        }
        'NightElf' { '1-6 Shadowglen'; break }
        'Draenei' { '1-12 Azuremyst Isle'; break }
        'Orc' { '1-6 Durotar'; break }
        'Troll' { '1-6 Durotar'; break }
        'Tauren' { '1-6 Mulgore'; break }
        'Scourge' { '1-6 Tirisfal Glades'; break }
        'BloodElf' { '1-6 Eversong Woods'; break }
    }
    if (-not $name) { return $null }
    return [pscustomobject]@{ Group = $group; Name = $name }
}

function Get-ExpectedEarlyRouteMilestone($Profile) {
    if ($Profile.Class -eq 'DEATHKNIGHT') { return $null }
    if ($Profile.Faction -eq 'Alliance') {
        if ($Profile.Race -eq 'Draenei') { return '11-20 Bloodmyst (Draenei)' }
        return '14-20 Bloodmyst'
    }
    $barrensClassRoute =
        $Profile.Class -in @('WARRIOR', 'SHAMAN') -or
        ($Profile.Class -eq 'HUNTER' -and
            $Profile.Race -in @('Orc', 'Troll'))
    if ($barrensClassRoute) {
        return '13-22 The Barrens'
    }
    return '16-20 Ghostlands'
}

$routeCatalogSources = @{}
foreach ($baseProfile in $profiles) {
    $baseKey = "$($baseProfile.Faction)|$($baseProfile.Race)|$($baseProfile.Class)"
    $catalogSources = New-Object 'Collections.Generic.List[object]'
    $probeProfile = [pscustomobject]@{
        Faction = $baseProfile.Faction; Race = $baseProfile.Race
        Class = $baseProfile.Class; Level = 1; Rate = 1.0
        ConditionKey = "$baseKey|1"
    }
    foreach ($guide in $primaryRouteGuides) {
        $probeName = Get-ApplicableHeaderValue $guide 'name' $probeProfile
        if (-not $probeName) { continue }
        $probeRange = Get-GuideLevelRange $probeName
        $guideLevel = if ($probeRange.Start -gt 0) { $probeRange.Start } else { 1 }
        $guideProfile = [pscustomobject]@{
            Faction = $probeProfile.Faction; Race = $probeProfile.Race
            Class = $probeProfile.Class; Level = $guideLevel; Rate = 1.0
            ConditionKey = "$baseKey|$guideLevel"
        }
        if (-not (Test-GuideConditions $guide $guideProfile)) { continue }
        $name = Get-ApplicableHeaderValue $guide 'name' $guideProfile
        $rawGroup = Get-ApplicableHeaderValue $guide 'group' $guideProfile
        if (-not $name -or -not $rawGroup) { continue }
        $group = Normalize-Group $rawGroup
        if (-not $primaryRouteGroups.ContainsKey($group)) { continue }
        $range = Get-GuideLevelRange $name
        $subgroup = Get-ApplicableHeaderValue $guide 'subgroup' $guideProfile
        $routeEventLevel = if ($range.Start -gt 0) { $range.Start } else { $guideLevel }
        $routeEventProfile = [pscustomobject]@{
            Faction = $probeProfile.Faction; Race = $probeProfile.Race
            Class = $probeProfile.Class; Level = $routeEventLevel; Rate = 1.0
            ConditionKey = "$baseKey|$routeEventLevel"
        }
        $baseLifecycleEvents = New-Object 'Collections.Generic.List[object]'
        $routeStepVisibility = @{}
        $routeStepRates = @{}
        foreach ($event in $guide.RouteEvents) {
            $isClosure = $event.Kind -eq 2 -or $event.Kind -eq 4
            $stepId = [int]$event.Metadata.Id
            if (-not $routeStepVisibility.ContainsKey($stepId)) {
                $routeStepVisibility[$stepId] =
                    Test-Applies $event.StepCondition $routeEventProfile
                $resolvedRate = ''
                foreach ($restriction in $event.Metadata.Rates) {
                    if (Test-Applies $restriction.Condition $routeEventProfile) {
                        $resolvedRate = $restriction.Expression
                    }
                }
                $routeStepRates[$stepId] = $resolvedRate
            }
            if (-not $routeStepVisibility[$stepId] -or
                ($event.Metadata.Optional -and -not $isClosure) -or
                -not (Test-Applies $event.LineCondition $routeEventProfile)) {
                continue
            }
            $baseLifecycleEvents.Add([pscustomobject]@{
                Event = $event; XpRate = [string]$routeStepRates[$stepId]
            })
        }
        $catalogSources.Add([pscustomobject]@{
            File = $guide.File; Group = $group; Name = $name; Range = $range
            MaxLevel = Get-ApplicableHeaderValue $guide 'maxlevel' $guideProfile
            SavedKey = "$group|$subgroup|$name"
            SourceKey = "$($guide.File)|$($guide.Name)"
            GuideRate = Get-ApplicableHeaderValue $guide 'xprate' $guideProfile
            Guide = $guide
            BaseLifecycleEvents = $baseLifecycleEvents
            LifecycleEvents = @{}
        })
    }
    $routeCatalogSources[$baseKey] = $catalogSources
}

foreach ($baseProfile in $profiles) {
    $baseKey = "$($baseProfile.Faction)|$($baseProfile.Race)|$($baseProfile.Class)"
    $catalogSources = $routeCatalogSources[$baseKey]

    # XP rate is consumed only through Test-XpRate in the route simulation.
    # Collapse sampled rates that produce the same truth vector for every
    # guide and lifecycle expression reachable by this class/race profile.
    # The full sampled-rate count and labels are retained below so this is a
    # computational optimization, not a reduction in validation coverage.
    $routeRateExpressionSet = @{}
    foreach ($instance in $catalogSources) {
        if ($instance.GuideRate) {
            $routeRateExpressionSet[[string]$instance.GuideRate] = $true
        }
        foreach ($candidateEvent in $instance.BaseLifecycleEvents) {
            if ($candidateEvent.XpRate) {
                $routeRateExpressionSet[[string]$candidateEvent.XpRate] = $true
            }
        }
    }
    $routeRateExpressions = @($routeRateExpressionSet.Keys | Sort-Object)
    $routeRateGroupsBySignature = @{}
    $routeRateGroups = New-Object 'Collections.Generic.List[object]'
    foreach ($candidateRate in $routeRates) {
        $signatureBuilder = [Text.StringBuilder]::new(
            [math]::Max(1, $routeRateExpressions.Count))
        foreach ($expression in $routeRateExpressions) {
            if (Test-XpRate $expression $candidateRate) {
                [void]$signatureBuilder.Append('1')
            } else {
                [void]$signatureBuilder.Append('0')
            }
        }
        $signature = $signatureBuilder.ToString()
        if (-not $routeRateGroupsBySignature.ContainsKey($signature)) {
            $rateGroup = [pscustomobject]@{
                Representative = [double]$candidateRate
                Rates = New-Object 'Collections.Generic.List[double]'
            }
            $routeRateGroupsBySignature[$signature] = $rateGroup
            $routeRateGroups.Add($rateGroup)
        }
        $routeRateGroupsBySignature[$signature].Rates.Add(
            [double]$candidateRate)
    }

    foreach ($rateGroup in $routeRateGroups) {
        $rate = [double]$rateGroup.Representative
        $profile = [pscustomobject]@{
            Faction = $baseProfile.Faction; Race = $baseProfile.Race
            Class = $baseProfile.Class; Level = 1; Rate = [double]$rate
            ConditionKey = "$baseKey|1"
        }
        $catalog = @{}
        foreach ($instance in $catalogSources) {
            if ($instance.GuideRate -and
                -not (Test-XpRate $instance.GuideRate $profile.Rate)) { continue }
            $lookupKey = "$($instance.Group)|$($instance.Name)"
            if ($catalog.ContainsKey($lookupKey)) {
                foreach ($actualRate in $rateGroup.Rates) {
                    Add-RouteIssue (
                        "Route catalog collision for $($profile.Race) $($profile.Class) @$actualRate`x: " +
                        "$lookupKey [$($catalog[$lookupKey].SavedKey)] and [$($instance.SavedKey)].")
                }
            } else {
                $catalog[$lookupKey] = $instance
            }
        }

        $start = Get-RouteStart $profile
        if (-not $start) {
            Add-RouteIssue "No route start mapping for $($profile.Race) $($profile.Class)."
            continue
        }

        foreach ($alignment in $routeAlignments) {
            $profileLabels = New-Object 'Collections.Generic.List[string]'
            foreach ($actualRate in $rateGroup.Rates) {
                $profileLabels.Add(
                    "$($profile.Race) $($profile.Class) @$actualRate`x/$alignment")
            }
            $routeMatrixRuns += $profileLabels.Count
            # Each reputation branch is an independent simulated login. Do
            # not let the completed Aldor trace leave the Scryer trace at 80.
            $profile.Level = if ($profile.Class -eq 'DEATHKNIGHT') { 55 } else { 1 }
            $profile.ConditionKey = "$baseKey|$($profile.Level)"
            $currentKey = "$($start.Group)|$($start.Name)"
            if (-not $catalog.ContainsKey($currentKey)) {
                foreach ($profileLabel in $profileLabels) {
                    Add-RouteIssue "Route matrix $profileLabel has no active starter $currentKey."
                }
                continue
            }

            $seen = @{}
            $traceNames = New-Object 'Collections.Generic.List[string]'
            $traceGroups = @{}
            $routeAccepted = @{}
            $routeObservedObjectives = @{}
            $routeWholeCompleted = @{}
            $routeCompletionSources = @{}
            $terminal = $false
            for ($hop = 0; $hop -lt 80; $hop++) {
                if ($seen.ContainsKey($currentKey)) {
                    foreach ($profileLabel in $profileLabels) {
                        Add-RouteIssue "Route matrix $profileLabel loops at $currentKey."
                    }
                    break
                }
                $seen[$currentKey] = $true
                $current = $catalog[$currentKey]
                if ($wantReport) {
                    if (-not $routeMembership.ContainsKey($current.SourceKey)) {
                        $routeMembership[$current.SourceKey] = @{}
                    }
                    $routeMembership[$current.SourceKey]["$($profile.Race) $($profile.Class)"] = $true
                }
                $traceNames.Add($current.Name)
                $traceGroups[$current.Group] = $true

                # Carry mandatory quest state through the complete primary
                # route. A per-guide scan cannot distinguish a deliberately
                # carried quest from one that is silently stranded when the
                # guide advances to its next chapter.
                $lifeKey = $profile.Rate.ToString(
                    [Globalization.CultureInfo]::InvariantCulture)
                if (-not $current.LifecycleEvents.ContainsKey($lifeKey)) {
                    $lifecycleEvents = New-Object 'Collections.Generic.List[object]'
                    foreach ($candidateEvent in $current.BaseLifecycleEvents) {
                        if ($candidateEvent.XpRate -and
                            -not (Test-XpRate $candidateEvent.XpRate $profile.Rate)) {
                            continue
                        }
                        $lifecycleEvents.Add($candidateEvent.Event)
                    }
                    $current.LifecycleEvents[$lifeKey] = $lifecycleEvents
                }
                foreach ($event in $current.LifecycleEvents[$lifeKey]) {
                    $questId = [int]$event.Quest
                    if ($event.Kind -eq 1) {
                        $routeAccepted[$questId] = [pscustomobject]@{
                            File = $current.File; Guide = $current.Name
                            Line = $event.Line
                        }
                        $routeObservedObjectives[$questId] = @{}
                        $routeWholeCompleted.Remove($questId)
                        $routeCompletionSources.Remove($questId)
                        if ($autoCompleteQuests[$questId]) {
                            $routeWholeCompleted[$questId] = $true
                            $routeCompletionSources[$questId] = [pscustomobject]@{
                                File = $current.File; Guide = $current.Name
                                Line = $event.Line
                            }
                        }
                    } elseif ($event.Kind -eq 3 -or $event.Kind -eq 5) {
                        if ($routeAccepted.ContainsKey($questId)) {
                            if ($event.Objective -gt 0) {
                                $routeObservedObjectives[$questId][$event.Objective] = $true
                            } else {
                                $routeWholeCompleted[$questId] = $true
                            }
                            $routeCompletionSources[$questId] = [pscustomobject]@{
                                File = $current.File; Guide = $current.Name
                                Line = $event.Line
                            }
                        }
                    } elseif ($event.Kind -eq 2 -or $event.Kind -eq 4) {
                        $routeAccepted.Remove($questId)
                        $routeObservedObjectives.Remove($questId)
                        $routeWholeCompleted.Remove($questId)
                        $routeCompletionSources.Remove($questId)
                    }
                }
                if ($current.Range.End -gt 0) {
                    $profile.Level = $current.Range.End
                    $profile.ConditionKey = "$baseKey|$($profile.Level)"
                }

                $nextValue = Get-ApplicableHeaderValue $current.Guide 'next' $profile
                if (-not $nextValue) {
                    if ($current.Range.End -ge 80 -and
                        $current.Group -eq ("RestedXP WotLK Guide (" +
                            $(if ($profile.Faction -eq 'Alliance') { 'A' } else { 'H' }) + ')')) {
                        $terminal = $true
                    } else {
                        foreach ($profileLabel in $profileLabels) {
                            Add-RouteIssue (
                                "Route matrix $profileLabel ends early at $currentKey " +
                                "(level $($current.Range.End)).")
                        }
                    }
                    break
                }

                $selected = $null
                $candidateDisplay = New-Object 'Collections.Generic.List[string]'
                foreach ($candidateRaw in ($nextValue -split ';')) {
                    $candidate = Resolve-RouteCandidate `
                        $current.Group $candidateRaw $alignment
                    if (-not $candidate) { continue }
                    $candidateKey = "$($candidate.Group)|$($candidate.Name)"
                    $candidateDisplay.Add($candidateKey)
                    if (-not $catalog.ContainsKey($candidateKey)) { continue }
                    $candidateGuide = $catalog[$candidateKey]
                    $maxLevel = 0
                    if ($candidateGuide.MaxLevel) {
                        [void][int]::TryParse([string]$candidateGuide.MaxLevel,
                                             [ref]$maxLevel)
                    }
                    if ($maxLevel -gt 0 -and $profile.Level -gt $maxLevel) { continue }
                    $selected = $candidateGuide
                    break
                }
                if (-not $selected) {
                    foreach ($profileLabel in $profileLabels) {
                        Add-RouteIssue (
                            "Route matrix $profileLabel cannot resolve #next from " +
                            "$currentKey to [$($candidateDisplay -join '; ')].")
                    }
                    break
                }
                $currentKey = "$($selected.Group)|$($selected.Name)"
            }

            if (-not $terminal) { continue }
            foreach ($questId in @($routeAccepted.Keys)) {
                $fullyCompleted = [bool]$routeWholeCompleted[$questId]
                if (-not $fullyCompleted -and
                    $questRequiredObjectives.ContainsKey($questId)) {
                    $required = $questRequiredObjectives[$questId]
                    $observed = $routeObservedObjectives[$questId]
                    if ($required.Count -gt 0 -and $null -ne $observed) {
                        $fullyCompleted = $true
                        foreach ($objective in $required.Keys) {
                            if (-not $observed.ContainsKey($objective)) {
                                $fullyCompleted = $false
                                break
                            }
                        }
                    }
                }
                if (-not $fullyCompleted -or
                    -not $routeCompletionSources.ContainsKey($questId)) { continue }
                $origin = $routeAccepted[$questId]
                $completion = $routeCompletionSources[$questId]
                $findingKey = "$($origin.File)|$($origin.Guide)|$questId"
                if (-not $routeOpenCompletions.ContainsKey($findingKey)) {
                    $routeOpenCompletions[$findingKey] = [pscustomobject]@{
                        Quest = $questId
                        AcceptedAt = "$($origin.File):$($origin.Line) $($origin.Guide)"
                        CompletedAt = "$($completion.File):$($completion.Line) $($completion.Guide)"
                        Profiles = New-Object 'Collections.Generic.List[string]'
                    }
                }
                if ($wantReport) {
                    foreach ($profileLabel in $profileLabels) {
                        if (-not $routeOpenCompletions[$findingKey].Profiles.Contains($profileLabel)) {
                            $routeOpenCompletions[$findingKey].Profiles.Add($profileLabel)
                        }
                    }
                }
            }
            $expectedEarly = Get-ExpectedEarlyRouteMilestone $profile
            if ($expectedEarly -and -not $traceNames.Contains($expectedEarly)) {
                foreach ($profileLabel in $profileLabels) {
                    Add-RouteIssue (
                        "Route matrix $profileLabel misses intended early milestone " +
                        "'$expectedEarly'.")
                }
            }
            $suffix = if ($profile.Faction -eq 'Alliance') { 'A' } else { 'H' }
            foreach ($requiredGroup in @(
                "RestedXP TBC Guide ($suffix)",
                "RestedXP WotLK Guide ($suffix)")) {
                if (-not $traceGroups.ContainsKey($requiredGroup)) {
                    foreach ($profileLabel in $profileLabels) {
                        Add-RouteIssue (
                            "Route matrix $profileLabel never enters $requiredGroup.")
                    }
                }
            }
        }
    }
}

foreach ($routeIssue in ($routeIssues.Keys | Sort-Object)) {
    $errors.Add($routeIssue)
}
foreach ($finding in ($routeOpenCompletions.Values | Sort-Object AcceptedAt, Quest)) {
    $errors.Add(
        "Primary route leaves fully completed quest $($finding.Quest) open " +
        "(accepted at $($finding.AcceptedAt); completed at $($finding.CompletedAt)).")
}

# Label/reference integrity is independent of XP-rate branches. A reference is
# valid when the authored 3.3.5 guide contains the label on an applicable class
# or race branch; the runtime parser then filters both branch halves.
if (-not $SkipLabelValidation) { foreach ($guide in $guides) {
    $labels = @{}
    $references = New-Object 'Collections.Generic.List[object]'
    foreach ($record in $guide.LabelRecords) {
        $reachable = (Test-ConditionReachable335 $record.StepCondition) -and
                     (Test-ConditionReachable335 $record.LineCondition)
        if (-not $reachable) { continue }
        if ($record.Kind -eq 'label') {
            $labels[$record.Name] = $record.Line
        } else {
            $references.Add($record)
        }
    }
    foreach ($reference in $references) {
        if ($reference.Name -ne 'next' -and
            -not $labels.ContainsKey($reference.Name)) {
            $errors.Add("$($guide.File):$($reference.Line) missing label '$($reference.Name)' in $($guide.Name)")
        }
    }
} }

# Lifecycle coverage is separate from prerequisite availability. A completed
# collection with no reward anywhere, or a class-only accept paired with an
# unconditional hand-in, can have perfectly valid prerequisite data.
$acceptOwners = @{}
$questWork = @{}
$questClosures = @{}
$lifecycleIssues = @{}
foreach ($guide in $guides) {
    $owner = "$($guide.File)|$($guide.Name)"
    foreach ($event in $guide.Events) {
        if (-not (Test-ConditionReachable335 $event.StepCondition) -or
            -not (Test-ConditionReachable335 $event.LineCondition)) { continue }
        $id = $event.Quest
        if ($event.Kind -eq 1) {
            if (-not $acceptOwners.ContainsKey($id)) { $acceptOwners[$id] = @{} }
            $acceptOwners[$id][$owner] = $true
        } elseif ($event.Kind -eq 3) {
            $questWork[$id] = "$($guide.File):$($event.Line) $($guide.Name)"
        } elseif ($event.Kind -eq 2 -or $event.Kind -eq 4) {
            $questClosures[$id] = $true
        }
    }
}
foreach ($id in $questWork.Keys) {
    if ($acceptOwners.ContainsKey($id) -and -not $questClosures.ContainsKey($id)) {
        $lifecycleIssues["$($questWork[$id]) works on accepted quest $id, but no validated guide rewards or explicitly abandons it."] = $true
    }
}

$rates = @(1.0, 1.1, 1.12, 1.3, 1.49, 1.5, 1.6, 1.7, 2.5)

$internalIssues = @{}
$applicableRuns = 0
if (-not $SkipQuestValidation) { foreach ($guide in $guides) {
    # Only run one representative rate for each distinct visibility result in
    # this guide. Most guides have no XP branch or only the 1.5x split, so this
    # retains threshold coverage without multiplying every guide by all rates.
    $xpExpressions = $guide.XpExpressions
    $guideRates = New-Object 'Collections.Generic.List[double]'
    $rateSignatures = @{}
    foreach ($rate in $rates) {
        $signature = (@($xpExpressions | ForEach-Object {
            if (Test-XpRate $_ $rate) { '1' } else { '0' }
        }) -join '')
        if (-not $rateSignatures.ContainsKey($signature)) {
            $rateSignatures[$signature] = $true
            $guideRates.Add([double]$rate)
        }
    }

    # Guide-level rates are independent of class. Step-level conditional
    # headers are resolved separately for each profile below.
    $rateData = New-Object 'Collections.Generic.List[object]'
    foreach ($guideRate in $guideRates) {
        $rateData.Add([pscustomobject]@{
            Rate = [double]$guideRate
            GuideVisible = Test-XpRate $guide.XpRate $guideRate
        })
    }

    # Profiles frequently produce byte-for-byte identical event streams. The
    # prerequisite state machine is a pure function of that stream, so retain
    # the full branch count while simulating each distinct stream once.
    $runGroups = @{}
    $orderedRunGroups = New-Object 'Collections.Generic.List[object]'
    foreach ($baseProfile in $profiles) {
        $profile = [pscustomobject]@{
            Faction = $baseProfile.Faction; Race = $baseProfile.Race;
            Class = $baseProfile.Class; Rate = 1.0;
            Level = if ($guide.Level -gt 0) { $guide.Level } else { 1 }
        }
        $profile | Add-Member -NotePropertyName ConditionKey -NotePropertyValue (
            "$($profile.Faction)|$($profile.Race)|$($profile.Class)|$($profile.Level)")
        if (-not (Test-GuideConditions $guide $profile)) { continue }

        $conditionVisibility = [bool[]]::new($guide.Events.Count)
        $profileRates = [string[]]::new($guide.Events.Count)
        $stepVisibility = @{}
        $stepRates = @{}
        for ($eventIndex = 0; $eventIndex -lt $guide.Events.Count; $eventIndex++) {
            $event = $guide.Events[$eventIndex]
            $stepId = [int]$event.Metadata.Id
            if (-not $stepVisibility.ContainsKey($stepId)) {
                $stepVisibility[$stepId] =
                    -not $event.Metadata.Optional -and
                    (Test-Applies $event.StepCondition $profile)
                $resolvedRate = ''
                foreach ($restriction in $event.Metadata.Rates) {
                    if (Test-Applies $restriction.Condition $profile) {
                        $resolvedRate = $restriction.Expression
                    }
                }
                $stepRates[$stepId] = $resolvedRate
            }
            $conditionVisibility[$eventIndex] =
                $stepVisibility[$stepId] -and
                (Test-Applies $event.LineCondition $profile)
            $profileRates[$eventIndex] = [string]$stepRates[$stepId]
        }

      foreach ($currentRate in $rateData) {
        if (-not $currentRate.GuideVisible) { continue }
        $applicableRuns++
        $rateResults = @{}
        $visibleIndices = New-Object 'Collections.Generic.List[int]'
        $signature = [Text.StringBuilder]::new(
                         [math]::Max(16, $guide.Events.Count * 3))
        for ($eventIndex = 0; $eventIndex -lt $guide.Events.Count; $eventIndex++) {
            $expression = [string]$profileRates[$eventIndex]
            if (-not $rateResults.ContainsKey($expression)) {
                $rateResults[$expression] = Test-XpRate $expression $currentRate.Rate
            }
            if ($conditionVisibility[$eventIndex] -and $rateResults[$expression]) {
                $visibleIndices.Add($eventIndex)
                if ($signature.Length -gt 0) { [void]$signature.Append(',') }
                [void]$signature.Append($eventIndex)
            }
        }

        $signatureKey = $signature.ToString()
        if (-not $runGroups.ContainsKey($signatureKey)) {
            $events = New-Object 'Collections.Generic.List[object]'
            foreach ($eventIndex in $visibleIndices) {
                $events.Add($guide.Events[$eventIndex])
            }
            $run = [pscustomobject]@{
                Events = $events
                Profiles = New-Object 'Collections.Generic.List[string]'
            }
            $runGroups[$signatureKey] = $run
            $orderedRunGroups.Add($run)
        }
        if ($wantReport -or $runGroups[$signatureKey].Profiles.Count -lt 4) {
            $runGroups[$signatureKey].Profiles.Add(
                "$($profile.Race) $($profile.Class) @$($currentRate.Rate)x")
        }
      }
    }

    foreach ($run in $orderedRunGroups) {
        $events = $run.Events
        $turnedIn = @{}
        $completed = @{}
        $accepted = @{}
        $priorWork = @{}
        $futureTurnIns = @{}
        foreach ($event in $events) {
            if ($event.Kind -eq 2) {
                $futureTurnIns[$event.Quest] = 1 + [int]$futureTurnIns[$event.Quest]
            }
        }
        $owner = "$($guide.File)|$($guide.Name)"
        for ($eventIndex = 0; $eventIndex -lt $events.Count; $eventIndex++) {
            $event = $events[$eventIndex]
            if ($event.Directive -in @('complete','turnin','turninmultiple') -and
                -not $event.SkipIfMissing -and
                -not $accepted[$event.Quest] -and -not $turnedIn[$event.Quest] -and
                -not $event.Metadata.Guards.ContainsKey($event.Quest)) {
                $owners = $acceptOwners[$event.Quest]
                # Potential ordering gap, not proof of an impossible route:
                # pre-looting, optional pickups, sticky labels, item-started
                # quests and manual entry all need runtime/server context.
                # Keep these explicit in the audit report, not a silent allowlist.
                if ($owners -and $owners.Count -eq 1 -and $owners.ContainsKey($owner)) {
                    $warning = "$($guide.File):$($event.Line) $($guide.Name) .$($event.Directive) $($event.Quest) has no preceding mandatory applicable accept"
                    if (-not $lifecycleWarnings.ContainsKey($warning)) {
                        $lifecycleWarnings[$warning] = New-Object 'Collections.Generic.List[string]'
                        if ($wantReport) {
                            $optionalPickups = @($guide.Events | Where-Object {
                                $_.Quest -eq $event.Quest -and $_.Line -lt $event.Line -and
                                $_.Kind -eq 1 -and $_.Metadata.Optional
                            } | ForEach-Object { $_.Line })
                            $lifecycleDetails[$warning] = [pscustomobject]@{
                                Owner = $owner; OptionalPickups = $optionalPickups
                            }
                        }
                    }
                    foreach ($profileName in $run.Profiles) {
                        if (($wantReport -or $lifecycleWarnings[$warning].Count -lt 4) -and
                            -not $lifecycleWarnings[$warning].Contains($profileName)) {
                            $lifecycleWarnings[$warning].Add($profileName)
                        }
                    }
                }
            }
            if ($event.Kind -eq 2) {
                $futureTurnIns[$event.Quest] = [int]$futureTurnIns[$event.Quest] - 1
                $turnedIn[$event.Quest] = $true
                $completed[$event.Quest] = $true
                $accepted.Remove($event.Quest)
                continue
            }
            if ($event.Kind -eq 4) {
                $accepted.Remove($event.Quest)
                continue
            }
            if ($event.Kind -eq 3) {
                $completed[$event.Quest] = $true
                $priorWork[$event.Quest] = $true
                continue
            }
            if ($event.Kind -ne 1) { continue }
            $specification = $prerequisites[$event.Quest]
            $missing = @(Get-MissingPrerequisites $specification $turnedIn $completed $accepted)
            if ($missing.Count -gt 0 -and $event.Metadata.Guards.Count -gt 0) {
                $unguarded = New-Object 'Collections.Generic.List[int]'
                foreach ($missingId in $missing) {
                    if (-not $event.Metadata.Guards.ContainsKey($missingId)) {
                        $unguarded.Add($missingId)
                    }
                }
                $missing = @($unguarded)
            }
            if ($missing.Count -gt 0) {
                foreach ($prerequisiteId in $missing) {
                $key = "$($guide.File)|$($guide.Name)|$($event.Line)|$($event.Quest)|$prerequisiteId"
                if ($priorWork[$prerequisiteId] -or [int]$futureTurnIns[$prerequisiteId] -gt 0) {
                    if (-not $internalIssues.ContainsKey($key)) {
                        $internalIssues[$key] = New-Object 'Collections.Generic.List[string]'
                    }
                    foreach ($profileName in $run.Profiles) {
                        if ($internalIssues[$key].Count -lt 4 -and
                            -not $internalIssues[$key].Contains($profileName)) {
                            $internalIssues[$key].Add($profileName)
                        }
                    }
                } else {
                    $entryKey = "$($guide.Group)|$($guide.Name)|$prerequisiteId"
                    if (-not $entryWarnings.ContainsKey($entryKey)) { $entryWarnings[$entryKey] = $true }
                }
                }
            }
            $accepted[$event.Quest] = $true
            if ($autoCompleteQuests[$event.Quest]) {
                $completed[$event.Quest] = $true
            }
            $priorWork[$event.Quest] = $true
        }
    }
} }

foreach ($key in $internalIssues.Keys | Sort-Object) {
    $parts = $key -split '\|'
    $profilesText = ($internalIssues[$key] | Select-Object -First 3) -join ', '
    if ($internalIssues[$key].Count -gt 3) { $profilesText += ', ...' }
    $errors.Add("$($parts[0]):$($parts[2]) $($parts[1]) accepts quest $($parts[3]) before prerequisite $($parts[4]) is active/completed [$profilesText]")
}

foreach ($issue in ($lifecycleIssues.Keys | Sort-Object)) { $errors.Add($issue) }
if ($FailOnLifecycleWarnings) {
    foreach ($warning in ($lifecycleWarnings.Keys | Sort-Object)) { $errors.Add($warning) }
}

if ($FailOnEntryWarnings) {
    foreach ($key in $entryWarnings.Keys) { $errors.Add("Unresolved guide-entry prerequisite: $key") }
}

if ($ReportPath) {
    # Index authored providers once. A provider is evidence for review, not
    # proof that every class/rate route actually visited or finished it.
    $providers = @{}
    foreach ($guide in $guides) {
        foreach ($event in $guide.Events) {
            if ($event.Directive -notin @('turnin','turninmultiple','dailyturnin')) { continue }
            if (-not $providers.ContainsKey($event.Quest)) { $providers[$event.Quest] = @{} }
            $source = "$($guide.File):$($event.Line) $($guide.Name)"
            $providers[$event.Quest][$source] = $true
        }
    }
    # Stable source-only diagnostics: no absolute source paths, account data,
    # timestamps, machine names or runtime SavedVariables in the artifact.
    $report = [ordered]@{
        schemaVersion = 3
        guideCount = $guides.Count
        branchRuns = $applicableRuns
        routeRuns = $routeMatrixRuns
        routeOpenCompletions = @(
            foreach ($finding in ($routeOpenCompletions.Values |
                Sort-Object AcceptedAt, Quest)) {
                [ordered]@{
                    quest = $finding.Quest
                    acceptedAt = $finding.AcceptedAt
                    completedAt = $finding.CompletedAt
                    profiles = @($finding.Profiles | Sort-Object)
                }
            }
        )
        errors = @($errors | Sort-Object)
        entryDependencies = @($entryWarnings.Keys | Sort-Object)
        entryReferences = @(
            foreach ($entry in ($entryWarnings.Keys | Sort-Object)) {
                $id = [int](($entry -split '\|')[-1])
                [ordered]@{
                    dependency = $entry
                    authoredProviders = @(if ($providers.ContainsKey($id)) {
                        @($providers[$id].Keys | Sort-Object)
                    })
                }
            }
        )
        lifecycleReviews = @(
            foreach ($warning in ($lifecycleWarnings.Keys | Sort-Object)) {
                $details = $lifecycleDetails[$warning]
                $members = $routeMembership[$details.Owner]
                $onRoute = @($lifecycleWarnings[$warning] | Where-Object {
                    $members -and $members.ContainsKey(($_ -replace ' @.*$', ''))
                })
                $context = if ($details.OptionalPickups.Count) { 'optional-pickup' }
                    elseif ($members -and $onRoute.Count -eq 0) { 'manual-off-route-entry' }
                    else { 'runtime-review' }
                [ordered]@{
                    finding = $warning
                    context = $context
                    precedingOptionalPickups = @($details.OptionalPickups)
                    profiles = @($lifecycleWarnings[$warning] | Sort-Object)
                    defaultRouteProfiles = @($onRoute | Sort-Object)
                }
            }
        )
    }
    $reportFile = [IO.Path]::GetFullPath($ReportPath)
    [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($reportFile))
    [IO.File]::WriteAllText($reportFile, ($report | ConvertTo-Json -Depth 6),
                          (New-Object Text.UTF8Encoding($false)))
}

if ($errors.Count -gt 0) {
    foreach ($message in ($errors | Select-Object -First $MaxErrors)) { Write-Host "ERROR: $message" -ForegroundColor Red }
    if ($errors.Count -gt $MaxErrors) { Write-Host "... $($errors.Count - $MaxErrors) additional error(s) omitted." -ForegroundColor Red }
    throw "3.3.5 quest-flow validation failed with $($errors.Count) error(s)."
}

Write-Host "Quest-flow validation passed: $($guides.Count) guides, $applicableRuns class/race/XP branch runs, $routeMatrixRuns complete route-matrix runs; missing-reward lifecycle check passed." -ForegroundColor Green
Write-Host "REVIEW: $($routeOpenCompletions.Count) route-open completions, $($lifecycleWarnings.Count) conditional/optional lifecycle findings, and $($entryWarnings.Count) entry dependencies need route/server context; this is not an exhaustive gameplay certification. Use -ReportPath for details."
