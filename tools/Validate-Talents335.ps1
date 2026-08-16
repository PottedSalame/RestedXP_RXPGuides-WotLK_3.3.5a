param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot '..\Talents_wotlk_335.xml'),
    [string]$TalentDataPath,
    [int]$MaxErrors = 100
)

$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$errors = New-Object 'Collections.Generic.List[string]'
$plans = New-Object 'Collections.Generic.List[object]'
$knownHeaders = @{
    name = $true; next = $true; minLevel = $true; maxLevel = $true; reset = $true
    description = $true; displayname = $true; key = $true; pet = $true
    order = $true; hardcore = $true
}

function Add-ValidationError([string]$Message) { $errors.Add($Message) }

$talentLayouts = @{}
if ($TalentDataPath) {
    $talentDataFullPath = [IO.Path]::GetFullPath($TalentDataPath)
    if (-not [IO.File]::Exists($talentDataFullPath)) {
        throw "Talent reference data is missing: $talentDataFullPath"
    }
    $classTokens = @{
        deathknight = 'DEATHKNIGHT'; druid = 'DRUID'; hunter = 'HUNTER'; mage = 'MAGE'; paladin = 'PALADIN'
        priest = 'PRIEST'; rogue = 'ROGUE'; shaman = 'SHAMAN'; warlock = 'WARLOCK'; warrior = 'WARRIOR'
    }
    $talentNames = @{}
    $reference = [IO.File]::ReadAllText($talentDataFullPath) | ConvertFrom-Json
    foreach ($classData in $reference.classes) {
        $classToken = $classTokens[$classData.id]
        if (-not $classToken) { continue }
        for ($treeIndex = 0; $treeIndex -lt $classData.trees.Count; $treeIndex++) {
            foreach ($talent in $classData.trees[$treeIndex].talents) {
                $tab = $treeIndex + 1
                $position = "$tab,$([int]$talent.row + 1),$([int]$talent.col + 1)"
                $talentLayouts["$classToken|$position"] = [pscustomobject]@{
                    Name = $talent.name
                    MaxRank = [int]$talent.maxRank
                    Attached = $talent.attached
                    ParentPosition = $null
                }
                $talentNames["$classToken|$tab|$($talent.name.ToLowerInvariant())"] = $position
            }
        }
    }
    foreach ($layoutKey in @($talentLayouts.Keys)) {
        $layout = $talentLayouts[$layoutKey]
        if (-not $layout.Attached -or $layout.Attached -eq 'none') { continue }
        $classToken, $position = $layoutKey -split '\|', 2
        $tab = ($position -split ',')[0]
        $parentName = $layout.Attached
        # Correct a typo in the external Spell.dbc-derived reference file.
        if ($parentName -eq 'Sweeping Strike') { $parentName = 'Sweeping Strikes' }
        $layout.ParentPosition = $talentNames["$classToken|$tab|$($parentName.ToLowerInvariant())"]
        if (-not $layout.ParentPosition) {
            Add-ValidationError "Talent reference cannot resolve prerequisite $parentName for $classToken $($layout.Name)."
        }
    }
}

function Test-ReferenceTalent([string]$Class, [string]$File, [string]$Plan, [string]$Position,
                              [int]$Rank, [hashtable]$CurrentRanks) {
    if ($talentLayouts.Count -eq 0) { return }
    $layout = $talentLayouts["$Class|$Position"]
    if (-not $layout) {
        Add-ValidationError "$File / $Plan references a nonexistent talent position $Position."
        return
    }
    if ($Rank -gt $layout.MaxRank) {
        Add-ValidationError "$File / $Plan gives $($layout.Name) rank $Rank; maximum is $($layout.MaxRank)."
    }
    if ($layout.ParentPosition) {
        $parent = $talentLayouts["$Class|$($layout.ParentPosition)"]
        $parentRank = if ($CurrentRanks.ContainsKey($layout.ParentPosition)) {
            $CurrentRanks[$layout.ParentPosition]
        } else { 0 }
        if ($parentRank -lt $parent.MaxRank) {
            Add-ValidationError "$File / $Plan takes $($layout.Name) before completing $($parent.Name)."
        }
    }
}

