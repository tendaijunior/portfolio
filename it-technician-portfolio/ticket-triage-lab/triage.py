from __future__ import annotations

import json
import sys
from pathlib import Path

IMPACT = {"individual": 1, "meeting": 2, "operations": 5, "payroll": 6, "revenue": 6}


def score(ticket: dict) -> tuple[int, list[str]]:
    total = int(ticket.get("urgency", 1)) * 2
    impact = IMPACT.get(str(ticket.get("business_impact", "individual")).lower(), 1)
    total += impact
    reasons = [f"business impact +{impact}"]
    users = int(ticket.get("affected_users", 1))
    user_weight = 4 if users >= 25 else 2 if users >= 5 else 1
    total += user_weight
    reasons.append(f"affected users +{user_weight}")
    if ticket.get("security_indicator"):
        total += 10
        reasons.append("security escalation +10")
    return total, reasons


def priority(value: int) -> str:
    return "P1" if value >= 18 else "P2" if value >= 13 else "P3" if value >= 8 else "P4"


def main(path: Path) -> None:
    tickets = json.loads(path.read_text(encoding="utf-8"))
    ranked = [(score(ticket), ticket) for ticket in tickets]
    for (value, reasons), ticket in sorted(ranked, key=lambda item: item[0][0], reverse=True):
        print(f"{priority(value)} | {ticket['id']} | score {value} | {ticket['summary']}")
        print(f"     {'; '.join(reasons)}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python triage.py sample-tickets.json")
    main(Path(sys.argv[1]))
