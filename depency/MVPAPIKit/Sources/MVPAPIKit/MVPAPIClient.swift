import Foundation

public final class MVPAPIClient {
    private let chatService: ChatServiceProtocol
    private let speechService: SpeechServiceProtocol
    private let homeService: HomeServiceProtocol
    
    public init(apiKey: String) {
        self.chatService = ServiceFactory.createChatService(apiKey: apiKey)
        self.speechService = ServiceFactory.createSpeechService(apiKey: apiKey)
        self.homeService = ServiceFactory.createHomeService(apiKey: apiKey)
    }
    
    public init(
        chatService: ChatServiceProtocol,
        speechService: SpeechServiceProtocol,
        homeService: HomeServiceProtocol
    ) {
        self.chatService = chatService
        self.speechService = speechService
        self.homeService = homeService
    }
    
    public var messageHistory: [Message] {
        chatService.historyList
    }
    
    public func sendMessage(
        _ content: String,
        model: String = "gpt-3.5-turbo",
        temperature: Double = 0.5
    ) async throws -> String {
        let message = Message(role: "user", content: content)
        
        return try await withCheckedThrowingContinuation { continuation in
            chatService.sendMessage(message, model: model, temperature: temperature) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response.data.content)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func sendStreamMessage(
        _ content: String,
        model: String = "gpt-3.5-turbo",
        temperature: Double = 0.5
    ) -> AsyncThrowingStream<String, Error> {
        let message = Message(role: "user", content: content)
        
        return AsyncThrowingStream { continuation in
            Task {
                try await chatService.sendStreamMessage(message, model: model, temperature: temperature) { result in
                    switch result {
                    case .success(let message):
                        continuation.yield(message.content)
                    case .failure(let error):
                        continuation.finish(throwing: error)
                    }
                }
            }
        }
    }
    
    public func generateImage(prompt: String, locale: String = "en") async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                try await chatService.generateImage(prompt: prompt, locale: locale) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }
    
    public func textToSpeech(text: String, roleId: String = "default") async throws -> URL? {
        return try await speechService.textToSpeech(text: text, roleId: roleId)
    }
    
    public func fetchHomeRecommendations(locale: String = "en") async throws -> Data {
        return try await homeService.fetchHomeData(locale: locale)
    }
    
    public func clearHistory() {
        chatService.clearHistory()
    }
}

public extension MVPAPIClient {
    static func createMockClient(
        responses: [String] = ["Hello!", "How can I help?"],
        delay: TimeInterval = 0.1
    ) -> MVPAPIClient {
        return MVPAPIClient(
            chatService: ServiceFactory.createMockChatService(responses: responses, delay: delay),
            speechService: ServiceFactory.createMockSpeechService(delay: delay),
            homeService: ServiceFactory.createMockHomeService(delay: delay)
        )
    }
}