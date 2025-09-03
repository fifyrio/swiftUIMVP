import Foundation

public protocol ChatServiceProtocol: Sendable {
    func sendMessage(
        _ message: Message,
        model: String,
        temperature: Double,
        completion: @escaping @Sendable (Result<WWChatGPTAPIResponse, Error>) -> Void
    )
    
    func sendStreamMessage(
        _ message: Message,
        model: String,
        temperature: Double,
        completion: @escaping @Sendable (Result<Message, Error>) -> Void
    ) async throws
    
    func generateImage(
        prompt: String,
        locale: String,
        completion: @escaping @Sendable (Result<String, Error>) -> Void
    ) async throws
    
    var historyList: [Message] { get }
    func addToHistory(_ message: Message)
    func clearHistory()
}