$manifestFullPath = [IO.Path]::GetFullPath($ManifestPath)
if (-not [IO.File]::Exists($manifestFullPath)) { throw "Talent manifest is missing: $manifestFullPath" }
$manifest = [IO.File]::ReadAllText($manifestFullPath)
$files = New-Object 'Collections.Generic.List[string]'
$seenFiles = @{}

foreach ($match in [regex]::Matches($manifest, '<Script\s+file="([^"]+)"\s*/>')) {
    $relative = $match.Groups[1].Value -replace '\\', [IO.Path]::DirectorySeparatorChar
    $path = [IO.Path]::GetFullPath((Join-Path $root $relative))
    if ($seenFiles.ContainsKey($path)) {
        Add-ValidationError "Talent manifest loads a file more than once: $relative"
        continue
    }
    $seenFiles[$path] = $true
    if (-not [IO.File]::Exists($path)) {
        Add-ValidationError "Talent manifest file is missing: $relative"
        continue
    }
    $files.Add($path)
}

if ($files.Count -eq 0) { Add-ValidationError 'Talent manifest contains no Script entries.' }

$guidePattern = [regex]'(?ms)addon\.talents\.RegisterGuide\s*\(\[\[(.*?)\]\]\)'
$buildPattern = [regex]'(?ms)addon\.talents\.RegisterBuild\s*\(\s*"([^"]+)"\s*,\s*\[\[(.*?)\]\]\s*\)'
$guideKeys = @{}
$stepCount = 0

