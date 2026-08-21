param(
    [Parameter(Mandatory = $true)]
    [string]$SourceRoot,
    [string]$DestinationRoot
)

$ErrorActionPreference = 'Stop'

if (-not $DestinationRoot) {
    $DestinationRoot = Split-Path -Parent $PSScriptRoot
}

$source = Join-Path $SourceRoot 'DB\classic\dangerousMobs.lua'
$destination = Join-Path $DestinationRoot 'DB\tbc\dangerousMobs.lua'
$zones = @(
    "Blade's Edge Mountains",
    'Hellfire Peninsula',
    'Zangarmarsh',
    'Terokkar Forest',
    'Nagrand',
    'Netherstorm',
    'Shadowmoon Valley'
)

if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "Missing upstream dangerous-mob database: $source"
}

$lines = [IO.File]::ReadAllLines($source)

function Get-TableBlocks([string]$Name) {
    $needle = '    ["' + $Name + '"] = {'
    $blocks = New-Object System.Collections.Generic.List[object]

    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -ne $needle) { continue }

        $depth = 0
        $block = New-Object System.Collections.Generic.List[string]
        for ($cursor = $index; $cursor -lt $lines.Count; $cursor++) {
            $line = $lines[$cursor]
            $block.Add($line)
            $depth += ([regex]::Matches($line, '\{')).Count
            $depth -= ([regex]::Matches($line, '\}')).Count
            if ($depth -eq 0) { break }
        }
        if ($depth -ne 0) { throw "Unbalanced table for zone '$Name'" }
        $blocks.Add($block.ToArray())
    }

    return ,$blocks.ToArray()
}

$output = New-Object System.Collections.Generic.List[string]
$output.Add('local _, addon = ...')
$output.Add('')
$output.Add('-- Outland danger routes selectively imported from RestedXP/RXPGuides')
$output.Add('-- v4.10.25. The upstream data duplicates these routes by faction;')
$output.Add('-- 3.3.5 stores one shared copy because the operational records are equal.')
$output.Add('if addon.game ~= "WOTLK" or addon.gameVersion ~= 30300 then return end')
$output.Add('')
$output.Add('local dangerousMobs = addon.dangerousMobs')
$output.Add('if type(dangerousMobs) ~= "table" then return end')
$output.Add('')
$zoneBlocks = @{}
$factionRecordCounts = @(0, 0)
foreach ($zone in $zones) {
    $blocks = Get-TableBlocks $zone
    if ($blocks.Count -lt 2 -or ($blocks.Count % 2) -ne 0) {
        throw "Expected paired Alliance and Horde blocks for '$zone'; found $($blocks.Count)"
    }

    $factionBlockCount = $blocks.Count / 2
    for ($blockIndex = 0; $blockIndex -lt $factionBlockCount; $blockIndex++) {
        $allianceOperational = ($blocks[$blockIndex] | Where-Object { $_ -notmatch '^\s*Notes\s*=' }) -join "`n"
        $hordeOperational = ($blocks[$blockIndex + $factionBlockCount] | Where-Object { $_ -notmatch '^\s*Notes\s*=' }) -join "`n"
        if ($allianceOperational -cne $hordeOperational) {
            throw "Alliance and Horde operational data differ for '$zone' block $($blockIndex + 1)"
        }
        $factionRecordCounts[0] += ([regex]::Matches(($blocks[$blockIndex] -join "`n"), 'MinLevel\s*=')).Count
        $factionRecordCounts[1] += ([regex]::Matches(($blocks[$blockIndex + $factionBlockCount] -join "`n"), 'MinLevel\s*=')).Count
    }
    $zoneBlocks[$zone] = $blocks
}

if ($factionRecordCounts[0] -ne 86 -or $factionRecordCounts[1] -ne 86) {
    throw "Expected 86 danger records per faction; found Alliance $($factionRecordCounts[0]), Horde $($factionRecordCounts[1])"
}

$output.Add('local outlandDangerousMobs = {')
foreach ($factionIndex in 0, 1) {
    $faction = if ($factionIndex -eq 0) { 'Alliance' } else { 'Horde' }
    $output.Add('  ["' + $faction + '"] = {')
    foreach ($zone in $zones) {
        $blocks = $zoneBlocks[$zone]
        $factionBlockCount = $blocks.Count / 2

        # Some upstream zones are split into duplicate Lua keys. Merge their
        # contents so later declarations cannot overwrite earlier records.
        $output.Add('    ["' + $zone + '"] = {')
        for ($blockIndex = 0; $blockIndex -lt $factionBlockCount; $blockIndex++) {
            $sourceIndex = $blockIndex + ($factionIndex * $factionBlockCount)
            $block = $blocks[$sourceIndex]
            for ($lineIndex = 1; $lineIndex -lt ($block.Count - 1); $lineIndex++) {
                $output.Add($block[$lineIndex])
            }
        }
        $output.Add('    },')
    }
    $output.Add('  },')
}

$output.Add('}')
$output.Add('')
$output.Add('local factionMobs = outlandDangerousMobs[_G.UnitFactionGroup("player")]')
$output.Add('if type(factionMobs) ~= "table" then return end')
$output.Add('for zone, records in pairs(factionMobs) do')
$output.Add('    if dangerousMobs[zone] == nil then dangerousMobs[zone] = records end')
$output.Add('end')
$output.Add('')

$directory = Split-Path -Parent $destination
if (-not (Test-Path -LiteralPath $directory)) {
    New-Item -ItemType Directory -Path $directory | Out-Null
}
[IO.File]::WriteAllLines($destination, $output, (New-Object Text.UTF8Encoding($false)))
Write-Host "Generated $destination with 86 records for each faction across $($zones.Count) Outland zones."
