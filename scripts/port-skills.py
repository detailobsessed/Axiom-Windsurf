#!/usr/bin/env python3
"""
Port upstream Axiom skills to Windsurf SKILL.md format.

Upstream skills in docs/skills/ already use compatible YAML frontmatter.
This script:
1. Finds all skill markdown files
2. Transforms VitePress-specific content
3. Outputs to skills/<skill-name>/SKILL.md

Usage:
    python scripts/port-skills.py --dry-run  # Preview what would be created
    python scripts/port-skills.py            # Actually create the files
"""

import argparse
import re
import shutil
from pathlib import Path


def find_upstream_skills(docs_dir: Path) -> list[Path]:
    """Find all skill markdown files in docs/skills/."""
    skills = []
    for md_file in docs_dir.rglob("*.md"):
        # Skip index files
        if md_file.name == "index.md":
            continue
        skills.append(md_file)
    return sorted(skills)


def extract_frontmatter(content: str) -> tuple[dict, str]:
    """Extract YAML frontmatter and body from markdown."""
    if not content.startswith("---"):
        return {}, content

    # Find the closing ---
    end_match = re.search(r"\n---\n", content[3:])
    if not end_match:
        return {}, content

    frontmatter_text = content[3 : 3 + end_match.start()]
    body = content[3 + end_match.end() :]

    # Parse simple YAML (name: value)
    frontmatter = {}
    for line in frontmatter_text.strip().split("\n"):
        if ":" in line:
            key, value = line.split(":", 1)
            frontmatter[key.strip()] = value.strip()

    return frontmatter, body


def fix_fenced_code_blocks(body: str) -> str:
    """Fix MD040: Add language specifier to fenced code blocks without one.

    Heuristics:
    - If contains 'swift' keywords -> swift
    - If contains shell commands -> bash
    - If looks like a URL or path -> text
    - Default to text
    """
    swift_indicators = [
        "struct ", "class ", "func ", "var ", "let ", "@", "import ",
        "enum ", "protocol ", "extension ", "case ", "guard ", "if let",
    ]
    bash_indicators = ["$", "cd ", "rm ", "cp ", "mkdir ", "git ", "brew ", "xcrun "]

    def detect_language(code: str) -> str:
        code_lower = code.lower()
        # Check for Swift
        for indicator in swift_indicators:
            if indicator in code:
                return "swift"
        # Check for bash/shell
        for indicator in bash_indicators:
            if indicator in code:
                return "bash"
        # URLs or paths
        if "https://" in code or "http://" in code or "~/" in code:
            return "text"
        return "text"

    def replace_code_block(match: re.Match) -> str:
        indent = match.group(1)
        code = match.group(2)
        lang = detect_language(code)
        return f"{indent}```{lang}\n{code}{indent}```"

    # Match fenced code blocks without language (``` followed by newline, not ```lang)
    # Handles both unindented and indented code blocks
    pattern = r"([ \t]*)```\n(.*?)(?=\1```)"
    body = re.sub(pattern, replace_code_block, body, flags=re.DOTALL)

    return body


def fix_duplicate_headings(body: str) -> str:
    """Fix MD024: Make duplicate headings unique by adding context."""
    lines = body.split("\n")
    heading_counts: dict[str, int] = {}
    result = []

    for line in lines:
        # Match markdown headings
        heading_match = re.match(r"^(#{1,6})\s+(.+)$", line)
        if heading_match:
            prefix = heading_match.group(1)
            text = heading_match.group(2)
            key = f"{prefix}:{text}"

            if key in heading_counts:
                heading_counts[key] += 1
                # Add occurrence number to make unique
                result.append(f"{prefix} {text} ({heading_counts[key]})")
            else:
                heading_counts[key] = 1
                result.append(line)
        else:
            result.append(line)

    return "\n".join(result)


