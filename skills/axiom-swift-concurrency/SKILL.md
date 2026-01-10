---
name: axiom-swift-concurrency
description: Use when seeing data race warnings, actor isolation errors, "Sendable" violations, crashes with multithreaded access, or migrating to Swift 6 strict concurrency — provides systematic diagnosis and copy-paste fix patterns for iOS/macOS apps
---

# Swift Concurrency Debugging

Systematic diagnosis and fixes for Swift 6 concurrency issues. Covers the patterns responsible for 90% of real-world concurrency problems.

## When to Use This Skill

Use this skill when you're:

- Migrating to Swift 6 strict concurrency
- Seeing "data race" warnings or actor isolation errors
- Experiencing crashes with multithreaded access
- Before enabling strict concurrency checking
- After adding async/await or actors to your codebase
- Getting "Sendable" violations in your code

**Core principle:** Most concurrency issues can be fixed with ~5 lines of code once you identify the pattern.

## Example Prompts

Questions that should trigger this skill:

- "I'm getting data race warnings after enabling strict concurrency"
- "How do I make my ObservableObject thread-safe?"
- "What does 'Sendable' mean and how do I fix violations?"
- "My app crashes with 'simultaneous access' errors"
- "How do I migrate to Swift 6 concurrency?"
- "Actor isolation errors are blocking my build"

## Concurrency Issue Patterns

### 🔴 Critical (Crashes/Memory Leaks)

#### Missing @MainActor on UI Classes

```swift
// ❌ DATA RACE: Can be accessed from any thread
class ProfileViewModel: ObservableObject {
    @Published var name: String = ""
}

// ✅ SAFE: MainActor ensures thread safety
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var name: String = ""
}
```

#### Unsafe Task Self Capture

```swift
// ❌ LEAKS: Task captures self strongly
var loadTask: Task<Void, Never>?
loadTask = Task {
    self.data = await fetchData()  // Retain cycle!
}

// ✅ SAFE: Use weak self
loadTask = Task { [weak self] in
    guard let self = self else { return }
    self.data = await fetchData()
}
```

### 🟡 High Priority (Data Races)

#### Sendable Violations

```swift
// ❌ DATA RACE: Non-Sendable type crossing actor boundary
class UserData {
    var name: String
}

Task { @MainActor in
    await actor.process(userData)  // Warning: UserData is not Sendable
}

// ✅ SAFE: Make Sendable or use value types
struct UserData: Sendable {
    let name: String
}
```

#### Improper Actor Isolation

```swift
// ❌ DATA RACE: Using actor data without isolation
let result = await dataActor.getData()
result.mutate()  // Unsafe if result is mutable reference type!

// ✅ SAFE: Copy data before leaving actor context
let result = await dataActor.getData().copy()
result.mutate()  // Safe - working with copy
```

### 🟢 Medium Priority (Warnings)

#### Thread Confinement Violations

```swift
// ❌ WARNING: MainActor property accessed in detached task
Task.detached {
    print(self.mainActorProperty)  // Warning!
}

// ✅ SAFE: Capture value before detaching
let value = mainActorProperty
Task.detached {
    print(value)  // Safe - captured before detaching
}
```

## Quick Diagnostic Table

| Symptom | Pattern | Fix | Time |
|---------|---------|-----|------|
| ObservableObject data race | Missing @MainActor | Add @MainActor to class | 1 min |
| Task memory leak | Strong self capture | Add [weak self] | 2 min |
| Sendable violation | Non-Sendable type | Use struct or add Sendable | 5 min |
| Actor isolation error | Improper data access | Copy before leaving actor | 5 min |
| Thread confinement warning | MainActor in detached | Capture value first | 2 min |

## Migration Checklist

When migrating to Swift 6 strict concurrency:

1. **Add @MainActor to all ObservableObject classes**
2. **Add [weak self] to all stored Task properties**
3. **Convert mutable classes to Sendable structs where possible**
4. **Use nonisolated(unsafe) only as last resort**
5. **Enable strict concurrency checking incrementally**

## Time Cost Transparency

- 5-10 minutes: Fix individual concurrency warnings
- 30-60 minutes: Migrate small module to strict concurrency
- 2-4 hours: Full app migration (without this skill: 2-3 days)

## Related Skills

- `axiom-memory-debugging` — When leaks are from retain cycles, not concurrency
- `axiom-xcode-debugging` — Environment issues masquerading as concurrency bugs

## Resources

**WWDC**: 2021-10133, 2022-110351, 2024-10169

**Docs**: /swift/concurrency, /swift/sendable
