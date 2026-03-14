import Carbon
import Foundation

/// A global hotkey that invokes a handler when the user presses a
/// system-wide keyboard shortcut, even when the app is not focused.
///
/// Uses Carbon's `RegisterEventHotKey` under the hood.
///
/// ```swift
/// let hotKey = GlobalHotKey(
///     keyCode: .space,
///     modifiers: [.command, .option],
///     handler: { print("hotkey fired!") }
/// )
/// try hotKey.register()
/// // later…
/// hotKey.unregister()
/// ```
public final class GlobalHotKey {
    // MARK: - Static ID counter

    /// Four-character signature used to identify this library's hotkeys.
    /// "GHKY" encoded as a big-endian `OSType`.
    private static let signature: OSType = {
        "GHKY".utf8.reduce(0 as UInt32) { $0 << 8 | UInt32($1) }
    }()

    private static var nextID: UInt32 = 0

    // MARK: - Instance properties

    /// The virtual key code for this hotkey.
    public let keyCode: KeyCode

    /// The modifier flags required to trigger this hotkey.
    public let modifiers: HotKeyModifiers

    private let handler: () -> Void
    private let id: UInt32
    private var hotKeyRef: EventHotKeyRef?

    /// Whether this hotkey is currently registered with the system.
    public var isRegistered: Bool { hotKeyRef != nil }

    // MARK: - Initialiser

    /// Creates a new global hotkey.
    ///
    /// The hotkey is **not** registered until you call ``register()``.
    ///
    /// - Parameters:
    ///   - keyCode: The virtual key code to listen for.
    ///   - modifiers: The modifier keys that must be held.
    ///   - handler: A closure invoked on the main thread when the hotkey fires.
    public init(
        keyCode: KeyCode,
        modifiers: HotKeyModifiers,
        handler: @escaping () -> Void
    ) {
        Self.nextID += 1
        self.id = Self.nextID
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.handler = handler
    }

    deinit {
        unregister()
    }

    // MARK: - Registration

    /// Registers the hotkey with the system.
    ///
    /// - Throws: ``GlobalHotKeyError/alreadyRegistered`` if already registered,
    ///   or ``GlobalHotKeyError/registrationFailed(_:)`` if Carbon returns an error.
    public func register() throws {
        guard hotKeyRef == nil else {
            throw GlobalHotKeyError.alreadyRegistered
        }

        HotKeyManager.shared.installEventHandlerIfNeeded()

        var eventHotKeyID = EventHotKeyID(
            signature: Self.signature,
            id: id
        )

        let carbonModifiers = modifiers.toCarbonModifiers()

        let status = RegisterEventHotKey(
            keyCode.rawValue,
            carbonModifiers,
            eventHotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        guard status == noErr else {
            throw GlobalHotKeyError.registrationFailed(status)
        }

        HotKeyManager.shared.handlerMap[id] = handler
    }

    /// Unregisters the hotkey from the system.
    ///
    /// Safe to call even if the hotkey is not currently registered.
    public func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        HotKeyManager.shared.handlerMap.removeValue(forKey: id)
    }
}
