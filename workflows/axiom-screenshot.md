---
description: Capture screenshot from booted iOS Simulator for visual analysis
---

# Axiom Screenshot

Capture and analyze a screenshot from the iOS Simulator.

## Steps

1. Check if a simulator is booted:

```bash
xcrun simctl list devices booted
```

2. If no simulator is booted, boot one:

```bash
# List available simulators
xcrun simctl list devices available | grep -E "iPhone|iPad" | head -10

# Boot a simulator (replace with an available device from the list above)
xcrun simctl boot "<DEVICE_NAME>"
```

3. Capture the screenshot:

```bash
xcrun simctl io booted screenshot /tmp/axiom-screenshot-$(date +%Y%m%d-%H%M%S).png
```

4. Display the screenshot path and read the image file to analyze it.

5. Describe what's visible in the screenshot and ask if the user wants to:
   - Debug a visual issue
   - Verify a fix
   - Document the current state
