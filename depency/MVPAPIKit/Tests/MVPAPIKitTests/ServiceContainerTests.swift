import XCTest
@testable import MVPAPIKit

final class ServiceContainerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        ServiceContainer.shared.clear()
    }
    
    func testServiceRegistrationAndResolution() {
        let container = ServiceContainer.shared
        
        let mockService = MockChatService()
        container.register(ChatServiceProtocol.self, instance: mockService)
        
        let resolvedService: ChatServiceProtocol? = container.resolve(ChatServiceProtocol.self)
        XCTAssertNotNil(resolvedService)
        XCTAssertTrue(resolvedService is MockChatService)
    }
    
    func testServiceFactoryRegistration() {
        let container = ServiceContainer.shared
        container.register(ChatServiceProtocol.self) {
            MockChatService(mockResponses: ["Test response"])
        }
        
        let service: ChatServiceProtocol? = container.resolve(ChatServiceProtocol.self)
        XCTAssertNotNil(service)
    }
    
    func testDefaultServicesRegistration() {
        ServiceContainer.registerDefaultServices(apiKey: "test-key")
        
        let chatService: ChatServiceProtocol = ServiceContainer.shared.requireService(ChatServiceProtocol.self)
        let speechService: SpeechServiceProtocol = ServiceContainer.shared.requireService(SpeechServiceProtocol.self)
        let homeService: HomeServiceProtocol = ServiceContainer.shared.requireService(HomeServiceProtocol.self)
        
        XCTAssertNotNil(chatService)
        XCTAssertNotNil(speechService)
        XCTAssertNotNil(homeService)
        
        XCTAssertTrue(chatService is DefaultChatService)
        XCTAssertTrue(speechService is DefaultSpeechService)
        XCTAssertTrue(homeService is DefaultHomeService)
    }
    
    func testServiceFactoryMockCreation() {
        let chatService = ServiceFactory.createMockChatService(
            responses: ["Mock 1", "Mock 2"],
            delay: 0.01
        )
        
        XCTAssertTrue(chatService is MockChatService)
        XCTAssertEqual(chatService.historyList.count, 0)
    }
}