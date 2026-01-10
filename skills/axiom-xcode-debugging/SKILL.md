---
name: axiom-xcode-debugging
description: Use when encountering BUILD FAILED, test crashes, simulator hangs, stale builds, zombie xcodebuild processes, "Unable to boot simulator", "No such module" after SPM changes, or mysterious test failures despite no code changes — systematic environment-first diagnostics for iOS/macOS projects
---

# Xcode Debugging

Environment-first diagnostics for mysterious Xcode issues. Prevents 30+ minute rabbit holes by checking build environment before debugging code.

## When to Use This Skill

Use this skill when you're:

- Getting BUILD FAILED with no clear error
- Tests passed yesterday, failing today with no code changes
- Build succeeds but old code executes
- Simulator says "Unable to boot" or stuck at splash screen
- Getting "No such module" after SPM updates
- Experiencing intermittent build failures

**Core principle:** 80% of "mysterious" Xcode issues are environment problems (stale Derived Data, stuck simulators, zombie processes), not code bugs.

## Example Prompts

Questions that should trigger this skill:

- "My build fails with 'BUILD FAILED' but no error details. I haven't changed anything."
- "Tests passed yesterday, failing today with no code changes. What's going on?"
- "My app builds but runs old code from before my changes."
- "Simulator says 'Unable to boot simulator'. How do I recover?"
- "I'm getting 'No such module' errors after updating SPM dependencies."
- "Build sometimes succeeds, sometimes fails. Why?"
- "I have 20 xcodebuild processes running. Is that normal?"

## Red Flags (Check Environment First)

- "It works on my machine but not CI"
- "Tests passed yesterday, failing today"
- "Build succeeds but old code executes"
- Intermittent success/failure
- Simulator stuck or unresponsive
- Multiple zombie xcodebuild processes

## The Environment-First Checklist

```bash
# 1. Check for zombie processes (10+ or older than 30 min = problem)
ps aux | grep -E "xcodebuild|Simulator" | grep -v grep

# 2. Kill zombies if found
killall xcodebuild 2>/dev/null
killall Simulator 2>/dev/null

# 3. Clean Derived Data
rm -rf ~/Library/Developer/Xcode/DerivedData

# 4. Reset simulators if needed
xcrun simctl shutdown all
xcrun simctl erase all  # Nuclear option - erases all simulator data

# 5. Clean SPM cache if module errors persist
rm -rf ~/Library/Caches/org.swift.swiftpm
```

## When to Use Each Step

| Symptom | Fix | Time |
|---------|-----|------|
| Stale builds, old code runs | Delete Derived Data | 2 min |
| "No such module" | Delete Derived Data + SPM cache | 3 min |
| Simulator stuck | simctl shutdown + reboot | 2 min |
| Zombie processes | killall | 1 min |
| All of the above | Full reset + reboot | 10 min |

## Time Cost Transparency

- 2-5 minutes: Derived Data cleanup
- 5-10 minutes: Full environment reset
- 30+ minutes: Debugging code when problem is environment

## Related Skills

- `axiom-build-debugging` — Dependency resolution for CocoaPods/SPM
- `axiom-performance-profiling` — When issue is performance, not environment

## Resources

**WWDC**: 2021-10209, 2023-10164
**Apple Docs**: /xcode/debugging-and-testing
