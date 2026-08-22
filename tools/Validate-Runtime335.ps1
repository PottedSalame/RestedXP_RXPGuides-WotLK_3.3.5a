param(
    [switch]$RequireLua
)

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$errors = [Collections.Generic.List[string]]::new()
$loadedFiles = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::OrdinalIgnoreCase)

function Add-ValidationError([string]$Message) {
    $errors.Add($Message)
}

function Get-ExactChild([string]$Parent, [string]$Name) {
    if (-not (Test-Path -LiteralPath $Parent -PathType Container)) { return $null }
    return Get-ChildItem -LiteralPath $Parent -Force |
        Where-Object { $_.Name -ceq $Name } | Select-Object -First 1
}

function Resolve-ExactPath([string]$Base, [string]$Relative) {
    $current = [IO.Path]::GetFullPath($Base)
    foreach ($part in (($Relative -replace '\\', '/') -split '/')) {
        if ([string]::IsNullOrWhiteSpace($part) -or $part -eq '.') { continue }
        if ($part -eq '..') {
            $current = Split-Path -Parent $current
            continue
        }
        $child = Get-ExactChild $current $part
        if (-not $child) { return $null }
        $current = $child.FullName
    }
    return $current
}

function Read-Resource([string]$Path, [bool]$RecurseXml = $true) {
    if (-not $loadedFiles.Add($Path)) { return }
    if (-not $RecurseXml -or [IO.Path]::GetExtension($Path) -ine '.xml') {
        return
    }
    try {
        [xml]$xml = [IO.File]::ReadAllText($Path)
        $nodes = $xml.SelectNodes(
            '//*[local-name()="Script" or local-name()="Include"]')
        foreach ($node in $nodes) {
            $child = [string]$node.GetAttribute('file')
            if (-not $child) { continue }
            $childPath = Resolve-ExactPath (Split-Path -Parent $Path) $child
            if (-not $childPath) {
                Add-ValidationError (
                    'XML path is missing or has incorrect case: {0} (from {1})' -f
                    $child, $Path)
            } else {
                Read-Resource $childPath
            }
        }
    } catch {
        Add-ValidationError (
            'Unable to parse XML manifest {0}: {1}' -f
            $Path, $_.Exception.Message)
    }
}

$tocPath = Join-Path $root 'RXPGuides.toc'
$tocPaths = @((Get-Item -LiteralPath $tocPath)) + @(
    Get-ChildItem -LiteralPath $root -File -Filter '*.toc' |
        Where-Object { $_.FullName -cne $tocPath } |
        Sort-Object Name)
if ($tocPaths.Count -ne 1) {
    $unsupported = @($tocPaths | Select-Object -Skip 1 |
        ForEach-Object { $_.Name }) -join ', '
    Add-ValidationError (
        'Only the supported 3.3.5a manifest may ship. Remove unsupported ' +
        "client manifests: $unsupported")
}

# Keep the release focused on Vanilla, TBC, and WotLK content. These paths are
# upstream client/expansion artifacts and are neither loaded nor valid on the
# supported 3.3.5a runtime. Pre-WotLK source data and dormant feature modules
# are intentionally not included here because they remain useful to backports.
$unsupportedReleasePaths = @(
    'DB\cata', 'DB\mop', 'DB\mainline',
    'Guides\cata', 'Guides\mop', 'Guides\Retail', 'Guides\SoD',
    'libs\mainline', 'UI\AH',
    'DB\cata.xml', 'DB\mainline.xml', 'DB\mop.xml',
    'Guides\GuideList-cata.xml', 'Guides\GuideList-mainline.xml',
    'Guides\GuideList-mop.xml', 'libs\embeds_Mainline.xml'
)
foreach ($relative in $unsupportedReleasePaths) {
    if (Test-Path -LiteralPath (Join-Path $root $relative)) {
        Add-ValidationError "Unsupported post-WotLK release path exists: $relative"
    }
}

