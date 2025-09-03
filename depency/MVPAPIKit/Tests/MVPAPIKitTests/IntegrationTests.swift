import XCTest
@testable import MVPAPIKit

final class IntegrationTests: XCTestCase {
    
    func testEndToEndChatFlow() async throws {
        let chatService = ServiceFactory.createMockChatService(
            responses: ["Hello!", "How can I help you today?"],
            delay: 0.01
        )
        
        let message1 = Message(role: "user", content: "Hi")
        let response1 = try await withCheckedThrowingContinuation { continuation in
            chatService.sendMessage(message1, model: "gpt-3.5-turbo", temperature: 0.7) { result in
                continuation.resume(with: result)
            }
        }
        
        XCTAssertEqual(response1.data.content, "Hello!")
        XCTAssertEqual(chatService.historyList.count, 2)
        
        let message2 = Message(role: "user", content: "Help me")
        let response2 = try await withCheckedThrowingContinuation { continuation in
            chatService.sendMessage(message2, model: "gpt-3.5-turbo", temperature: 0.7) { result in
                continuation.resume(with: result)
            }
        }
        
        XCTAssertEqual(response2.data.content, "How can I help you today?")
        XCTAssertEqual(chatService.historyList.count, 4)
    }
    
    func testServiceInjectionPattern() {
        ServiceContainer.shared.clear()
        
        let mockNetworkService = MockNetworkService(
            mockData: """
            {"code": 200, "msg": "success", "data": {"role": "assistant", "content": "Injected response", "type": 0}}
            """.data(using: .utf8)!
        )
        
        let configuration = DefaultAPIConfiguration(apiKey: "test-key")
        ServiceContainer.shared.register(ConfigurationProtocol.self, instance: configuration)
        ServiceContainer.shared.register(NetworkServiceProtocol.self, instance: mockNetworkService)
        
        let resolvedConfig: ConfigurationProtocol? = ServiceContainer.shared.resolve(ConfigurationProtocol.self)
        let resolvedNetwork: NetworkServiceProtocol? = ServiceContainer.shared.resolve(NetworkServiceProtocol.self)
        
        XCTAssertNotNil(resolvedConfig)
        XCTAssertNotNil(resolvedNetwork)
        XCTAssertTrue(resolvedNetwork is MockNetworkService)
    }
    
    func testConcurrentServiceAccess() async throws {
        let chatService = ServiceFactory.createMockChatService(delay: 0.05)
        
        await withTaskGroup(of: Void.self) { group in
            for i in 1...10 {
                group.addTask {
                    let message = Message(role: "user", content: "Message \(i)")
                    chatService.sendMessage(message, model: "gpt-3.5-turbo", temperature: 0.5) { _ in }
                    chatService.addToHistory(Message(role: "test", content: "Test \(i)"))
                }
            }
        }
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        XCTAssertTrue(chatService.historyList.count >= 10)
    }
}