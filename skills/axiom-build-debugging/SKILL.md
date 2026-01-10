---
name: axiom-build-debugging
description: Use when Xcode build fails with dependency errors, CocoaPods/SPM conflicts, "No such module" after package updates, or version resolution failures — systematic diagnosis for iOS/macOS dependency issues
---

# Build Debugging

Systematic diagnosis for Xcode build failures related to dependencies, package managers, and project configuration.

## When to Use This Skill

Use this skill when you're:

- Getting "No such module" errors after SPM updates
- CocoaPods or SPM version conflicts
- Build fails after switching branches
- Dependency resolution taking forever or failing
- Xcode can't find frameworks that should exist
- Linker errors with third-party libraries

**Core principle:** Most dependency issues are cache/state problems, not actual conflicts. Clean state first, debug second.

## Example Prompts

Questions that should trigger this skill:

- "Build fails with 'No such module' after updating packages"
- "CocoaPods says there's a version conflict"
- "SPM is stuck resolving dependencies"
- "Linker error: framework not found"
- "Build works on my machine but fails on CI"
- "Xcode can't find a module I just added"

## Diagnostic Workflow

### Step 1: Environment Check (Always First)

```bash
# Check for zombie processes
ps aux | grep -E "xcodebuild|swift" | grep -v grep

# Kill if found
killall xcodebuild 2>/dev/null

# Check Derived Data size (>10GB = problem)
du -sh ~/Library/Developer/Xcode/DerivedData
```

### Step 2: Identify Package Manager

| Manager | Config File | Cache Location |
|---------|-------------|----------------|
| SPM | Package.swift, Package.resolved | ~/Library/Caches/org.swift.swiftpm |
| CocoaPods | Podfile, Podfile.lock | Pods/, ~/Library/Caches/CocoaPods |
| Carthage | Cartfile, Cartfile.resolved | Carthage/ |

### Step 3: Clean and Reset

#### For SPM Issues

```bash
# Nuclear option - full SPM reset
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf .build
rm Package.resolved  # Only if you want fresh resolution

# Then in Xcode: File > Packages > Reset Package Caches
```

#### For CocoaPods Issues

```bash
# Full CocoaPods reset
rm -rf Pods
rm Podfile.lock  # Only if you want fresh resolution
pod cache clean --all
pod deintegrate
pod install
```

## Common Issues and Fixes

### 🔴 "No such module" After SPM Update

```bash
# 1. Clean Derived Data
rm -rf ~/Library/Developer/Xcode/DerivedData

# 2. Reset SPM cache
rm -rf ~/Library/Caches/org.swift.swiftpm

# 3. Close and reopen Xcode

# 4. File > Packages > Resolve Package Versions
```

**Time:** 3-5 minutes

### 🔴 SPM Version Conflict

```text
Package 'X' requires 'Y' 2.0.0, but 'Z' requires 'Y' 1.0.0
```

**Fix options:**

1. Check if packages have compatible version ranges
2. Fork and update the outdated package
3. Use `.upToNextMajor(from:)` instead of exact versions

### 🟡 CocoaPods Spec Repo Out of Date

```bash
# Update spec repo
pod repo update

# Then reinstall
pod install
```

### 🟡 Linker Error: Framework Not Found

```bash
# Check framework search paths in Build Settings
# Verify framework is in:
# - Embedded Binaries (for dynamic frameworks)
# - Link Binary With Libraries (for all frameworks)

# For SPM packages, ensure target is linked:
# Target > General > Frameworks, Libraries, and Embedded Content
```

### 🟢 Build Works Locally, Fails on CI

Common causes:

1. **Different Xcode version** — Check CI Xcode version
2. **Missing Package.resolved** — Commit it to git
3. **Cache corruption** — Add cache clear step to CI
4. **Keychain issues** — Ensure certificates are installed

## Quick Diagnostic Table

| Symptom | First Action | Time |
|---------|--------------|------|
| "No such module" | Clean Derived Data + SPM cache | 3 min |
| Version conflict | Check Package.resolved | 5 min |
| Stuck resolving | Kill xcodebuild, reset cache | 2 min |
| Framework not found | Check link settings | 5 min |
| CI-only failure | Compare Xcode versions | 10 min |

## Prevention Tips

1. **Commit Package.resolved/Podfile.lock** — Ensures reproducible builds
2. **Pin major versions** — Use `.upToNextMinor` for stability
3. **Clean before branch switch** — Prevents stale cache issues
4. **CI cache strategy** — Cache SPM/Pods but invalidate on lockfile change

## Time Cost Transparency

- 2-5 minutes: Cache reset fixes most issues
- 10-30 minutes: Actual version conflict resolution
- 1-2 hours: Debugging without systematic approach

## Related Skills

- `axiom-xcode-debugging` — Environment issues (zombies, simulators)
- `axiom-swift-concurrency` — When build fails due to concurrency errors

## Resources

**WWDC**: 2022-110359 (SPM), 2023-10164 (Xcode)

**Docs**: /xcode/swift-packages, /xcode/build-system
