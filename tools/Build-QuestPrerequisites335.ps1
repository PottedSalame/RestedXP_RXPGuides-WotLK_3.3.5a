param(
    [Parameter(Mandatory = $true)]
    [string]$QuestTemplatePath,
    [string]$OutputPath = ''
)

$ErrorActionPreference = 'Stop'
if (-not $OutputPath) {
    $OutputPath = Join-Path $PSScriptRoot '..\DB\wotlk\questPrerequisites_335.lua'
}
$sourcePath = [IO.Path]::GetFullPath($QuestTemplatePath)
$destinationPath = [IO.Path]::GetFullPath($OutputPath)
if (-not [IO.File]::Exists($sourcePath)) {
    throw "AzerothCore quest_template reference not found: $sourcePath"
}

# AzerothCore builds Quest::prevQuests from both a quest's signed PrevQuestId
# and every NextQuestId link that points at it. SatisfyQuestPreviousQuest ORs
# those candidates. A predecessor in a negative ExclusiveGroup expands to the
# whole group; positive groups remain alternatives.
$quests = @{}
foreach ($line in [IO.File]::ReadLines($sourcePath)) {
    if (-not $line.StartsWith('(')) { continue }
    # All fields needed here precede the first SQL string, so limiting Split
    # avoids having to interpret escaped commas in localized quest text.
    $fields = $line.Substring(1).Split(',', 26)
    if ($fields.Count -lt 25) { continue }
    $id = 0; $method = 0; $previous = 0; $next = 0; $exclusive = 0
    if (-not [int]::TryParse($fields[0], [ref]$id)) { continue }
    [void][int]::TryParse($fields[1], [ref]$method)
    [void][int]::TryParse($fields[21], [ref]$previous)
    [void][int]::TryParse($fields[22], [ref]$next)
    [void][int]::TryParse($fields[23], [ref]$exclusive)
    $quests[$id] = [pscustomobject]@{
        Id = $id; Method = $method; Previous = $previous
        Next = $next; Exclusive = $exclusive
    }
}
if ($quests.Count -eq 0) { throw 'No quest rows were parsed from the SQL input.' }

$exclusiveGroups = @{}
foreach ($quest in $quests.Values) {
    if ($quest.Exclusive -eq 0) { continue }
    if (-not $exclusiveGroups.ContainsKey($quest.Exclusive)) {
        $exclusiveGroups[$quest.Exclusive] = New-Object 'Collections.Generic.List[int]'
    }
    $exclusiveGroups[$quest.Exclusive].Add($quest.Id)
}

$previousCandidates = @{}
function Add-PreviousCandidate([int]$QuestId, [int]$Candidate) {
    if ($QuestId -le 0 -or $Candidate -eq 0 -or
        [math]::Abs($Candidate) -eq $QuestId) { return }
    if (-not $previousCandidates.ContainsKey($QuestId)) {
        $previousCandidates[$QuestId] = New-Object 'Collections.Generic.List[int]'
    }
    if (-not $previousCandidates[$QuestId].Contains($Candidate)) {
        $previousCandidates[$QuestId].Add($Candidate)
    }
}

foreach ($quest in $quests.Values) {
    if ($quest.Previous -ne 0) {
        Add-PreviousCandidate $quest.Id $quest.Previous
    }
    $nextId = [math]::Abs($quest.Next)
    if ($nextId -gt 0 -and $quests.ContainsKey($nextId)) {
        # The legacy combined table stores some destination IDs as negative;
        # the sign belongs to the link, not to the predecessor's completion
        # state. AzerothCore adds the source quest as a positive candidate.
        Add-PreviousCandidate $nextId $quest.Id
    }
}

function Get-RequirementKey([string]$State, [int]$Id) {
    return "$State$id"
}

$encodedEntries = New-Object 'Collections.Generic.List[string]'
foreach ($questId in @($previousCandidates.Keys | Sort-Object)) {
    $clauseKeys = @{}
    foreach ($candidate in $previousCandidates[$questId]) {
        $predecessorId = [math]::Abs($candidate)
        if (-not $quests.ContainsKey($predecessorId)) { continue }
        $predecessor = $quests[$predecessorId]
        $requirements = New-Object 'Collections.Generic.List[string]'

        if ($candidate -gt 0) {
            if ($predecessor.Exclusive -lt 0 -and
                $exclusiveGroups.ContainsKey($predecessor.Exclusive)) {
                foreach ($groupId in @($exclusiveGroups[$predecessor.Exclusive] | Sort-Object)) {
                    $requirements.Add((Get-RequirementKey 'R' $groupId))
                }
            } else {
                $requirements.Add((Get-RequirementKey 'R' $predecessorId))
            }
        } else {
            $requirements.Add((Get-RequirementKey 'A' $predecessorId))
            if ($predecessor.Exclusive -lt 0 -and
                $exclusiveGroups.ContainsKey($predecessor.Exclusive)) {
                # This mirrors AzerothCore's current implementation exactly:
                # the selected negative predecessor must be active while the
                # other members of its negative group must not be active.
                foreach ($groupId in @($exclusiveGroups[$predecessor.Exclusive] | Sort-Object)) {
                    if ($groupId -ne $predecessorId) {
                        $requirements.Add((Get-RequirementKey 'N' $groupId))
                    }
                }
            }
        }

        $clause = @($requirements | Sort-Object -Unique) -join '+'
        if ($clause) { $clauseKeys[$clause] = $true }
    }
    if ($clauseKeys.Count -gt 0) {
        $encodedEntries.Add("$questId=$(@($clauseKeys.Keys | Sort-Object) -join '|');")
    }
}

$lines = New-Object 'Collections.Generic.List[string]'
$current = ''
foreach ($entry in $encodedEntries) {
    if ($current.Length -gt 0 -and $current.Length + $entry.Length -gt 150) {
        $lines.Add($current)
        $current = ''
    }
    $current += $entry
}
if ($current) { $lines.Add($current) }

$header = @'
local _, addon = ...

-- Standalone quest prerequisites for AzerothCore's complete 3.3.5 quest set.
-- Generated by tools/Build-QuestPrerequisites335.ps1 from PrevQuestId,
-- NextQuestId, and ExclusiveGroup using AzerothCore's actual prevQuests rules:
-- https://github.com/azerothcore/azerothcore-wotlk/blob/master/src/server/game/Entities/Player/PlayerQuest.cpp
-- R = rewarded, A = active or rewarded, N = neither active nor rewarded.
-- + joins requirements in one AND clause; | joins alternative OR clauses.
local encoded = [[
'@

$footer = @'
]]

local prerequisites = {}
for questId, specification in string.gmatch(encoded, "(%d+)=([^;]+)") do
    local clauses = {}
    for clauseText in string.gmatch(specification .. "|", "([^|]+)|") do
        local requirements = {}
        for state, id in string.gmatch(clauseText, "([RAN])(%d+)") do
            table.insert(requirements, {state = state, id = tonumber(id)})
        end
        if #requirements > 0 then table.insert(clauses, requirements) end
    end
    if #clauses > 0 then
        prerequisites[tonumber(questId)] = {clauses = clauses}
    end
end

addon.QuestPrerequisites335 = prerequisites
'@

$content = $header + ($lines -join "`r`n") + "`r`n" + $footer
[IO.File]::WriteAllText($destinationPath, $content, [Text.UTF8Encoding]::new($false))
Write-Host "Generated $($encodedEntries.Count) quest prerequisite records from $($quests.Count) quests." -ForegroundColor Green
