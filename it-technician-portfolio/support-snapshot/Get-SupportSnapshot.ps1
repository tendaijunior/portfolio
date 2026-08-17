[CmdletBinding()]
param([string]$OutputPath = ".\output")

$ErrorActionPreference = "SilentlyContinue"
New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
$reportPath = Join-Path $OutputPath "support-snapshot-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
$os = Get-CimInstance Win32_OperatingSystem
$computer = Get-CimInstance Win32_ComputerSystem
$disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
$adapters = @(Get-NetIPConfiguration | Where-Object { $_.IPv4Address })
$events = Get-WinEvent -FilterHashtable @{ LogName="System"; Level=1,2; StartTime=(Get-Date).AddHours(-24) } -MaxEvents 10

$lines = @(
    "SUPPORT SNAPSHOT", "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')", "",
    "SYSTEM", "Computer: $($computer.Name)", "Model: $($computer.Manufacturer) $($computer.Model)",
    "OS: $($os.Caption) $($os.Version)", "Last boot: $($os.LastBootUpTime)",
    "Memory GB: $([math]::Round($computer.TotalPhysicalMemory / 1GB, 2))", "", "STORAGE"
)
$lines += $disks | ForEach-Object { "Drive $($_.DeviceID): $([math]::Round($_.FreeSpace/1GB,2)) GB free of $([math]::Round($_.Size/1GB,2)) GB" }
$lines += "", "NETWORK"
$lines += $adapters | ForEach-Object { "$($_.InterfaceAlias): IPv4 $($_.IPv4Address.IPAddress); Gateway $($_.IPv4DefaultGateway.NextHop); DNS $($_.DNSServer.ServerAddresses -join ', ')" }
$lines += "", "CONNECTIVITY"
if ($adapters.Count) { $lines += "Gateway reachable: $(Test-Connection $adapters[0].IPv4DefaultGateway.NextHop -Count 1 -Quiet)" }
$lines += "DNS resolution: $([bool](Resolve-DnsName example.com))"
$lines += "HTTPS reachable: $(Test-NetConnection example.com -Port 443 -InformationLevel Quiet)"
$lines += "", "KEY SERVICES"
$lines += "wuauserv", "WinDefend", "Dnscache" | ForEach-Object { $service=Get-Service $_; "${_}: $($service.Status)" }
$lines += "", "RECENT CRITICAL OR ERROR EVENTS"
$lines += $events | ForEach-Object { "$($_.TimeCreated) | Event $($_.Id) | $($_.ProviderName) | $($_.Message -replace '\s+',' ')" }
$lines | Set-Content $reportPath -Encoding UTF8
Write-Output "Snapshot created: $reportPath"
