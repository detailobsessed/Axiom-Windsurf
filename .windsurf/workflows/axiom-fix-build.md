---
description: Diagnose and fix Xcode build failures using environment-first diagnostics
---

# Axiom Fix Build

Environment-first diagnostics for Xcode build failures. 80% of "mysterious" build issues are environment problems, not code bugs.

## Steps

1. Verify you're in the project directory:

```bash
ls -la | grep -E "\.xcodeproj|\.xcworkspace"
```

If nothing shows, you're in the wrong directory.

2. Check for zombie xcodebuild processes:

```bash
ps -eo pid,etime,command | grep -E "xcodebuild|Simulator" | grep -v grep
```

Processes running > 30 minutes are likely zombies. Kill them if found:

```bash
killall -9 xcodebuild
```

3. Check Derived Data size:

```bash
du -sh ~/Library/Developer/Xcode/DerivedData
```

If > 10GB, clean it:

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

4. Check simulator states:

```bash
xcrun simctl list devices | grep -E "Booted|Booting|Shutting Down"
```

If stuck, shutdown all:

```bash
xcrun simctl shutdown all
```

5. Get the scheme name and rebuild:

```bash
xcodebuild -list
```

Then clean and build:

```bash
xcodebuild clean build -scheme <SCHEME_NAME> -destination 'platform=iOS Simulator,name=iPhone 16'
```

6. Report results with:
   - Environment check results
   - Issue identified
   - Fix applied
   - Verification status
   - Next steps

## For SPM Issues

If "No such module" with Swift packages:

```bash
rm -rf ~/Library/Caches/org.swift.swiftpm/
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf .build/
xcodebuild -resolvePackageDependencies -scheme <SCHEME_NAME>
```

## Related Skills

- `axiom-build-debugging` — Detailed dependency troubleshooting
- `axiom-xcode-debugging` — Environment issues
