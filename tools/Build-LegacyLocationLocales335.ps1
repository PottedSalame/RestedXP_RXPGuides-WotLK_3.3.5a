param(
    [Parameter(Mandatory = $true)]
    [string]$LibBabbleSubZoneRoot,
    [string]$LegacyBabbleSubZonePath,
    [string]$LegacyBabbleZonePath,
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not $OutputPath) {
    $OutputPath = Join-Path $repoRoot 'Compat\LocationLocales335.lua'
}

$required = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::Ordinal)
$requiredAreaIDs = [Collections.Generic.HashSet[int]]::new()

function Add-RequiredName([string]$Name) {
    if ([string]::IsNullOrWhiteSpace($Name)) { return }
    [void]$required.Add($Name.Trim())
}

$hbdPath = Join-Path $repoRoot 'libs\HBD335\HereBeDragons-335.lua'
$hbd = [IO.File]::ReadAllText($hbdPath)
$areaBlock = [regex]::Match(
    $hbd, '(?s)local legacyAreaNames\s*=\s*\{(.*?)\n\}')
if (-not $areaBlock.Success) {
    throw 'Could not locate legacyAreaNames in HereBeDragons-335.lua.'
}
$legacyAreaNames = @{}
foreach ($match in [regex]::Matches(
    $areaBlock.Groups[1].Value,
    '\[(?<id>\d+)\]\s*=\s*"(?<name>(?:\\.|[^"])*)"')) {
    $name = $match.Groups['name'].Value -replace '\\"', '"'
    $legacyAreaNames[[int]$match.Groups['id'].Value] = $name
    Add-RequiredName $name
}

$dbPath = Join-Path $repoRoot 'DB\wotlk\db.lua'
$db = [IO.File]::ReadAllText($dbPath)
foreach ($match in [regex]::Matches(
    $db, '\["(?<name>(?:\\.|[^"])*)"\]\s*=\s*\d+')) {
    Add-RequiredName ($match.Groups['name'].Value -replace '\\"', '"')
}

$flightPath = Join-Path $repoRoot 'DB\wotlk\flightData.lua'
$flight = [IO.File]::ReadAllText($flightPath)
foreach ($match in [regex]::Matches(
    $flight, '\["name"\]\s*=\s*"(?<name>(?:\\.|[^"])*)"')) {
    $name = $match.Groups['name'].Value -replace '\\"', '"'
    Add-RequiredName $name
    foreach ($part in $name.Split(',')) { Add-RequiredName $part }
}

