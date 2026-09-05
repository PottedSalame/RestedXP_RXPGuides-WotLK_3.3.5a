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
        # A bare condition disables the whole guide. Conditional #name and
        # #group headers are alternatives selected by the parser, so a
        # non-matching alternative must not disable an otherwise valid guide.
        if ($line -match '^<<\s*(.+)$' -and
            -not (Test-Applies $Matches[1] $Profile)) { return $false }
    }
    return $true
}

function Get-ApplicableHeaderValue(
    [string]$Header,
    [string]$Name,
    $Profile
) {
    $pattern = '^#' + [regex]::Escape($Name) + '(?:\s+(.*?))?\s*$'
    foreach ($rawLine in ($Header -split "`n")) {
        $line = $rawLine.Trim()
        $match = [regex]::Match($line, $pattern)
        if (-not $match.Success) { continue }
        $rawValue = $match.Groups[1].Value
        $condition = Get-Condition $line
        if ($condition -and -not (Test-Applies $condition $Profile)) { continue }
        return ($rawValue -replace '\s*<<.*$', '').Trim()
    }
    return $null
}

function Get-GuideLevelRange([string]$Name) {
    $match = [regex]::Match($Name, '(?<!\d)(\d{1,2})\s*-\s*(\d{1,2})(?!\d)')
    if (-not $match.Success) {
        return [pscustomobject]@{ Start = 0; End = 0 }
    }
    return [pscustomobject]@{
        Start = [int]$match.Groups[1].Value
        End = [int]$match.Groups[2].Value
    }
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
        $stepAt = $content.IndexOf("`nstep")
        $header = if ($stepAt -ge 0) { $content.Substring(0, $stepAt) } else { $content }
        $rawGroup = Get-Header $header 'group'
        $group = Normalize-Group $rawGroup
        $name = Get-Header $header 'name'
        if (-not $group -or -not $name) { continue }
        if ($rawGroup.TrimStart('+', '*').StartsWith('Original Guides - ')) { continue }
        $parsedEvents = New-Object 'Collections.Generic.List[object]'
        $stepCondition = ''
        $stepRate = ''
        $stepRateCondition = ''
        $stepMetadata = [pscustomobject]@{ Optional = $false; Guards = @{}; Rates = [Collections.Generic.List[object]]::new() }
        $lineNumber = 0
        $contentLines = $content -split "`n"
        foreach ($rawLine in $contentLines) {
            $lineNumber++
            $line = $rawLine.Trim()
            if ($line -match '^step\b') {
                $stepCondition = Get-Condition $line
                $stepRate = ''
                $stepRateCondition = ''
                $stepMetadata = [pscustomobject]@{ Optional = $false; Guards = @{}; Rates = [Collections.Generic.List[object]]::new() }
                continue
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
            if ($line -match '^\.(accept|acceptmultiple|daily|turnin|turninmultiple|dailyturnin|complete)\s+([^>]+)') {
                $directive = $Matches[1]
                $args = $Matches[2] -replace '\s*(?:--|<<).*$', ''
                $ids = @([regex]::Matches($args, '(?<![.\d])-?\d+(?![.\d])') | ForEach-Object { [int]$_.Value })
                if ($directive -notin @('acceptmultiple','daily','turninmultiple','dailyturnin') -and $ids.Count -gt 1) { $ids = @($ids[0]) }
                foreach ($id in $ids) {
                    $parsedEvents.Add([pscustomobject]@{
                        Directive = $directive; Quest = [math]::Abs($id); Line = $lineNumber;
                        SkipIfMissing = ($directive -eq 'turnin' -and $id -lt 0);
                        StepCondition = $stepCondition; LineCondition = Get-Condition $line;
                        XpRate = $stepRate; XpRateCondition = $stepRateCondition; Metadata = $stepMetadata
                    })
                }
            }
        }
        $guides.Add([pscustomobject]@{
            File = $relative; Group = $group; Name = $name; Content = $content;
            RawGroup = $rawGroup;
            Header = $header; Level = [int](([regex]::Match($name, '^(\d+)').Groups[1].Value) -as [int])
            # Only the pre-step header controls guide visibility. Step-level
            # #xprate directives are evaluated independently below.
            XpRate = Get-Header $header 'xprate'; Lines = $contentLines;
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
    foreach ($rateLine in [regex]::Matches(
        $routeGuide.Header, '(?m)^#xprate\s+(.+?)\s*$')) {
        foreach ($number in [regex]::Matches(
            $rateLine.Groups[1].Value, '\d+(?:\.\d+)?')) {
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

foreach ($baseProfile in $profiles) {
    foreach ($rate in $routeRates) {
        $profile = [pscustomobject]@{
            Faction = $baseProfile.Faction; Race = $baseProfile.Race
            Class = $baseProfile.Class; Level = 1; Rate = [double]$rate
        }
        $catalog = @{}
        foreach ($guide in $primaryRouteGuides) {
            $probeName = Get-ApplicableHeaderValue $guide.Header 'name' $profile
            if (-not $probeName) { continue }
            $probeRange = Get-GuideLevelRange $probeName
            $guideProfile = [pscustomobject]@{
                Faction = $profile.Faction; Race = $profile.Race
                Class = $profile.Class
                Level = if ($probeRange.Start -gt 0) { $probeRange.Start } else { 1 }
                Rate = $profile.Rate
            }
            if (-not (Test-GuideConditions $guide $guideProfile)) { continue }
            $name = Get-ApplicableHeaderValue $guide.Header 'name' $guideProfile
            $rawGroup = Get-ApplicableHeaderValue $guide.Header 'group' $guideProfile
            if (-not $name -or -not $rawGroup) { continue }
            $group = Normalize-Group $rawGroup
            if (-not $primaryRouteGroups.ContainsKey($group)) { continue }
            $guideRate = Get-ApplicableHeaderValue $guide.Header 'xprate' $guideProfile
            if ($guideRate -and -not (Test-XpRate $guideRate $profile.Rate)) { continue }
            $range = Get-GuideLevelRange $name
            $subgroup = Get-ApplicableHeaderValue $guide.Header 'subgroup' $guideProfile
            $instance = [pscustomobject]@{
                File = $guide.File; Header = $guide.Header; Group = $group
                Name = $name; Range = $range
                MaxLevel = Get-ApplicableHeaderValue $guide.Header 'maxlevel' $guideProfile
                SavedKey = "$group|$subgroup|$name"
                SourceKey = "$($guide.File)|$($guide.Name)"
            }
            $lookupKey = "$group|$name"
            if ($catalog.ContainsKey($lookupKey)) {
                Add-RouteIssue (
                    "Route catalog collision for $($profile.Race) $($profile.Class) @$rate`x: " +
                    "$lookupKey [$($catalog[$lookupKey].SavedKey)] and [$($instance.SavedKey)].")
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
            $routeMatrixRuns++
            # Each reputation branch is an independent simulated login. Do
            # not let the completed Aldor trace leave the Scryer trace at 80.
            $profile.Level = if ($profile.Class -eq 'DEATHKNIGHT') { 55 } else { 1 }
            $profileLabel = "$($profile.Race) $($profile.Class) @$rate`x/$alignment"
            $currentKey = "$($start.Group)|$($start.Name)"
            if (-not $catalog.ContainsKey($currentKey)) {
                Add-RouteIssue "Route matrix $profileLabel has no active starter $currentKey."
                continue
            }

            $seen = @{}
            $traceNames = New-Object 'Collections.Generic.List[string]'
            $traceGroups = @{}
            $terminal = $false
            for ($hop = 0; $hop -lt 80; $hop++) {
                if ($seen.ContainsKey($currentKey)) {
                    Add-RouteIssue "Route matrix $profileLabel loops at $currentKey."
                    break
                }
                $seen[$currentKey] = $true
                $current = $catalog[$currentKey]
                if (-not $routeMembership.ContainsKey($current.SourceKey)) {
                    $routeMembership[$current.SourceKey] = @{}
                }
                $routeMembership[$current.SourceKey]["$($profile.Race) $($profile.Class)"] = $true
                $traceNames.Add($current.Name)
                $traceGroups[$current.Group] = $true
                if ($current.Range.End -gt 0) { $profile.Level = $current.Range.End }

                $nextValue = Get-ApplicableHeaderValue $current.Header 'next' $profile
                if (-not $nextValue) {
                    if ($current.Range.End -ge 80 -and
                        $current.Group -eq ("RestedXP WotLK Guide (" +
                            $(if ($profile.Faction -eq 'Alliance') { 'A' } else { 'H' }) + ')')) {
                        $terminal = $true
                    } else {
                        Add-RouteIssue (
                            "Route matrix $profileLabel ends early at $currentKey " +
                            "(level $($current.Range.End)).")
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
                    Add-RouteIssue (
                        "Route matrix $profileLabel cannot resolve #next from " +
                        "$currentKey to [$($candidateDisplay -join '; ')].")
                    break
                }
                $currentKey = "$($selected.Group)|$($selected.Name)"
            }

            if (-not $terminal) { continue }
            $expectedEarly = Get-ExpectedEarlyRouteMilestone $profile
            if ($expectedEarly -and -not $traceNames.Contains($expectedEarly)) {
                Add-RouteIssue (
                    "Route matrix $profileLabel misses intended early milestone " +
                    "'$expectedEarly'.")
            }
            $suffix = if ($profile.Faction -eq 'Alliance') { 'A' } else { 'H' }
            foreach ($requiredGroup in @(
                "RestedXP TBC Guide ($suffix)",
                "RestedXP WotLK Guide ($suffix)")) {
                if (-not $traceGroups.ContainsKey($requiredGroup)) {
                    Add-RouteIssue (
                        "Route matrix $profileLabel never enters $requiredGroup.")
                }
            }
        }
    }
}

foreach ($routeIssue in ($routeIssues.Keys | Sort-Object)) {
    $errors.Add($routeIssue)
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
        if ($event.Directive -in @('accept','acceptmultiple','daily')) {
            if (-not $acceptOwners.ContainsKey($id)) { $acceptOwners[$id] = @{} }
            $acceptOwners[$id][$owner] = $true
        } elseif ($event.Directive -eq 'complete') {
            $questWork[$id] = "$($guide.File):$($event.Line) $($guide.Name)"
        } elseif ($event.Directive -in @('turnin','turninmultiple','dailyturnin')) {
            $questClosures[$id] = $true
        }
    }
    # An explicit abandonment documents an intentional partial quest. Keep it
    # distinct from simply losing a turn-in when content is imported/edited.
    foreach ($abandon in [regex]::Matches($guide.Content, '(?m)^\s*\.abandon\s+(\d+)')) {
        $questClosures[[int]$abandon.Groups[1].Value] = $true
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
    $xpExpressions = @($guide.Events | ForEach-Object { $_.Metadata.Rates.Expression } |
        Where-Object { $_ } | Select-Object -Unique)
    $guideRateExpression = Get-Header $guide.Header 'xprate'
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
        if (-not (Test-GuideConditions $guide $profile)) { continue }

        $conditionVisibility = [bool[]]::new($guide.Events.Count)
        $profileRates = [string[]]::new($guide.Events.Count)
        for ($eventIndex = 0; $eventIndex -lt $guide.Events.Count; $eventIndex++) {
            $event = $guide.Events[$eventIndex]
            $conditionVisibility[$eventIndex] =
                -not $event.Metadata.Optional -and
                (Test-Applies $event.StepCondition $profile) -and
                (Test-Applies $event.LineCondition $profile)
            # Runtime applies conditional headers in source order; the last
            # matching #xprate wins. A nonmatching Mage header must not erase
            # the Warlock threshold from the same step (or vice versa).
            foreach ($restriction in $event.Metadata.Rates) {
                if (Test-Applies $restriction.Condition $profile) {
                    $profileRates[$eventIndex] = $restriction.Expression
                }
            }
        }

      foreach ($currentRate in $rateData) {
        if (-not $currentRate.GuideVisible) { continue }
        $applicableRuns++
        $visible = [bool[]]::new($guide.Events.Count)
        $rateResults = @{}
        for ($eventIndex = 0; $eventIndex -lt $guide.Events.Count; $eventIndex++) {
            $expression = [string]$profileRates[$eventIndex]
            if (-not $rateResults.ContainsKey($expression)) {
                $rateResults[$expression] = Test-XpRate $expression $currentRate.Rate
            }
            $visible[$eventIndex] = $conditionVisibility[$eventIndex] -and $rateResults[$expression]
        }
        $signature = [Text.StringBuilder]::new(
                         [math]::Max(16, $guide.Events.Count * 3))
        for ($eventIndex = 0; $eventIndex -lt $guide.Events.Count; $eventIndex++) {
            if ($visible[$eventIndex]) {
                if ($signature.Length -gt 0) { [void]$signature.Append(',') }
                [void]$signature.Append($eventIndex)
            }
        }

        $signatureKey = $signature.ToString()
        if (-not $runGroups.ContainsKey($signatureKey)) {
            $events = New-Object 'Collections.Generic.List[object]'
            for ($eventIndex = 0; $eventIndex -lt $guide.Events.Count; $eventIndex++) {
                if ($visible[$eventIndex]) {
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
            if ($event.Directive -in @('complete','turnin','turninmultiple') -and
                -not $event.SkipIfMissing -and
                -not $accepted[$event.Quest] -and -not $turnedIn[$event.Quest] -and
                -not $event.Metadata.Guards.ContainsKey($event.Quest)) {
                $owners = $acceptOwners[$event.Quest]
                $owner = "$($guide.File)|$($guide.Name)"
                # Potential ordering gap, not proof of an impossible route:
                # pre-looting, optional pickups, sticky labels, item-started
                # quests and manual entry all need runtime/server context.
                # Keep these explicit in the audit report, not a silent allowlist.
                if ($owners -and $owners.Count -eq 1 -and $owners.ContainsKey($owner)) {
                    $warning = "$($guide.File):$($event.Line) $($guide.Name) .$($event.Directive) $($event.Quest) has no preceding mandatory applicable accept"
                    if (-not $lifecycleWarnings.ContainsKey($warning)) {
                        $lifecycleWarnings[$warning] = New-Object 'Collections.Generic.List[string]'
                        $optionalPickups = @($guide.Events | Where-Object {
                            $_.Quest -eq $event.Quest -and $_.Line -lt $event.Line -and
                            $_.Directive -in @('accept','acceptmultiple','daily') -and
                            $_.Metadata.Optional
                        } | ForEach-Object { $_.Line })
                        $lifecycleDetails[$warning] = [pscustomobject]@{
                            Owner = $owner; OptionalPickups = $optionalPickups
                        }
                    }
                    foreach ($profileName in $run.Profiles) {
                        if (-not $lifecycleWarnings[$warning].Contains($profileName)) {
                            $lifecycleWarnings[$warning].Add($profileName)
                        }
                    }
                }
            }
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
        schemaVersion = 2
        guideCount = $guides.Count
        branchRuns = $applicableRuns
        routeRuns = $routeMatrixRuns
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
Write-Host "REVIEW: $($lifecycleWarnings.Count) conditional/optional lifecycle findings and $($entryWarnings.Count) entry dependencies need route/server context; this is not an exhaustive gameplay certification. Use -ReportPath for details."
