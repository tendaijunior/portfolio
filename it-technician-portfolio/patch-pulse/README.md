# PatchPulse

PatchPulse performs a read-only Windows endpoint health audit and exports a CSV suitable for a small-business patch review. It highlights stale updates, disabled security services, low disk space, and devices that have not restarted recently.

## Hiring signal

- Endpoint maintenance
- Security fundamentals
- Risk-based reporting
- PowerShell automation
- Audit-friendly output

## Usage

```powershell
.\Invoke-PatchPulse.ps1 -OutputFile .\patch-report.csv
```

The script does not install updates or change services. It records observations and assigns a transparent risk rating.

## Risk rules

- High: Microsoft Defender disabled or no successful hotfix in 90 days
- Medium: less than 15 GB free on the system drive or uptime exceeds 30 days
- Low: no detected risk rule

Production use would require centralized collection, approved remote-management controls, and tested exception handling.