def fix_emphasis_as_heading(body: str) -> str:
    """Fix MD036: Convert standalone bold text to proper headings.

    Also fixes MD026 (trailing punctuation) and MD001 (heading increment).
    """
    lines = body.split("\n")
    result = []
    last_heading_level = 0

    for i, line in enumerate(lines):
        stripped = line.strip()

        # Track heading levels for MD001 compliance
        heading_match = re.match(r"^(#{1,6})\s+", line)
        if heading_match:
            last_heading_level = len(heading_match.group(1))
            # Fix MD026: Remove trailing punctuation from headings
            if line.rstrip().endswith(":"):
                line = line.rstrip()[:-1]
            result.append(line)
            continue

        # Check if line is just bold text (standalone paragraph)
        if re.match(r"^\*\*[^*]+\*\*$", stripped):
            # Check if preceded and followed by blank lines (standalone)
            prev_blank = i == 0 or lines[i - 1].strip() == ""
            next_blank = i == len(lines) - 1 or lines[i + 1].strip() == ""

            if prev_blank and next_blank:
                text = stripped[2:-2]  # Remove ** from both ends
                # Remove trailing punctuation (MD026)
                if text.endswith(":"):
                    text = text[:-1]
                # Determine appropriate heading level (MD001: increment by 1)
                new_level = min(last_heading_level + 1, 6) if last_heading_level > 0 else 3
                result.append(f"{'#' * new_level} {text}")
                last_heading_level = new_level
                continue

        result.append(line)

    return "\n".join(result)


def transform_body(body: str) -> str:
    """Transform VitePress-specific content for Windsurf compatibility."""
    # Convert VitePress internal links to notes
    # e.g., [concurrency-auditor](/agents/concurrency-auditor) -> `concurrency-auditor` agent
    body = re.sub(
        r"\[([^\]]+)\]\(/agents/([^\)]+)\)",
        r"`\1` agent (see upstream Axiom docs)",
        body,
    )

    # Convert command links
    # e.g., [/axiom:audit-concurrency](/commands/...) -> `/axiom:audit-concurrency` command
    body = re.sub(
        r"\[([^\]]+)\]\(/commands/[^\)]+\)",
        r"`\1` command (Claude Code only)",
        body,
    )

    # Convert skill links to backticked references
    # e.g., [swift-performance](/skills/concurrency/swift-performance) -> `swift-performance` skill
    body = re.sub(
        r"\[([^\]]+)\]\(/skills/[^\)]+\)",
        r"`\1` skill",
        body,
    )

    # Fix markdownlint issues
    body = fix_fenced_code_blocks(body)
    body = fix_duplicate_headings(body)
    body = fix_emphasis_as_heading(body)

    return body


def generate_skill_name(file_path: Path) -> str:
    """Generate skill name from file path."""
    # Use the file stem as the skill name
    return f"axiom-{file_path.stem}"


def port_skill(
    source: Path, output_dir: Path, dry_run: bool = False
) -> tuple[str, bool]:
    """Port a single skill file to Windsurf format."""
    content = source.read_text()
    frontmatter, body = extract_frontmatter(content)

    if not frontmatter.get("name"):
        return f"SKIP (no name): {source}", False

    # Generate output path
    skill_name = f"axiom-{frontmatter['name']}"
    skill_dir = output_dir / skill_name
    skill_file = skill_dir / "SKILL.md"

    # Check if already exists
    if skill_file.exists():
        return f"EXISTS: {skill_name}", False

    # Transform body
    transformed_body = transform_body(body)

    # Build output content
    output_lines = [
        "---",
        f"name: {skill_name}",
    ]
    if frontmatter.get("description"):
        output_lines.append(f"description: {frontmatter['description']}")
    output_lines.append("---")
    output_lines.append(transformed_body)

    output_content = "\n".join(output_lines)

    if dry_run:
        return f"WOULD CREATE: {skill_name}", True

    # Create directory and file
    skill_dir.mkdir(parents=True, exist_ok=True)
    skill_file.write_text(output_content)
    return f"CREATED: {skill_name}", True


def main():
    parser = argparse.ArgumentParser(description="Port Axiom skills to Windsurf format")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview what would be created without making changes",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("skills"),
        help="Output directory for ported skills (default: skills/)",
    )
    args = parser.parse_args()

    # Find project root
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    docs_skills = project_root / "docs" / "skills"
    output_dir = project_root / args.output

    if not docs_skills.exists():
        print(f"ERROR: {docs_skills} not found")
        return 1

    print(f"Source: {docs_skills}")
    print(f"Output: {output_dir}")
    print(f"Mode: {'DRY RUN' if args.dry_run else 'LIVE'}")
    print()

    # Find and port skills
    skills = find_upstream_skills(docs_skills)
    print(f"Found {len(skills)} skill files\n")

    created = 0
    skipped = 0
    for skill_path in skills:
        result, was_created = port_skill(skill_path, output_dir, args.dry_run)
        print(result)
        if was_created:
            created += 1
        else:
            skipped += 1

    print()
    print(f"Summary: {created} {'would be ' if args.dry_run else ''}created, {skipped} skipped")

    return 0


if __name__ == "__main__":
    exit(main())