$obsoleteLoaderPaths = @(
    'DB\classic.xml', 'DB\tbc.xml', 'DB\wotlk.xml',
    'Guides\GuideList.xml', 'Guides\GuideList-classic.xml',
    'Guides\Talents\classic.xml', 'Guides\Talents\tbc.xml',
    'Guides\Talents\wotlk.xml', 'libs\embeds.xml', 'UI\includes.xml',
    'libs\AceAddon-3.0', 'libs\AceComm-3.0', 'libs\AceConfig-3.0',
    'libs\AceConsole-3.0', 'libs\AceDB-3.0', 'libs\AceDBOptions-3.0',
    'libs\AceEvent-3.0', 'libs\AceGUI-3.0', 'libs\AceLocale-3.0',
    'libs\AceSerializer-3.0', 'libs\CallbackHandler-1.0',
    'libs\HereBeDragons', 'libs\LibDataBroker-1.1', 'libs\LibDBIcon-1.0'
)
foreach ($relative in $obsoleteLoaderPaths) {
    if (Test-Path -LiteralPath (Join-Path $root $relative)) {
        Add-ValidationError "Obsolete non-3.3.5 loader artifact exists: $relative"
    }
}
foreach ($manifest in $tocPaths) {
    $recurseXml = $manifest.FullName -ceq $tocPath
    foreach ($rawLine in [IO.File]::ReadLines($manifest.FullName)) {
        $line = $rawLine.Trim()
        if (-not $line -or $line.StartsWith('#')) { continue }
        $resolved = Resolve-ExactPath $root $line
        if (-not $resolved) {
            Add-ValidationError (
                "Manifest path is missing or has incorrect case: $line " +
                "(from $($manifest.Name))")
        } else {
            # Nested XML path semantics differ on later clients. Only 30300 is
            # supported and recursively validated; other manifests still get
            # strict validation for each mechanically updated root entry.
            Read-Resource $resolved $recurseXml
        }
    }
}

$tocText = [IO.File]::ReadAllText($tocPath)
$orderedPaths = @(
    'Compat\Bootstrap.lua', 'Compat\InventoryCount335.lua',
    'libs\embeds_335.xml', 'Core\Locale.lua',
    'Core\Services.lua', 'Core\Scheduler.lua', 'Core\Storage.lua',
    'Core\Runtime.lua', 'Core\Facade.lua', 'Guide\QuestAcceptState.lua',
    'Core\Addon.lua',
    'DB\wotlk\db.lua', 'Compat\LocationLocales335.lua',
    'Guide\ElementState.lua', 'Guide\AutomationOrder.lua',
    'Guide\Directives\Handlers.lua',
    'Guide\Directives\Registry.lua', 'Guide\Loader.lua',
    'Guide\Registry.lua', 'GuideList_335.xml',
    'Features\Talents.lua', 'Talents_wotlk_335.xml', 'Compat\Options.lua'
)
$lastIndex = -1
foreach ($path in $orderedPaths) {
    $index = $tocText.IndexOf($path, [StringComparison]::Ordinal)
    if ($index -lt 0) {
        Add-ValidationError "Required load-order entry is missing: $path"
    } elseif ($index -le $lastIndex) {
        Add-ValidationError "Load-order entry is out of order: $path"
    }
    $lastIndex = [Math]::Max($lastIndex, $index)
}

# The 3.3.5 map APIs expose localized display names. Navigation must bind map
# IDs through Astrolabe's stable GetMapInfo() tokens instead; otherwise every
# non-English client loses world coordinates, arrows, and pins. Validate the
# complete bundled token set so future database or library updates cannot
# silently reintroduce that failure.
$hbdPath = Join-Path $root 'libs\HBD335\HereBeDragons-335.lua'
$hbdText = [IO.File]::ReadAllText($hbdPath)
$mapDbText = [IO.File]::ReadAllText((Join-Path $root 'DB\wotlk\db.lua'))
$astrolabeText = [IO.File]::ReadAllText(
    (Join-Path $root 'libs\Astrolabe\Astrolabe.lua'))

function ConvertTo-StableMapKey([string]$Name) {
    if ([string]::IsNullOrWhiteSpace($Name)) { return $null }
    $key = ($Name.ToLowerInvariant() -replace '[^a-z0-9]', '')
    if ($key.StartsWith('the')) { $key = $key.Substring(3) }
    return $key
}

$mapIDs = @{}
$mapBlock = [regex]::Match(
    $mapDbText, '(?s)addon\.mapId\s*=\s*\{(?<body>.*?)\n\}')
