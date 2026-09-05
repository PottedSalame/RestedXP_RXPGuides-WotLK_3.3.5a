$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$errors = New-Object 'Collections.Generic.List[string]'
function Add-Error([string]$Message) { $errors.Add($Message) }

$tocPath = Join-Path $root 'RXPGuides.toc'
$toc = [IO.File]::ReadAllText($tocPath)
$modules = @(
    'Features/Roadmap.lua','UI/GuideHub.lua','Features/Diagnostics.lua',
    'Core/Recovery.lua','Features/CompatibilityPacks.lua',
    'Features/PartySync.lua','Features/Supplies.lua','Features/GearAdvisor.lua',
    'Features/ActivityPlanner.lua','Features/Accessibility.lua',
    'Features/GuideRecorder.lua','Features/PerformanceInspector.lua',
    'Features/GuideAnalysis.lua','Features/RunArchive.lua',
    'Features/PetAssistant.lua','Features/XPAssistant.lua',
    'Features/SpeedrunCore.lua','Features/SpeedrunAdvisors.lua',
    'Features/SpeedrunPractice.lua'
)
$lastOffset = -1
foreach ($module in $modules) {
    $path = Join-Path $root $module
    if (-not [IO.File]::Exists($path)) { Add-Error "Missing roadmap module: $module"; continue }
    $tocModule = $module -replace '/', '\'
    $offset = $toc.IndexOf($tocModule, [StringComparison]::OrdinalIgnoreCase)
    if ($offset -lt 0) { Add-Error "3.3.5 manifest does not load $module" }
    elseif ($offset -le $lastOffset) { Add-Error "Roadmap module load order is invalid at $module" }
    $lastOffset = $offset
}

$coreText = [IO.File]::ReadAllText((Join-Path $root 'Core/Addon.lua'))
$cacheVersionMatch = [regex]::Match($coreText, 'local cacheVersion\s*=\s*(\d+)\b')
if (-not $cacheVersionMatch.Success -or [int]$cacheVersionMatch.Groups[1].Value -lt 34) {
    Add-Error 'Guide metadata cache version must be at least 34 for content-signature invalidation.'
}

$settingsText = [IO.File]::ReadAllText((Join-Path $root 'UI/Settings.lua'))
foreach ($command in @('guides','diagnose','backup','supplies','gear','dailies','record',
        'preflight','watch','archives','pet','perf','coach','grind','pitstop',
        'deathwarp','practice','audio','rules')) {
    if ($settingsText -notmatch ('input\s*==\s*"' + [regex]::Escape($command) + '"')) {
        Add-Error "Missing /rxp $command command routing."
    }
}

$speedrunCoreText = [IO.File]::ReadAllText((Join-Path $root 'Features/SpeedrunCore.lua'))
$speedrunAdvisorText = [IO.File]::ReadAllText((Join-Path $root 'Features/SpeedrunAdvisors.lua'))
$speedrunPracticeText = [IO.File]::ReadAllText((Join-Path $root 'Features/SpeedrunPractice.lua'))
foreach ($setting in @('enableSpeedrunSuite','enableSpeedrunCoach',
        'enableSpeedrunGrind','enableSpeedrunPitStop','enableSpeedrunRoute',
        'enableSpeedrunDeathwarp','enableSpeedrunPractice',
        'enableSpeedrunAudio','enableSpeedrunRules')) {
    if ($settingsText -notmatch [regex]::Escape($setting)) {
        Add-Error "Speedrunning Suite setting is missing: $setting"
    }
}
foreach ($pattern in @('function\s+speedrun:StartSegment\s*\(',
        'function\s+speedrun:GetComparison\s*\(',
        'function\s+speedrun:EnsureLiveSetup\s*\(',
        'loading/offline','MAX_DETAILED_RUNS\s*=\s*10')) {
    if ($speedrunCoreText -notmatch $pattern) {
        Add-Error "Speedrun timing foundation is missing: $pattern"
    }
}
foreach ($api in @('grind:Scan','pitstop:Scan','strategist:Scan','deathwarp:Scan')) {
    if ($speedrunAdvisorText -notmatch ('function\s+' + [regex]::Escape($api) + '\s*\(')) {
        Add-Error "Speedrun advisor API is missing: $api"
    }
}
foreach ($api in @('Start','Pause','Split','Finish','Abort')) {
    if ($speedrunPracticeText -notmatch ('function\s+practice:' + $api + '\s*\(')) {
        Add-Error "Speedrun Practice API is missing: $api"
    }
}
if ($speedrunPracticeText -match 'addon\.SetStep\s*\(' -or
    $speedrunPracticeText -match 'addon\.GoToStep\s*\(') {
    Add-Error 'Practice mode must not mutate the real guide step.'
}
$speedrunMultiReturnHazards = @(
    'tonumber\s*\(\s*GetContainerNumFreeSlots\s*\(',
    'tonumber\s*\(\s*GetRepairAllCost\s*\(',
    'tonumber\s*\(\s*addon\.tracker:GetElapsedTimes\s*\(',
    'tonumber\s*\(\s*select\s*\(\s*3\s*,\s*GetItemInfo\s*\('
)
foreach ($pattern in $speedrunMultiReturnHazards) {
    if ($speedrunCoreText -match $pattern -or
        $speedrunAdvisorText -match $pattern -or
        $speedrunPracticeText -match $pattern) {
        Add-Error (
            'Speedrun code passes a multi-return API directly to tonumber: ' +
            $pattern)
    }
}

