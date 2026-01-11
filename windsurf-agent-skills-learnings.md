# Windsurf Agent Skills Learnings

Tracking discoveries about Windsurf Next's skills implementation as we port Axiom from Claude Code.

## Key Findings

### File Naming

- **Global skills**: Use `SKILL.md` (uppercase) - located at `~/.codeium/windsurf-next/skills/`
- **Workspace skills**: Use `skill.md` (lowercase) - located at `.windsurf/skills/`
- Both use YAML frontmatter with `name` and `description` fields

### Skill Locations

| Type | Path | Discovered |
|------|------|------------|
| Global | `~/.codeium/windsurf-next/skills/<skill-name>/SKILL.md` | 2026-01-10 |
| Workspace | `.windsurf/skills/<skill-name>/skill.md` | 2026-01-10 |

### Frontmatter Format

```yaml
---
name: skill-name
description: A brief description, shown to the model to help it understand when to use this skill
---
```

### Invocation

- Windsurf has a `skill` tool that loads skill instructions
- Skills appear in system prompt as available skills with their descriptions
- Can be invoked via the `skill` tool with `SkillName` parameter

## Open Questions

- [x] Does Windsurf support `references/` subdirectories for progressive disclosure? **YES** - via read_file with base directory
- [ ] Does Windsurf support `scripts/` for executable code?
- [ ] Does Windsurf support `assets/` for templates/resources?
- [ ] How does auto-triggering work based on description? (see task 0d2)
- [ ] Is there a character/token limit for skill content?
- [ ] Can skills reference other skills?
- [x] Why does skill tool return cached/stale instructions after edits? **Tool cache lags behind UI discovery**

## Tests Performed

### Test 1: Basic Skill Discovery

- **Date**: 2026-01-10
- **Test**: Created workspace skill at `.windsurf/skills/a-test-skill/skill.md`
- **Result**: ✅ Skill discovered and invocable via `skill` tool
- **Notes**: Returns base directory and instructions

### Test 2: Global Skill Discovery

- **Date**: 2026-01-10
- **Test**: Created global skill at `~/.codeium/windsurf-next/skills/a-global-windsurf-skill/SKILL.md`
- **Result**: ✅ Skill appears in available skills list
- **Notes**: Uses uppercase `SKILL.md`

### Test 3: Progressive Disclosure (references/)

- **Date**: 2026-01-10
- **Test**: Added `references/test-reference.md` to global skill, referenced it in SKILL.md
- **Result**: ✅ Can read reference files using `read_file` tool with base directory path
- **Notes**:
  - Skill tool returns `Base Directory` which enables relative file access
  - Skill instructions may be cached - edits didn't reflect immediately
  - Progressive disclosure works manually (Cascade can read bundled files)

### Test 4: New Skill Discovery

- **Date**: 2026-01-10
- **Test**: Created new skill `axiom-xcode-debugging` in global skills directory
- **Result**: ✅ Skills discovered without restart! UI shows all three skills.
- **Notes**:
  - Directory created at `~/.codeium/windsurf-next/skills/axiom-xcode-debugging/SKILL.md`
  - Skill tool initially returned "not found" but UI showed skill was discovered
  - UI shows "1 resource" for skills with `references/` folder - **Windsurf tracks bundled resources!**
  - Skills labeled as "Global" vs "Workspace" in UI
  - **Correction**: No restart needed - skill tool cache may lag behind UI discovery

### Test 5: Skill Invocation

- **Date**: 2026-01-10
- **Test**: Invoked `axiom-xcode-debugging` skill via skill tool
- **Result**: ✅ Full skill content loaded successfully
- **Notes**:
  - Returns base directory and full instructions
  - All markdown formatting preserved (headers, code blocks, tables)
  - Skill is fully functional for iOS development guidance

### Test 6: Batch Skill Porting

- **Date**: 2026-01-10
- **Test**: Ported 4 additional high-priority skills to global skills directory
- **Result**: ✅ All skills discovered immediately
- **Skills ported**:
  - `axiom-swift-concurrency` — Swift 6 concurrency issues
  - `axiom-swiftui-debugging` — SwiftUI view update issues
  - `axiom-build-debugging` — Dependency and build failures
  - `axiom-memory-debugging` — Memory leaks and retain cycles