foreach ($match in [regex]::Matches(
    $mapBlock.Groups['body'].Value,
    '\["(?<name>(?:\\.|[^"])*)"\]\s*=\s*(?<id>\d+)')) {
    $mapIDs[$match.Groups['name'].Value] = [int]$match.Groups['id'].Value
}
foreach ($match in [regex]::Matches(
    $mapDbText,
    'addon\.mapId\["(?<name>(?:\\.|[^"])*)"\]\s*=\s*(?<id>\d+)')) {
    $mapIDs[$match.Groups['name'].Value] = [int]$match.Groups['id'].Value
}
$stableMapIDs = @{}
foreach ($entry in $mapIDs.GetEnumerator()) {
    $key = ConvertTo-StableMapKey $entry.Key
    if (-not $key) { continue }
    if (-not $stableMapIDs.ContainsKey($key)) {
        $stableMapIDs[$key] = $entry.Value
    } elseif ($stableMapIDs[$key] -ne $entry.Value) {
        $stableMapIDs[$key] = $false
    }
}

$mapAliases = @{}
$aliasBlock = [regex]::Match(
    $hbdText, '(?s)local legacyMapFileAliases\s*=\s*\{(?<body>.*?)\n\}')
foreach ($match in [regex]::Matches(
    $aliasBlock.Groups['body'].Value,
    '(?m)^\s*(?<token>[A-Za-z][A-Za-z0-9]*)\s*=\s*"(?<name>[^"]+)"')) {
    $mapAliases[$match.Groups['token'].Value] = $match.Groups['name'].Value
}

$mapTokens = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::Ordinal)
foreach ($match in [regex]::Matches(
    $astrolabeText,
    '(?m)^\t{3}(?<token>[A-Za-z][A-Za-z0-9]*)\s*=\s*\{')) {
    [void]$mapTokens.Add($match.Groups['token'].Value)
}
if ($mapTokens.Count -lt 60) {
    Add-ValidationError (
        "Astrolabe map-token validation found only $($mapTokens.Count) zones.")
}
foreach ($token in $mapTokens) {
    $name = if ($mapAliases.ContainsKey($token)) { $mapAliases[$token] } else { $token }
    $key = ConvertTo-StableMapKey $name
    if (-not $mapIDs.ContainsKey($name) -and
        (-not $stableMapIDs.ContainsKey($key) -or
            $stableMapIDs[$key] -eq $false)) {
        Add-ValidationError "Astrolabe map token does not resolve to a map ID: $token"
    }
}

$locationLocaleText = [IO.File]::ReadAllText(
    (Join-Path $root 'Compat\LocationLocales335.lua'))
$legacyAreaBlock = [regex]::Match(
    $hbdText, '(?s)local legacyAreaNames\s*=\s*\{(?<body>.*?)\n\}')
$legacyAreaNames = @([regex]::Matches(
    $legacyAreaBlock.Groups['body'].Value,
    '\[\d+\]\s*=\s*"(?<name>(?:\\.|[^"])*)"') |
        ForEach-Object { $_.Groups['name'].Value } | Sort-Object -Unique)
foreach ($clientLocale in @('deDE', 'esES', 'frFR', 'koKR', 'ruRU', 'zhCN', 'zhTW')) {
    $localeBlock = [regex]::Match(
        $locationLocaleText,
        '(?s)\["' + [regex]::Escape($clientLocale) +
            '"\]\s*=\s*\{(?<body>.*?)\n\s*\},')
    if (-not $localeBlock.Success) {
        Add-ValidationError "Legacy location translations are missing: $clientLocale"
        continue
    }
    $translatedNames = [Collections.Generic.HashSet[string]]::new(
        [StringComparer]::Ordinal)
    foreach ($match in [regex]::Matches(
        $localeBlock.Groups['body'].Value,
        '\["(?<name>(?:\\.|[^"])*)"\]\s*=')) {
        [void]$translatedNames.Add($match.Groups['name'].Value)
    }
    $missingAreaNames = @($legacyAreaNames | Where-Object {
        -not $translatedNames.Contains($_)
    })
    if ($missingAreaNames.Count -gt 0) {
        Add-ValidationError (
            "$clientLocale lacks $($missingAreaNames.Count) legacy area translation(s).")
    }
}
if ($hbdText -notmatch 'Astrolabe\.ContinentList') {
    Add-ValidationError 'The legacy map bridge no longer uses stable Astrolabe map tokens.'
}

