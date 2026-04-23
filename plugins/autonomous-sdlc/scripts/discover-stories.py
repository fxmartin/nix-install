#!/usr/bin/env python3
# ABOUTME: Deterministic story discovery for the autonomous-sdlc Codex plugin
# ABOUTME: Parses story files, resolves dependencies, and emits a machine-readable build queue

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass, field
from pathlib import Path


ROOT = Path.cwd()
STORY_HEADER_RE = re.compile(r"^#{3,6}\s+(?:Story\s+)?(\d+\.\d+-\d+):?\s*(.+?)\s*$", re.MULTILINE)
CHECKBOX_RE = re.compile(r"^\s*-\s+\[( |x|X)\]")


@dataclass
class Story:
    id: str
    title: str
    epic_id: str
    epic_name: str
    epic_file: str
    priority: str = "Should Have"
    points: int = 3
    agent_type: str = "senior-code-reviewer"
    dependencies: list[str] = field(default_factory=list)
    is_complete: bool = False
    warnings: list[str] = field(default_factory=list)

    @property
    def priority_weight(self) -> int:
        return {"Must Have": 3, "Should Have": 2, "Could Have": 1, "Won't Have": 0}.get(
            self.priority, 2
        )

    def queue_record(self) -> dict:
        return {
            "id": self.id,
            "title": self.title,
            "epic_id": self.epic_id,
            "epic_name": self.epic_name,
            "epic_file": self.epic_file,
            "priority": self.priority,
            "points": self.points,
            "agent_type": self.agent_type,
            "dependencies": self.dependencies,
        }


def story_files() -> list[Path]:
    candidates: list[Path] = []
    for pattern in (
        "docs/stories/epic-*.md",
        "stories/epic-*.md",
        "stories/features/epic-*.md",
        "**/non-functional-requirements.md",
    ):
        candidates.extend(ROOT.glob(pattern))
    return sorted({p for p in candidates if p.is_file() and ".git" not in p.parts})


def extract_field(section: str, names: tuple[str, ...]) -> str | None:
    joined = "|".join(re.escape(name) for name in names)
    match = re.search(rf"(?im)^\s*(?:\*\*)?(?:{joined})(?:\*\*)?\s*:\s*(.+?)\s*$", section)
    return match.group(1).strip() if match else None


def normalize_priority(value: str | None) -> str:
    if not value:
        return "Should Have"
    cleaned = value.strip().strip("*")
    for option in ("Must Have", "Should Have", "Could Have", "Won't Have"):
        if cleaned.lower().startswith(option.lower()):
            return option
    return "Should Have"


def parse_points(value: str | None) -> int:
    if not value:
        return 3
    match = re.search(r"\d+", value)
    return int(match.group(0)) if match else 3


def parse_dependencies(value: str | None) -> list[str]:
    if not value or value.lower().startswith("none"):
        return []
    return re.findall(r"\d+\.\d+-\d+", value)


def detect_agent(title: str, body: str) -> str:
    text = f"{title}\n{body}".lower()
    checks = [
        (("api", "endpoint", "backend", "server", "database", "migration"), "python-backend-engineer"),
        (("ui", "frontend", "component", "page", "responsive", "form"), "ui-engineer"),
        (("container", "docker", "podman", "deploy", "image"), "podman-container-architect"),
        (("script", "automation", "ci", "pipeline", "workflow", "shell", "bash", "nix"), "bash-zsh-macos-engineer"),
        (("test", "coverage", "quality", "qa", "validation"), "qa-engineer"),
        (("review", "architecture", "security", "refactor"), "senior-code-reviewer"),
    ]
    for keywords, agent in checks:
        if any(keyword in text for keyword in keywords):
            return agent
    return "senior-code-reviewer"


def dod_complete(section: str) -> tuple[bool, int, int]:
    dod_match = re.search(
        r"(?im)^\s*#{1,6}.*(?:definition of done|dod).*?$|^\s*\*\*(?:definition of done|dod)\*\*.*?$",
        section,
    )
    search_area = section[dod_match.start() :] if dod_match else section
    checked = 0
    unchecked = 0
    for line in search_area.splitlines():
        match = CHECKBOX_RE.match(line)
        if not match:
            continue
        if match.group(1).lower() == "x":
            checked += 1
        else:
            unchecked += 1
    return unchecked == 0 and checked > 0, checked, checked + unchecked


def validate_story(section: str, story: Story, dod_total: int) -> None:
    if not re.search(r"(?im)^\s*#{1,6}.*acceptance criteria|^\s*\*\*acceptance criteria\*\*", section):
        story.warnings.append("Missing acceptance criteria")
    if dod_total == 0:
        story.warnings.append("Missing DoD checkboxes")
    nonblank = [line for line in section.splitlines() if line.strip()]
    if len(nonblank) < 5:
        story.warnings.append("Thin story content")


