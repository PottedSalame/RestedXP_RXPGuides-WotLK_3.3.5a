[CmdletBinding()]
param(
    [string]$RepoRoot,
    [string]$SourceCatalog,
    [switch]$RequireLua
)

$ErrorActionPreference = 'Stop'
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent $PSScriptRoot }
function Join-RepoPath([string]$Relative) {
    $native = $Relative -replace '[\\/]', [IO.Path]::DirectorySeparatorChar
    return Join-Path $RepoRoot $native
}
function Get-CanonicalJson([string]$Path) {
    $document = [IO.File]::ReadAllText($Path) | ConvertFrom-Json
    if ($document.units) {
        $unitList = New-Object 'System.Collections.Generic.List[object]'
        foreach ($unit in $document.units) { $unitList.Add($unit) }
        $unitList.Sort([Comparison[object]]{
            param($left, $right)
            foreach ($property in @('id','domain','status','english',
                                      'translation','contextKey')) {
                $comparison = [StringComparer]::Ordinal.Compare(
                    [string]$left.$property, [string]$right.$property)
                if ($comparison -ne 0) { return $comparison }
            }
            return 0
        })
        $document.units = @($unitList.ToArray())
    }
    return $document | ConvertTo-Json -Depth 20 -Compress
}
function Decode-ForPrint([string]$Encoded) {
    $alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789()'
    $values = @{}
    for ($index = 0; $index -lt $alphabet.Length; $index++) {
        $values[$alphabet[$index]] = $index
    }
    $bytes = New-Object Collections.Generic.List[byte]
    [uint64]$cache = 0
    $bits = 0
    foreach ($character in $Encoded.ToCharArray()) {
        if (-not $values.ContainsKey($character)) {
            throw "Invalid LibDeflate print character '$character'."
        }
        $cache += [uint64]$values[$character] *
            [uint64][math]::Pow(2, $bits)
        $bits += 6
        while ($bits -ge 8) {
            $bytes.Add([byte]($cache % 256))
            $cache = [uint64][math]::Floor($cache / 256)
            $bits -= 8
        }
    }
    return ,$bytes.ToArray()
}
function Get-CanonicalPackPayload([string]$Path) {
    $text = [IO.File]::ReadAllText($Path)
    $payloadBlock = [regex]::Match($text,
        '(?s)local payload = table\.concat\(\{(.*?)\}\)')
    if (-not $payloadBlock.Success) {
        throw "Could not read compiled translation payload: $Path"
    }
    $encoded = (@([regex]::Matches($payloadBlock.Groups[1].Value,
        '"([A-Za-z0-9()]+)"') | ForEach-Object {
            $_.Groups[1].Value
        }) -join '')
    $compressed = Decode-ForPrint $encoded
    $input = New-Object IO.MemoryStream(,([byte[]]$compressed))
    $inflater = New-Object IO.Compression.DeflateStream($input,
        [IO.Compression.CompressionMode]::Decompress)
    $output = New-Object IO.MemoryStream
    try {
        $inflater.CopyTo($output)
        $utf8Strict = New-Object Text.UTF8Encoding($false, $true)
        $payload = $utf8Strict.GetString($output.ToArray())
        $recordSeparator, $fieldSeparator = [char]30, [char]31
        $records = @($payload.Split(
            [char[]]@($recordSeparator),
            [StringSplitOptions]::RemoveEmptyEntries))
        if ($records.Count -lt 1) { throw "Empty translation pack: $Path" }
        $header = @($records[0].Split([char[]]@($fieldSeparator)))
        if ($header.Count -ne 7 -or $header[0] -ne 'H' -or $header[1] -ne '1') {
            throw "Invalid translation pack header: $Path"
        }
        foreach ($index in @(2, 3)) {
            $separator = if ($index -eq 2) { '+' } else { '; ' }
            $parts = New-Object 'System.Collections.Generic.List[string]'
            foreach ($part in @($header[$index].Split(
                    [string[]]@($separator),
                    [StringSplitOptions]::RemoveEmptyEntries))) {
                $parts.Add($part)
            }
            $parts.Sort([StringComparer]::Ordinal)
            $header[$index] = $parts -join $separator
        }
        $data = New-Object 'System.Collections.Generic.List[string]'
        for ($index = 1; $index -lt $records.Count; $index++) {
            $fields = @($records[$index].Split([char[]]@($fieldSeparator)))
            if ($fields.Count -ne 7 -or $fields[0] -notin @('G','C','U')) {
                throw "Invalid translation pack record $index in $Path"
            }
            $data.Add($records[$index])
        }
        $data.Sort([StringComparer]::Ordinal)
        return (@($header -join $fieldSeparator) + @($data)) -join $recordSeparator
    } finally {
        $inflater.Dispose()
        $input.Dispose()
        $output.Dispose()
    }
}
$temporaryRoot = Join-Path ([IO.Path]::GetTempPath()) `
    ('rxp-translations-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temporaryRoot | Out-Null
try {
    $source = if ($SourceCatalog) {
        [IO.Path]::GetFullPath((Join-Path $RepoRoot $SourceCatalog))
    } else { Join-Path $temporaryRoot 'source.json' }
    $importedRoot = Join-RepoPath 'translations/imported'
    $contextMatches = @(Get-ChildItem $importedRoot -Filter '*.json' -File `
        -ErrorAction SilentlyContinue | Select-String `
        -Pattern '"contextKey"\s*:' -Quiet)
    $hasContextual = $contextMatches -contains $true
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        $sourceParent = Split-Path -Parent $source
        if ($sourceParent -and -not (Test-Path -LiteralPath $sourceParent)) {
            New-Item -ItemType Directory -Path $sourceParent -Force | Out-Null
        }
        $exportArguments = @{AddonRoot = $RepoRoot; OutputPath = $source}
        if (-not $hasContextual) { $exportArguments.OmitContexts = $true }
        & (Join-Path $PSScriptRoot 'Export-TranslationUnits335.ps1') @exportArguments
    } else {
        Write-Host "Using cached translation inventory: $source"
    }
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
            (Get-CanonicalJson $generatedCatalog) -cne
            (Get-CanonicalJson $committedCatalog)) {
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
        if ((Get-CanonicalPackPayload $generated) -cne
            (Get-CanonicalPackPayload $committed)) {
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
            if ((Get-CanonicalJson $generatedAllowlist) -cne
                (Get-CanonicalJson $committedAllowlist)) {
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