$surface = [IO.File]::ReadAllText(
    (Join-Path $root 'tests\runtime-surface.json')) | ConvertFrom-Json
$directiveLuaFiles = $loadedFiles | Where-Object {
    [IO.Path]::GetExtension($_) -ceq '.lua'
}
$directiveText = ($directiveLuaFiles | ForEach-Object {
    [IO.File]::ReadAllText($_)
}) -join [Environment]::NewLine
$expectedDirectiveNames = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::Ordinal)
foreach ($name in $surface.directives) {
    [void]$expectedDirectiveNames.Add([string]$name)
    $pattern = 'function\s+addon\.functions\.' +
        [regex]::Escape([string]$name) + '\b'
    if ($directiveText -notmatch $pattern) {
        Add-ValidationError "Compatibility directive is missing: .$name"
    }
}
foreach ($name in $surface.directiveAliases) {
    [void]$expectedDirectiveNames.Add([string]$name)
}

# Database modules also own a few directives. Discover definitions across every
# Lua resource actually loaded by the 30300 manifest so a future refactor cannot
# silently omit one from the compatibility snapshot or domain catalog.
$definedDirectivePattern =
    '(?:function\s+addon\.functions\.|addon\.functions\.)([A-Za-z][A-Za-z0-9_]*)' +
    '(?:\s*\(|\s*=\s*function\b)'
foreach ($match in [regex]::Matches($directiveText,
    $definedDirectivePattern)) {
    $name = $match.Groups[1].Value
    if (-not $expectedDirectiveNames.Contains($name)) {
        Add-ValidationError (
            "Loaded directive is absent from the compatibility snapshot: .$name")
    }
}

$catalogNames = @{}
$domainFiles = @(
    'Quest.lua', 'Navigation.lua', 'Travel.lua', 'Inventory.lua',
    'Character.lua', 'Conditions.lua', 'Collection.lua', 'SpecialActions.lua')
foreach ($domainFile in $domainFiles) {
    $domainPath = Join-Path $root (Join-Path 'Guide\Directives' $domainFile)
    $domainText = [IO.File]::ReadAllText($domainPath)
    $domainMatch = [regex]::Match(
        $domainText, '(?s)RegisterDomain\("[^"]+",\s*\{(.*?)\}\)')
    if (-not $domainMatch.Success) {
        Add-ValidationError "Directive domain is malformed: $domainFile"
        continue
    }
    foreach ($match in [regex]::Matches(
        $domainMatch.Groups[1].Value, '"([A-Za-z][A-Za-z0-9_]*)"')) {
        $name = $match.Groups[1].Value
        if ($catalogNames.ContainsKey($name)) {
            Add-ValidationError "Directive is assigned to multiple domains: .$name"
        }
        $catalogNames[$name] = $domainFile
    }
}
foreach ($name in @($surface.directives) + @($surface.directiveAliases)) {
    if (-not $catalogNames.ContainsKey([string]$name)) {
        Add-ValidationError "Directive is missing a domain: .$name"
    }
}
$expectedDirectiveCount = $surface.directives.Count +
                              $surface.directiveAliases.Count
if ($catalogNames.Count -ne $expectedDirectiveCount) {
    Add-ValidationError (
        "Directive catalog contains $($catalogNames.Count) names; " +
        "expected $expectedDirectiveCount.")
}

$runtimeFiles = Get-ChildItem (Join-Path $root 'Core'),
    (Join-Path $root 'Guide'), (Join-Path $root 'UI'),
    (Join-Path $root 'Features') -Recurse -File -Filter *.lua
$runtimeText = ($runtimeFiles | ForEach-Object {
    [IO.File]::ReadAllText($_.FullName)
}) -join [Environment]::NewLine

# Legacy quest-log APIs may return numeric zero for false. A raw truthiness
# check makes every missing quest look active on those clients and can skip
# item/objective elements before their targets are rendered.
$compatBootstrapText = [IO.File]::ReadAllText(
    (Join-Path $root 'Compat\Bootstrap.lua'))
