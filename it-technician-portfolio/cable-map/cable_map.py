from __future__ import annotations

import csv
import html
import sys
from pathlib import Path

FIELDS = ["site", "room", "wall_port", "patch_panel", "switch", "switch_port", "vlan", "device", "status", "last_verified"]


def is_valid(row: dict[str, str]) -> bool:
    return all(row.get(field, "").strip() for field in FIELDS) and row["vlan"].isdigit()


def build(source: Path, destination: Path) -> None:
    with source.open(newline="", encoding="utf-8-sig") as stream:
        reader = csv.DictReader(stream)
        missing = set(FIELDS) - set(reader.fieldnames or [])
        if missing:
            raise ValueError(f"Missing CSV fields: {', '.join(sorted(missing))}")
        rows = list(reader)

    table_rows = []
    for row in sorted(rows, key=lambda item: (item["site"], item["room"], item["wall_port"])):
        cells = "".join(f"<td>{html.escape(row.get(field, ''))}</td>" for field in FIELDS)
        table_rows.append(f'<tr class="{"ok" if is_valid(row) else "invalid"}">{cells}</tr>')

    headers = "".join(f"<th>{field.replace('_', ' ').title()}</th>" for field in FIELDS)
    document = f'''<!doctype html><html lang="en"><head><meta charset="utf-8"><title>CableMap</title>
<style>body{{font:14px Arial;margin:32px;color:#172017}}table{{border-collapse:collapse;width:100%}}th,td{{border:1px solid #ccd2ca;padding:8px;text-align:left}}th{{background:#1d2a20;color:white}}tr:nth-child(even){{background:#f3f5f1}}tr.invalid{{background:#ffe7df}}</style>
</head><body><h1>CableMap Network Register</h1><p>{len(rows)} documented ports. Red rows require review.</p><table><thead><tr>{headers}</tr></thead><tbody>{''.join(table_rows)}</tbody></table></body></html>'''
    destination.write_text(document, encoding="utf-8")
    print(f"Created {destination}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit("Usage: python cable_map.py input.csv output.html")
    build(Path(sys.argv[1]), Path(sys.argv[2]))
