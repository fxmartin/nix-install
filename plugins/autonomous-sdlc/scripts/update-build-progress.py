#!/usr/bin/env python3
# ABOUTME: Updates markdown build progress files for the autonomous-sdlc Codex plugin
# ABOUTME: Main-agent-only helper; worker agents must not call this script

from __future__ import annotations

import argparse
from datetime import datetime, timezone
from pathlib import Path


HEADER = "| Order | Story ID | Title | Status | PR | Branch | Started | Completed |"
SEPARATOR = "|-------|----------|-------|--------|----|--------|---------|-----------|"


def now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def progress_path(value: str | None) -> Path:
    if value:
        return Path(value)
    docs = Path("docs/stories")
    if docs.exists():
        return docs / ".build-progress.md"
    return Path("stories") / ".build-progress.md"


def parse_rows(text: str) -> list[list[str]]:
    rows: list[list[str]] = []
    for line in text.splitlines():
        if not line.startswith("|") or "Story ID" in line or line.startswith("|---") or line.startswith("|-------"):
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) == 8:
            rows.append(cells)
    return rows


def parse_metadata(text: str) -> tuple[str | None, str | None]:
    scope = None
    mode = None
    for line in text.splitlines():
        if line.startswith("**Scope**:"):
            scope = line.split(":", 1)[1].strip()
        elif line.startswith("**Mode**:"):
            mode = line.split(":", 1)[1].strip()
    return scope, mode


def render(path: Path, scope: str, mode: str, rows: list[list[str]]) -> None:
    counts: dict[str, int] = {}
    for row in rows:
        counts[row[3]] = counts.get(row[3], 0) + 1
    lines = [
        "# Build Progress",
        "",
        f"**Last Updated**: {now()}",
        f"**Scope**: {scope}",
        f"**Mode**: {mode}",
        "",
        "## Queue",
        "",
        HEADER,
        SEPARATOR,
    ]
    lines.extend("| " + " | ".join(row) + " |" for row in rows)
    lines.extend(["", "## Summary", ""])
    for status in ("DONE", "IN_PROGRESS", "FAILED", "SKIPPED", "BLOCKED", "PENDING"):
        lines.append(f"- **{status.title().replace('_', ' ')}**: {counts.get(status, 0)}")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Update a build progress markdown file.")
    parser.add_argument("command", choices=("init", "set"))
    parser.add_argument("--file")
    parser.add_argument("--scope", default="all")
    parser.add_argument("--mode", default="sequential")
    parser.add_argument("--story-id")
    parser.add_argument("--title", default="")
    parser.add_argument("--status", default="PENDING")
    parser.add_argument("--order", default="")
    parser.add_argument("--pr", default="-")
    parser.add_argument("--branch", default="-")
    args = parser.parse_args()

    path = progress_path(args.file)
    existing_text = path.read_text(encoding="utf-8") if path.exists() else ""
    rows = parse_rows(existing_text) if existing_text else []
    existing_scope, existing_mode = parse_metadata(existing_text) if existing_text else (None, None)

    if args.command == "init":
        render(path, args.scope, args.mode, rows)
        return 0

    if not args.story_id:
        parser.error("--story-id is required for set")

    started = now() if args.status == "IN_PROGRESS" else "-"
    completed = now() if args.status in {"DONE", "FAILED", "SKIPPED", "BLOCKED"} else "-"
    branch = args.branch if args.branch != "-" else (f"feature/{args.story_id}" if args.status == "IN_PROGRESS" else "-")
    updated = False
    for row in rows:
        if row[1] == args.story_id:
            row[3] = args.status
            row[4] = args.pr
            row[5] = branch
            if row[6] == "-":
                row[6] = started
            row[7] = completed if completed != "-" else row[7]
            updated = True
            break
    if not updated:
        order = args.order or str(len(rows) + 1)
        rows.append([order, args.story_id, args.title or args.story_id, args.status, args.pr, branch, started, completed])

    render(path, existing_scope or args.scope, existing_mode or args.mode, rows)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