foreach ($path in $files) {
    $relative = $path.Substring($root.Length).TrimStart([IO.Path]::DirectorySeparatorChar,
                                                        [IO.Path]::AltDirectorySeparatorChar)
    $content = [IO.File]::ReadAllText($path)
    $classMatch = [regex]::Match($content, 'addon\.player\.class\s*~=\s*"([A-Z]+)"')
    if (-not $classMatch.Success) {
        Add-ValidationError "$relative has no class load guard."
        continue
    }
    $class = $classMatch.Groups[1].Value
    $blocks = $guidePattern.Matches($content)
    $buildBlocks = $buildPattern.Matches($content)
    if ($blocks.Count -eq 0 -and $buildBlocks.Count -eq 0) {
        Add-ValidationError "$relative registers no talent plans."
        continue
    }

    foreach ($block in $blocks) {
        $body = $block.Groups[1].Value
        $headers = @{}
        $steps = New-Object 'Collections.Generic.List[object]'
        $currentStep = $null
        $lineNumber = 0

        foreach ($rawLine in ($body -split "`r?`n")) {
            $lineNumber++
            $line = $rawLine.Trim()
            if (-not $line -or $line.StartsWith('--')) { continue }

            if ($line -eq 'level' -or $line -match '^level\s') {
                $commentRank = $null
                if ($line -match '\(Rank\s+(\d+)\)') { $commentRank = [int]$Matches[1] }
                $currentStep = [pscustomobject]@{
                    Line = $lineNumber
                    Optional = $false
                    Talents = New-Object 'Collections.Generic.List[object]'
                    CommentRank = $commentRank
                }
                $steps.Add($currentStep)
                continue
            }

            if ($null -eq $currentStep) {
                if ($line -notmatch '^#(\S+)\s*(.*)$') {
                    Add-ValidationError "$relative`:$lineNumber invalid pre-plan line: $line"
                    continue
                }
                $header = $Matches[1]
                $value = $Matches[2].Trim()
                if (-not $knownHeaders.ContainsKey($header)) {
                    Add-ValidationError "$relative`:$lineNumber unknown talent header #$header"
                } elseif ($headers.ContainsKey($header)) {
                    Add-ValidationError "$relative`:$lineNumber duplicate talent header #$header"
                } else {
                    $headers[$header] = $value
                }
                continue
            }

            if ($line -eq '#optional') { $currentStep.Optional = $true; continue }
            if ($line -notmatch '^\.(talent|pettalent)\s+(\d+)\s*,\s*(\d+)\s*,\s*(\d+)(?:\s*,\s*(\d+))?\s*$') {
                Add-ValidationError "$relative`:$lineNumber invalid talent directive: $line"
                continue
            }

            $kind = $Matches[1]
            $tab = [int]$Matches[2]
            $tier = [int]$Matches[3]
            $column = [int]$Matches[4]
            $rank = if ($Matches[5]) { [int]$Matches[5] } else { 1 }
            $maxTier = if ($kind -eq 'pettalent') { 6 } else { 11 }
            $maxRank = if ($kind -eq 'pettalent') { 3 } else { 5 }
            if ($tab -lt 1 -or $tab -gt 3 -or $tier -lt 1 -or $tier -gt $maxTier -or
                $column -lt 1 -or $column -gt 4 -or $rank -lt 1 -or $rank -gt $maxRank) {
                Add-ValidationError "$relative`:$lineNumber out-of-range $kind coordinate $tab,$tier,$column,$rank"
            }
            $currentStep.Talents.Add([pscustomobject]@{
                Kind = $kind; Tab = $tab; Tier = $tier; Column = $column; Rank = $rank; Line = $lineNumber
            })
        }

        $name = $headers['name']
        if (-not $name) { Add-ValidationError "$relative has a talent plan without #name."; $name = '<unnamed>' }
        $minLevel = 0
        $maxLevel = 0
        if (-not [int]::TryParse($headers['minLevel'], [ref]$minLevel) -or $minLevel -lt 1) {
            Add-ValidationError "$relative / $name has an invalid #minLevel."
        }
        if (-not [int]::TryParse($headers['maxLevel'], [ref]$maxLevel) -or $maxLevel -lt $minLevel) {
            Add-ValidationError "$relative / $name has an invalid #maxLevel."
        }
        $isPetPlan = $headers.ContainsKey('pet') -and -not [string]::IsNullOrWhiteSpace($headers['pet'])
        if (-not $isPetPlan -and $steps.Count -ne ($maxLevel - $minLevel + 1)) {
            Add-ValidationError "$relative / $name has $($steps.Count) steps for levels $minLevel-$maxLevel."
        }
        if ($isPetPlan -and $steps.Count -ne 16 -and $steps.Count -ne 20) {
            Add-ValidationError "$relative / $name has $($steps.Count) pet points; expected a 16- or 20-point plan."
        }

        $key = "$class - $name"
        if ($guideKeys.ContainsKey($key)) {
            Add-ValidationError "$relative duplicates talent guide key: $key"
        } else {
            $guideKeys[$key] = $true
        }

        $ranks = @{}
        $tabPoints = @{ 1 = 0; 2 = 0; 3 = 0 }
        foreach ($step in $steps) {
            if ($step.Talents.Count -eq 0) {
                Add-ValidationError "$relative / $name has an empty step at level $($minLevel + $steps.IndexOf($step))."
                continue
            }
            if (-not $step.Optional -and $step.Talents.Count -ne 1) {
                Add-ValidationError "$relative`:$($step.Line) non-optional step has $($step.Talents.Count) directives."
            }
            foreach ($talent in $step.Talents) {
                if ($talent.Kind -ne 'talent' -and $talent.Kind -ne 'pettalent') { continue }
                $position = "$($talent.Tab),$($talent.Tier),$($talent.Column)"
                $expectedRank = if ($ranks.ContainsKey($position)) { $ranks[$position] + 1 } else { 1 }
                if ($talent.Rank -ne $expectedRank) {
                    Add-ValidationError "$relative`:$($talent.Line) $position uses rank $($talent.Rank), expected $expectedRank."
                }
                if ($null -ne $step.CommentRank -and $talent.Rank -ne $step.CommentRank) {
                    Add-ValidationError "$relative`:$($talent.Line) comment says rank $($step.CommentRank), directive uses rank $($talent.Rank)."
                }
                $requiredPoints = ($talent.Tier - 1) * 3
                if ($talent.Kind -eq 'talent') { $requiredPoints = ($talent.Tier - 1) * 5 }
                if ($tabPoints[$talent.Tab] -lt $requiredPoints) {
                    Add-ValidationError "$relative`:$($talent.Line) $position requires $requiredPoints prior tree points; plan has $($tabPoints[$talent.Tab])."
                }
                if ($talent.Kind -eq 'talent') {
                    Test-ReferenceTalent $class $relative $name $position $talent.Rank $ranks
                }
                $ranks[$position] = $talent.Rank
                $tabPoints[$talent.Tab]++
            }
        }

        $primaryTab = 1
        if ($tabPoints[2] -gt $tabPoints[$primaryTab]) { $primaryTab = 2 }
        if ($tabPoints[3] -gt $tabPoints[$primaryTab]) { $primaryTab = 3 }
        $plans.Add([pscustomobject]@{
            File = $relative; Class = $class; Name = $name; Next = $headers['next']; Steps = $steps.Count
            PrimaryTab = $primaryTab
        })
        $stepCount += $steps.Count
    }

    foreach ($buildBlock in $buildBlocks) {
        $name = $buildBlock.Groups[1].Value.Trim()
        $body = $buildBlock.Groups[2].Value
        $key = "$class - $name"
        if ($guideKeys.ContainsKey($key)) {
            Add-ValidationError "$relative duplicates talent guide key: $key"
        } else {
            $guideKeys[$key] = $true
        }

        $ranks = @{}
        $tabPoints = @{ 1 = 0; 2 = 0; 3 = 0 }
        $points = 0
        foreach ($rawEntry in ($body -split ';')) {
            $entry = $rawEntry.Trim()
            if (-not $entry) { continue }
            if ($entry -notmatch '^(\d+),(\d+),(\d+),(\d+)$') {
                Add-ValidationError "$relative / $name has an invalid compact entry: $entry"
                continue
            }
            $tab, $tier, $column, $count = [int]$Matches[1], [int]$Matches[2], [int]$Matches[3], [int]$Matches[4]
            if ($tab -lt 1 -or $tab -gt 3 -or $tier -lt 1 -or $tier -gt 11 -or
                $column -lt 1 -or $column -gt 4 -or $count -lt 1 -or $count -gt 5) {
                Add-ValidationError "$relative / $name has an out-of-range compact entry: $entry"
                continue
            }

            $position = "$tab,$tier,$column"
            $startingRank = if ($ranks.ContainsKey($position)) { $ranks[$position] } else { 0 }
            if ($startingRank + $count -gt 5) {
                Add-ValidationError "$relative / $name over-ranks $position."
            }
            $requiredPoints = ($tier - 1) * 5
            if ($tabPoints[$tab] -lt $requiredPoints) {
                Add-ValidationError "$relative / $name reaches $position with $($tabPoints[$tab]) prior tree points; $requiredPoints required."
            }
            for ($rankOffset = 1; $rankOffset -le $count; $rankOffset++) {
                Test-ReferenceTalent $class $relative $name $position ($startingRank + $rankOffset) $ranks
            }
            $ranks[$position] = $startingRank + $count
            $tabPoints[$tab] += $count
            $points += $count
        }

        if ($points -ne 71) {
            Add-ValidationError "$relative / $name has $points compact points; expected 71."
        }
        $primaryTab = 1
        if ($tabPoints[2] -gt $tabPoints[$primaryTab]) { $primaryTab = 2 }
        if ($tabPoints[3] -gt $tabPoints[$primaryTab]) { $primaryTab = 3 }
        $plans.Add([pscustomobject]@{
            File = $relative; Class = $class; Name = $name; Next = $null; Steps = $points
            PrimaryTab = $primaryTab
        })
        $stepCount += $points
    }
}

