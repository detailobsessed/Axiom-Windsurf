---
name: axiom-memory-debugging
description: Use when debugging retain cycles, memory leaks, crashes after 10+ minutes, or progressive memory growth from 50MB to 200MB+ — provides systematic diagnosis, Instruments patterns, and production-ready fixes for iOS/macOS apps
---

# Memory Debugging

Systematic memory leak diagnosis using Instruments. Covers the 5 leak patterns responsible for 90% of real-world iOS memory issues.

## When to Use This Skill

Use this skill when you're:

- Seeing app memory grow progressively during use (50MB → 100MB → 200MB)
- Finding multiple instances of the same view controller in Instruments
- Getting crashes after 10-15 minutes with no error message
- Instruments shows retain cycles or leaked objects
- View controllers don't deallocate after dismiss

**Time investment:** 15-30 minutes with this skill vs 2-3 hours hunting without it.

## Example Prompts

Questions that should trigger this skill:

- "My app crashes after 10-15 minutes of use with no error messages"
- "Memory jumps from 50MB to 200MB+ on a specific action"
- "View controllers don't deallocate after dismiss"
- "I have timers and observers that might be leaking"
- "My app uses 200MB. Is that normal or do I have leaks?"
- "How do I set up Instruments to track memory leaks?"

## The 5 Leak Patterns (90% of Real Issues)

### 🔴 Pattern 1: Closure Capture Leaks

```swift
// ❌ LEAKS: Strong capture of self
viewModel.onUpdate = {
    self.updateUI()  // self captured strongly
}

// ✅ SAFE: Weak capture
viewModel.onUpdate = { [weak self] in
    self?.updateUI()
}
```

### 🔴 Pattern 2: Delegate Cycles

```swift
// ❌ LEAKS: Strong delegate creates cycle
class Child {
    var delegate: Parent?  // Strong reference!
}

// ✅ SAFE: Weak delegate
class Child {
    weak var delegate: Parent?
}
```

### 🔴 Pattern 3: Timer Leaks

```swift
// ❌ LEAKS: Timer never invalidated
var timer: Timer?
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
    self.tick()
}

// ✅ SAFE: Invalidate in deinit
deinit {
    timer?.invalidate()
}
```

### 🟡 Pattern 4: NotificationCenter Leaks

```swift
// ❌ LEAKS: Observer never removed
NotificationCenter.default.addObserver(
    self,
    selector: #selector(handleNotification),
    name: .someNotification,
    object: nil
)

// ✅ SAFE: Remove in deinit
deinit {
    NotificationCenter.default.removeObserver(self)
}
```

### 🟡 Pattern 5: Parent-Child Cycles

```swift
// ❌ LEAKS: Navigation creates cycle
class ParentVC: UIViewController {
    var childVC: ChildVC?
}
class ChildVC: UIViewController {
    var parentVC: ParentVC?  // Strong back-reference!
}

// ✅ SAFE: Weak back-reference
class ChildVC: UIViewController {
    weak var parentVC: ParentVC?
}
```

## Quick Diagnosis Checklist

1. **Add deinit logging:**

```swift
deinit {
    print("\(type(of: self)) deallocated")
}
```

1. **Does deinit fire when expected?** If not, leak exists

2. **Check in order:** closures → delegates → timers → observers

3. **Use Memory Graph Debugger** (Debug > Debug Memory Graph) to find retainer

## Instruments Workflow

### Setup for Leak Detection

1. **Product > Profile** (Cmd-I)
2. Select **Allocations** template
3. Record while reproducing the issue
4. Use **Mark Generation** before/after action to isolate

### Finding the Retainer

1. **Debug > Debug Memory Graph** in Xcode
2. Find the leaked object in left sidebar
3. Follow arrows to see what's retaining it
4. Purple "!" indicates strong reference cycle

## Quick Diagnostic Table

| Symptom | Likely Pattern | Fix Time |
|---------|----------------|----------|
| VC doesn't deallocate | Closure or delegate | 5 min |
| Memory grows 10MB/min | Timer leak | 2 min |
| Crash after 10-15 min | Multiple leaks | 30 min |
| Multiple VC instances | Navigation cycle | 10 min |

## Verification

After fixing, verify the leak is gone:

```swift
// 1. Add deinit print
deinit {
    print("✅ \(type(of: self)) deallocated")
}

// 2. Reproduce the action that caused the leak
// 3. Verify deinit prints
// 4. Check Instruments shows flat memory graph
```

## Time Cost Transparency

- 5-10 minutes: Fix single leak with known pattern
- 15-30 minutes: Find and fix unknown leak with Instruments
- 2-3 hours: Debugging without systematic approach

## Related Skills

- `axiom-swift-concurrency` — When leaks are from Task captures
- `axiom-xcode-debugging` — Environment issues, not actual leaks

## Resources

**WWDC**: 2021-10180, 2022-10106, 2024-10173

**Docs**: /instruments, /xcode/debugging-and-testing
