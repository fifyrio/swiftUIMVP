import Foundation

public protocol SpeechServiceProtocol: Sendable {
    func textToSpeech(text: String, roleId: String) async throws -> URL?
}