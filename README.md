# GlobalHotKey

A zero-dependency Swift Package for registering global hotkeys on macOS using Carbon's `RegisterEventHotKey`.

## Background

[boring.notch](https://github.com/TheBoredTeam/boring.notch) and [Atoll](https://github.com/AtoLLNern/atoll) both vendor a `KeyboardShortcutsHelper.swift` that bridges [Sindre Sorhus's KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) to SwiftUI. The core of this bridge uses Carbon's `UCKeyTranslate` to convert Carbon key codes to SwiftUI `KeyEquivalent`. This package extracts and generalises that pattern into a standalone, pure-Swift global hotkey library requiring no external dependencies.

## Requirements

- macOS 13+
- Swift 5.9+

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/swift-global-hotkey.git", from: "1.0.0"),
]
```

Or add it in Xcode via **File → Add Package Dependencies**.

## Usage

### Register a global hotkey

```swift
import GlobalHotKey

let hotKey = GlobalHotKey(
    keyCode: .space,
    modifiers: [.command, .option],
    handler: { print("hotkey fired!") }
)
try hotKey.register()
```

### Unregister

```swift
hotKey.unregister()
```

The hotkey is also automatically unregistered when the `GlobalHotKey` instance is deallocated.

### Bridge to SwiftUI KeyEquivalent

Use the `keyEquivalent` property to convert a `KeyCode` to the character it produces on the current keyboard layout via `UCKeyTranslate`:

```swift
import SwiftUI
import GlobalHotKey

if let char = KeyCode.a.keyEquivalent {
    let equivalent = KeyEquivalent(char)
    // Use in SwiftUI keyboard shortcut APIs
}
```

### Available key codes

All 26 letter keys (`a`–`z`), special keys (`space`, `returnKey`, `tab`, `escape`), and function keys (`f1`–`f12`) are provided. Key codes match Apple's Carbon `kVK_*` constants.

### Modifier flags

`HotKeyModifiers` is a typealias for `NSEvent.ModifierFlags`. Use standard AppKit modifiers:

```swift
let modifiers: HotKeyModifiers = [.command, .shift, .option, .control]
```

## License

MIT
