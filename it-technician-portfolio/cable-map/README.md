# CableMap

Turns a technician-maintained CSV into a clean offline network-port register. Small environments often need reliable documentation more than another complex platform.

## Demonstrates

- Switch-port and patch-panel fundamentals
- Structured network documentation
- Change-control thinking
- Python, CSV, and HTML

## Usage

```powershell
python .\cable_map.py .\sample-ports.csv .\network-register.html
```

Invalid rows are highlighted for review. Only synthetic values are included; never publish a production network register publicly.
