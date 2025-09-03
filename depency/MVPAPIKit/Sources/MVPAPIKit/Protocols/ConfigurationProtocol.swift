import Foundation

public protocol ConfigurationProtocol: Sendable {
    var baseURL: String { get }
    var apiKey: String { get }
    var headers: [String: String] { get }
}

public protocol URLRequestBuilderProtocol: Sendable {
    func buildChatRequest(
        messages: [Message],
        model: String,
        temperature: Double,
        stream: Bool,
        roleId: String
    ) -> URLRequest
    
    func buildSpeechRequest(text: String, roleId: String) -> URLRequest
    func buildHomeRequest(locale: String) -> URLRequest
    func buildImageRequest(prompt: String, locale: String) -> URLRequest
}