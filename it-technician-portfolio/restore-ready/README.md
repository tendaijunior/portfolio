# RestoreReady

Verifies whether a backup set is present, readable, and unchanged since its baseline manifest was created. It addresses a common failure: a backup job appears successful, but nobody validates its contents.

## Demonstrates

- Backup and recovery fundamentals
- SHA-256 integrity verification
- Safe change control
- JSON reporting

## Usage

```powershell
.\Test-RestoreReady.ps1 -BackupPath C:\LabBackup -ManifestPath .\manifest.json -CreateBaseline
.\Test-RestoreReady.ps1 -BackupPath C:\LabBackup -ManifestPath .\manifest.json
```

The tool reads files and writes a manifest; it does not modify the backup. Hash checks are not a complete restore test. A mature process must also restore representative files into isolation and open them with their applications.
