import XCTest
@testable import MVPAPIKit

final class SpeechServiceTests: XCTestCase {
    
    func testMockSpeechServiceTextToSpeech() async throws {
        let speechService = ServiceFactory.createMockSpeechService(delay: 0.01)
        
        let audioUrl = try await speechService.textToSpeech(text: "Hello world", roleId: "test-role")
        
        XCTAssertNotNil(audioUrl)
        XCTAssertTrue(audioUrl!.lastPathComponent.contains("mock_speech_"))
        XCTAssertTrue(audioUrl!.lastPathComponent.hasSuffix(".mp3"))
        
        let fileExists = FileManager.default.fileExists(atPath: audioUrl!.path)
        XCTAssertTrue(fileExists)
        
        try? FileManager.default.removeItem(at: audioUrl!)
    }
    
    func testMockSpeechServiceErrorHandling() async throws {
        let speechService = ServiceFactory.createMockSpeechService(shouldError: true)
        
        do {
            let _ = try await speechService.textToSpeech(text: "Hello", roleId: "test")
            XCTFail("Expected error but got success")
        } catch {
            XCTAssertTrue(error is MockError)
        }
    }
}