import XCTest
@testable import swiftMVPInfra

final class SwiftMVPInfraTests: XCTestCase {
    func testHello() throws {
        let infrastructure = SwiftMVPInfra()
        XCTAssertEqual(infrastructure.hello(), "Hello, Swift MVP Infrastructure!")
    }
}