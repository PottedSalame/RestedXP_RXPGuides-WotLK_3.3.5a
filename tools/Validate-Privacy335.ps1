$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$safeRoot = $root.Replace('\', '/')
$extensions = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
foreach ($extension in @('.lua','.md','.ps1','.yml','.yaml','.xml','.toc','.txt','.json')) {
    [void]$extensions.Add($extension)
}
$patterns = @(
    '(?i)(?<![A-Za-z0-9])[A-Z]:\\(?:[^\\\r\n]+\\)+',
    '(?i)/(?:Users|home)/[^/]+',
    '(?i)\.claude[/\\]projects'
)
$personalPathRegex = New-Object Text.RegularExpressions.Regex(
    (($patterns | ForEach-Object { "(?:$_)" }) -join '|'),
    ([Text.RegularExpressions.RegexOptions]::Compiled -bor
        [Text.RegularExpressions.RegexOptions]::CultureInvariant))

$tracked = @(& git -c "safe.directory=$safeRoot" -C $root ls-files)
if ($LASTEXITCODE -ne 0) { throw 'Unable to enumerate tracked release files.' }
$untracked = @(& git -c "safe.directory=$safeRoot" -C $root ls-files --others --exclude-standard)
if ($LASTEXITCODE -ne 0) { throw 'Unable to enumerate untracked candidate files.' }
$files = @($tracked + $untracked) | Sort-Object -Unique

$hits = New-Object 'Collections.Generic.List[object]'
foreach ($file in $files) {
    $path = Join-Path $root $file
    if (-not $extensions.Contains([IO.Path]::GetExtension($file)) -or
        -not [IO.File]::Exists($path)) { continue }
    $text = [IO.File]::ReadAllText($path)
    foreach ($match in $personalPathRegex.Matches($text)) {
        # Line numbers are only calculated for failures; the successful path
        # stays a single buffered read and one compiled-regex scan per file.
        $lineNumber = 1
        for ($index = 0; $index -lt $match.Index; $index++) {
            if ($text[$index] -eq "`n") { $lineNumber++ }
        }
        $hits.Add([pscustomobject]@{ Path = $path; LineNumber = $lineNumber })
    }
}

if ($hits) {
    foreach ($hit in $hits) {
        Write-Host "ERROR: $($hit.Path):$($hit.LineNumber) contains a personal path." -ForegroundColor Red
    }
    throw "Privacy validation failed with $($hits.Count) match(es)."
}

Write-Host "Privacy validation passed: $($files.Count) tracked and candidate files checked." -ForegroundColor Green
