import XCTest
@testable import MVPAPIKit

final class MVPAPIClientTests: XCTestCase {
    
    func testMockClientBasicUsage() async throws {
        let client = MVPAPIClient.createMockClient(
            responses: ["Hello! I'm your AI assistant.", "I can help you with various tasks."],
            delay: 0.01
        )
        
        let response1 = try await client.sendMessage("Hello")
        XCTAssertEqual(response1, "Hello! I'm your AI assistant.")
        XCTAssertEqual(client.messageHistory.count, 2)
        
        let response2 = try await client.sendMessage("Can you help me?")
        XCTAssertEqual(response2, "I can help you with various tasks.")
        XCTAssertEqual(client.messageHistory.count, 4)
        
        client.clearHistory()
        XCTAssertEqual(client.messageHistory.count, 0)
    }
    
    func testMockClientStreamMessage() async throws {
        let client = MVPAPIClient.createMockClient(
            responses: ["Streaming response test"],
            delay: 0.01
        )
        
        var fullResponse = ""
        let stream = client.sendStreamMessage("Test streaming")
        
        for try await chunk in stream {
            fullResponse += chunk
        }
        
        XCTAssertTrue(fullResponse.contains("Streaming"))
        XCTAssertTrue(fullResponse.contains("response"))
        XCTAssertTrue(fullResponse.contains("test"))
    }
    
    func testMockClientSpeechGeneration() async throws {
        let client = MVPAPIClient.createMockClient(delay: 0.01)
        
        let audioUrl = try await client.textToSpeech(text: "Hello world")
        XCTAssertNotNil(audioUrl)
        XCTAssertTrue(audioUrl!.lastPathComponent.contains("mock_speech_"))
        
        try? FileManager.default.removeItem(at: audioUrl!)
    }
    
    func testMockClientImageGeneration() async throws {
        let client = MVPAPIClient.createMockClient(delay: 0.01)
        
        let imageUrl = try await client.generateImage(prompt: "A beautiful landscape")
        XCTAssertTrue(imageUrl.contains("mock-image-url.com"))
        XCTAssertTrue(imageUrl.contains(".jpg"))
    }
    
    func testMockClientHomeRecommendations() async throws {
        let client = MVPAPIClient.createMockClient(delay: 0.01)
        
        let homeData = try await client.fetchHomeRecommendations()
        XCTAssertFalse(homeData.isEmpty)
        
        let json = try JSONSerialization.jsonObject(with: homeData) as? [String: Any]
        XCTAssertNotNil(json?["recommendations"])
        XCTAssertNotNil(json?["featured"])
    }
}