foreach ($plan in $plans) {
    if (-not $plan.Next) { continue }
    $nextKey = "$($plan.Class) - $($plan.Next)"
    if (-not $guideKeys.ContainsKey($nextKey)) {
        Add-ValidationError "$($plan.File) / $($plan.Name) points to missing next plan: $nextKey"
    }
}

foreach ($classPlans in ($plans | Group-Object Class)) {
    for ($tab = 1; $tab -le 3; $tab++) {
        if (-not ($classPlans.Group | Where-Object { $_.PrimaryTab -eq $tab })) {
            Add-ValidationError "$($classPlans.Name) has no complete plan primarily using talent tab $tab."
        }
    }
}

if ($plans.Count -ne 38) {
    Add-ValidationError "Talent-plan baseline changed: found $($plans.Count), expected 38."
}

if ($errors.Count -gt 0) {
    foreach ($errorText in ($errors | Select-Object -First $MaxErrors)) {
        Write-Host "ERROR: $errorText" -ForegroundColor Red
    }
    if ($errors.Count -gt $MaxErrors) {
        Write-Host "... $($errors.Count - $MaxErrors) additional error(s) omitted." -ForegroundColor Red
    }
    throw "Talent validation failed with $($errors.Count) error(s)."
}

Write-Host "Talent validation passed: $($files.Count) files, $($plans.Count) plans, $stepCount steps." -ForegroundColor Green
