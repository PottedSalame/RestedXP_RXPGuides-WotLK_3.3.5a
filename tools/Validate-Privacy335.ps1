$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$safeRoot = $root.Replace('\', '/')
$extensions = @('.lua','.md','.ps1','.yml','.yaml','.xml','.toc','.txt','.json')
$patterns = @(
    '(?i)(?<![A-Za-z0-9])[A-Z]:\\(?:[^\\\r\n]+\\)+',
    '(?i)/(?:Users|home)/[^/]+',
    '(?i)\.claude[/\\]projects'
)

$tracked = @(& git -c "safe.directory=$safeRoot" -C $root ls-files)
if ($LASTEXITCODE -ne 0) { throw 'Unable to enumerate tracked release files.' }
$untracked = @(& git -c "safe.directory=$safeRoot" -C $root ls-files --others --exclude-standard)
if ($LASTEXITCODE -ne 0) { throw 'Unable to enumerate untracked candidate files.' }
$files = @($tracked + $untracked) | Sort-Object -Unique

$hits = foreach ($file in $files) {
    $path = Join-Path $root $file
    if (($extensions -contains [IO.Path]::GetExtension($file).ToLowerInvariant()) -and
        [IO.File]::Exists($path)) {
        Select-String -LiteralPath $path -Pattern $patterns -ErrorAction SilentlyContinue
    }
}

if ($hits) {
    foreach ($hit in $hits) {
        Write-Host "ERROR: $($hit.Path):$($hit.LineNumber) contains a personal path." -ForegroundColor Red
    }
    throw "Privacy validation failed with $($hits.Count) match(es)."
}

Write-Host "Privacy validation passed: $($files.Count) tracked and candidate files checked." -ForegroundColor Green
