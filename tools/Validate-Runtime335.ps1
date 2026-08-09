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
    'Compat\Bootstrap.lua', 'libs\embeds_335.xml', 'Core\Locale.lua',
    'Core\Services.lua', 'Core\Scheduler.lua', 'Core\Storage.lua',
    'Core\Runtime.lua', 'Core\Facade.lua', 'Guide\QuestAcceptState.lua',
    'Core\Addon.lua',
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

# Backport.lua stores several locales in one data table instead of ordinary
# L[...] assignments. Validate every translated entry there, including future
# additions, so Lua 5.1-incompatible placeholder reordering cannot slip in.
$backportLocalePath = Join-Path $root 'locale\Backport.lua'
if (Test-Path -LiteralPath $backportLocalePath) {
    $backportLocaleText = [IO.File]::ReadAllText($backportLocalePath)
    foreach ($entry in [regex]::Matches(
        $backportLocaleText,
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
                "Backport.lua reorders placeholders for '$($entry.Groups['key'].Value)': " +
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
