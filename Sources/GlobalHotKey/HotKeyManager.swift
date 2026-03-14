import Carbon
import Foundation

/// Manages the Carbon event handler that dispatches global hotkey events.
///
/// This is an internal singleton — consumers interact with ``GlobalHotKey``
/// directly, which delegates to this manager for handler installation and
/// dispatch.
internal final class HotKeyManager {
    static let shared = HotKeyManager()

    /// Maps hotkey IDs to their handler closures.
    var handlerMap: [UInt32: () -> Void] = [:]

    /// Reference to the installed Carbon event handler.
    private var eventHandlerRef: EventHandlerRef?

    private init() {}

    /// Installs the Carbon event handler if it hasn't been installed yet.
    func installEventHandlerIfNeeded() {
        guard eventHandlerRef == nil else { return }

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_: EventHandlerCallRef?, event: EventRef?, _: UnsafeMutableRawPointer?) -> OSStatus in
                var hotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                guard status == noErr else { return status }
                HotKeyManager.shared.handlerMap[hotKeyID.id]?()
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )
    }
}