if ($compatBootstrapText -match
    'GetQuestLogIndexByID\s*\([^)]*\)\s*and\s*true') {
    Add-ValidationError (
        'The legacy quest-log index is used as a boolean; index zero must be rejected.')
}
if ($compatBootstrapText -notmatch
        'local function validatedLogIndex\s*\(' -or
    $compatBootstrapText -notmatch
        'index\s+and\s+index\s*>\s*0\s+and\s+questIDFromIndex\(index\)\s*==\s*questID' -or
    $compatBootstrapText -notmatch
        'local function legacyTrue\s*\(') {
    Add-ValidationError (
        'The 3.3.5 quest facade must validate positive quest-log indices and numeric booleans.')
}

$directiveHandlersText = [IO.File]::ReadAllText(
    (Join-Path $root 'Guide\Directives\Handlers.lua'))
$guideWindowText = [IO.File]::ReadAllText(
    (Join-Path $root 'UI\GuideWindow.lua'))
$inventoryCountPath = Join-Path $root 'Compat\InventoryCount335.lua'
$inventoryCountText = [IO.File]::ReadAllText($inventoryCountPath)
if ($inventoryCountText -notmatch
        'KEYRING_CONTAINER\s*=\s*_G\.KEYRING_CONTAINER\s+or\s+-2' -or
    $inventoryCountText -notmatch
        'explicitCarried\s*=\s*CountOrdinaryCarried\(wantedID\)\s*\+\s*keyringCount' -or
    $inventoryCountText -notmatch
        'requestedCount\s*\+\s*missingFromLegacyAPI' -or
    $directiveHandlersText -notmatch
        'events\.itemcount\s*=\s*events\.collect' -or
    $directiveHandlersText -notmatch
        'gameVersion\s*==\s*30300\s+and\s+"BAG_UPDATE"') {
    Add-ValidationError (
        'Legacy guide item validation must count keyring container -2 and ' +
        'refresh collect/itemcount elements from BAG_UPDATE on 3.3.5.')
}
if ($directiveHandlersText -notmatch 'element\.autoSkip\s*=\s*true' -or
    $directiveHandlersText -notmatch
        'element\.autoSkip\s+and\s+not\s+element\.manualSkip' -or
    $directiveHandlersText -notmatch
        'addon\.RefreshObjectiveTargets\s*=\s*refreshObjectiveTargets' -or
    $directiveHandlersText -notmatch
        'local function ExtractObjectiveMobName\s*\(' -or
    $directiveHandlersText -notmatch
        'SetInferredObjectiveMob\(element,\s*not completed and inferredMobName or nil\)' -or
    $guideWindowText -notmatch 'element\.manualSkip\s*=') {
    Add-ValidationError (
        'Automatic objective skips must be reversible without clearing manual skips.')
}

if ($directiveHandlersText -notmatch
        'element\.hearthPending\s*=\s*true' -or
    $directiveHandlersText -notmatch
        'event\s*==\s*"PLAYER_ENTERING_WORLD"' -or
    $guideWindowText -notmatch
        'step\.waitForHearth\s*=\s*waitForHearth\s+or\s+nil' -or
    $guideWindowText -notmatch
        'step\.completed\s+and\s+not\s+waitingForHearth') {
    Add-ValidationError (
        'Hearth steps must block through the completed teleport while retaining fallback guards.')
}

$coreAddonText = [IO.File]::ReadAllText((Join-Path $root 'Core\Addon.lua'))
$automationOrderText = [IO.File]::ReadAllText(
    (Join-Path $root 'Guide\AutomationOrder.lua'))
if ($coreAddonText -notmatch
        'RegisterEvent\s*\(\s*"QUEST_FINISHED"\s*\)' -or
    $coreAddonText -notmatch
        'ReconcileSubmittedQuestInteraction\s*\(\s*disabled\s*,\s*true\s*\)' -or
    $coreAddonText -notmatch
        'MarkQuestSubmitted\s*\(\s*"turnin"' -or
    $automationOrderText -notmatch
        'function\s+automationOrder:MarkQuestSubmitted\s*\(' -or
    $automationOrderText -notmatch
        'GetQuestReservation\s*\(\s*nil\s*,\s*now\s*\)') {
    Add-ValidationError (
        'Same-NPC quest automation must reconcile submitted rewards through ' +
        'the stock 3.3.5 QUEST_FINISHED lifecycle without cross-kind races.')
}

