# Axiom for Windsurf

[![Porting Progress](https://img.shields.io/badge/skills%20ported-42%2F58-blue)](skills/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Windsurf Next](https://img.shields.io/badge/Windsurf-Next-purple)](https://windsurf.com/)

iOS development skills for [Windsurf Next](https://windsurf.com/), ported from [CharlesWiltgen/Axiom](https://github.com/CharlesWiltgen/Axiom).

See [`skills/`](skills/) for currently available skills, ready to use with Windsurf Next.

## Installation

### Manual Installation

Copy the skills to Windsurf's global skills directory:

```bash
cp -r skills/* ~/.codeium/windsurf-next/skills/
```

### Verify Installation

Skills should appear in Windsurf's skill picker. Each skill is automatically suggested based on your questions.

## Usage

Skills are **automatically triggered** based on your questions. Examples:

- "My build fails with BUILD FAILED but no error" → `axiom-xcode-debugging`
- "I'm getting Swift concurrency warnings" → `axiom-swift-concurrency`
- "My SwiftUI view isn't updating" → `axiom-swiftui-debugging`
- "No such module after SPM update" → `axiom-build-debugging`
- "My app has memory leaks" → `axiom-memory-debugging`

## Project Structure

```text
skills/              # Windsurf-compatible SKILL.md files (use these)
.claude-plugin/      # Upstream skills source (for porting)
docs/                # Upstream documentation (reference)
```

## Upstream

The original Axiom project has 58+ skills covering SwiftUI, concurrency, persistence, debugging, and more.

- **Documentation**: [charleswiltgen.github.io/Axiom](https://charleswiltgen.github.io/Axiom/)
- **Repository**: [CharlesWiltgen/Axiom](https://github.com/CharlesWiltgen/Axiom)

## Windsurf Limitations

Windsurf Next doesn't yet support all Axiom features:

- **Sub-agents**: Autonomous agents (e.g., `build-fixer`, `accessibility-auditor`) require sub-agent support not yet available
- **Slash commands**: `/axiom:*` commands are Claude Code specific
- **Some metadata fields**: Limited frontmatter support compared to Claude Code

Skills work fully. Agents and commands are referenced in skill content but link to upstream docs.

## Contributing

- **Issues**: [GitHub Issues](https://github.com/ichoosetoaccept/Axiom-Windsurf/issues)
- **Skill content**: Contribute upstream at [CharlesWiltgen/Axiom](https://github.com/CharlesWiltgen/Axiom)

## License

MIT — Same as upstream Axiom project.
