import AppKit
import Carbon

/// Bridges `NSEvent.ModifierFlags` to Carbon modifier key constants
/// used by `RegisterEventHotKey`.
public typealias HotKeyModifiers = NSEvent.ModifierFlags

extension NSEvent.ModifierFlags {
    /// Converts AppKit modifier flags to the Carbon modifier mask expected
    /// by `RegisterEventHotKey`.
    public func toCarbonModifiers() -> UInt32 {
        var carbon: UInt32 = 0
        if contains(.command) { carbon |= UInt32(cmdKey) }
        if contains(.option)  { carbon |= UInt32(optionKey) }
        if contains(.control) { carbon |= UInt32(controlKey) }
        if contains(.shift)   { carbon |= UInt32(shiftKey) }
        return carbon
    }
}
