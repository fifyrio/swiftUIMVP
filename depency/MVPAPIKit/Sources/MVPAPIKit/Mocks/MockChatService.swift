import Foundation

public final class MockChatService: ChatServiceProtocol {
    public private(set) var historyList: [Message] = []
    
    private let mockResponses: [String]
    private var responseIndex = 0
    private let mockDelay: TimeInterval
    private let shouldSimulateError: Bool
    private let lock = NSLock()
    
    public init(
        mockResponses: [String] = ["Hello! This is a mock response.", "I'm a mock AI assistant."],
        mockDelay: TimeInterval = 0.1,
        shouldSimulateError: Bool = false
    ) {
        self.mockResponses = mockResponses
        self.mockDelay = mockDelay
        self.shouldSimulateError = shouldSimulateError
    }
    
    public func sendMessage(
        _ message: Message,
        model: String,
        temperature: Double,
        completion: @escaping @Sendable (Result<WWChatGPTAPIResponse, Error>) -> Void
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
            
            if shouldSimulateError {
                completion(.failure(MockError.simulatedError))
                return
            }
            
            addToHistory(message)
            
            let mockContent = getNextMockResponse()
            let mockResponse = WWChatGPTAPIResponse(
                code: 200,
                msg: "success",
                data: WWChatGPTAPIResponse.ResponseData(
                    role: "assistant",
                    content: mockContent,
                    type: 0
                )
            )
            
            let assistantMessage = Message(role: "assistant", content: mockContent)
            addToHistory(assistantMessage)
            
            completion(.success(mockResponse))
        }
    }
    
    public func sendStreamMessage(
        _ message: Message,
        model: String,
        temperature: Double,
        completion: @escaping @Sendable (Result<Message, Error>) -> Void
    ) async throws {
        if shouldSimulateError {
            throw MockError.simulatedError
        }
        
        addToHistory(message)
        
        let mockContent = getNextMockResponse()
        let words = mockContent.components(separatedBy: " ")
        
        for word in words {
            try? await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
            let partialMessage = Message(role: "assistant", content: word + " ")
            completion(.success(partialMessage))
        }
        
        let finalMessage = Message(role: "assistant", content: mockContent)
        addToHistory(finalMessage)
    }
    
    public func generateImage(
        prompt: String,
        locale: String,
        completion: @escaping @Sendable (Result<String, Error>) -> Void
    ) async throws {
        try? await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
        
        if shouldSimulateError {
            completion(.failure(MockError.simulatedError))
            return
        }
        
        let mockImageUrl = "https://mock-image-url.com/generated-image-\(UUID().uuidString).jpg"
        completion(.success(mockImageUrl))
    }
    
    public func addToHistory(_ message: Message) {
        lock.withLock {
            historyList.append(message)
        }
    }
    
    public func clearHistory() {
        lock.withLock {
            historyList.removeAll()
        }
    }
    
    private func getNextMockResponse() -> String {
        lock.withLock {
            let response = mockResponses[responseIndex % mockResponses.count]
            responseIndex += 1
            return response
        }
    }
}

public enum MockError: Error, LocalizedError {
    case simulatedError
    
    public var errorDescription: String? {
        switch self {
        case .simulatedError:
            return "Simulated error for testing"
        }
    }
}