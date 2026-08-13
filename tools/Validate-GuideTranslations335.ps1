[CmdletBinding()]
param(
    [string]$RepoRoot,
    [switch]$CoreOnly
)

$ErrorActionPreference = 'Stop'
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent $PSScriptRoot }
$utf8 = New-Object System.Text.UTF8Encoding($false, $true)
$errors = New-Object System.Collections.Generic.List[string]

function Read-Utf8([string]$relative) {
    $native = $relative -replace '[\\/]', [IO.Path]::DirectorySeparatorChar
    $path = Join-Path $RepoRoot $native
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $errors.Add("Missing translation resource: $relative")
        return ''
    }
    try { return [IO.File]::ReadAllText($path, $utf8) }
    catch { $errors.Add("Invalid UTF-8 in ${relative}: $($_.Exception.Message)"); return '' }
}

$service = Read-Utf8 'Guide\Localization.lua'
$uiLocale = Read-Utf8 'Core\Locale.lua'
$catalogs = Read-Utf8 'locale\GuideCatalogs.lua'
$addonCore = Read-Utf8 'Core\Addon.lua'
$zhExact = if ($CoreOnly) { '' } else { Read-Utf8 'locale\GuideExact.zhCN.lua' }
$translationLocales = @('deDE','esES','frFR','koKR','ruRU','zhCN','zhTW')
$packs = @{}
if (-not $CoreOnly) {
    foreach ($translationLocale in $translationLocales) {
        $packs[$translationLocale] = Read-Utf8 `
            "locale\GuidePack.$translationLocale.lua"
    }
}
$englishNames = Read-Utf8 'DB\wotlk\guideEnglishNames_335.lua'
$toc = Read-Utf8 'RXPGuides.toc'
$settings = Read-Utf8 'UI\Settings.lua'
$loader = Read-Utf8 'Guide\Loader.lua'
$guideWindow = Read-Utf8 'UI\GuideWindow.lua'
$handlers = Read-Utf8 'Guide\Directives\Handlers.lua'
$guideList = Read-Utf8 'GuideList_335.xml'

if ($uiLocale -match 'local\s+ssplit[^\r\n]*strsplittable' -or
    $uiLocale -notmatch 'local\s+function\s+SplitLiteral\s*\(' -or
    $uiLocale -notmatch 'local\s+words\s*=\s*SplitLiteral\(delim, text\)' -or
    $uiLocale -notmatch 'local\s+lazyPhrase\s*=\s*tconcat\(words, delim\)') {
    $errors.Add('Core locale fallback still depends on unavailable modern string split/join helpers.')
}

$loadedVisible = @{}
foreach ($script in [regex]::Matches($guideList,
        '<Script\s+file="([^"]+\.lua)"')) {
    $relative = $script.Groups[1].Value.Replace('\',
        [IO.Path]::DirectorySeparatorChar)
    $path = Join-Path $RepoRoot $relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { continue }
    foreach ($line in [IO.File]::ReadAllLines($path, $utf8)) {
        $visible = [regex]::Match($line, '>>\s*(.+?)\s*$')
        if (-not $visible.Success) {
            $visible = [regex]::Match($line, '^\s*[+*]\s*(.+?)\s*$')
        }
        if ($visible.Success) { $loadedVisible[$visible.Groups[1].Value] = $true }
    }
}

foreach ($locale in $translationLocales) {
    if ($catalogs -notmatch ('locale\s*==\s*"' + $locale + '"')) {
        $errors.Add("Missing active-locale catalog: $locale")
    }
}
foreach ($verb in @('Accept','Turn in','Cast','Talk to','Kill','Loot','Collect','Use',
        'Equip','Buy','Train','Vendor','Hearth to','Fly to','Travel to','Grind to')) {
    if ($catalogs -notmatch ('\{"' + [regex]::Escape($verb) + '",')) {
        $errors.Add("Missing reviewed action template: $verb")
    }
}
if ($catalogs -match '%\d+\$[sdif]' -or $zhExact -match '%\d+\$[sdif]') {
    $errors.Add('Guide catalogs contain positional formatting; named tokens are required.')
}
if ($catalogs -notmatch '\{value\}') {
    $errors.Add('Guide catalogs do not use the required named value token.')
}
foreach ($template in [regex]::Matches($catalogs,
        '"((?:\\.|[^"\\])*)"\s*\}\s*,?')) {
    $value = $template.Groups[1].Value
    if ($value -match '\{') {
        $stripped = [regex]::Replace($value,
            '\{(?:value|amount|level|standing|faction)\}', '')
        if ($stripped -match '[{}]') {
            $errors.Add("Invalid named-token signature in guide template: $value")
        }
    }
}
foreach ($semanticKey in @('xpAway','xpInto','xpPercent','grindLevel',
        'repAway','repInto','repPercent','reputation')) {
    if ([regex]::Matches($catalogs,
            ('\b' + $semanticKey + '\s*=')).Count -ne 7) {
        $errors.Add("Semantic formatter '$semanticKey' is not defined for all locales.")
    }
}
if ($service -notmatch 'FALLBACK_BADGE\s*=\s*" \|cff9d9d9d\[EN\]\|r"' -or
    $service -notmatch 'guideTranslationFallback') {
    $errors.Add('English fallback badge/metadata wiring is missing.')
}
if ($service -notmatch 'MACHINE_BADGE\s*=\s*" \|cff70a0ff\[MT\]\|r"' -or
    $service -notmatch 'guideTranslationMachine') {
    $errors.Add('Machine-translation badge/metadata wiring is missing.')
}
foreach ($api in @('RenderElement','RenderGuideName','RenderGroup','SetMode',
        'RegisterTranslationPack','RegisterCompressedPack','Tokenize',
        'UIWithMetadata','GetStatusExplanation')) {
    if ($service -notmatch ('function\s+service:' + $api + '\s*\(')) {
        $errors.Add("Missing guide-localization API: $api")
    }
}
foreach ($field in @('sourceText','sourceTooltipText','sourceGroup','sourceName',
        'sourceDisplayName','sourceSubgroup','sourceTitle','sourceGuideKey')) {
    if ($loader -notmatch [regex]::Escape($field)) {
        $errors.Add("Immutable English source field is not captured: $field")
    }
}
if ($settings -notmatch 'guideLanguage\s*=\s*"localized"' -or
    $settings -notmatch 'Translated \(client language\)' -or
    $settings -notmatch 'Original English') {
    $errors.Add('Localized/English profile control is incomplete.')
}
if ($guideWindow -match
        '(?s)ReplaceNpcIds\s*\(\s*addon\.locale\.GuideText\s*\(') {
    $errors.Add('GuideText metadata is being forwarded to ReplaceNpcIds as an element.')
}
if ($service -notmatch
        '(?s)addon\.locale\.GuideText\s*=\s*function.*?local rendered\s*=\s*service:Render\(.*?return rendered\s*end') {
    $errors.Add('Legacy GuideText no longer preserves its single-return contract.')
}
if ($service -notmatch '(?s)TranslateLines\(output, element, field\).*?ReplaceQuestName\(output, element, true\)' -or
    $service -notmatch '(?s)SourceFor\(text, element, field, localized\).*?if liveProgress then output = output \.\. liveProgress end') {
    $errors.Add('Official quest names or live counters can bypass canonical translation order.')
}
if ($service -notmatch 'local\s+function\s+LocalizeSemanticValue\s*\(' -or
    $service -notmatch 'value,\s*official\s*=\s*LocalizeSemanticValue\(value, element\)') {
    $errors.Add('Reviewed semantic actions do not preserve official localized entity names.')
}
if ($handlers -notmatch
        'type\(element\.step\)\s*==\s*"table"') {
    $errors.Add('ReplaceNpcIds does not guard non-element localization metadata.')
}

$order = @('Core\Locale.lua','Guide\Localization.lua','locale\GuideCatalogs.lua')
if (-not $CoreOnly) {
    $order += @('locale\GuideExact.zhCN.lua')
    $order += @($translationLocales | ForEach-Object {
        "locale\GuidePack.$_.lua"
    })
}
$order += @('UI\GuideWindow.lua','DB\wotlk\guideEnglishNames_335.lua',
    'Guide\Loader.lua')
$last = -1
foreach ($entry in $order) {
    $index = $toc.IndexOf($entry)
    if ($index -lt 0) { $errors.Add("TOC is missing $entry") }
    elseif ($index -le $last) { $errors.Add("Unsafe translation load order around $entry") }
    $last = $index
}

$exactCount = 0
if (-not $CoreOnly) {
    foreach ($match in [regex]::Matches($zhExact,
            '(?m)^\s*\["((?:\\.|[^"\\])*)"\]\s*=\s*"((?:\\.|[^"\\])*)",\s*$')) {
        $exactCount++
        $english = $match.Groups[1].Value
        $translated = $match.Groups[2].Value
        $sourceEnglish = $english.Replace('\"', '"').Replace('\\', '\')
        if (-not $loadedVisible.ContainsKey($sourceEnglish)) {
            $errors.Add("Stale zhCN source string is not present in loaded guides: $sourceEnglish")
        }
        if ($translated -notmatch '[\u3400-\u9fff]') {
            $errors.Add("zhCN exact entry has no Chinese display text: $english")
        }
        foreach ($token in @('\|cRXP_[A-Z]+_','\|r','\|T','\|t','\|H','\|h',
                '\d+(?:\.\d+)?')) {
            if ([regex]::Matches($english, $token).Count -ne
                [regex]::Matches($translated, $token).Count) {
                $errors.Add("Markup signature changed for zhCN entry: $english")
                break
            }
        }
        if ($translated -match '(^|\\n)\s*\.[a-z]+\s') {
            $errors.Add("Translated directive leaked into display catalog: $english")
        }
    }
    if ($exactCount -lt 1) {
        $errors.Add('No safely aligned upstream zhCN display strings were imported.')
    }
    foreach ($translationLocale in $translationLocales) {
        $pack = $packs[$translationLocale]
        if ($pack -notmatch ('GetLocale\(\)\s*~=\s*"' + $translationLocale + '"') -or
            $pack -notmatch ('RegisterCompressedPack\("' + $translationLocale +
                '", payload\)')) {
            $errors.Add("Compiled active-locale $translationLocale pack is missing or not locale gated.")
        }
    }
}

if ($CoreOnly) {
    $bootstrap = Read-Utf8 'packaging\locale\Bootstrap.lua'
    $packager = Read-Utf8 'tools\Build-LocalePackages335.sh'
    $releaseWorkflow = Read-Utf8 '.github\workflows\release.yml'
    $lock = (Read-Utf8 'LOCALIZATIONS.lock').Trim()
    if ($toc -match 'locale\\Guide(?:Exact|Pack)\.') {
        $errors.Add('The core TOC still embeds optional locale payloads.')
    }
    foreach ($api in @('GetCompanionAddonName','LoadCompanion',
            'GetCompanionState')) {
        if ($service -notmatch ('function\s+service:' + $api + '\s*\(')) {
            $errors.Add("Missing locale-companion API: $api")
        }
    }
    if ($addonCore -notmatch
            'addon\.guideLocalization:LoadCompanion\(\)') {
        $errors.Add('Core startup does not load the matching locale companion.')
    }
    if ($bootstrap -notmatch 'GetAddon\("RXPGuides", true\)' -or
        $bootstrap -notmatch 'companion\.guideLocalization\s*=') {
        $errors.Add('Locale companion bootstrap does not bind to the core presentation service.')
    }
    if ($lock -notmatch '^[0-9a-f]{40}$') {
        $errors.Add('LOCALIZATIONS.lock must contain one full Git commit ID.')
    }
    foreach ($locale in $translationLocales) {
        if ($packager -notmatch ('\b' + $locale + '\b')) {
            $errors.Add("Locale packager does not include $locale.")
        }
    }
    if ($packager -notmatch '## LoadOnDemand: 1' -or
        $packager -notmatch 'scripts=\("Bootstrap\.lua"\)' -or
        $packager -notmatch 'X-RXPGuides-Localization-Commit') {
        $errors.Add('Locale package manifest/order metadata is incomplete.')
    }
    if ($releaseWorkflow -notmatch 'LOCALIZATIONS\.lock' -or
        $releaseWorkflow -notmatch 'Build-LocalePackages335\.sh' -or
        $releaseWorkflow -notmatch '\.locale-release/\*\.zip') {
        $errors.Add('Release workflow does not publish the pinned locale assets.')
    }
}
if (-not $CoreOnly) {
    foreach ($tool in @('Export-TranslationUnits335.ps1',
            'Import-GuideTranslations335.ps1','Import-TranslationMap335.ps1',
            'Compile-TranslationPack335.ps1','New-TranslationDraft335.ps1',
            'New-GlossaryMachineCatalog335.ps1',
            'Import-AceLocaleTranslations335.ps1',
            'Get-TranslationCoverage335.ps1',
            'Get-UiLocalizationCoverage335.ps1',
            'Validate-TranslationPacks335.ps1')) {
        $toolPath = Join-Path (Join-Path $RepoRoot 'tools') $tool
        if (-not (Test-Path -LiteralPath $toolPath `
                -PathType Leaf)) {
            $errors.Add("Missing localization workflow tool: $tool")
        }
    }
}

