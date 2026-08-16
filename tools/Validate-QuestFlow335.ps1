param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot '..\GuideList_335.xml'),
    [string]$QuestTemplatePath = '',
    [int]$MaxErrors = 200,
    [switch]$FailOnEntryWarnings,
    [switch]$SkipLabelValidation,
    [switch]$SkipQuestValidation
)

$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$errors = New-Object 'Collections.Generic.List[string]'
$entryWarnings = @{}
$conditionCache = @{}
$reachabilityCache = @{}
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
    $cacheKey = "$($Profile.Faction)|$($Profile.Race)|$($Profile.Class)|$($Profile.Level)|$Condition"
    if ($conditionCache.ContainsKey($cacheKey)) { return $conditionCache[$cacheKey] }
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
        if ($matches) { $conditionCache[$cacheKey] = $true; return $true }
    }
    $conditionCache[$cacheKey] = $false
    return $false
}

function Test-XpRate([string]$Expression, [double]$Rate) {
    if ([string]::IsNullOrWhiteSpace($Expression)) { return $true }
    if ($Expression -match '^<\s*(\d+(?:\.\d+)?)') { return $Rate -lt [double]$Matches[1] }
    if ($Expression -match '^>\s*(\d+(?:\.\d+)?)') { return $Rate -gt [double]$Matches[1] }
    if ($Expression -match '^(\d+(?:\.\d+)?)\s*-\s*(\d+(?:\.\d+)?)') {
        return $Rate -ge [double]$Matches[1] -and $Rate -le [double]$Matches[2]
    }
    if ($Expression -match '^(\d+(?:\.\d+)?)$') { return $Rate -ge [double]$Matches[1] }
    return $true
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
    $header = $Guide.Header
    $expansionHeaders = [regex]::Matches($header, '(?m)^#(?:classic|tbc|wotlk|cata|mop|retail|df)\b')
    if ($expansionHeaders.Count -gt 0 -and $header -notmatch '(?m)^#wotlk\b') { return $false }
    foreach ($line in ($header -split "`n")) {
        if ($line -match '^(?:<<|#(?:group|name)\b).*<<\s*(.+)$' -and
            -not (Test-Applies $Matches[1] $Profile)) { return $false }
        if ($line -match '^<<\s*(.+)$' -and -not (Test-Applies $Matches[1] $Profile)) { return $false }
    }
    return $true
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
foreach ($fileMatch in [regex]::Matches($manifest, '<Script\s+file="([^"]+)"\s*/>')) {
    $relative = $fileMatch.Groups[1].Value -replace '\\', [IO.Path]::DirectorySeparatorChar
    $path = [IO.Path]::GetFullPath((Join-Path $root $relative))
    if (-not [IO.File]::Exists($path)) { continue }
    $text = [IO.File]::ReadAllText($path)
    foreach ($guideMatch in $guidePattern.Matches($text)) {
        $content = $guideMatch.Groups[1].Value -replace "`r`n", "`n"
        $group = Normalize-Group (Get-Header $content 'group')
        $name = Get-Header $content 'name'
        if (-not $group -or -not $name) { continue }
        if ($group.TrimStart('+', '*').StartsWith('Original Guides - ')) { continue }
        $stepAt = $content.IndexOf("`nstep")
        $header = if ($stepAt -ge 0) { $content.Substring(0, $stepAt) } else { $content }
        $parsedEvents = New-Object 'Collections.Generic.List[object]'
        $stepCondition = ''
        $stepRate = ''
        $stepMetadata = [pscustomobject]@{ Optional = $false; Guards = @{} }
        $lineNumber = 0
        $contentLines = $content -split "`n"
        foreach ($rawLine in $contentLines) {
            $lineNumber++
            $line = $rawLine.Trim()
            if ($line -match '^step\b') {
                $stepCondition = Get-Condition $line
                $stepRate = ''
                $stepMetadata = [pscustomobject]@{ Optional = $false; Guards = @{} }
                continue
            }
            if ($line -match '^#optional\b') {
                $stepMetadata.Optional = $true
                continue
            }
            if ($line -match '^#xprate\s+(.+?)(?:\s*<<|$)') {
                $stepRate = $Matches[1].Trim()
                continue
            }
            if ($line -match '^\.(?:isQuestTurnedIn|isQuestComplete|isOnQuest)\s+([^>]+)') {
                foreach ($guardId in @([regex]::Matches($Matches[1], '(?<![.\d])-?\d+(?![.\d])') |
                    ForEach-Object { [math]::Abs([int]$_.Value) })) {
                    $stepMetadata.Guards[$guardId] = $true
                }
            }
            if ($line -match '^\.(accept|acceptmultiple|daily|turnin|turninmultiple|dailyturnin|complete)\s+([^>]+)') {
                $directive = $Matches[1]
                $args = $Matches[2] -replace '\s*--.*$', ''
                $ids = @([regex]::Matches($args, '(?<![.\d])-?\d+(?![.\d])') | ForEach-Object { [math]::Abs([int]$_.Value) })
                if ($directive -notin @('acceptmultiple','daily','turninmultiple','dailyturnin') -and $ids.Count -gt 1) { $ids = @($ids[0]) }
                foreach ($id in $ids) {
                    $parsedEvents.Add([pscustomobject]@{
                        Directive = $directive; Quest = $id; Line = $lineNumber;
                        StepCondition = $stepCondition; LineCondition = Get-Condition $line;
                        XpRate = $stepRate; Metadata = $stepMetadata
                    })
                }
            }
        }
        $guides.Add([pscustomobject]@{
            File = $relative; Group = $group; Name = $name; Content = $content;
            Header = $header; Level = [int](([regex]::Match($name, '^(\d+)').Groups[1].Value) -as [int])
            XpRate = Get-Header $content 'xprate'; Lines = $contentLines;
            Events = $parsedEvents
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
        })
    }
}

# Label/reference integrity is independent of XP-rate branches. A reference is
# valid when the authored 3.3.5 guide contains the label on an applicable class
# or race branch; the runtime parser then filters both branch halves.
if (-not $SkipLabelValidation) { foreach ($guide in $guides) {
    $labels = @{}
    $references = New-Object 'Collections.Generic.List[object]'
    $stepCondition = ''
    $lineNumber = 0
    foreach ($rawLine in $guide.Lines) {
        $lineNumber++
        $line = $rawLine.Trim()
        if ($line -match '^step\b') { $stepCondition = Get-Condition $line; continue }
        if ($line -notmatch '^#(?:label|requires|completewith)\s+(\S+)') { continue }
        $kind = if ($line.StartsWith('#label')) { 'label' } else { 'reference' }
        $value = $Matches[1]
        $reachable = (Test-ConditionReachable335 $stepCondition) -and
                     (Test-ConditionReachable335 (Get-Condition $line))
        if (-not $reachable) { continue }
        if ($kind -eq 'label') {
            $labels[$value] = $lineNumber
        } else {
            $references.Add([pscustomobject]@{ Name = $value; Line = $lineNumber })
        }
    }
    foreach ($reference in $references) {
        if ($reference.Name -ne 'next' -and
            -not $labels.ContainsKey($reference.Name)) {
            $errors.Add("$($guide.File):$($reference.Line) missing label '$($reference.Name)' in $($guide.Name)")
        }
    }
} }

$rates = @(1.0, 1.1, 1.12, 1.3, 1.49, 1.5, 1.6, 1.7, 2.5)

$internalIssues = @{}
$applicableRuns = 0
if (-not $SkipQuestValidation) { foreach ($guide in $guides) {
    # Only run one representative rate for each distinct visibility result in
    # this guide. Most guides have no XP branch or only the 1.5x split, so this
    # retains threshold coverage without multiplying every guide by all rates.
    $xpExpressions = @($guide.Events | ForEach-Object { $_.XpRate } |
        Where-Object { $_ } | Select-Object -Unique)
    $guideRateExpression = Get-Header $guide.Content 'xprate'
    if ($guideRateExpression) { $xpExpressions += $guideRateExpression }
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

    # XP-rate expressions depend only on the representative rate, not on the
    # character profile. Resolve them once per guide/rate instead of once for
    # every class/race branch.
    $rateData = New-Object 'Collections.Generic.List[object]'
    foreach ($guideRate in $guideRates) {
        $eventRateVisibility = [bool[]]::new($guide.Events.Count)
        for ($eventIndex = 0; $eventIndex -lt $guide.Events.Count; $eventIndex++) {
            $eventRateVisibility[$eventIndex] = Test-XpRate $guide.Events[$eventIndex].XpRate $guideRate
        }
        $rateData.Add([pscustomobject]@{
            Rate = [double]$guideRate
            GuideVisible = Test-XpRate $guide.XpRate $guideRate
            EventVisible = $eventRateVisibility
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
        if (-not (Test-GuideConditions $guide $profile)) { continue }

        $conditionVisibility = [bool[]]::new($guide.Events.Count)
        for ($eventIndex = 0; $eventIndex -lt $guide.Events.Count; $eventIndex++) {
            $event = $guide.Events[$eventIndex]
            $conditionVisibility[$eventIndex] =
                -not $event.Metadata.Optional -and
                (Test-Applies $event.StepCondition $profile) -and
                (Test-Applies $event.LineCondition $profile)
        }

      foreach ($currentRate in $rateData) {
        if (-not $currentRate.GuideVisible) { continue }
        $applicableRuns++
        $signature = [Text.StringBuilder]::new(
                         [math]::Max(16, $guide.Events.Count * 3))
        for ($eventIndex = 0; $eventIndex -lt $guide.Events.Count; $eventIndex++) {
            if ($conditionVisibility[$eventIndex] -and
                $currentRate.EventVisible[$eventIndex]) {
                if ($signature.Length -gt 0) { [void]$signature.Append(',') }
                [void]$signature.Append($eventIndex)
            }
        }

        $signatureKey = $signature.ToString()
        if (-not $runGroups.ContainsKey($signatureKey)) {
            $events = New-Object 'Collections.Generic.List[object]'
            for ($eventIndex = 0; $eventIndex -lt $guide.Events.Count; $eventIndex++) {
                if ($conditionVisibility[$eventIndex] -and
                    $currentRate.EventVisible[$eventIndex]) {
                    $events.Add($guide.Events[$eventIndex])
                }
            }
            $run = [pscustomobject]@{
                Events = $events
                Profiles = New-Object 'Collections.Generic.List[string]'
            }
            $runGroups[$signatureKey] = $run
            $orderedRunGroups.Add($run)
        }
        $runGroups[$signatureKey].Profiles.Add(
            "$($profile.Race) $($profile.Class) @$($currentRate.Rate)x")
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
            if ($event.Directive -in @('turnin','turninmultiple','dailyturnin')) {
                $futureTurnIns[$event.Quest] = 1 + [int]$futureTurnIns[$event.Quest]
            }
        }
        for ($eventIndex = 0; $eventIndex -lt $events.Count; $eventIndex++) {
            $event = $events[$eventIndex]
            if ($event.Directive -in @('turnin','turninmultiple','dailyturnin')) {
                $futureTurnIns[$event.Quest] = [int]$futureTurnIns[$event.Quest] - 1
                $turnedIn[$event.Quest] = $true
                $completed[$event.Quest] = $true
                $accepted.Remove($event.Quest)
                continue
            }
            if ($event.Directive -eq 'complete') {
                $completed[$event.Quest] = $true
                $priorWork[$event.Quest] = $true
                continue
            }
            if ($event.Directive -notin @('accept','acceptmultiple','daily')) { continue }
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
                        if (-not $internalIssues[$key].Contains($profileName)) {
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

if ($FailOnEntryWarnings) {
    foreach ($key in $entryWarnings.Keys) { $errors.Add("Unresolved guide-entry prerequisite: $key") }
}

if ($errors.Count -gt 0) {
    foreach ($message in ($errors | Select-Object -First $MaxErrors)) { Write-Host "ERROR: $message" -ForegroundColor Red }
    if ($errors.Count -gt $MaxErrors) { Write-Host "... $($errors.Count - $MaxErrors) additional error(s) omitted." -ForegroundColor Red }
    throw "3.3.5 quest-flow validation failed with $($errors.Count) error(s)."
}

Write-Host "Quest-flow validation passed: $($guides.Count) guides, $applicableRuns class/race/XP branch runs, $($entryWarnings.Count) documented entry dependencies." -ForegroundColor Green
