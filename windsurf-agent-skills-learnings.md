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
- [ ] How does auto-triggering work based on description?
- [ ] Is there a character/token limit for skill content?
- [ ] Can skills reference other skills?
- [ ] Why does skill tool return cached/stale instructions after edits?

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

## Porting Strategy

### Phase 1: Proof of Concept

1. Port one simple Axiom skill to global skills
2. Test if references/ subdirectory works
3. Document findings

### Phase 2: Core Skills

Port high-value iOS development skills:

- `xcode-debugging`
- `swift-concurrency`
- `swiftui-debugging`
- `build-debugging`

### Phase 3: Full Collection

Systematically port remaining skills with automation.

## Differences: Claude Code vs Windsurf

| Feature | Claude Code | Windsurf Next |
|---------|-------------|---------------|
| File name | `SKILL.md` | `SKILL.md` (global) / `skill.md` (workspace) |
| Location | `plugins/*/skills/` | `~/.codeium/windsurf-next/skills/` (global) |
| Progressive disclosure | ✅ Documented | ❓ Unknown |
| Auto-triggering | ✅ Based on description | ❓ Unknown |
| Bundled resources | `scripts/`, `references/`, `assets/` | ❓ Unknown |

## Resources

- [Agent Skills Spec](https://agentskills.io/specification) - Anthropic's open format
- [Claude Code Skills Docs](https://github.com/anthropics/claude-code) - Reference implementation
- [Windsurf Docs](https://docs.windsurf.com/) - Official documentation (skills not yet documented)
