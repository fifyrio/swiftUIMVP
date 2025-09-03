import XCTest
@testable import MVPAPIKit

final class HomeServiceTests: XCTestCase {
    
    func testMockHomeServiceFetchData() async throws {
        let homeService = ServiceFactory.createMockHomeService(delay: 0.01)
        
        let data = try await homeService.fetchHomeData(locale: "en")
        
        XCTAssertFalse(data.isEmpty)
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertNotNil(json)
        XCTAssertNotNil(json?["recommendations"])
        XCTAssertNotNil(json?["featured"])
    }
    
    func testMockHomeServiceErrorHandling() async throws {
        let homeService = ServiceFactory.createMockHomeService(shouldError: true)
        
        do {
            let _ = try await homeService.fetchHomeData(locale: "en")
            XCTFail("Expected error but got success")
        } catch {
            XCTAssertTrue(error is MockError)
        }
    }
}