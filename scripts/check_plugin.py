#!/usr/bin/env python3
"""Check that every skill and command in this plugin can actually be found,
and that no forbidden text is anywhere in the repo.

A skill whose frontmatter `name` disagrees with its directory, or which has no
description for the model to match against, installs cleanly and then never
triggers. This catches that before a release.

Usage:
  python3 scripts/check_plugin.py
  python3 scripts/check_plugin.py --forbid "term one,term two"
  TWO_TIMING_FORBID="term one,term two" python3 scripts/check_plugin.py

--forbid is a privacy grep: a case-insensitive scan of every tracked text file
for terms that must never ship (a legal name, an email, an internal URL). The
terms are supplied at run time on purpose, so they never live in the repo.
ERROR blocks; WARNING does not.
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DIR_NAMED = {"skills"}
SKIP_DIRS = {".git", "__pycache__", "node_modules"}
TEXT_SUFFIXES = {".md", ".json", ".sh", ".py", ".txt", ".toml", ".yaml", ".yml", ""}


def parse_frontmatter(path: Path) -> tuple[dict[str, str], str | None]:
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0].strip() != "---":
        return {}, "missing opening --- frontmatter delimiter"
    fields: dict[str, str] = {}
    for line in lines[1:]:
        if line.strip() == "---":
            return fields, None
        if not line.strip() or line.startswith((" ", "\t", "#")):
            continue
        key, separator, value = line.partition(":")
        if separator:
            fields[key.strip()] = value.strip().strip("'\"")
    return fields, "missing closing --- frontmatter delimiter"


def check_components(kind: str, errors: list[str], warnings: list[str], names: dict[str, list[str]]) -> int:
    directory = ROOT / kind
    if not directory.is_dir():
        return 0
    paths = sorted(directory.glob("*/SKILL.md")) if kind in DIR_NAMED else sorted(directory.glob("*.md"))
    if not paths:
        errors.append(f"{kind}/ exists but contains no components")
        return 0
    for path in paths:
        relative = path.relative_to(ROOT)
        fields, error = parse_frontmatter(path)
        if error:
            errors.append(f"{relative}: {error}")
            continue
        if not fields.get("description"):
            errors.append(f"{relative}: no non-empty 'description'; the model has nothing to match on")
        expected = path.parent.name if kind in DIR_NAMED else path.stem
        name = fields.get("name")
        if not name:
            if kind in DIR_NAMED:
                warnings.append(f"{relative}: no 'name'; loads as {expected!r} by directory-name fallback")
            name = expected
        elif name != expected:
            errors.append(f"{relative}: frontmatter name {name!r} does not match {expected!r}")
        names.setdefault(name, []).append(str(relative))
        body = path.read_text(encoding="utf-8")
        if kind == "commands" and "$ARGUMENTS" not in body and "$1" not in body:
            warnings.append(f"{relative}: command never uses $ARGUMENTS; arguments typed after it are dropped")
    return len(paths)


def check_manifests(errors: list[str]) -> None:
    for relative in (".claude-plugin/plugin.json", ".claude-plugin/marketplace.json"):
        path = ROOT / relative
        if not path.is_file():
            errors.append(f"{relative}: missing")
            continue
        try:
            payload = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            errors.append(f"{relative}: invalid JSON: {exc.msg} at line {exc.lineno}")
            continue
        if not payload.get("name"):
            errors.append(f"{relative}: missing 'name'")
        if relative.endswith("marketplace.json"):
            plugins = payload.get("plugins")
            if not isinstance(plugins, list) or not plugins:
                errors.append(f"{relative}: 'plugins' must be a non-empty array")
                continue
            for index, entry in enumerate(plugins):
                source = entry.get("source")
                if not source:
                    errors.append(f"{relative}: plugins[{index}] is missing 'source'")
                elif not (ROOT / source).exists():
                    errors.append(f"{relative}: plugins[{index}] source {source!r} does not exist")


def check_scripts(errors: list[str]) -> None:
    for path in sorted((ROOT / "scripts").glob("*.sh")):
        if not os.access(path, os.X_OK):
            errors.append(f"{path.relative_to(ROOT)}: not executable (chmod +x)")


def check_forbidden(terms: list[str], errors: list[str]) -> None:
    terms = [t.strip() for t in terms if t.strip()]
    if not terms:
        return
    lowered = [t.lower() for t in terms]
    for path in ROOT.rglob("*"):
        if any(part in SKIP_DIRS for part in path.parts) or not path.is_file():
            continue
        if path.suffix.lower() not in TEXT_SUFFIXES:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for number, line in enumerate(text.splitlines(), 1):
            low = line.lower()
            for term in lowered:
                if term in low:
                    errors.append(f"{path.relative_to(ROOT)}:{number}: contains forbidden term #{lowered.index(term) + 1}")


def main(argv: list[str]) -> int:
    forbid = os.environ.get("TWO_TIMING_FORBID", "")
    if "--forbid" in argv:
        forbid = argv[argv.index("--forbid") + 1]
    errors: list[str] = []
    warnings: list[str] = []
    names: dict[str, list[str]] = {}
    counts = {kind: check_components(kind, errors, warnings, names) for kind in ("skills", "agents", "commands")}
    check_manifests(errors)
    check_scripts(errors)
    check_forbidden(forbid.split(","), errors)
    for name, locations in sorted(names.items()):
        if len(locations) > 1:
            errors.append(f"duplicate component name {name!r} in: {', '.join(locations)}")
    for warning in warnings:
        print(f"WARNING: {warning}")
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    summary = ", ".join(f"{count} {kind}" for kind, count in counts.items() if count)
    if errors:
        print(f"\n{len(errors)} error(s), {len(warnings)} warning(s).", file=sys.stderr)
        return 1
    print(f"\nComponents reachable: {summary}. {len(warnings)} warning(s). Forbidden-term scan: {'ran' if forbid.strip() else 'skipped (no terms given)'}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
