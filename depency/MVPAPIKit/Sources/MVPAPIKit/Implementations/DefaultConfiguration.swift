import Foundation

public final class DefaultAPIConfiguration: ConfigurationProtocol {
    public let baseURL: String
    public let apiKey: String
    
    public var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
    
    public init(
        baseURL: String = "https://us-central1-emma-ai-2e0d5.cloudfunctions.net/aiRolePlayApi",
        apiKey: String
    ) {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
}