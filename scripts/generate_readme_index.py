#!/usr/bin/env python3
"""Generate and verify the chapter question index in README.md."""

from __future__ import annotations

import argparse
import re
import sys
import unicodedata
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
README = ROOT / "README.md"
CHAPTER_DIR = ROOT / "docs" / "chapters"
START = "<!-- BEGIN GENERATED QUESTION INDEX -->"
END = "<!-- END GENERATED QUESTION INDEX -->"
EXPECTED_CHAPTERS = 21
EXPECTED_QUESTIONS = 1380


def github_slug(text: str) -> str:
    """Mirror GitHub's heading slug: remove punctuation/symbols, hyphenate spaces."""
    text = text.strip().lower()
    kept = []
    for char in text:
        category = unicodedata.category(char)
        if category.startswith(("P", "S")) and char not in "_-":
            continue
        kept.append(char)
    return re.sub(r"\s+", "-", "".join(kept)).strip("-")


def escaped_label(text: str) -> str:
    return text.replace("\\", "\\\\").replace("[", "\\[").replace("]", "\\]")


def chapter_data(path: Path):
    lines = path.read_text(encoding="utf-8").splitlines()
    # GitHub assigns slugs to all headings, so section headings must count when
    # resolving duplicate question titles too.
    used = Counter()
    headings = []
    for line in lines:
        match = re.match(r"^(#{1,6})\s+(.+?)\s*#*\s*$", line)
        if match:
            base = github_slug(match.group(2))
            suffix = used[base]
            used[base] += 1
            headings.append((len(match.group(1)), match.group(2), base + (f"-{suffix}" if suffix else "")))

    questions = []
    for level, title, anchor in headings:
        # In these source chapters, H3 section labels follow N.N Title, while
        # each non-numbered H3 is one real Q (titles need not end in ?).
        if level == 3 and not re.match(r"^\d+\.\d+\s", title):
            questions.append((title, anchor))
    return questions


def generated_block():
    files = sorted(CHAPTER_DIR.glob("ch[0-9][0-9].md"))
    if len(files) != EXPECTED_CHAPTERS:
        raise ValueError(f"expected {EXPECTED_CHAPTERS} chapter files, found {len(files)}")
    rows = []
    total = 0
    sections = 0
    counts = []
    for path in files:
        num = int(path.stem[2:])
        questions = chapter_data(path)
        source_lines = path.read_text(encoding="utf-8").splitlines()
        sections += sum(bool(re.match(r"^### \d+\.\d+\s", line)) for line in source_lines)
        counts.append((num, len(questions)))
        total += len(questions)
        rows.append(f"### 第 {num} 章（{len(questions)} 个问题）\n")
        for title, anchor in questions:
            rows.append(f"- [{escaped_label(title)}](docs/chapters/{path.name}#{anchor})")
        rows.append("")
    if total != EXPECTED_QUESTIONS:
        raise ValueError(f"expected {EXPECTED_QUESTIONS} real Q headings, found {total}; chapter counts: {counts}")
    return "\n".join(rows).rstrip(), counts, total, sections


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="verify README index is current without writing")
    args = parser.parse_args()
    block, counts, total, sections = generated_block()
    readme = README.read_text(encoding="utf-8")
    if readme.count(START) != 1 or readme.count(END) != 1:
        raise ValueError("README must contain exactly one pair of generated-index markers")
    pattern = re.compile(re.escape(START) + r".*?" + re.escape(END), re.S)
    replacement = START + "\n" + block + "\n" + END
    current = pattern.sub(replacement, readme)
    if args.check:
        if current != readme:
            print("README question index is stale; run python3 scripts/generate_readme_index.py", file=sys.stderr)
            return 1
        print(f"PASS: {len(counts)} chapters, {total} Q headings; generated index matches README")
    else:
        README.write_text(current, encoding="utf-8")
        print(f"Generated README index: {len(counts)} chapters, {total} Q headings")
    print("Chapter counts: " + ", ".join(f"{n:02d}={count}" for n, count in counts))
    print(f"Section headings excluded: {sections} (numbered N.N headings, not Q entries)")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(2)