$toolWindowText = [IO.File]::ReadAllText((Join-Path $root 'UI/ToolWindow.lua'))
foreach ($pattern in @(
        'function\s+manager:GetAppearanceValue\s*\(',
        'function\s+manager:SetAppearanceValue\s*\(',
        'function\s+manager:ResetWindow\s*\(',
        'function\s+manager:BringToFront\s*\(',
        'function\s+manager:RefreshLayering\s*\(',
        'backgroundOpacity\s*=\s*\{0,\s*1\}')) {
    if ($toolWindowText -notmatch $pattern) {
        Add-Error "Shared feature-tool appearance control is missing: $pattern"
    }
}
if ($toolWindowText -notmatch 'local\s+function\s+PreventEscapeClose\s*\(' -or
    $toolWindowText -match 'RegisterEscapeFrame') {
    Add-Error 'Shared Feature Tool windows must not close through UISpecialFrames/Escape.'
}
if ($toolWindowText -notmatch
        'local\s+scrollName\s*=\s*spec\.name\s+or' -or
    $toolWindowText -notmatch
        'CreateFrame\("ScrollFrame",\s*scrollName,\s*frame') {
    Add-Error (
        'Legacy UIPanelScrollFrameTemplate instances must have stable names.')
}
if ($settingsText -notmatch 'featureToolsSettings\s*=\s*\{' -or
    $settingsText -notmatch 'childGroups\s*=\s*"tree"') {
    Add-Error 'Feature Tools does not expose an individual settings-page tree.'
}
if ($settingsText -notmatch
        'function\s+addon\.settings:ApplySpeedrunSettings\s*\(' -or
    $settingsText -notmatch
        'SPEEDRUN_SETTINGS_OWNER' -or
    $settingsText -match
        'self\.profile\[setting\]\s*=\s*value\s*==\s*true') {
    Add-Error 'Speedrun toggles are not reconciled live across legacy AceGUI callbacks.'
}
$xpText = [IO.File]::ReadAllText((Join-Path $root 'Features/XPAssistant.lua'))
foreach ($key in @('xpEstimatorShowStockXP','xpEstimatorShowKills',
                    'xpEstimatorShowAdaptive','xpEstimatorShowAdaptiveKills',
                    'xpEstimatorShowRested')) {
    if ($settingsText -notmatch [regex]::Escape($key) -or
        $xpText -notmatch [regex]::Escape($key)) {
        Add-Error "XP estimator display option is not fully wired: $key"
    }
}
if ($xpText -notmatch 'function\s+assistant:ResizeForVisibleColumns\s*\(' -or
    $xpText -notmatch 'xpColumnCount') {
    Add-Error 'XP estimator does not adapt its saved window size to visible columns.'
}

