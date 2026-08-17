[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$BackupPath,
    [string]$ManifestPath = ".\manifest.json",
    [switch]$CreateBaseline
)

if (-not (Test-Path -LiteralPath $BackupPath -PathType Container)) { throw "Backup path does not exist: $BackupPath" }
$root = (Resolve-Path $BackupPath).Path
$current = @(Get-ChildItem -LiteralPath $root -File -Recurse | ForEach-Object {
    [pscustomobject]@{
        RelativePath = $_.FullName.Substring($root.Length).TrimStart('\')
        SizeBytes = $_.Length
        LastWriteTime = $_.LastWriteTimeUtc
        Sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    }
})

if ($CreateBaseline) {
    [pscustomobject]@{ CreatedUtc=(Get-Date).ToUniversalTime(); Source=$root; FileCount=$current.Count; Files=$current } |
        ConvertTo-Json -Depth 5 | Set-Content $ManifestPath -Encoding UTF8
    Write-Output "Baseline created: $ManifestPath"
    return
}

if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Manifest not found: $ManifestPath" }
$baseline = Get-Content $ManifestPath -Raw | ConvertFrom-Json
$baselineMap=@{}; $baseline.Files | ForEach-Object { $baselineMap[$_.RelativePath]=$_ }
$currentMap=@{}; $current | ForEach-Object { $currentMap[$_.RelativePath]=$_ }
$missing=@($baseline.Files | Where-Object { -not $currentMap.ContainsKey($_.RelativePath) })
$changed=@($current | Where-Object { $baselineMap.ContainsKey($_.RelativePath) -and $baselineMap[$_.RelativePath].Sha256 -ne $_.Sha256 })
$new=@($current | Where-Object { -not $baselineMap.ContainsKey($_.RelativePath) })
[pscustomobject]@{
    Status=if($missing.Count -or $changed.Count){"Attention required"}else{"Verified"}
    CheckedUtc=(Get-Date).ToUniversalTime(); CurrentFileCount=$current.Count
    MissingFiles=@($missing.RelativePath); ChangedFiles=@($changed.RelativePath); NewFiles=@($new.RelativePath)
} | ConvertTo-Json -Depth 4
