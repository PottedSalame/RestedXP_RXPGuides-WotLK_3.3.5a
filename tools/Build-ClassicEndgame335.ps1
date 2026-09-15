param(
    [string]$SourceRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$DestinationRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'

function Read-GuideBlocks {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Guide source not found: $Path"
    }

    $text = [IO.File]::ReadAllText($Path)
    $matches = [regex]::Matches(
        $text,
        '(?ms)^RXPGuides\.RegisterGuide\(\[\[(.*?)^[ \t]*\]\]\)\s*'
    )
    $result = @{}
    foreach ($match in $matches) {
        $nameMatch = [regex]::Match($match.Groups[1].Value, '(?m)^#name\s+(.+?)\s*$')
        if (-not $nameMatch.Success) { continue }
        $name = $nameMatch.Groups[1].Value.Trim()
        if ($result.ContainsKey($name)) {
            throw "Duplicate guide '$name' in $Path"
        }
        $result[$name] = $match.Value.TrimEnd()
    }
    return $result
}

$setSource = Read-GuideBlocks (Join-Path $SourceRoot 'Guides\Classic-0.5.lua')
$keySource = Read-GuideBlocks (Join-Path $SourceRoot 'Guides\Classic-Attunements.lua')

$setNames = @(
    'Part 1: Bracers',
    'Part 2: Belt & Gloves',
    'Part 3: Pants, Shoulders & Boots',
    'Part 4: Helm & Chest'
)
$keyNames = @(
    'Onyxia Attunement (A)',
    'Onyxia Attunement (H)',
    'Molten Core Attunement',
    'Blackwing Lair Attunement',
    'Upper Blackrock Spire Key',
    'Scholomance Key (A)',
    'Scholomance Key (H)',
    'Blackrock Depths Key',
    'Dire Maul Key'
)

$onyxiaFactions = @{
    'Onyxia Attunement (A)' = 'Alliance'
    'Onyxia Attunement (H)' = 'Horde'
}
$blocks = New-Object 'System.Collections.Generic.List[string]'
$coordinateTravel = [ordered]@{
    '.subzone 2738 >>Travel to Southwind Village in |cFFfa9602Silithus|r' = '.goto Silithus,61.60,48.60,80 >>Travel to Southwind Village in |cFFfa9602Silithus|r'
    '.subzone 2256 >>Travel to Darkwhisper Gorge in |cFFfa9602Winterspring|r' = '.goto Winterspring,58.87,78.40,80 >>Travel to Darkwhisper Gorge in |cFFfa9602Winterspring|r'
    ".subzone 2744 >>Travel to Hive'Regal in |cFFfa9602Silithus|r" = ".goto Silithus,55.77,71.71,80 >>Travel to Hive'Regal in |cFFfa9602Silithus|r"
    '.subzone 2249 >>Travel to Frostwhisper Gorge in |cFFfa9602Winterspring|r' = '.goto Winterspring,61.44,68.26,80 >>Travel to Frostwhisper Gorge in |cFFfa9602Winterspring|r'
    ".subzone 2266 >>Travel to Tyr's Hand in |cFFfa9602Eastern Plaguelands|r" = ".goto Eastern Plaguelands,84.17,83.38,80 >>Travel to Tyr's Hand in |cFFfa9602Eastern Plaguelands|r"
    '.subzone 896 >>Travel to Purgation Isle in |cFFfa9602Hillsbrad Foothills|r' = '.goto Hillsbrad Foothills,19.67,76.92,80 >>Travel to Purgation Isle in |cFFfa9602Hillsbrad Foothills|r'
    '.subzone 2079 >>Travel to Alcaz Island in |cFFfa9602Dustwallow Marsh|r' = '.goto Dustwallow Marsh,76.91,18.24,80 >>Travel to Alcaz Island in |cFFfa9602Dustwallow Marsh|r'
    ".subzone 2158 >>Enter Emberstrife's Den" = ".goto Dustwallow Marsh,56.67,87.64,80 >>Enter Emberstrife's Den"
    '.subzone 2245 >>Enter the Mazthoril cave' = '.goto Winterspring,57.07,49.97,60 >>Enter the Mazthoril cave'
    '.subzone 2418 >>Travel to Morgan''s Vigil in |cFFfa9602Burning Steppes|r' = '.goto Burning Steppes,84.74,69.02,80 >>Travel to Morgan''s Vigil in |cFFfa9602Burning Steppes|r'
    '.subzone 1038 >>Travel to the Dragonmaw Gates' = '.goto Wetlands,75.44,46.76,80 >>Travel to the Dragonmaw Gates'
}

