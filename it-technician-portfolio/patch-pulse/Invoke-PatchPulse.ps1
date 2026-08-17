[CmdletBinding()]
param(
    [string]$OutputFile = ".\patch-report.csv"
)

$os = Get-CimInstance Win32_OperatingSystem
$systemDrive = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$($os.SystemDrive)'"
$defender = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
$latestHotfix = Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 1
$uptimeDays = [math]::Floor(((Get-Date) - $os.LastBootUpTime).TotalDays)
$freeGb = [math]::Round($systemDrive.FreeSpace / 1GB, 2)
$hotfixAge = if ($latestHotfix.InstalledOn) { ((Get-Date) - $latestHotfix.InstalledOn).Days } else { 9999 }

$findings = @()
if (-not $defender -or $defender.Status -ne "Running") { $findings += "Defender service not running" }
if ($hotfixAge -gt 90) { $findings += "Latest detected hotfix is older than 90 days" }
if ($freeGb -lt 15) { $findings += "System drive has less than 15 GB free" }
if ($uptimeDays -gt 30) { $findings += "Device uptime exceeds 30 days" }

$risk = if ($findings -match "Defender|90 days") { "High" } elseif ($findings.Count) { "Medium" } else { "Low" }

[pscustomobject]@{
    ComputerName = $env:COMPUTERNAME
    AuditDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    OS = $os.Caption
    OSBuild = $os.BuildNumber
    LatestHotfix = $latestHotfix.HotFixID
    LatestHotfixDate = $latestHotfix.InstalledOn
    UptimeDays = $uptimeDays
    SystemDriveFreeGB = $freeGb
    DefenderStatus = if ($defender) { $defender.Status } else { "Not detected" }
    Risk = $risk
    Findings = $findings -join "; "
} | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

Write-Output "Patch audit created: $OutputFile"
