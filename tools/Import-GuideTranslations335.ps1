[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$UpstreamRoot,
    [string]$SourceVersion = 'unspecified',
    [string]$AddonRoot,
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
if (-not $AddonRoot) { $AddonRoot = Split-Path -Parent $PSScriptRoot }
if (-not $OutputPath) {
    $OutputPath = Join-Path $AddonRoot 'locale\GuideExact.zhCN.lua'
}
$englishRoot = Join-Path $UpstreamRoot 'Guides'
$translatedRoot = Join-Path $UpstreamRoot 'lang\Guides-zhCN'
if (-not (Test-Path -LiteralPath $englishRoot -PathType Container)) {
    throw "Missing upstream English guide directory: $englishRoot"
}
if (-not (Test-Path -LiteralPath $translatedRoot -PathType Container)) {
    throw "Missing upstream zhCN guide directory: $translatedRoot"
}

function Get-VisibleText([string]$line) {
    $match = [regex]::Match($line, '>>\s*(.+?)\s*$')
    if ($match.Success) { return $match.Groups[1].Value }
    $match = [regex]::Match($line, '^\s*[+*]\s*(.+?)\s*$')
    if ($match.Success) { return $match.Groups[1].Value }
    return $null
}

function Get-SortedMatches([string]$text, [string]$pattern) {
    return @([regex]::Matches($text, $pattern) | ForEach-Object { $_.Value } | Sort-Object)
}

function Test-SameSignature([string]$english, [string]$translated) {
    if ($translated -notmatch '[\u3400-\u9fff]') { return $false }
    if ($translated.TrimStart().StartsWith('.')) { return $false }
    if ($translated -match '<<|^#|RXPGuides\.RegisterGuide') { return $false }
    $checks = @(
        @('\|cRXP_[A-Z]+_', 'semantic colors'),
        @('\|T', 'texture opens'),
        @('\|t', 'texture closes'),
        @('\|H', 'hyperlink opens'),
        @('\|h', 'hyperlink fields'),
        @('\d+(?:\.\d+)?', 'numbers')
    )
    foreach ($check in $checks) {
        $left = @(Get-SortedMatches $english $check[0])
        $right = @(Get-SortedMatches $translated $check[0])
        if (($left -join [char]31) -ne ($right -join [char]31)) { return $false }
    }
    return $true
}

function Escape-Lua([string]$value) {
    return $value.Replace('\', '\\').Replace('"', '\"').Replace("`r", '\r').Replace("`n", '\n')
}

$currentVisible = @{}
$guideListPath = Join-Path $AddonRoot 'GuideList_335.xml'
$guideList = [IO.File]::ReadAllText($guideListPath, $utf8)
foreach ($match in [regex]::Matches($guideList, '<Script\s+file="([^"]+\.lua)"')) {
    $relative = $match.Groups[1].Value.Replace('\', [IO.Path]::DirectorySeparatorChar)
    $path = Join-Path $AddonRoot $relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { continue }
    foreach ($line in [IO.File]::ReadAllLines($path, $utf8)) {
        $visible = Get-VisibleText $line
        if ($visible) { $currentVisible[$visible] = $true }
    }
}

$candidates = @{}
$conflicts = @{}
foreach ($translatedFile in Get-ChildItem -LiteralPath $translatedRoot -Recurse -Filter '*.lua' -File) {
    $relative = $translatedFile.FullName.Substring($translatedRoot.Length).TrimStart('\', '/')
    $englishFile = Join-Path $englishRoot $relative
    if (-not (Test-Path -LiteralPath $englishFile -PathType Leaf)) { continue }
    $englishLines = [IO.File]::ReadAllLines($englishFile, $utf8)
    $translatedLines = [IO.File]::ReadAllLines($translatedFile.FullName, $utf8)
    if ($englishLines.Count -ne $translatedLines.Count) { continue }
    for ($index = 0; $index -lt $englishLines.Count; $index++) {
        $english = Get-VisibleText $englishLines[$index]
        $translated = Get-VisibleText $translatedLines[$index]
        if (-not $english -or -not $translated -or $english -eq $translated) { continue }
        if (-not $currentVisible.ContainsKey($english)) { continue }
        if (-not (Test-SameSignature $english $translated)) { continue }
        if ($candidates.ContainsKey($english) -and $candidates[$english] -ne $translated) {
            $conflicts[$english] = $true
        } else {
            $candidates[$english] = $translated
        }
    }
}
foreach ($english in $conflicts.Keys) { $candidates.Remove($english) }

$builder = New-Object Text.StringBuilder
[void]$builder.AppendLine('local _, addon = ...')
[void]$builder.AppendLine('if GetLocale() ~= "zhCN" or not addon.guideLocalization then return end')
[void]$builder.AppendLine('')
[void]$builder.AppendLine("-- Source: RestedXP upstream zhCN guide catalog ($SourceVersion snapshot).")
[void]$builder.AppendLine('-- Visible display text only; operational guide data is never imported.')
[void]$builder.AppendLine('-- Retain the upstream project''s attribution and licensing when redistributing.')
[void]$builder.AppendLine('local exact = {')
foreach ($english in @($candidates.Keys | Sort-Object)) {
    [void]$builder.AppendLine(('    ["{0}"] = "{1}",' -f (Escape-Lua $english), (Escape-Lua $candidates[$english])))
}
[void]$builder.AppendLine('}')
[void]$builder.AppendLine('addon.guideLocalization:RegisterExactCatalog("zhCN", exact,')
[void]$builder.AppendLine('    "RestedXP upstream zhCN visible guide text")')
[IO.File]::WriteAllText($OutputPath, $builder.ToString(), $utf8)
Write-Host ("Imported {0} reviewed zhCN display strings; rejected {1} conflicts." -f $candidates.Count, $conflicts.Count)