# Remaining 3.3.5 backport completion guards. These are intentionally
# structural: gameplay behavior is exercised in-game, while CI prevents a
# manifest cleanup or upstream merge from silently disconnecting the feature.
foreach ($database in @('DB\classic\SpiritHealerDB.lua',
                         'DB\classic\dangerousMobs.lua',
                         'DB\tbc\dangerousMobs.lua')) {
    if ($toc.IndexOf($database, [StringComparison]::OrdinalIgnoreCase) -lt 0) {
        Add-Error "3.3.5 manifest does not load $database"
    }
}
$outlandDangerText = [IO.File]::ReadAllText((Join-Path $root 'DB/tbc/dangerousMobs.lua'))
if (([regex]::Matches($outlandDangerText, 'MinLevel\s*=')).Count -ne 172 -or
    ([regex]::Matches($outlandDangerText, '(?m)^\s{4}\["(?:Blade''s Edge Mountains|Hellfire Peninsula|Zangarmarsh|Terokkar Forest|Nagrand|Netherstorm|Shadowmoon Valley)"\]\s*=\s*\{')).Count -ne 14 -or
    $outlandDangerText -notmatch 'outlandDangerousMobs\[_G\.UnitFactionGroup\("player"\)\]') {
    Add-Error 'Outland dangerous-mob data must retain 86 faction-scoped records across all seven zones.'
}
$mapText = [IO.File]::ReadAllText((Join-Path $root 'UI/Map.lua'))
$healerText = [IO.File]::ReadAllText((Join-Path $root 'DB/classic/SpiritHealerDB.lua'))
$hbdText = [IO.File]::ReadAllText((Join-Path $root 'libs/HBD335/HereBeDragons-335.lua'))
if ($mapText -notmatch 'FindNearestSpiritHealer' -or
    $mapText -notmatch '(?s)spiritHealerDBKeys\s*=.*\[3\]\s*=\s*\{\s*530\s*\}.*\[4\]\s*=\s*\{\s*571\s*\}' -or
    $mapText -notmatch 'deathskipResolved' -or
    $mapText -notmatch 'ShouldFollowGuideWhileGhost' -or
    $mapText -notmatch 'needsDeathWaypoint' -or
    $mapText -notmatch 'ClearCorpseWaypoint' -or
    $mapText -match 'guideName\s*==\s*"41-43 Badlands"' -or
    $mapText -notmatch 'MAX_SPIRIT_HEALER_SPAWN_DISTANCE' -or
    $mapText -match 'px\s*-\s*n\.wy' -or
    $hbdText -notmatch 'GetWorldCoordinatesFromLegacyPosition') {
    Add-Error 'Outdoor-only Outland/Northrend deathskip routing is not wired.'
}
if ($healerText -notmatch '(?m)^\s*\[530\]\s*=\s*\{' -or
    $healerText -notmatch '(?m)^\s*\[571\]\s*=\s*\{') {
    Add-Error 'Spirit Healer data does not cover Outland and Northrend.'
}

$plannerText = [IO.File]::ReadAllText((Join-Path $root 'Features/ActivityPlanner.lua'))
if ($plannerText -match 'group:find\("Northrend Daily Quests"' -or
    $plannerText -notmatch 'element\.tag\s*==\s*"daily"' -or
    $plannerText -notmatch 'element\.tag\s*==\s*"dailyturnin"') {
    Add-Error 'Daily Planner still depends on a hard-coded guide group.'
}

$targetingText = [IO.File]::ReadAllText((Join-Path $root 'Features/Targeting.lua'))
$tipsText = [IO.File]::ReadAllText((Join-Path $root 'Features/Tips.lua'))
foreach ($setting in @('showTargetingOnProximity','showDangerousMobsMap',
                        'showDangerousUnitscan','showDangerousMobWarning')) {
    if ($settingsText -notmatch [regex]::Escape($setting)) {
        Add-Error "Missing targeting/danger setting: $setting"
    }
}
if ($targetingText -notmatch 'dangerousTargets' -or
    $targetingText -notmatch 'kind\s*==\s*"dangerous"' -or
    $tipsText -notmatch 'element\.dangerous\s*=\s*true' -or
    $tipsText -notmatch 'session\.lastDangerFlash') {
    Add-Error 'Dangerous-mob observations are not isolated and cooldown-bounded.'
}
if ($targetingText -notmatch 'nearby-target-macro' -or
    $targetingText -notmatch 'proxmityPolling\.scannedTargets\[t\]' -or
    $targetingText -notmatch
        'for\s+_,\s*t\s+in\s+ipairs\(observedTargets\)\s+do\s+tinsert\(executionTargets,\s*t\)') {
    Add-Error 'The 3.3.5 target macro does not prioritize observed nearby targets.'
}
$handlerText = [IO.File]::ReadAllText(
    (Join-Path $root 'Guide/Directives/Handlers.lua'))
if ($handlerText -notmatch 'element\.unitIds\[i\]\s*=\s*id' -or
    $handlerText -notmatch
        'element\.unitIds\s+and\s+element\.unitIds\[i\]\s+or\s+tonumber\(value\)' -or
    $handlerText -notmatch 'addon\.GetCreatureName\(name\)\s+or\s+name') {
    Add-Error 'Name::NPCID targets can degrade into numeric macro targets before cache resolution.'
}
if ($tipsText -notmatch
        'local\s+FlashClientIcon\s*=\s*_G\.FlashClientIcon' -or
    $tipsText -notmatch
        'if\s+FlashClientIcon\s+then\s+FlashClientIcon\(\)\s+end') {
    Add-Error 'Drowning warnings must guard the post-WotLK FlashClientIcon API.'
}

