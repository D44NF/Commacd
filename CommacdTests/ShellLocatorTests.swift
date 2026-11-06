import XCTest
@testable import Commacd

final class ShellLocatorTests: XCTestCase {
    func testLoginShellPathReturnsExistingExecutable() {
        let path = ShellLocator.loginShellPath()
        XCTAssertTrue(FileManager.default.isExecutableFile(atPath: path))
    }
}