def parse_file(path: Path) -> list[Story]:
    text = path.read_text(encoding="utf-8", errors="replace")
    matches = list(STORY_HEADER_RE.finditer(text))
    stories: list[Story] = []
    epic_id_match = re.search(r"epic-(\d+)", str(path), re.IGNORECASE)
    fallback_epic_id = epic_id_match.group(1) if epic_id_match else "NFR"
    epic_name = path.stem.replace("-", " ").title()

    for index, match in enumerate(matches):
        start = match.start()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        section = text[start:end]
        story_id = match.group(1)
        title = match.group(2).strip()
        epic_id = story_id.split(".", 1)[0] if "." in story_id else fallback_epic_id
        priority = normalize_priority(extract_field(section, ("Priority",)))
        points = parse_points(extract_field(section, ("Story Points", "Points")))
        deps = parse_dependencies(extract_field(section, ("Dependencies",)))
        complete, _checked, dod_total = dod_complete(section)
        story = Story(
            id=story_id,
            title=title,
            epic_id=epic_id,
            epic_name=epic_name,
            epic_file=str(path.relative_to(ROOT)),
            priority=priority,
            points=points,
            agent_type=detect_agent(title, section),
            dependencies=deps,
            is_complete=complete,
        )
        validate_story(section, story, dod_total)
        stories.append(story)
    return stories


def in_scope(story: Story, scope: str) -> bool:
    if scope in {"all", "resume"}:
        return True
    normalized = scope.lower()
    if normalized.startswith("epic-"):
        requested = normalized.removeprefix("epic-").zfill(2)
        return story.epic_id.zfill(2) == requested
    return normalized in story.epic_name.lower() or normalized in story.epic_file.lower()


def topo_sort(stories: list[Story]) -> tuple[list[Story], list[str]]:
    by_id = {story.id: story for story in stories}
    remaining = set(by_id)
    sorted_stories: list[Story] = []
    cycles: list[str] = []

    while remaining:
        ready = [
            by_id[story_id]
            for story_id in remaining
            if all(dep not in by_id or dep not in remaining for dep in by_id[story_id].dependencies)
        ]
        if not ready:
            cycles = sorted(remaining)
            break
        ready.sort(
            key=lambda s: (
                -s.priority_weight,
                int(s.epic_id) if s.epic_id.isdigit() else 999,
                s.points,
                s.id,
            )
        )
        chosen = ready[0]
        sorted_stories.append(chosen)
        remaining.remove(chosen.id)
    return sorted_stories, cycles


def render_table(queue: list[Story]) -> None:
    print("## Build Queue")
    print()
    print("| # | Story ID | Title | Priority | Points | Agent | Dependencies |")
    print("|---|----------|-------|----------|--------|-------|--------------|")
    for index, story in enumerate(queue, start=1):
        deps = ", ".join(story.dependencies) if story.dependencies else "None"
        print(
            f"| {index} | {story.id} | {story.title} | {story.priority} | "
            f"{story.points} | {story.agent_type} | {deps} |"
        )


def main() -> int:
    parser = argparse.ArgumentParser(description="Discover incomplete stories and emit a build queue.")
    parser.add_argument("scope", nargs="?", default="all")
    parser.add_argument("--limit", type=int)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    all_stories = [story for path in story_files() for story in parse_file(path)]
    scoped = [story for story in all_stories if in_scope(story, args.scope)]
    incomplete = [story for story in scoped if not story.is_complete]
    queue, cycles = topo_sort(incomplete)
    if args.limit is not None:
        queue = queue[: args.limit]

    if cycles:
        print(f"DISCOVERY_ERROR: Circular dependency detected among stories: {', '.join(cycles)}")
        return 1

    render_table(queue)
    completed = [story for story in scoped if story.is_complete]
    if completed:
        print()
        print("### Already Complete")
        for story in completed:
            print(f"- {story.id}: {story.title}")

    warnings = [(story.id, warning) for story in scoped for warning in story.warnings]
    if warnings:
        print()
        print("### Validation Warnings")
        print()
        print("| Story ID | Warning |")
        print("|----------|---------|")
        for story_id, warning in warnings:
            print(f"| {story_id} | {warning} |")

    payload = [story.queue_record() for story in queue]
    print()
    print(f"QUEUE_JSON:{json.dumps(payload, separators=(',', ':'))}")
    print(f"QUEUE_TOTAL: {len(queue)} stories, {sum(story.points for story in queue)} story points")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
