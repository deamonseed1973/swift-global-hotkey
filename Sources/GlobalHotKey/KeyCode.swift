import Carbon
import Foundation

/// Virtual key codes matching Apple's Carbon `kVK_*` constants.
///
/// These correspond to physical key positions on the keyboard and are
/// layout-independent. Use ``keyEquivalent`` to resolve the character
/// produced by a key code on the current keyboard layout via `UCKeyTranslate`.
public enum KeyCode: UInt32, CaseIterable, Sendable {
    // MARK: - Letters
    case a = 0
    case s = 1
    case d = 2
    case f = 3
    case h = 4
    case g = 5
    case z = 6
    case x = 7
    case c = 8
    case v = 9
    case b = 11
    case q = 12
    case w = 13
    case e = 14
    case r = 15
    case y = 16
    case t = 17
    case o = 31
    case u = 32
    case i = 34
    case p = 35
    case l = 37
    case j = 38
    case k = 40
    case n = 45
    case m = 46

    // MARK: - Special keys
    case returnKey = 36
    case tab = 48
    case space = 49
    case escape = 53

    // MARK: - Function keys
    case f1 = 122
    case f2 = 120
    case f3 = 99
    case f4 = 118
    case f5 = 96
    case f6 = 97
    case f7 = 98
    case f8 = 100
    case f9 = 101
    case f10 = 109
    case f11 = 103
    case f12 = 111
}

// MARK: - UCKeyTranslate bridging

extension KeyCode {
    /// Returns the character produced by this key code on the current keyboard
    /// layout, using Carbon's `UCKeyTranslate`.
    ///
    /// This is the same technique used by boring.notch's `KeyboardShortcutsHelper`
    /// to bridge Carbon key codes to SwiftUI `KeyEquivalent`.
    ///
    /// Returns `nil` if the key code cannot be translated (e.g. when running
    /// in a headless environment without an active keyboard layout).
    public var keyEquivalent: Character? {
        let carbonKeyCode = UInt16(rawValue)
        let maxNameLength = 4
        var nameBuffer = [UniChar](repeating: 0, count: maxNameLength)
        var nameLength = 0
        let modifierKeys = UInt32(alphaLock >> 8) & 0xFF
        var deadKeys: UInt32 = 0
        let keyboardType = UInt32(LMGetKbdType())

        guard let sourceRef = TISCopyCurrentKeyboardLayoutInputSource() else {
            return nil
        }
        let source = sourceRef.takeRetainedValue()
        guard let ptr = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) else {
            return nil
        }

        let layoutData = Unmanaged<CFData>.fromOpaque(ptr).takeUnretainedValue() as Data
        let osStatus = layoutData.withUnsafeBytes {
            UCKeyTranslate(
                $0.bindMemory(to: UCKeyboardLayout.self).baseAddress!,
                carbonKeyCode,
                UInt16(kUCKeyActionDown),
                modifierKeys,
                keyboardType,
                UInt32(kUCKeyTranslateNoDeadKeysMask),
                &deadKeys,
                maxNameLength,
                &nameLength,
                &nameBuffer
            )
        }

        guard osStatus == noErr, nameLength > 0 else { return nil }
        return Character(String(utf16CodeUnits: nameBuffer, count: nameLength))
    }
}
