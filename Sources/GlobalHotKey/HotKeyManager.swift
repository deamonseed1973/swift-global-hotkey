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
    /// - Throws: ``GlobalHotKeyError/eventHandlerInstallFailed(_:)`` if Carbon
    ///   returns a non-`noErr` status (e.g. application event target not ready).
    func installEventHandlerIfNeeded() throws {
        guard eventHandlerRef == nil else { return }

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (_: EventHandlerCallRef?, event: EventRef?, _: UnsafeMutableRawPointer?) -> OSStatus in
                var hotKeyID = EventHotKeyID()
                let paramStatus = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                guard paramStatus == noErr else { return paramStatus }
                HotKeyManager.shared.handlerMap[hotKeyID.id]?()
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )

        guard status == noErr else {
            throw GlobalHotKeyError.eventHandlerInstallFailed(status)
        }
    }
}