foreach ($module in $surface.aceModules) {
    $pattern = 'NewModule\(\s*["'']' +
        [regex]::Escape([string]$module) + '["'']'
    if ($runtimeText -notmatch $pattern) {
        Add-ValidationError "AceAddon module is missing: $module"
    }
}
foreach ($message in $surface.messages) {
    $pattern = '["'']' + [regex]::Escape([string]$message) + '["'']'
    if ($runtimeText -notmatch $pattern) {
        Add-ValidationError "Addon message or popup key is missing: $message"
    }
}
foreach ($macroName in $surface.macros) {
    $pattern = '["'']' + [regex]::Escape([string]$macroName) + '["'']'
    if ($runtimeText -notmatch $pattern) {
        Add-ValidationError "Managed macro name is missing: $macroName"
    }
}
foreach ($prefix in $surface.addonMessagePrefixes) {
    $pattern = '["'']' + [regex]::Escape([string]$prefix) + '["'']'
    if ($runtimeText -notmatch $pattern) {
        Add-ValidationError "Addon-message prefix is missing: $prefix"
    }
}

$settingsText = [IO.File]::ReadAllText((Join-Path $root 'UI\Settings.lua'))
if ($settingsText -notmatch
    'localizedAceConfigOptions\s*=\s*setmetatable\s*\(\s*\{\s*\}\s*,\s*\{\s*__mode\s*=\s*["'']k["'']' -or
    $settingsText -notmatch
    '(?s)key:match\s*\(\s*["'']\^_rxp["'']\s*\).*?option\[key\]\s*=\s*nil') {
    Add-ValidationError (
        'Legacy AceConfig translation metadata must remain outside option ' +
        'tables and private option fields must be stripped before registration.')
}
if ($settingsText -notmatch
    'addon\.settings\.AddToBlizzardOptions\s*=\s*AddToBlizzardOptions' -or
    $settingsText -notmatch
    'addon\.settings\.gui\.panels\[panelName\]') {
    Add-ValidationError (
        'Legacy option panels must use the shared protected registration ' +
        'adapter and named child-panel registry.')
}

# Every first-party child panel must go through Settings' protected adapter.
# Calling AceConfigDialog:AddToBlizOptions directly can select a partial retail
# Settings API installed by another addon and fail with a nil category on 3.3.5.
$optionRegistrationFiles = Get-ChildItem (Join-Path $root 'Core'),
    (Join-Path $root 'Guide'), (Join-Path $root 'UI'),
    (Join-Path $root 'Features'), (Join-Path $root 'Compat'),
    (Join-Path $root 'DB') -Recurse -File -Filter *.lua
