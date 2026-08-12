[CmdletBinding()]
param(
    [string]$RepoRoot,
    [switch]$RequireLua
)

$ErrorActionPreference = 'Stop'
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent $PSScriptRoot }
function Join-RepoPath([string]$Relative) {
    $native = $Relative -replace '[\\/]', [IO.Path]::DirectorySeparatorChar
    return Join-Path $RepoRoot $native
}
$temporaryRoot = Join-Path ([IO.Path]::GetTempPath()) `
    ('rxp-translations-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temporaryRoot | Out-Null
try {
    $source = Join-Path $temporaryRoot 'source.json'
    & (Join-Path $PSScriptRoot 'Export-TranslationUnits335.ps1') `
        -AddonRoot $RepoRoot -OutputPath $source
    $maps = @(Get-ChildItem (Join-RepoPath 'translations/source') `
        -Filter '*.json' -File -ErrorAction SilentlyContinue | Sort-Object Name)
    foreach ($map in $maps) {
        $mapDocument = Get-Content -LiteralPath $map.FullName -Raw |
            ConvertFrom-Json
        if (-not $mapDocument.locale) { continue }
        if ($mapDocument.sourceType -eq 'fallbackAllowlist') { continue }
        $outputName = if ($mapDocument.output) {
            [string]$mapDocument.output
        } else { $map.Name }
        $generatedCatalog = Join-Path $temporaryRoot $outputName
        if ($mapDocument.sourceType -eq 'aceLocale') {
            & (Join-Path $PSScriptRoot 'Import-AceLocaleTranslations335.ps1') `
                -SourceCatalog $source -Locale ([string]$mapDocument.locale) `
                -RepoRoot $RepoRoot -OutputPath $generatedCatalog
        } elseif ($mapDocument.rules) {
            $existing = @($mapDocument.existingCatalogs | ForEach-Object {
                Join-RepoPath "translations/imported/$_"
            })
            & (Join-Path $PSScriptRoot 'New-GlossaryMachineCatalog335.ps1') `
                -SourceCatalog $source -Rules $map.FullName `
                -ExistingCatalog $existing -OutputPath $generatedCatalog
        } elseif ($mapDocument.units) {
            & (Join-Path $PSScriptRoot 'Import-TranslationMap335.ps1') `
                -SourceCatalog $source -TranslationMap $map.FullName `
                -OutputPath $generatedCatalog
        } else { continue }
        $committedCatalog = Join-RepoPath `
            ("translations/imported/" + $outputName)
        if (-not (Test-Path -LiteralPath $committedCatalog -PathType Leaf) -or
            [Convert]::ToBase64String([IO.File]::ReadAllBytes($generatedCatalog)) -ne
            [Convert]::ToBase64String([IO.File]::ReadAllBytes($committedCatalog))) {
            throw "Imported translation catalog is stale: translations/imported/$outputName"
        }
    }
    $catalogs = @(Get-ChildItem (Join-RepoPath 'translations/imported') `
        -Filter '*.json' -File -ErrorAction SilentlyContinue | Sort-Object Name)
    $groups = @($catalogs | Group-Object {
        [string](Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json).locale
    })
    foreach ($group in $groups) {
        $locale = [string]$group.Name
        $generated = Join-Path $temporaryRoot "GuidePack.$locale.lua"
        & (Join-Path $PSScriptRoot 'Compile-TranslationPack335.ps1') `
            -AddonRoot $RepoRoot -SourceCatalog $source `
            -TranslationCatalog @($group.Group.FullName) -OutputPath $generated
        $committed = Join-RepoPath "locale/GuidePack.$locale.lua"
        if (-not (Test-Path -LiteralPath $committed -PathType Leaf)) {
            throw "Missing compiled runtime pack for $locale."
        }
        $left = [IO.File]::ReadAllBytes($generated)
        $right = [IO.File]::ReadAllBytes($committed)
        if ($left.Length -ne $right.Length -or
            [Convert]::ToBase64String($left) -ne
            [Convert]::ToBase64String($right)) {
            throw "Compiled runtime pack is stale: locale/GuidePack.$locale.lua"
        }
        if ($RequireLua) {
            $lua = Get-Command lua5.1 -ErrorAction SilentlyContinue
            if (-not $lua) { $lua = Get-Command lua -ErrorAction SilentlyContinue }
            if (-not $lua) { throw 'Lua 5.1 is required but was not found.' }
            $generatedText = [IO.File]::ReadAllText($generated)
            $payloadBlock = [regex]::Match($generatedText,
                '(?s)local payload = table\.concat\(\{(.*?)\}\)')
            if (-not $payloadBlock.Success) {
                throw "Could not read generated payload for $locale."
            }
            $encoded = (@([regex]::Matches($payloadBlock.Groups[1].Value,
                '"([A-Za-z0-9()]+)"') | ForEach-Object {
                    $_.Groups[1].Value
                }) -join '')
            $smokePath = Join-Path $temporaryRoot "smoke-$locale.lua"
            $libStub = (Join-RepoPath 'libs/LibStub/LibStub.lua').Replace('\','/')
            $libDeflate = (Join-RepoPath 'libs/LibDeflate/LibDeflate.lua').Replace('\','/')
            $smoke = @"
dofile([[$libStub]])
dofile([[$libDeflate]])
local encoded = [=[$encoded]=]
local lib = LibStub("LibDeflate")
local compressed = assert(lib:DecodeForPrint(encoded))
local payload = assert(lib:DecompressDeflate(compressed))
assert(payload:sub(1, 2) == "H" .. string.char(31))
assert(payload:find(string.char(30), 1, true))
"@
            [IO.File]::WriteAllText($smokePath, $smoke,
                (New-Object Text.UTF8Encoding($false)))
            & $lua.Source $smokePath
            if ($LASTEXITCODE -ne 0) {
                throw "LibDeflate could not decode the generated $locale pack."
            }
        }
        if ($locale -eq 'zhCN') {
            $generatedAllowlist = Join-Path $temporaryRoot `
                "$locale-fallback-allowlist.json"
            $coverageText = (& (Join-Path $PSScriptRoot `
                    'Get-TranslationCoverage335.ps1') `
                -SourceCatalog $source `
                -TranslationCatalog @($group.Group.FullName) `
                -RepoRoot $RepoRoot -Locale $locale `
                -FallbackAllowlistPath $generatedAllowlist | Out-String)
            $coverage = $coverageText | ConvertFrom-Json
            if ([int]$coverage.summary.ui.fallback -ne 0) {
                throw 'zhCN ordinary UI coverage contains unclassified fallbacks.'
            }
            $guideOccurrences = [double]$coverage.summary.guide.occurrences.total
            $resolvedOccurrences = $guideOccurrences -
                [double]$coverage.summary.guide.occurrences.fallback
            if ($guideOccurrences -le 0 -or
                $resolvedOccurrences / $guideOccurrences -lt 0.90) {
                throw 'zhCN guide catalog coverage fell below the accepted rollout floor.'
            }
            $committedAllowlist = Join-RepoPath `
                "translations/source/$locale-fallback-allowlist.json"
            if (-not (Test-Path -LiteralPath $committedAllowlist -PathType Leaf)) {
                throw "Missing documented $locale fallback allowlist."
            }
            $generatedText = [IO.File]::ReadAllText($generatedAllowlist).
                Replace("`r`n", "`n").TrimEnd("`r", "`n")
            $committedText = [IO.File]::ReadAllText($committedAllowlist).
                Replace("`r`n", "`n").TrimEnd("`r", "`n")
            if ($generatedText -cne $committedText) {
                throw "The documented $locale fallback allowlist is stale."
            }
        }
    }
    Write-Host ("Translation packs passed deterministic validation: {0} catalog(s)." -f `
        $catalogs.Count)
} finally {
    if (Test-Path -LiteralPath $temporaryRoot) {
        Remove-Item -LiteralPath $temporaryRoot -Recurse -Force
    }
}
