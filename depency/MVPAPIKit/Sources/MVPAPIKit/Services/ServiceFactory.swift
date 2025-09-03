import Foundation

public final class ServiceFactory {
    public static func createChatService(apiKey: String) -> ChatServiceProtocol {
        ServiceContainer.registerDefaultServices(apiKey: apiKey)
        return ServiceContainer.shared.requireService(ChatServiceProtocol.self)
    }
    
    public static func createSpeechService(apiKey: String) -> SpeechServiceProtocol {
        ServiceContainer.registerDefaultServices(apiKey: apiKey)
        return ServiceContainer.shared.requireService(SpeechServiceProtocol.self)
    }
    
    public static func createHomeService(apiKey: String) -> HomeServiceProtocol {
        ServiceContainer.registerDefaultServices(apiKey: apiKey)
        return ServiceContainer.shared.requireService(HomeServiceProtocol.self)
    }
    
    public static func createMockChatService(
        responses: [String] = ["Mock response 1", "Mock response 2"],
        delay: TimeInterval = 0.1,
        shouldError: Bool = false
    ) -> ChatServiceProtocol {
        return MockChatService(
            mockResponses: responses,
            mockDelay: delay,
            shouldSimulateError: shouldError
        )
    }
    
    public static func createMockSpeechService(
        delay: TimeInterval = 0.5,
        shouldError: Bool = false
    ) -> SpeechServiceProtocol {
        return MockSpeechService(
            mockDelay: delay,
            shouldSimulateError: shouldError
        )
    }
    
    public static func createMockHomeService(
        delay: TimeInterval = 0.3,
        shouldError: Bool = false
    ) -> HomeServiceProtocol {
        return MockHomeService(
            mockDelay: delay,
            shouldSimulateError: shouldError
        )
    }
}