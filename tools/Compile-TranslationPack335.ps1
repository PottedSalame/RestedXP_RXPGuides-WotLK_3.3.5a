[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceCatalog,
    [Parameter(Mandatory = $true)]
    [string[]]$TranslationCatalog,
    [string]$AddonRoot,
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
if (-not $AddonRoot) { $AddonRoot = Split-Path -Parent $PSScriptRoot }
function Join-AddonPath([string]$Relative) {
    $native = $Relative -replace '[\\/]', [IO.Path]::DirectorySeparatorChar
    return Join-Path $AddonRoot $native
}
$utf8Strict = New-Object Text.UTF8Encoding($false, $true)
$utf8 = New-Object Text.UTF8Encoding($false)

function Read-Json([string]$Path) {
    try {
        return [IO.File]::ReadAllText([IO.Path]::GetFullPath($Path),
            $utf8Strict) | ConvertFrom-Json
    } catch {
        throw "Invalid UTF-8/JSON translation catalog '$Path': $($_.Exception.Message)"
    }
}

function Get-PackInputSignature([string]$SourcePath, [string[]]$CatalogPaths) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        # Diagnostic contexts may be omitted from the cached inventory when
        # no contextual translations exist. The revision is derived from the
        # authoritative English units, so equivalent compact/full inventories
        # intentionally produce the same pack signature.
        $sourceDocument = [IO.File]::ReadAllText(
            [IO.Path]::GetFullPath($SourcePath)) | ConvertFrom-Json
        $sourceBytes = [Text.Encoding]::UTF8.GetBytes(
            'sourceRevision:' + [string]$sourceDocument.sourceRevision)
        $separator = [byte[]](0)
        [void]$sha.TransformBlock($sourceBytes, 0, $sourceBytes.Length,
            $sourceBytes, 0)
        [void]$sha.TransformBlock($separator, 0, 1, $separator, 0)
        $paths = @($CatalogPaths | ForEach-Object {
                [IO.Path]::GetFullPath($_)
            } | Sort-Object) + @([IO.Path]::GetFullPath($PSCommandPath))
        foreach ($path in $paths) {
            $bytes = [IO.File]::ReadAllBytes($path)
            if ($bytes.Length -gt 0) {
                [void]$sha.TransformBlock($bytes, 0, $bytes.Length, $bytes, 0)
            }
            [void]$sha.TransformBlock($separator, 0, 1, $separator, 0)
        }
        [void]$sha.TransformFinalBlock([byte[]]@(), 0, 0)
        return -join ($sha.Hash | ForEach-Object { $_.ToString('x2') })
    } finally { $sha.Dispose() }
}

function Get-SourceSignature([string]$Value) {
    [uint64]$hash = 5381
    foreach ($byte in $utf8.GetBytes([string]$Value)) {
        $hash = (($hash * 33) + $byte) % 4294967296
    }
    return '{0:x8}' -f [uint32]$hash
}

