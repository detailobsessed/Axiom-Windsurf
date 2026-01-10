---
name: axiom-swiftui-debugging
description: Use when SwiftUI views don't update, update too often, state resets unexpectedly, or previews crash — provides Self._printChanges() analysis, Instruments workflows, and systematic diagnosis for view update issues
---

# SwiftUI Debugging

Systematic diagnostics for SwiftUI view update issues. Uses Self._printChanges() and SwiftUI Instrument for evidence-based diagnosis.

## When to Use This Skill

Use this skill when you're:

- View not updating after state changes
- Self._printChanges() shows unexpected update patterns
- Intermittent issues ("works sometimes")
- Complex dependency chains causing cascading updates
- Views updating too often (performance)
- Preview crashes that aren't immediately obvious
- State resets unexpectedly during navigation

**Core principle:** SwiftUI issues are almost always about identity, state ownership, or update triggers — not "SwiftUI is broken."

## Example Prompts

Questions that should trigger this skill:

- "My view isn't updating even though state changed"
- "Self._printChanges() shows @self changed but I don't know why"
- "View updates intermittently — works sometimes, fails others"
- "Too many views updating when I change one value"
- "Preview crashes without clear error message"
- "State resets when navigating back"
- "My list performance is terrible"

## Diagnostic Patterns

### Pattern D1: Self._printChanges() Analysis

```swift
var body: some View {
    let _ = Self._printChanges()  // Add temporarily
    // Output tells you exactly what triggered update
}
```

**Output interpretation:**

- `@self changed` → View value or environment changed
- `propertyName changed` → That specific state triggered update
- Nothing logged → Body not being called at all

### Pattern D2: SwiftUI Instrument

For complex cases, use Instruments:

1. Launch Instruments with SwiftUI template (Cmd-I)
2. Record while reproducing issue
3. Check "Long View Body Updates" lane for expensive views
4. Use "Cause & Effect Graph" to trace data flow

### Pattern D3: View Identity Investigation

For state that resets unexpectedly:

```swift
// ❌ PROBLEM: View recreated on each toggle
if showDetail {
    DetailView()  // New identity each time!
}

// ✅ SAFE: Stable identity
DetailView()
    .opacity(showDetail ? 1 : 0)

// Or use explicit ID
DetailView()
    .id("detail")  // Stable identity
```

**Check for:**

- Views inside `if/else` conditionals
- `.id()` modifiers with changing values
- ForEach without unique, stable identifiers

### Pattern D4: Environment Dependency Check

For cascading updates:

```swift
// ❌ PROBLEM: Entire tree updates on any change
.environment(\.appState, appState)  // AppState changes frequently

// ✅ BETTER: Pass only what's needed
.environment(\.userSettings, appState.userSettings)
```

**Check for:**

- `.environment()` modifiers with frequently-changing values
- Consider using direct parameters instead

### Pattern D5: Preview Diagnostics

For preview crashes:

1. Click "Diagnostics" button in preview canvas
2. Check for missing environment objects
3. Verify preview provider has all required data
4. Try isolating the view in a new preview

## Quick Diagnostic Table

| Symptom | First Check | Pattern | Fix Time |
|---------|-------------|---------|----------|
| View doesn't update | Self._printChanges() | D1 | 10 min |
| View updates too often | Instruments | D2 | 30 min |
| State resets | .id() modifiers | D3 | 15 min |
| Cascade updates | Environment | D4 | 20 min |
| Preview crashes | Diagnostics button | D5 | 10 min |

## Common Fixes

### State Not Updating

```swift
// ❌ PROBLEM: Observing wrong thing
@State var items: [Item]  // Won't update on item property changes

// ✅ FIX: Use ObservableObject or @Observable
@StateObject var viewModel = ItemsViewModel()
// or with Observation framework:
@State var viewModel = ItemsViewModel()  // if @Observable
```

### Too Many Updates

```swift
// ❌ PROBLEM: Entire view rebuilds
var body: some View {
    VStack {
        ExpensiveView()
        Text(counter)  // Changes frequently
    }
}

// ✅ FIX: Extract changing parts
var body: some View {
    VStack {
        ExpensiveView()
        CounterView(counter: counter)  // Isolated updates
    }
}
```

## Time Cost Transparency

- 10-15 minutes: Diagnose with Self._printChanges()
- 30-60 minutes: Complex Instruments analysis
- 2-3 hours: Debugging without systematic approach

## Related Skills

- `axiom-xcode-debugging` — When issue is environment, not SwiftUI
- `axiom-memory-debugging` — When views leak instead of just misbehave

## Resources

**WWDC**: 2025-306 (SwiftUI Instruments), 2023-10160 (Performance), 2021-10022 (View identity)

**Docs**: /swiftui, /xcode/instruments
