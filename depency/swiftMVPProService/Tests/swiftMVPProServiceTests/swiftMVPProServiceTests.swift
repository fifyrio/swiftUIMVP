import XCTest
@testable import swiftMVPProService

final class swiftMVPProServiceTests: XCTestCase {
    func testExample() throws {
        let service = swiftMVPProService()
        XCTAssertEqual(service.text, "Hello, World!")
    }
}