function Escape-Lua([string]$Value) {
    return $Value.Replace('\','\\').Replace('"','\"').Replace("`r",'\r').Replace("`n",'\n')
}

function Encode-ForPrint([byte[]]$Bytes) {
    $alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789()'
    $builder = New-Object Text.StringBuilder
    $index = 0
    while ($index + 2 -lt $Bytes.Length) {
        [uint32]$cache = $Bytes[$index] + ($Bytes[$index + 1] * 256) +
            ($Bytes[$index + 2] * 65536)
        for ($part = 0; $part -lt 4; $part++) {
            [void]$builder.Append($alphabet[[int]($cache % 64)])
            $cache = [math]::Floor($cache / 64)
        }
        $index += 3
    }
    [uint32]$tail = 0
    $bits = 0
    while ($index -lt $Bytes.Length) {
        $tail += $Bytes[$index] * [math]::Pow(2, $bits)
        $bits += 8
        $index++
    }
    while ($bits -gt 0) {
        [void]$builder.Append($alphabet[[int]($tail % 64)])
        $tail = [math]::Floor($tail / 64)
        $bits -= 6
    }
    return $builder.ToString()
}

$source = Read-Json $SourceCatalog
$translationDocuments = @($TranslationCatalog | Sort-Object | ForEach-Object {
    Read-Json $_
})
$inputSignature = Get-PackInputSignature $SourceCatalog $TranslationCatalog
if ([int]$source.schema -ne 1 -or $translationDocuments.Count -lt 1) {
    throw 'Unsupported translation catalog schema.'
}
$locale = [string]$translationDocuments[0].locale
if ($locale -notin @('deDE','esES','frFR','koKR','ruRU','zhCN','zhTW')) {
    throw "Unsupported translation locale '$locale'."
}
foreach ($translated in $translationDocuments) {
    if ([int]$translated.schema -ne 1) {
        throw 'Unsupported translation catalog schema.'
    }
    if ([string]$translated.locale -ne $locale) {
        throw 'All compiled translation catalogs must target one locale.'
    }
    if ([string]$translated.sourceRevision -ne [string]$source.sourceRevision) {
        throw 'Translation catalog was generated for a different English source revision.'
    }
}
if (-not $OutputPath) {
    $OutputPath = Join-AddonPath "locale/GuidePack.$locale.lua"
}

$byId = @{}
$byEnglish = @{}
foreach ($unit in $source.units) {
    $byId[[string]$unit.id] = $unit
    $byEnglish[[string]$unit.english] = $unit
}

$fieldSeparator = [char]31
$recordSeparator = [char]30
$records = New-Object Collections.Generic.List[string]
$packSource = (@($translationDocuments | ForEach-Object {
    if ($_.source) { [string]$_.source }
} | Select-Object -Unique) -join '; ')
if (-not $packSource) { $packSource = 'RXPGuides offline translation catalog' }
$revision = (@($translationDocuments | ForEach-Object {
    if ($_.revision) { [string]$_.revision }
} | Select-Object -Unique) -join '+')
if (-not $revision) { $revision = [string]$source.sourceRevision }
$records.Add(('H{0}1{0}{1}{0}{2}{0}{0}{0}' -f $fieldSeparator,
    $revision, $packSource))
$mergedTranslations = @{}
foreach ($document in $translationDocuments) {
    foreach ($translation in @($document.units)) {
        $domain = if ($translation.domain) {
            [string]$translation.domain
        } else { 'both' }
        if ($domain -notin @('guide','ui','both')) {
            throw "Invalid translation domain '$domain'."
        }
        $identity = if ($translation.contextKey) {
            'C' + $fieldSeparator + $domain + $fieldSeparator +
                [string]$translation.contextKey
        } elseif ($translation.id) {
            'I' + $fieldSeparator + $domain + $fieldSeparator +
                [string]$translation.id
        } else {
            'E' + $fieldSeparator + $domain + $fieldSeparator +
                [string]$translation.english
        }
        $existing = $mergedTranslations[$identity]
        if (-not $existing) {
            $mergedTranslations[$identity] = $translation
        } elseif ([string]$existing.translation -ne [string]$translation.translation) {
            if ($existing.status -eq 'reviewed' -and $translation.status -eq 'machine') {
                continue
            } elseif ($translation.status -eq 'reviewed' -and $existing.status -eq 'machine') {
                $mergedTranslations[$identity] = $translation
            } else {
                throw "Conflicting translation unit '$identity'."
            }
        }
    }
}
$seen = @{}
$translationList = New-Object 'System.Collections.Generic.List[object]'
foreach ($translation in $mergedTranslations.Values) {
    $translationList.Add($translation)
}
$translationList.Sort([Comparison[object]]{
    param($left, $right)
    $comparison = [StringComparer]::Ordinal.Compare(
        [string]$left.english, [string]$right.english)
    if ($comparison -ne 0) { return $comparison }
    $comparison = [StringComparer]::Ordinal.Compare(
        [string]$left.id, [string]$right.id)
    if ($comparison -ne 0) { return $comparison }
    return [StringComparer]::Ordinal.Compare(
        [string]$left.contextKey, [string]$right.contextKey)
})
foreach ($translation in $translationList) {
    $sourceUnit = $null
    if ($translation.id) { $sourceUnit = $byId[[string]$translation.id] }
    if (-not $sourceUnit -and $translation.english) {
        $sourceUnit = $byEnglish[[string]$translation.english]
    }
    if (-not $sourceUnit) { throw "Unknown translation unit '$($translation.id)'." }
    $english = [string]$sourceUnit.english
    if ($translation.english -and [string]$translation.english -ne $english) {
        throw "Stale English source for translation unit '$($sourceUnit.id)'."
    }
    $message = [string]$translation.translation
    if ([string]::IsNullOrWhiteSpace($message)) {
        throw "Empty translation for '$english'."
    }
    if ($message.IndexOf($fieldSeparator) -ge 0 -or
        $message.IndexOf($recordSeparator) -ge 0 -or
        $english.IndexOf($fieldSeparator) -ge 0 -or
        $english.IndexOf($recordSeparator) -ge 0) {
        throw "Translation contains a reserved control separator: '$english'."
    }
    if ($message -match '(^|\n)\s*\.[a-z]+\s' -or
        $message -match '(^|\n)\s*#(?:name|group|next|title)\s' -or
        $message -match 'RXPGuides\.RegisterGuide|<<') {
        throw "Operational guide syntax leaked into translation: '$english'."
    }
    $isTokenized = $translation.tokenized -ne $false
    if ($isTokenized) {
        if ($message -match '%(?:[0-9]+\$)?[-+0-9.]*[sdif](?![\p{L}])') {
            throw "Tokenized translation contains a positional placeholder: '$english'."
        }
        $expectedTokens = @($sourceUnit.tokens | Sort-Object)
        $actualTokens = @([regex]::Matches($message, '\{([a-z_]+)\}') |
            ForEach-Object { $_.Groups[1].Value } | Sort-Object)
        if (($expectedTokens -join $fieldSeparator) -ne
            ($actualTokens -join $fieldSeparator)) {
            throw "Named-token signature changed for '$english'."
        }
    } else {
        foreach ($pattern in @('\|cRXP_[A-Z]+_','\|r','\|T','\|t','\|H','\|h',
                '%[0-9.\-+]*[sdif]',
                '-?\d+(?:\.\d+)?')) {
            $left = @([regex]::Matches($english, $pattern) |
                ForEach-Object { $_.Value } | Sort-Object) -join $fieldSeparator
            $right = @([regex]::Matches($message, $pattern) |
                ForEach-Object { $_.Value } | Sort-Object) -join $fieldSeparator
            if ($left -ne $right) {
                throw "Markup/numeric signature changed for '$english'."
            }
        }
    }
    $status = [string]$translation.status
    if ($status -notin @('reviewed','machine')) {
        throw "Translation '$english' must be reviewed or machine."
    }
    $contextKey = [string]$translation.contextKey
    $signature = Get-SourceSignature $english
    if ($contextKey) {
        $contextParts = @($contextKey.Split([char]$fieldSeparator))
        if ($contextParts.Count -ne 4 -or
            $contextParts[3] -ne $signature) {
            throw "Malformed contextual key for '$english'."
        }
        $knownContext = $false
        foreach ($context in @($sourceUnit.contexts)) {
            $stepId = if ($context.stableStepId -ne $null) {
                [string]$context.stableStepId
            } else { 'guide' }
            if ([string]$context.guideKey -eq $contextParts[0] -and
                $stepId -eq $contextParts[1]) {
                $knownContext = $true
                break
            }
        }
        if (-not $knownContext) {
            throw "Dangling contextual translation for '$english'."
        }
    }
    $statusCode = if ($status -eq 'reviewed') { 'R' } else { 'M' }
    $domain = if ($translation.domain) { [string]$translation.domain } else { 'both' }
    $recordKinds = if ($contextKey) { @('C') }
        elseif ($domain -eq 'guide') { @('G') }
        elseif ($domain -eq 'ui') { @('U') }
        elseif ($sourceUnit.kind -eq 'shared') { @('G','U') }
        elseif ($sourceUnit.kind -eq 'ui') { @('U') } else { @('G') }
    foreach ($kind in $recordKinds) {
        $key = if ($contextKey) { $contextKey } else { $english }
        $dedupeKey = "$kind$fieldSeparator$key"
        $record = ($kind, $statusCode, $key,
            $(if ($kind -eq 'C') { $english } else { '' }),
            $message, $signature, $(if ($isTokenized) { '1' } else { '0' })) -join
            $fieldSeparator
        if ($seen.ContainsKey($dedupeKey)) {
            $previous = $seen[$dedupeKey]
            if ($previous.message -eq $message) { continue }
            if ($previous.status -eq 'reviewed' -and $status -eq 'machine') {
                continue
            }
            if ($status -eq 'reviewed' -and $previous.status -eq 'machine') {
                $records[$previous.index] = $record
                $seen[$dedupeKey] = [pscustomobject]@{
                    index = $previous.index
                    status = $status
                    message = $message
                }
                continue
            }
            throw "Conflicting translation key '$key'."
        }
        $seen[$dedupeKey] = [pscustomobject]@{
            index = $records.Count
            status = $status
            message = $message
        }
        $records.Add($record)
    }
}

$payload = ($records -join $recordSeparator) + $recordSeparator
$payloadBytes = $utf8.GetBytes($payload)
$memory = New-Object IO.MemoryStream
$compressor = New-Object IO.Compression.DeflateStream($memory,
    [IO.Compression.CompressionLevel]::Optimal, $true)
$compressor.Write($payloadBytes, 0, $payloadBytes.Length)
$compressor.Dispose()
$compressed = $memory.ToArray()
$memory.Dispose()
$encoded = Encode-ForPrint $compressed

$builder = New-Object Text.StringBuilder
[void]$builder.AppendLine('local _, addon = ...')
[void]$builder.AppendLine(('if GetLocale() ~= "{0}" or not addon.guideLocalization then return end' -f $locale))
[void]$builder.AppendLine('')
[void]$builder.AppendLine(('-- Generated from catalog revision {0}. Display data only; do not edit.' -f $revision))
[void]$builder.AppendLine(('-- Translation input signature: {0}' -f $inputSignature))
[void]$builder.AppendLine('local payload = table.concat({')
for ($index = 0; $index -lt $encoded.Length; $index += 120) {
    $length = [math]::Min(120, $encoded.Length - $index)
    [void]$builder.AppendLine(('    "{0}",' -f
        (Escape-Lua $encoded.Substring($index, $length))))
}
[void]$builder.AppendLine('})')
[void]$builder.AppendLine(('addon.guideLocalization:RegisterCompressedPack("{0}", payload)' -f $locale))
$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}
[IO.File]::WriteAllText($OutputPath, $builder.ToString(), $utf8)
Write-Host ("Compiled {0} {1} translations: {2:N0} -> {3:N0} bytes." -f `
    $mergedTranslations.Count, $locale, $payloadBytes.Length, $compressed.Length)