# Verify that directives which must synthesize English display text can resolve
# a bundled authored name from another loaded guide occurrence. Quest 9671 is
# the sole legacy bare directive and is explicitly catalogued by the service.
$required = @{ quests = @{}; items = @{}; spells = @{} }
$known = @{ quests = @{}; items = @{}; spells = @{} }
foreach ($kind in @('quests','items','spells')) {
    $block = [regex]::Match($englishNames,
        '(?s)\b' + $kind + '\s*=\s*\{(.*?)\n\s*\},')
    if (-not $block.Success) {
        $errors.Add("Missing bundled English $kind catalog.")
        continue
    }
    foreach ($match in [regex]::Matches($block.Groups[1].Value,
            '\[(\d+)\]\s*=\s*"')) {
        $known[$kind][[int]$match.Groups[1].Value] = $true
    }
}
foreach ($script in [regex]::Matches($guideList, '<Script\s+file="([^"]+\.lua)"')) {
    $relative = $script.Groups[1].Value.Replace('\', [IO.Path]::DirectorySeparatorChar)
    $path = Join-Path $RepoRoot $relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { continue }
    foreach ($line in [IO.File]::ReadAllLines($path, $utf8)) {
        $daily = [regex]::Match($line,
            '^\s*\.(?:daily|dailyturnin)\s+([^>]+)>>\s*(.+?)(?:\s*<<.*)?\s*$')
        if ($daily.Success) {
            $dailyName = $daily.Groups[2].Value -replace
                '^(?i:(?:Accept|Turn in))\s+', ''
            if ($dailyName.Trim()) {
                foreach ($questId in [regex]::Matches(
                        $daily.Groups[1].Value, '\d+')) {
                    $known.quests[[int]$questId.Value] = $true
                }
            }
        }
        $directive = [regex]::Match($line, '^\s*\.(\S+)\s+-?(\d+)')
        if (-not $directive.Success) { continue }
        $tag = $directive.Groups[1].Value
        $id = [int]$directive.Groups[2].Value
        $kind = if ($tag -in @('accept','turnin','complete')) { 'quests' }
            elseif ($tag -eq 'collect') { 'items' }
            else { $null }
        if (-not $kind) { continue }
        if ($tag -eq 'complete' -and $line -match '--\s*\S') { continue }
        $visibleMatch = [regex]::Match($line, '>>\s*(.+?)(?:\s*<<.*)?\s*$')
        if (-not $visibleMatch.Success -or $visibleMatch.Groups[1].Value -eq '*quest*') {
            $required[$kind][$id] = $true
            continue
        }
        $visible = $visibleMatch.Groups[1].Value
        $visible = $visible -replace '\|T.*?\|t','' -replace '\|cRXP_[A-Z]+_',''
        $visible = $visible -replace '\|c[0-9a-fA-F]{8}','' -replace '\|r',''
        if ($kind -eq 'quests') {
            $actionName = if ($tag -eq 'accept') {
                $visible -replace '^(?i:Accept)\s+',''
            } elseif ($visible -match '^(?i:Turn in)\s+(.+)$') {
                $Matches[1]
            } else { $null }
            if ($actionName -and $actionName.Trim()) {
                $known[$kind][$id] = $true
            }
        } else {
            $bracketName = [regex]::Match($visible, '\[([^\]]+)\]')
            if ($bracketName.Success -or ($kind -eq 'spells' -and $visible.Trim())) {
                $known[$kind][$id] = $true
            }
        }
    }
}
foreach ($kind in @('quests','items','spells')) {
    $missing = @($required[$kind].Keys | Where-Object { -not $known[$kind].ContainsKey($_) })
    if ($missing.Count -gt 0) {
        $errors.Add("Missing bundled English $kind names required by generated guide text: $($missing -join ', ')")
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    throw "Guide translation validation failed with $($errors.Count) error(s)."
}
if ($CoreOnly) {
    Write-Host 'Guide localization core OK: optional companion loading, named templates, immutable source, and pinned release input.'
} else {
    Write-Host "Guide translations OK: 7 locale catalogs and locale-gated packs, $exactCount reviewed zhCN exact strings, named templates, immutable source, and explicit fallbacks."
}
