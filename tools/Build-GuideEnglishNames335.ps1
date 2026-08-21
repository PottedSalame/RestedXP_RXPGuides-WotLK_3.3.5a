[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ReferenceRoot,
    [string]$AddonRoot,
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
if (-not $AddonRoot) { $AddonRoot = Split-Path -Parent $PSScriptRoot }
if (-not $OutputPath) {
    $OutputPath = Join-Path $AddonRoot 'DB\wotlk\guideEnglishNames_335.lua'
}
$guideListPath = Join-Path $AddonRoot 'GuideList_335.xml'
$guideList = [IO.File]::ReadAllText($guideListPath, $utf8)
$requiredItems = @{}
$names = @{}
$reviewedOverrides = @{
    2931 = "Maiden's Anguish"
    3703 = 'Southshore Stout'
    4589 = 'Long Elegant Feather'
    7371 = 'Heavy Quiver'
    8444 = "Executioner's Key"
    11285 = 'Jagged Arrow'
    16375 = 'Grimoire of Soothing Kiss'
    16368 = 'Grimoire of Lash of Pain (Rank 2)'
    17032 = 'Rune of Portals'
    20424 = 'Sandworm Meat'
    25744 = 'Dampscale Basilisk Eye'
    25765 = 'Fel Orc Plans'
    24291 = 'Bog Lord Tendril'
    28452 = 'Bloodgem Shard'
    28550 = 'Flaming Torch'
    29482 = 'Ethereum Essence'
    27991 = 'Shadow Labyrinth Key'
    31799 = 'Fei Fei Doggy Treat'
    33044 = 'Salvage Kit'
    40970 = 'Onslaught Gryphon Reins'
    44246 = 'Orb of Illusion'
}

function Clean-Name([string]$name) {
    if (-not $name) { return $null }
    $name = $name -replace '\|T.*?\|t','' -replace '\|cRXP_[A-Z]+_',''
    $name = $name -replace '\|c[0-9a-fA-F]{8}','' -replace '\|r',''
    $name = $name -replace '\s*\|.*$','' -replace '\s*<<.*$',''
    $name = $name -replace '^\s*(?:the\s+)?(?:\d+\s+)?',''
    $name = $name -replace '^(?i:Collect|Buy|Use|Loot|Get)\s+',''
    $name = $name -replace '\s*\(x?\d+\)\s*$',''
    $name = $name -replace '\s+(?:x\d+|\d+/\d+)\s*$',''
    $name = $name.Trim(' ', "`t", '.', ':')
    if (-not $name -or $name.Length -gt 100) { return $null }
    return $name
}

foreach ($match in [regex]::Matches($guideList, '<Script\s+file="([^"]+\.lua)"')) {
    $relative = $match.Groups[1].Value.Replace('\', [IO.Path]::DirectorySeparatorChar)
    $path = Join-Path $AddonRoot $relative
    foreach ($line in [IO.File]::ReadAllLines($path, $utf8)) {
        $directive = [regex]::Match($line, '^\s*\.collect\s+-?(\d+)')
        if (-not $directive.Success) { continue }
        $id = [int]$directive.Groups[1].Value
        $visible = [regex]::Match($line, '>>\s*(.+?)(?:\s*<<.*)?\s*$')
        if (-not $visible.Success) { $requiredItems[$id] = $true }
        $comment = [regex]::Match($line, '--\s*(.+?)\s*$')
        if ($comment.Success) {
            $name = Clean-Name $comment.Groups[1].Value
            if ($name) { $names[$id] = $name }
        }
    }
}

$referenceGuides = Join-Path $ReferenceRoot 'Guides'
if (-not (Test-Path -LiteralPath $referenceGuides -PathType Container)) {
    throw "Missing reference guide directory: $referenceGuides"
}
foreach ($file in Get-ChildItem -LiteralPath $referenceGuides -Recurse -Filter '*.lua' -File) {
    foreach ($line in [IO.File]::ReadLines($file.FullName, $utf8)) {
        foreach ($match in [regex]::Matches($line,
                '(?i)(?:collect|use|buy|trash|get)\s+(?:the\s+)?(?:\d+\s+)?(.+?)##(\d+)')) {
            $id = [int]$match.Groups[2].Value
            if ($requiredItems.ContainsKey($id) -and -not $names.ContainsKey($id)) {
                $name = Clean-Name $match.Groups[1].Value
                if ($name) { $names[$id] = $name }
            }
        }
    }
}

$referenceItemDb = Join-Path $ReferenceRoot 'ZygorItemDB.lua'
if (Test-Path -LiteralPath $referenceItemDb -PathType Leaf) {
    foreach ($line in [IO.File]::ReadLines($referenceItemDb, $utf8)) {
        $match = [regex]::Match($line, '^\s*\[(\d+)\]\s*=\s*\{n="((?:\\.|[^"\\])*)"')
        if ($match.Success) {
            $id = [int]$match.Groups[1].Value
            if ($requiredItems.ContainsKey($id) -and -not $names.ContainsKey($id)) {
                $names[$id] = $match.Groups[2].Value.Replace('\"', '"').Replace('\\', '\')
            }
        }
    }
}
foreach ($id in $reviewedOverrides.Keys) {
    if ($requiredItems.ContainsKey($id)) {
        $names[$id] = $reviewedOverrides[$id]
    }
}

$missing = @($requiredItems.Keys | Where-Object { -not $names.ContainsKey($_) })
if ($missing.Count -gt 0) {
    throw "Reference data is missing $($missing.Count) required item names: $($missing -join ', ')"
}

function Escape-Lua([string]$value) {
    return $value.Replace('\', '\\').Replace('"', '\"').Replace("`r", '\r').Replace("`n", '\n')
}
$builder = New-Object Text.StringBuilder
[void]$builder.AppendLine('local _, addon = ...')
[void]$builder.AppendLine('if not addon.guideLocalization then return end')
[void]$builder.AppendLine('')
[void]$builder.AppendLine('-- English display names generated offline from loaded RXP source comments and')
[void]$builder.AppendLine('-- the local 3.3.5 Zygor route reference. Runtime remains fully standalone.')
[void]$builder.AppendLine('addon.guideLocalization:RegisterEnglishNames({')
[void]$builder.AppendLine('    quests = {')
[void]$builder.AppendLine('        [9671] = "Urgent Delivery",')
[void]$builder.AppendLine('        [10024] = "Voren''thal''s Visions",')
[void]$builder.AppendLine('        [11940] = "Drake Hunt",')
[void]$builder.AppendLine('    },')
[void]$builder.AppendLine('    factions = {')
foreach ($entry in @(
        '        [529] = "Argent Dawn",',
        '        [576] = "Timbermaw Hold",',
        '        [922] = "Tranquillien",',
        '        [933] = "The Consortium",',
        '        [941] = "The Mag''har",',
        '        [942] = "Cenarion Expedition",',
        '        [970] = "Sporeggar",',
        '        [978] = "Kurenai",',
        '        [989] = "Keepers of Time",',
        '        [1015] = "Netherwing",',
        '        [1038] = "The Violet Eye",',
        '        [1119] = "The Sons of Hodir",')) {
    [void]$builder.AppendLine($entry)
}
[void]$builder.AppendLine('    },')
[void]$builder.AppendLine('    items = {')
foreach ($id in @($requiredItems.Keys | Sort-Object)) {
    [void]$builder.AppendLine(('        [{0}] = "{1}",' -f $id, (Escape-Lua $names[$id])))
}
[void]$builder.AppendLine('    },')
[void]$builder.AppendLine('    spells = {')
[void]$builder.AppendLine('    },')
[void]$builder.AppendLine('})')
[IO.File]::WriteAllText($OutputPath, $builder.ToString(), $utf8)
Write-Host "Generated $($requiredItems.Count) English item names."