$settingsPath = [IO.Path]::GetFullPath((Join-Path $root 'UI\Settings.lua'))
foreach ($file in $optionRegistrationFiles) {
    if ([IO.Path]::GetFullPath($file.FullName) -ceq $settingsPath) { continue }
    $text = [IO.File]::ReadAllText($file.FullName)
    if ($text -match '(?<![A-Za-z])AddToBlizOptions\s*\(') {
        $relative = $file.FullName.Substring($root.Length).TrimStart('\', '/')
        Add-ValidationError (
            "First-party option panel bypasses the protected adapter: $relative")
    }
}

$compatOptionsText = [IO.File]::ReadAllText(
    (Join-Path $root 'Compat\Options.lua'))
$questDBText = [IO.File]::ReadAllText((Join-Path $root 'DB\questDB.lua'))
$tbcQuestDBText = [IO.File]::ReadAllText((Join-Path $root 'DB\tbc\db.lua'))
if ($compatOptionsText -notmatch
    'RegisterOptionsPanel\s*\(\s*["'']3\.3\.5a["'']') {
    Add-ValidationError 'The 3.3.5 compatibility panel is not registered by name.'
}
foreach ($entry in @(
    @{ Name = 'WotLK quest-data'; Text = $questDBText },
    @{ Name = 'TBC quest-data'; Text = $tbcQuestDBText }
)) {
    if ($entry.Text -notmatch
        'RegisterOptionsPanel\s*\(\s*["'']Quest Data["'']') {
        Add-ValidationError "$($entry.Name) panel is not registered by name."
    }
}
$defaultsMatch = [regex]::Match(
    $settingsText,
    '(?s)local settingsDBDefaults\s*=\s*\{(.*?)function addon\.settings:InitializeDatabase')
if (-not $defaultsMatch.Success) {
    Add-ValidationError 'Settings defaults table could not be located.'
} else {
    $defaultsText = $defaultsMatch.Groups[1].Value
    foreach ($setting in $surface.settings) {
        $pattern = '(?m)^\s{8}' + [regex]::Escape([string]$setting) + '\s*='
        if ($defaultsText -notmatch $pattern) {
            Add-ValidationError "Profile setting is missing: $setting"
        }
    }
}
foreach ($command in $surface.slashCommands) {
    $pattern = '["''](?:\^)?' + [regex]::Escape([string]$command) +
        '(?:%s)?(?:["'']|\W)'
    if ($settingsText -notmatch $pattern) {
        Add-ValidationError "Slash-command compatibility token is missing: $command"
    }
}

$saved = ([regex]::Match(
    $tocText, '(?m)^## SavedVariables:\s*(.+)$')).Groups[1].Value -split ',' |
    ForEach-Object { $_.Trim() }
$savedCharacter = ([regex]::Match(
    $tocText, '(?m)^## SavedVariablesPerCharacter:\s*(.+)$')).Groups[1].Value -split ',' |
    ForEach-Object { $_.Trim() }
foreach ($name in $surface.savedVariables) {
    if ([string]$name -cnotin $saved) {
        Add-ValidationError "SavedVariable is missing: $name"
    }
}
foreach ($name in $surface.savedVariablesPerCharacter) {
    if ([string]$name -cnotin $savedCharacter) {
        Add-ValidationError "Per-character SavedVariable is missing: $name"
    }
}

$bindingsText = [IO.File]::ReadAllText((Join-Path $root 'Bindings.xml'))
foreach ($frame in $surface.bindingFrames) {
    if ($bindingsText -notmatch (
        'CLICK\s+' + [regex]::Escape([string]$frame) + ':')) {
        Add-ValidationError "Secure binding frame is missing: $frame"
    }
}
foreach ($name in $surface.globals) {
    if ($runtimeText -notmatch ('\b' + [regex]::Escape([string]$name) + '\b')) {
        Add-ValidationError "Public global compatibility name is missing: $name"
    }
}

# Lua 5.1 string.format does not support positional arguments. Localized
# strings used by hot guide and communications paths therefore have to retain
# the source placeholder order or an otherwise valid translation can abort an
# event callback. Keep this list focused on strings that are actually passed
# to string.format; literal percentages in option descriptions are harmless.
$localizedFormatKeys = @{
    'I just leveled from %d to %d in %s' = 'd,d,s'
    'Grind until you are %d xp away from level %s' = 'd,s'
    'Grind until you are %s xp into level %s' = 's,s'
    'Grind until you are %.0f%% into level %s' = 'f,s'
    'Grind until you are %d away from %s with %s' = 'd,s,s'
    'Grind until you are %s into %s with %s' = 's,s,s'
    'Grind until you are %.0f%% into %s with %s' = 'f,s,s'
    'Flying to %s ETA %s' = 's,s'
}
foreach ($localeFile in Get-ChildItem (Join-Path $root 'locale') -File -Filter '*.lua') {
    $localeText = [IO.File]::ReadAllText($localeFile.FullName)
    foreach ($formatKey in $localizedFormatKeys.Keys) {
        $translationMatch = [regex]::Match(
            $localeText,
            'L\["' + [regex]::Escape($formatKey) + '"\]\s*=\s*"([^"]*)"')
        if (-not $translationMatch.Success) { continue }
        $signature = @([regex]::Matches(
            $translationMatch.Groups[1].Value,
            '(?<!%)%(?!%)[-+0 #]*\d*(?:\.\d+)?([dfs])') |
                ForEach-Object { $_.Groups[1].Value }) -join ','
        $expected = $localizedFormatKeys[$formatKey]
        if ($signature -cne $expected) {
            Add-ValidationError (
                "$($localeFile.Name) reorders placeholders for '$formatKey': " +
                "$signature (expected $expected).")
        }
    }
}

# Multi-locale feature files store several locales in one data table instead
# of ordinary L[...] assignments. Validate every translated entry so Lua
# 5.1-incompatible placeholder reordering cannot slip in.
foreach ($multiLocaleRelative in @(
    'locale\Backport.lua', 'locale\FeatureTools.lua',
    'locale\XPAssistant.lua')) {
    $multiLocalePath = Join-Path $root $multiLocaleRelative
    if (-not (Test-Path -LiteralPath $multiLocalePath)) { continue }
    $multiLocaleText = [IO.File]::ReadAllText($multiLocalePath)
    foreach ($entry in [regex]::Matches(
        $multiLocaleText,
        '\["(?<key>(?:\\.|[^"])*)"\]\s*=\s*"(?<value>(?:\\.|[^"])*)"')) {
        $keySignature = @([regex]::Matches(
            $entry.Groups['key'].Value,
            '(?<!%)%(?!%)[-+0 #]*\d*(?:\.\d+)?([dfs])') |
                ForEach-Object { $_.Groups[1].Value }) -join ','
        $valueSignature = @([regex]::Matches(
            $entry.Groups['value'].Value,
            '(?<!%)%(?!%)[-+0 #]*\d*(?:\.\d+)?([dfs])') |
                ForEach-Object { $_.Groups[1].Value }) -join ','
        if ($keySignature -cne $valueSignature) {
            Add-ValidationError (
                "$multiLocaleRelative reorders placeholders for '$($entry.Groups['key'].Value)': " +
                "$valueSignature (expected $keySignature).")
        }
    }
}

$allowedWrites = @{}
foreach ($entry in $surface.allowedGlobalWrites) {
    $allowedWrites[[string]$entry] = $true
}
foreach ($file in $runtimeFiles) {
    $relative = $file.FullName.Substring($root.Length).TrimStart('\', '/') -replace '\\', '/'
    $text = [IO.File]::ReadAllText($file.FullName)
    foreach ($match in [regex]::Matches(
        $text, '(?m)^(?:_G\.)?([A-Z][A-Za-z0-9_]*)\s*=')) {
        $entry = $relative + ':' + $match.Groups[1].Value
        if (-not $allowedWrites.ContainsKey($entry)) {
            Add-ValidationError "Unapproved global write: $entry"
        }
    }
}

$lua = Get-Command lua5.1, lua -ErrorAction SilentlyContinue |
    Select-Object -First 1
$luac = Get-Command luac5.1, luac -ErrorAction SilentlyContinue |
    Select-Object -First 1
if ($RequireLua -and (-not $lua -or -not $luac)) {
    Add-ValidationError 'Lua 5.1 and luac 5.1 are required but were not found.'
}
if ($luac) {
    foreach ($file in $loadedFiles) {
        if ([IO.Path]::GetExtension($file) -ine '.lua') { continue }
        $compilePath = $file
        $temporaryPath = $null
        $bytes = [IO.File]::ReadAllBytes($file)
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and
            $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            $temporaryPath = Join-Path ([IO.Path]::GetTempPath()) (
                'rxp-luac-' + [guid]::NewGuid().ToString('N') + '.lua')
            [IO.File]::WriteAllBytes($temporaryPath, $bytes[3..($bytes.Length - 1)])
            $compilePath = $temporaryPath
        }
        & $luac.Source -p $compilePath
        if ($LASTEXITCODE -ne 0) {
            Add-ValidationError "Lua syntax validation failed: $file"
        }
        if ($temporaryPath) { Remove-Item -LiteralPath $temporaryPath -Force }
    }
}
if ($lua) {
    & $lua.Source (Join-Path $root 'tests\run.lua') $root
    if ($LASTEXITCODE -ne 0) {
        Add-ValidationError 'Core Lua 5.1 tests failed.'
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    throw "Runtime validation failed with $($errors.Count) error(s)."
}

Write-Host (
    'Runtime validation passed: {0} manifest resources, {1} directives, and {2} AceAddon modules.' -f
    $loadedFiles.Count, $surface.directives.Count, $surface.aceModules.Count)