$guideListPath = Join-Path $repoRoot 'GuideList_335.xml'
$guideFiles = [Collections.Generic.List[IO.FileInfo]]::new()
$guideList = [IO.File]::ReadAllText($guideListPath)
foreach ($match in [regex]::Matches(
    $guideList, '<Script\s+file="(?<path>[^"]+\.lua)"\s*/>')) {
    $relative = $match.Groups['path'].Value.Replace('\', [IO.Path]::DirectorySeparatorChar)
    $path = Join-Path $repoRoot $relative
    if (-not (Test-Path -LiteralPath $path)) {
        throw "GuideList_335.xml references missing file: $relative"
    }
    $guideFiles.Add((Get-Item -LiteralPath $path))
}

foreach ($guide in $guideFiles) {
    $text = [IO.File]::ReadAllText($guide.FullName)
    foreach ($match in [regex]::Matches(
        $text, '(?m)^\s*\.home\s+(?<name>[^>\r\n,]+?)\s*(?:>>|$)')) {
        $name = $match.Groups['name'].Value.Trim()
        if ($name -notmatch '^\d+$') { Add-RequiredName $name }
    }
    foreach ($match in [regex]::Matches(
        $text,
        '(?m)^\s*\.(?:subzone|subzoneskip|bindlocation|home)\s+(?<id>\d+)')) {
        [void]$requiredAreaIDs.Add([int]$match.Groups['id'].Value)
    }
}

$areaMapPath = Join-Path $LibBabbleSubZoneRoot 'Core\AreaToUIMapID.lua'
if (-not (Test-Path -LiteralPath $areaMapPath)) {
    throw "Missing LibBabble area map: $areaMapPath"
}
$areaMapSource = [IO.File]::ReadAllText($areaMapPath)
$areaNames = @{}
foreach ($id in $requiredAreaIDs) {
    if ($legacyAreaNames.ContainsKey($id)) {
        $areaNames[$id] = $legacyAreaNames[$id]
        Add-RequiredName $legacyAreaNames[$id]
    }
}
foreach ($match in [regex]::Matches(
    $areaMapSource,
    '\["(?<name>(?:\\.|[^"])*)"\]\s*=\s*(?<id>\d+)')) {
    $id = [int]$match.Groups['id'].Value
    if ($requiredAreaIDs.Contains($id) -and -not $areaNames.ContainsKey($id)) {
        $name = $match.Groups['name'].Value -replace '\\"', '"'
        $areaNames[$id] = $name
        Add-RequiredName $name
    }
}
$missingAreaIDs = @($requiredAreaIDs | Where-Object { -not $areaNames.ContainsKey($_) })
if ($missingAreaIDs.Count -gt 0) {
    throw ('LibBabble has no names for loaded-guide area IDs: ' +
        (($missingAreaIDs | Sort-Object) -join ', '))
}

$locales = @('deDE', 'esES', 'frFR', 'koKR', 'ruRU', 'zhCN', 'zhTW')
$builder = [Text.StringBuilder]::new()
[void]$builder.AppendLine('--[[-----------------------------------------------------------------------')
[void]$builder.AppendLine('    WotLK-era location translations used by the standalone 3.3.5 bridge.')
[void]$builder.AppendLine('    Derived from LibBabble-SubZone-3.0 (revision 258).')
if ($LegacyBabbleSubZonePath) {
    [void]$builder.AppendLine('    Legacy area names prefer LibBabble-SubZone-3.0 (revision 24).')
}
if ($LegacyBabbleZonePath) {
    [void]$builder.AppendLine('    WotLK zone names prefer LibBabble-Zone-3.0 (revision 135).')
}
[void]$builder.AppendLine('    Authors: ckknight, arithmandar, and LibBabble contributors.')
[void]$builder.AppendLine('    License: MIT')
[void]$builder.AppendLine('-------------------------------------------------------------------------]]')
[void]$builder.AppendLine('local _, addon = ...')
[void]$builder.AppendLine('addon.LegacyAreaNames335 = {')
foreach ($id in ($areaNames.Keys | Sort-Object)) {
    $escapedName = $areaNames[$id].Replace('\', '\\').Replace('"', '\"')
    [void]$builder.AppendLine(('    [{0}] = "{1}",' -f $id, $escapedName))
}
[void]$builder.AppendLine('}')
[void]$builder.AppendLine('local translations = {')

$generatedCount = 0
foreach ($locale in $locales) {
    $localePath = Join-Path $LibBabbleSubZoneRoot ("Locale\$locale.lua")
    if (-not (Test-Path -LiteralPath $localePath)) {
        throw "Missing LibBabble locale file: $localePath"
    }
    $source = [IO.File]::ReadAllText($localePath)
    $values = @{}
    foreach ($match in [regex]::Matches(
        $source,
        '\["(?<key>(?:\\.|[^"])*)"\]\s*=\s*"(?<value>(?:\\.|[^"])*)"')) {
        $key = $match.Groups['key'].Value -replace '\\"', '"'
        if ($required.Contains($key)) {
            $values[$key] = $match.Groups['value'].Value
        }
    }
    # Prefer the subzone wording from the same client generation. This matters
    # for exact comparisons with GetSubZoneText(), not merely for display.
    if ($LegacyBabbleSubZonePath) {
        if (-not (Test-Path -LiteralPath $LegacyBabbleSubZonePath)) {
            throw "Missing legacy LibBabble-SubZone file: $LegacyBabbleSubZonePath"
        }
        if (-not $legacyBabbleSubZoneSource) {
            $legacyBabbleSubZoneSource = [IO.File]::ReadAllText(
                [IO.Path]::GetFullPath($LegacyBabbleSubZonePath))
        }
        $localePattern = '(?s)(?:if|elseif)\s+GAME_LOCALE\s*==\s*"' +
            [regex]::Escape($locale) +
            '"\s+then\s+lib:SetCurrentTranslations\s*\{(?<body>.*?)\n\s*\}'
        $localeBlock = [regex]::Match(
            $legacyBabbleSubZoneSource, $localePattern)
        if (-not $localeBlock.Success) {
            throw "Legacy LibBabble-SubZone has no $locale translation block."
        }
        foreach ($match in [regex]::Matches(
            $localeBlock.Groups['body'].Value,
            '\["(?<key>(?:\\.|[^"])*)"\]\s*=\s*"(?<value>(?:\\.|[^"])*)"')) {
            $key = $match.Groups['key'].Value -replace '\\"', '"'
            if ($required.Contains($key)) {
                $values[$key] = $match.Groups['value'].Value
            }
        }
    }
    # Prefer the locale strings shipped by a contemporary WotLK library for
    # base zones and flight destinations. Newer LibBabble data remains useful
    # for subzones, but some languages changed punctuation or wording after
    # 3.3.5 and those strings no longer compare equal to the legacy client.
    if ($LegacyBabbleZonePath) {
        if (-not (Test-Path -LiteralPath $LegacyBabbleZonePath)) {
            throw "Missing legacy LibBabble-Zone file: $LegacyBabbleZonePath"
        }
        if (-not $legacyBabbleSource) {
            $legacyBabbleSource = [IO.File]::ReadAllText(
                [IO.Path]::GetFullPath($LegacyBabbleZonePath))
        }
        $localePattern = '(?s)(?:if|elseif)\s+GAME_LOCALE\s*==\s*"' +
            [regex]::Escape($locale) +
            '"\s+then\s+lib:SetCurrentTranslations\s*\{(?<body>.*?)\n\s*\}'
        $localeBlock = [regex]::Match($legacyBabbleSource, $localePattern)
        if (-not $localeBlock.Success) {
            throw "Legacy LibBabble-Zone has no $locale translation block."
        }
        foreach ($match in [regex]::Matches(
            $localeBlock.Groups['body'].Value,
            '\["(?<key>(?:\\.|[^"])*)"\]\s*=\s*"(?<value>(?:\\.|[^"])*)"')) {
            $key = $match.Groups['key'].Value -replace '\\"', '"'
            if ($required.Contains($key)) {
                $values[$key] = $match.Groups['value'].Value
            }
        }
    }
    [void]$builder.AppendLine(('    ["{0}"] = {{' -f $locale))
    foreach ($key in ($values.Keys | Sort-Object)) {
        $escapedKey = $key.Replace('\', '\\').Replace('"', '\"')
        [void]$builder.AppendLine(('        ["{0}"] = "{1}",' -f
            $escapedKey, $values[$key]))
        $generatedCount++
    }
    [void]$builder.AppendLine('    },')
}

[void]$builder.AppendLine('}')
[void]$builder.AppendLine('local active = translations[GetLocale()]')
[void]$builder.AppendLine('function addon.LocalizeLegacyLocationName(name)')
[void]$builder.AppendLine('    if type(name) ~= "string" or not active then return name end')
[void]$builder.AppendLine('    local exact = active[name]')
[void]$builder.AppendLine('    if exact then return exact end')
[void]$builder.AppendLine('    if not name:find(",", 1, true) then return name end')
[void]$builder.AppendLine('    local parts = {}')
[void]$builder.AppendLine('    for part in name:gmatch("[^,]+") do')
[void]$builder.AppendLine('        part = part:gsub("^%s+", ""):gsub("%s+$", "")')
[void]$builder.AppendLine('        parts[#parts + 1] = active[part] or part')
[void]$builder.AppendLine('    end')
[void]$builder.AppendLine('    return table.concat(parts, ", ")')
[void]$builder.AppendLine('end')

$encoding = [Text.UTF8Encoding]::new($false)
[IO.File]::WriteAllText([IO.Path]::GetFullPath($OutputPath),
    $builder.ToString(), $encoding)
Write-Output ("Generated {0} translations for {1} required names." -f
    $generatedCount, $required.Count)
