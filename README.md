# Axiom for Windsurf

[![Porting Progress](https://img.shields.io/badge/skills%20ported-42%2F58-blue)](skills/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Windsurf Next](https://img.shields.io/badge/Windsurf-Next-purple)](https://windsurf.com/)

iOS development skills for [Windsurf Next](https://windsurf.com/), ported from [CharlesWiltgen/Axiom](https://github.com/CharlesWiltgen/Axiom).

See [`skills/`](skills/) for currently available skills, ready to use with Windsurf Next.

**Documentation**: [GitHub Wiki](https://github.com/detailobsessed/Axiom-Windsurf/wiki)

## Installation

### macOS / Linux

```bash
curl -LsSf https://raw.githubusercontent.com/detailobsessed/Axiom-Windsurf/main/install.sh | sh
```

### Windows

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://raw.githubusercontent.com/detailobsessed/Axiom-Windsurf/main/install.ps1 | iex"
```

### Update

Re-run the install command — it's idempotent and will update existing skills.

### Verify Installation

Skills should appear in Windsurf's skill picker. Each skill is automatically suggested based on your questions.

## Usage

Skills are **automatically triggered** based on your questions. Examples:

- "My build fails with BUILD FAILED but no error" → `axiom-xcode-debugging`
- "I'm getting Swift concurrency warnings" → `axiom-swift-concurrency`
- "My SwiftUI view isn't updating" → `axiom-swiftui-debugging`
- "No such module after SPM update" → `axiom-build-debugging`
- "My app has memory leaks" → `axiom-memory-debugging`

## Workflows

Axiom includes workflows for common tasks. If you run the installer from your project directory (where `.git` or `.windsurf` exists), workflows are copied automatically. Otherwise, copy `.windsurf/workflows/` manually:

| Workflow | Description |
|----------|-------------|
| `/axiom-status` | Project health dashboard |
| `/axiom-screenshot` | Capture simulator screenshot |
| `/axiom-fix-build` | Environment-first build diagnostics |

## Project Structure

```text
skills/              # Windsurf-compatible SKILL.md files
scripts/             # Install and porting scripts
.windsurf/workflows/ # Reusable workflows
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

- **Issues**: [GitHub Issues](https://github.com/detailobsessed/Axiom-Windsurf/issues)
- **Skill content**: Contribute upstream at [CharlesWiltgen/Axiom](https://github.com/CharlesWiltgen/Axiom)

## License

MIT — Same as upstream Axiom project.
