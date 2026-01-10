---
description: iOS project health dashboard - shows environment status and suggests improvements
---

# Axiom Status

Project health dashboard for iOS development.

## Steps

1. Check environment health

```bash
# Zombie xcodebuild processes
echo "Xcodebuild processes: $(pgrep -f xcodebuild | wc -l | tr -d ' ')"

# Derived Data size
echo "Derived Data: $(du -sh ~/Library/Developer/Xcode/DerivedData 2>/dev/null | cut -f1)"

# Booted simulators
echo "Booted simulators:"
xcrun simctl list devices booted 2>/dev/null | grep -v "^--" | head -5
```

2. Analyze project structure

```bash
# Count SwiftUI views
echo "SwiftUI views: $(find . -name '*.swift' -exec grep -l 'struct.*:.*View' {} \; 2>/dev/null | wc -l | tr -d ' ')"

# Potential memory patterns (Timer, NotificationCenter)
echo "Potential memory patterns: $(grep -r 'Timer\|NotificationCenter\.default\.addObserver' --include='*.swift' 2>/dev/null | wc -l | tr -d ' ')"

# iOS deployment target
echo "Deployment target: $(find . -name 'project.pbxproj' -exec grep 'IPHONEOS_DEPLOYMENT_TARGET' {} \; 2>/dev/null | head -1 | grep -o '[0-9]*\.[0-9]*' | head -1)"
```

3. Format results as a dashboard

```
📊 Axiom Project Status
═══════════════════════

🔧 Environment
   Xcodebuild processes: [count] [⚠️ if > 3]
   Derived Data: [size] [⚠️ if > 10GB]
   Simulators running: [count]

📱 Project Analysis
   SwiftUI views: [count]
   Potential memory patterns: [count] [⚠️ if > 0]
   Deployment target: iOS [version]

💡 Suggested Actions
   [Based on findings, suggest relevant Axiom skills]
```

4. Based on findings, suggest 2-3 relevant Axiom skills to invoke