- **Notes**:
  - Total of 6 Axiom skills now available globally
  - Skills appear in Windsurf UI without restart
  - Each skill has comprehensive trigger descriptions for auto-invocation

## Porting Strategy

### Phase 1: Proof of Concept

1. Port one simple Axiom skill to global skills
2. Test if references/ subdirectory works
3. Document findings

### Phase 2: Core Skills ✅ COMPLETE

Port high-value iOS development skills:

- ✅ `axiom-xcode-debugging`
- ✅ `axiom-swift-concurrency`
- ✅ `axiom-swiftui-debugging`
- ✅ `axiom-build-debugging`
- ✅ `axiom-memory-debugging`

### Phase 3: Full Collection ✅ COMPLETE

Automated porting via `scripts/port-skills.py`:

- **42 skills** now in `skills/` directory
- **9 skipped** (missing frontmatter name in upstream)
- **16 agents** NOT ported (require sub-agent support)

Run `uv run scripts/port-skills.py --dry-run` to see what would be ported.

## Differences: Claude Code vs Windsurf

| Feature | Claude Code | Windsurf Next |
|---------|-------------|---------------|
| File name | `SKILL.md` | `SKILL.md` (global) / `skill.md` (workspace) |
| Location | `plugins/*/skills/` | `~/.codeium/windsurf-next/skills/` (global) |
| Progressive disclosure | ✅ Documented | ✅ Works via `references/` |
| Auto-triggering | ✅ Based on description | ❓ Unknown (needs testing) |
| Bundled resources | `scripts/`, `references/`, `assets/` | ✅ `references/` confirmed |
| Sub-agents | ✅ Full support | ❌ Not yet supported |
| Slash commands | ✅ `/axiom:*` | ❌ Not supported |
| Metadata fields | ✅ Full spec | ⚠️ Limited (name, description only) |

**Implications**:

- Skills work fully ✅
- Agents (autonomous sub-agents) cannot be ported yet
- Commands (slash commands) are Claude Code specific
- Focus on skill content, reference agents/commands in upstream docs

## Future Exploration

### Windsurf Workflows

Windsurf workflows support both global and workspace locations:

| Type | Path |
|------|------|
| Global | `~/.codeium/windsurf-next/global_workflows/*.md` |
| Workspace | `.windsurf/workflows/*.md` |

**Status:** 3 workflows created (`axiom-status`, `axiom-screenshot`, `axiom-fix-build`). Installed globally via `install.sh`.

### Windsurf Hooks

Port Axiom hooks to Windsurf's `hooks.json` format.

**Config locations (Windsurf Next):**

- User-level: `~/.codeium/windsurf-next/hooks.json`
- Workspace-level: `.windsurf/hooks.json`

**Available events:** `pre_write_code`, `post_write_code`, `pre_run_command`, `post_run_command`, `pre_user_prompt`, `post_cascade_response`, etc.

**Limitation:** Windsurf hooks can only block actions (exit code 2) or log output. They cannot inject context into the conversation like Axiom hooks can. See [GitHub issue #3](https://github.com/detailobsessed/Axiom-Windsurf/issues/3).

**Docs:** <https://docs.windsurf.com/windsurf/cascade/hooks>

### Curl-installable Script

**Status:** ✅ COMPLETE

Install scripts (`install.sh`, `install.ps1`) are finalized and documented in README.

**Important:** Workflows are stored in `workflows/` at repo root (NOT `.windsurf/workflows/`). The `.windsurf/workflows/` path is for workspace-level workflows, not distribution.

### Upstream Tracking

**Status:** No automated sync needed.

Fork has diverged significantly from upstream. To track upstream changes:

- Watch upstream releases on GitHub
- Periodically check for new skills worth porting
- Most upstream changes are agent-related (not portable to Windsurf)

## Resources

- [Agent Skills Spec](https://agentskills.io/specification) - Anthropic's open format
- [Claude Code Skills Docs](https://github.com/anthropics/claude-code) - Reference implementation
- [Windsurf Docs](https://docs.windsurf.com/) - Official documentation
- [Windsurf Hooks](https://docs.windsurf.com/windsurf/cascade/hooks) - Cascade hooks documentation
- [Windsurf Workflows](https://docs.windsurf.com/windsurf/cascade/workflows) - Workflow documentation
