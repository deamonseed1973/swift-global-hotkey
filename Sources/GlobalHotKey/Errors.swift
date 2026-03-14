import Foundation

/// Errors that can occur during global hotkey registration and management.
public enum GlobalHotKeyError: LocalizedError {
    /// The hotkey could not be registered with the system.
    /// The associated value is the Carbon `OSStatus` code.
    case registrationFailed(OSStatus)

    /// The hotkey is already registered.
    case alreadyRegistered

    public var errorDescription: String? {
        switch self {
        case .registrationFailed(let status):
            return "Failed to register hotkey (OSStatus \(status))"
        case .alreadyRegistered:
            return "Hotkey is already registered"
        }
    }
}