$talentManifest = [IO.File]::ReadAllText((Join-Path $root 'Talents_wotlk_335.xml'))
$talentText = [IO.File]::ReadAllText((Join-Path $root 'Features/Talents.lua'))
if ($talentManifest -notmatch 'wotlk-hunter-pets\.lua' -or
    $talentText -notmatch 'GetCurrentPetTree' -or
    $talentText -notmatch 'ProcessPetTalents') {
    Add-Error 'Hunter pet talent plans are not loaded through the locale-safe pet path.'
}

$recorderText = [IO.File]::ReadAllText((Join-Path $root 'Features/GuideRecorder.lua'))
foreach ($api in @('BuildSuggestion','PromoteEvent','AddSelected',
                    'AddAllReviewed','IgnoreSelected')) {
    if ($recorderText -notmatch ('function\s+recorder:' + $api + '\s*\(')) {
        Add-Error "Guide Recorder review API is missing: $api"
    }
}

$upgradeText = [IO.File]::ReadAllText((Join-Path $root 'Features/ItemUpgrades.lua'))
foreach ($pattern in @('ParseItemUniqueness','ValidateUniqueLayout',
                        'BeginOperation','ArmResponseTimeout',
                        'AUCTION_ITEM_LIST_UPDATE')) {
    if ($upgradeText -notmatch [regex]::Escape($pattern)) {
        Add-Error "ItemUpgrades/Auction House hardening is missing: $pattern"
    }
}
if ($upgradeText -notmatch
        'session\.trainedArmor\[itemSubTypeID\]\s*==\s*true\s+then\s+return\s+true' -or
    $upgradeText -notmatch
        'local\s+function\s+GetClientArmorWearability\s*\(' -or
    $upgradeText -notmatch
        'HasEquippedArmorSubclass\(subclassID\)' -or
    $upgradeText -notmatch
        'function\s+addon\.itemUpgrades:UPGRADE_EQUIPMENT_CHANGED\s*\(\)[\s\S]{0,500}RefreshWeaponProficiencies\(\)' -or
    $upgradeText -notmatch
        'GetClientArmorWearability\(itemLink,\s*clientUsable\)\s*==\s*true' -or
    $upgradeText -notmatch
        'local\s+requiresVerifiedProficiency\s*=\s*IsWeaponSlot\(itemEquipLoc\)' -or
    $upgradeText -notmatch
        'ARMOR_PROFICIENCY_SPELL\[itemSubTypeID\]\s*~=\s*nil' -or
    $upgradeText -match
        'fall back to the stock class map instead of the\s*\r?\n\s*-- reward UI hint') {
    Add-Error (
        '3.3.5 armor recommendations must require learned, equipped, or ' +
        'per-item client-confirmed proficiency after class/level eligibility.')
}
if ($upgradeText -notmatch
        'if\s+trained\s*==\s*true\s+then[\s\S]*?elseif\s+trained\s*==\s*false\s+then[\s\S]*?return\s+false[\s\S]*?else[\s\S]*?return\s+nil' -or
    $upgradeText -match 'local\s+function\s+IsClientItemUsable' -or
    $upgradeText -match
        'session\.equippableWeapons\[itemSubTypeID\][\s\S]{0,160}IsClientItemUsable') {
    Add-Error (
        '3.3.5 weapon recommendations must require a positively learned ' +
        'skill instead of trusting class eligibility or IsUsableItem hints.')
}

$forbidden = @(
    '\bTargetUnit\s*\(', '\bloadstring\s*\(', '\bdofile\s*\(',
    '\bdebug\s*\.', '\bReadProcessMemory\b', '\bOpenProcess\b',
    '\bCreateRemoteThread\b'
)
foreach ($module in $modules) {
    $path = Join-Path $root $module
    if (-not [IO.File]::Exists($path)) { continue }
    $text = [IO.File]::ReadAllText($path)
    foreach ($pattern in $forbidden) {
        if ($text -match $pattern) { Add-Error "$module contains forbidden runtime pattern $pattern" }
    }
    $personalPatterns = @(
        '(?i)(?<![A-Za-z0-9])[A-Z]:\\(?:[^\\\r\n]+\\)+',
        '(?i)/(?:Users|home)/[^/]+',
        '(?i)\.claude[/\\]projects'
    )
    foreach ($personal in $personalPatterns) {
        if ($text -match $personal) { Add-Error "$module contains a personal filesystem path." }
    }
}

if ($errors.Count -gt 0) {
    foreach ($message in $errors) { Write-Host "ERROR: $message" -ForegroundColor Red }
    throw "Roadmap validation failed with $($errors.Count) error(s)."
}
Write-Host "Roadmap validation passed: $($modules.Count) staged modules and all command/privacy guards." -ForegroundColor Green
