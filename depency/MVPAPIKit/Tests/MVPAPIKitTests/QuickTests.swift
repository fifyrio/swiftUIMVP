import XCTest
@testable import MVPAPIKit

final class QuickTests: XCTestCase {
    
    func testBasicMockServices() {
        let mockChatService = MockChatService()
        let mockSpeechService = MockSpeechService()
        let mockHomeService = MockHomeService()
        
        XCTAssertEqual(mockChatService.historyList.count, 0)
        
        mockChatService.addToHistory(Message(role: "user", content: "test"))
        XCTAssertEqual(mockChatService.historyList.count, 1)
        
        mockChatService.clearHistory()
        XCTAssertEqual(mockChatService.historyList.count, 0)
    }
    
    func testServiceFactory() {
        let chatService = ServiceFactory.createMockChatService()
        let speechService = ServiceFactory.createMockSpeechService()
        let homeService = ServiceFactory.createMockHomeService()
        
        XCTAssertNotNil(chatService)
        XCTAssertNotNil(speechService) 
        XCTAssertNotNil(homeService)
        
        XCTAssertTrue(chatService is MockChatService)
        XCTAssertTrue(speechService is MockSpeechService)
        XCTAssertTrue(homeService is MockHomeService)
    }
    
    func testMVPAPIClientCreation() {
        let mockClient = MVPAPIClient.createMockClient()
        XCTAssertNotNil(mockClient)
        XCTAssertEqual(mockClient.messageHistory.count, 0)
    }
}