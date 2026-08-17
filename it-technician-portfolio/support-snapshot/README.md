# Support Snapshot

Creates a concise diagnostic report before a technician escalates or changes a Windows endpoint. It captures OS details, storage pressure, network configuration, service state, basic connectivity, and recent critical events.

## Demonstrates

- Structured troubleshooting
- Windows administration
- Evidence-based escalation
- Privacy-aware documentation

## Usage

```powershell
.\Get-SupportSnapshot.ps1 -OutputPath .\output
```

Review reports before sharing because hostnames, usernames, and IP addresses may be sensitive. The script is read-only apart from writing its report.

## Scenario

A workstation is slow and intermittently loses cloud access. The snapshot lets a technician compare storage, network, DNS, security-service, and event-log evidence in one handover artifact.
