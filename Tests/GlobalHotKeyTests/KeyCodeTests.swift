import XCTest
@testable import GlobalHotKey

final class KeyCodeTests: XCTestCase {
    // MARK: - Raw values match Carbon kVK_* constants

    func testLetterKeyRawValues() {
        XCTAssertEqual(KeyCode.a.rawValue, 0)
        XCTAssertEqual(KeyCode.s.rawValue, 1)
        XCTAssertEqual(KeyCode.d.rawValue, 2)
        XCTAssertEqual(KeyCode.z.rawValue, 6)
        XCTAssertEqual(KeyCode.q.rawValue, 12)
        XCTAssertEqual(KeyCode.w.rawValue, 13)
    }

    func testSpecialKeyRawValues() {
        XCTAssertEqual(KeyCode.returnKey.rawValue, 36)
        XCTAssertEqual(KeyCode.tab.rawValue, 48)
        XCTAssertEqual(KeyCode.space.rawValue, 49)
        XCTAssertEqual(KeyCode.escape.rawValue, 53)
    }

    func testFunctionKeyRawValues() {
        XCTAssertEqual(KeyCode.f1.rawValue, 122)
        XCTAssertEqual(KeyCode.f2.rawValue, 120)
        XCTAssertEqual(KeyCode.f5.rawValue, 96)
        XCTAssertEqual(KeyCode.f12.rawValue, 111)
    }

    // MARK: - CaseIterable

    func testAllCasesContainsExpectedCount() {
        // 26 letters + 4 special + 12 function = 42
        XCTAssertEqual(KeyCode.allCases.count, 42)
    }

    func testAllCasesHaveUniqueRawValues() {
        let rawValues = KeyCode.allCases.map(\.rawValue)
        XCTAssertEqual(Set(rawValues).count, rawValues.count, "Duplicate raw values found")
    }

    // MARK: - Modifier flags → Carbon conversion

    func testCommandModifier() {
        let flags: HotKeyModifiers = .command
        let carbon = flags.toCarbonModifiers()
        // cmdKey = 256 = 0x100
        XCTAssertEqual(carbon & 0x100, 0x100)
    }

    func testOptionModifier() {
        let flags: HotKeyModifiers = .option
        let carbon = flags.toCarbonModifiers()
        // optionKey = 2048 = 0x800
        XCTAssertEqual(carbon & 0x800, 0x800)
    }

    func testCombinedModifiers() {
        let flags: HotKeyModifiers = [.command, .shift]
        let carbon = flags.toCarbonModifiers()
        XCTAssertEqual(carbon & 0x100, 0x100)   // cmdKey
        XCTAssertEqual(carbon & 0x200, 0x200)    // shiftKey
    }

    func testEmptyModifiers() {
        let flags: HotKeyModifiers = []
        XCTAssertEqual(flags.toCarbonModifiers(), 0)
    }

    // MARK: - GlobalHotKey init

    func testGlobalHotKeyInitialState() {
        let hotKey = GlobalHotKey(
            keyCode: .space,
            modifiers: [.command, .option],
            handler: {}
        )
        XCTAssertEqual(hotKey.keyCode, .space)
        XCTAssertTrue(hotKey.modifiers.contains(.command))
        XCTAssertTrue(hotKey.modifiers.contains(.option))
        XCTAssertFalse(hotKey.isRegistered)
    }

    // MARK: - Error descriptions

    func testRegistrationFailedErrorDescription() {
        let error = GlobalHotKeyError.registrationFailed(-1)
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("-1"))
    }

    func testAlreadyRegisteredErrorDescription() {
        let error = GlobalHotKeyError.alreadyRegistered
        XCTAssertNotNil(error.errorDescription)
    }
}