# These handoffs were repaired after the original curated file was generated.
# Keep them in the builder so regenerating the file can never discard the
# validated local quest-flow fixes.
$localQuestFlowRepairs = @{
    'Onyxia Attunement (A)' = @(
        @{
            Pattern = '(?m)^(\s*\.complete 4182,4 -- Black Wyrmkin slain \(4\))(\r?\n)\s*\.mob \+Black Drake(\r?\n)(\s*\.complete 4182,3 -- Black Drake slain)(\r?\n)\s*\.mob \+Black Wyrmkin\r?$'
            Replacement = '$1$2    .mob +Black Wyrmkin$3$4$5    .mob +Black Drake'
        },
        @{
            Pattern = '(?m)^(\s*\.accept 4242 >> Accept Abandoned Hope\r?)$'
            Replacement = '$1' + [char]10 + '    .target Marshal Windsor'
        },
        @{
            Pattern = '(?m)^(\s*\.accept 4282 >> Accept A Shred of Hope\r?)$'
            Replacement = '$1' + [char]10 + '    .target Marshal Windsor'
            Count = 2
        },
        @{
            Pattern = '(?m)^(\s*\.accept 4322,1 >> Accept Jail Break!\r?)$'
            Replacement = '$1' + [char]10 + '    .target Marshal Windsor'
        },
        @{
            Pattern = '(?m)^(\s*\.complete 4322,1 -- Jail Break! \(1\)\r?)$'
            Replacement = '$1' + [char]10 + '    .target Marshal Windsor'
        }
    )
    'Onyxia Attunement (H)' = @(
        @{
            Pattern = '(?m)^(\s*\.complete 6582,1 --The Skull of Scryer 1/1\r?)$'
            Replacement = '$1' + [char]10 + '    .unitscan Scryer'
        },
        @{
            Pattern = '(?m)^(\s*\.complete 6583,1 --The Skull of Somnus 1/1\r?)$'
            Replacement = '$1' + [char]10 + '    .unitscan Somnus'
        },
        @{
            Pattern = '(?m)^(\s*\.complete 6584,1 --The Skull of Chronalis 1/1\r?)$'
            Replacement = '$1' + [char]10 + '    .unitscan Chronalis'
        },
        @{
            Pattern = '(?m)^\s*\.unitscan Scryer\r?\n\s*\.unitscan Somnus\r?\n\s*\.unitscan Chronalis\r?\n?'
            Replacement = ''
        }
    )
    'Part 4: Helm & Chest' = @(
        @{
            Pattern = '(?m)^(\s*\.turnin 8332 >>Turn in Dukes of the Council\r?)$'
            Replacement = '$1' + "`n    .accept 8333 >>Accept Medallion of Station"
        }
    )
    'Scholomance Key (A)' = @(
        @{
            Pattern = '(?m)^(\s*\.accept 5098 >> Accept All Along the Watchtowers\r?)$'
            Replacement = "    .turnin 5092 >> Turn in Clear the Way`n" + '$1'
        },
        @{
            Pattern = '(?m)^(\s*\.turnin 5803 >>Turn in Araj''s Scarab\r?)$'
            Replacement = '$1' + "`n    .accept 5505 >>Accept The Key to Scholomance"
        }
    )
    'Scholomance Key (H)' = @(
        @{
            Pattern = '(?m)^(\s*\.turnin 5804 >>Turn in Araj''s Scarab\r?)$'
            Replacement = '$1' + "`n    .accept 5511 >>Accept The Key to Scholomance"
        }
    )
}
foreach ($name in @($setNames + $keyNames)) {
    $source = if ($setSource.ContainsKey($name)) { $setSource } else { $keySource }
    if (-not $source.ContainsKey($name)) {
        throw "Required endgame guide '$name' was not found"
    }
    $block = $source[$name]
    if ($onyxiaFactions.ContainsKey($name)) {
        $faction = $onyxiaFactions[$name]
        $beforeGate = $block
        $block = [regex]::Replace(
            $block,
            "(?m)^#classic\s*\r?\n<<\s*$faction\s*$",
            "<< ac335 $faction",
            1)
        if ($block -ceq $beforeGate) {
            throw "Onyxia guide '$name' did not receive its combined 3.3.5 faction gate"
        }
        $block = [regex]::Replace($block, '(?m)[ \t]+(?=\r?$)', '')

        $lineBreak = if ($block.Contains("`r`n")) { "`r`n" } else { "`n" }
        $opening = "step${lineBreak}    #completewith next${lineBreak}"
        $openingIndex = $block.IndexOf($opening, [StringComparison]::Ordinal)
        if ($openingIndex -lt 0) {
            throw "Onyxia guide '$name' has no opening travel step for its server warning"
        }
        $warning = '    >>|cRXP_WARN_This legacy attunement requires the Individual Progression server module or an equivalent server restoration. It is unavailable on stock AzerothCore, and RXPGuides cannot detect server-side modules automatically.|r' + $lineBreak
        $block = $block.Substring(0, $openingIndex) + $opening + $warning +
            $block.Substring($openingIndex + $opening.Length)

        if ($name -eq 'Onyxia Attunement (H)') {
            $legacyTitle = 'The Testament of Rexxar'
            if (-not $block.Contains($legacyTitle)) {
                throw "Horde Onyxia guide no longer contains the expected legacy quest title"
            }
            # Quest 6568 is named Mistress of Deception in the 3.3.5 client.
            # The route and NPC handoff are unchanged from the Classic chain.
            $block = $block.Replace(
                $legacyTitle,
                'Mistress of Deception')
        }
    } else {
        $block = [regex]::Replace($block, '(?m)^#classic\s*$', '<< ac335', 1)
    }
    foreach ($route in $coordinateTravel.GetEnumerator()) {
        $block = $block.Replace($route.Key, $route.Value)
    }
    if ($localQuestFlowRepairs.ContainsKey($name)) {
        foreach ($repair in $localQuestFlowRepairs[$name]) {
            $before = $block
            $count = if ($repair.ContainsKey('Count')) {
                [int]$repair.Count
            } else {
                1
            }
            $expression = New-Object Text.RegularExpressions.Regex(
                $repair.Pattern)
            $block = $expression.Replace(
                $block, $repair.Replacement, $count)
            if ($block -ceq $before) {
                throw "Local quest-flow repair for '$name' no longer matches its source"
            }
        }
    }
    if ($onyxiaFactions.ContainsKey($name)) {
        if ($block -notmatch "(?m)^<< ac335 $($onyxiaFactions[$name])\s*$") {
            throw "Guide '$name' lost its combined 3.3.5 faction gate"
        }
    } elseif ($block -notmatch '(?m)^<< ac335\s*$') {
        throw "Guide '$name' did not receive its 3.3.5 gate"
    }
    [void]$blocks.Add($block)
}

$unsupportedAreaPattern = '(?m)^\s*\.subzone\s+(?:896|1038|2079|2158|2245|2249|2256|2266|2418|2738|2744)\b'
if (($blocks -join "`n") -match $unsupportedAreaPattern) {
    throw 'A locale-sensitive endgame subzone was left without a coordinate travel gate.'
}

$header = @'
-- AUTO-GENERATED by tools/Build-ClassicEndgame335.ps1.
-- Curated from the bundled RestedXP legacy endgame guide sources.
-- Only chains verified for the AzerothCore 3.3.5 baseline are included.
-- Onyxia attunement is the documented exception: it requires a server-side
-- restoration such as mod-individual-progression revision 977e2005bacf97f35e506eb27b8af6b2ea1136af.
-- Distributed under this repository's GPL-3.0 license; upstream attribution retained.

'@
$output = $header + ($blocks -join "`r`n`r`n") + "`r`n"
$destination = Join-Path $DestinationRoot 'Guides\Classic-Endgame335.lua'
$utf8NoBom = New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllText($destination, $output, $utf8NoBom)

Write-Host "Generated Guides\Classic-Endgame335.lua with $($blocks.Count) verified guides."
