import XCTest
@testable import MVPAPIKit

final class ChatServiceTests: XCTestCase {
    
    func testMockChatServiceSendMessage() async throws {
        let mockResponses = ["Hello from mock!", "How can I help?"]
        let chatService = ServiceFactory.createMockChatService(
            responses: mockResponses,
            delay: 0.01
        )
        
        let userMessage = Message(role: "user", content: "Hello")
        
        let result = try await withCheckedThrowingContinuation { continuation in
            chatService.sendMessage(
                userMessage,
                model: "gpt-3.5-turbo",
                temperature: 0.5
            ) { result in
                continuation.resume(with: result)
            }
        }
        
        XCTAssertEqual(result.code, 200)
        XCTAssertEqual(result.data.content, "Hello from mock!")
        XCTAssertEqual(chatService.historyList.count, 2)
        XCTAssertEqual(chatService.historyList[0].content, "Hello")
        XCTAssertEqual(chatService.historyList[1].content, "Hello from mock!")
    }
    
    func testMockChatServiceStreamMessage() async throws {
        let chatService = ServiceFactory.createMockChatService(
            responses: ["Hello world"],
            delay: 0.01
        )
        
        let userMessage = Message(role: "user", content: "Hello")
        var receivedParts: [String] = []
        
        try await chatService.sendStreamMessage(
            userMessage,
            model: "gpt-3.5-turbo",
            temperature: 0.5
        ) { result in
            switch result {
            case .success(let message):
                receivedParts.append(message.content)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        XCTAssertTrue(receivedParts.count > 0)
        XCTAssertTrue(receivedParts.joined().contains("Hello"))
        XCTAssertEqual(chatService.historyList.count, 2)
    }
    
    func testMockChatServiceErrorHandling() async throws {
        let chatService = ServiceFactory.createMockChatService(shouldError: true)
        let userMessage = Message(role: "user", content: "Hello")
        
        do {
            let _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<WWChatGPTAPIResponse, Error>) in
                chatService.sendMessage(
                    userMessage,
                    model: "gpt-3.5-turbo",
                    temperature: 0.5
                ) { result in
                    continuation.resume(with: result)
                }
            }
            XCTFail("Expected error but got success")
        } catch {
            XCTAssertTrue(error is MockError)
        }
    }
    
    func testChatServiceHistoryManagement() {
        let chatService = ServiceFactory.createMockChatService()
        
        XCTAssertEqual(chatService.historyList.count, 0)
        
        let message1 = Message(role: "user", content: "Hello")
        let message2 = Message(role: "assistant", content: "Hi!")
        
        chatService.addToHistory(message1)
        chatService.addToHistory(message2)
        
        XCTAssertEqual(chatService.historyList.count, 2)
        XCTAssertEqual(chatService.historyList[0].content, "Hello")
        XCTAssertEqual(chatService.historyList[1].content, "Hi!")
        
        chatService.clearHistory()
        XCTAssertEqual(chatService.historyList.count, 0)
    }
    
    func testImageGeneration() async throws {
        let chatService = ServiceFactory.createMockChatService()
        
        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            Task {
                try await chatService.generateImage(
                    prompt: "A beautiful sunset",
                    locale: "en"
                ) { result in
                    continuation.resume(with: result)
                }
            }
        }
        
        XCTAssertTrue(result.contains("mock-image-url.com"))
        XCTAssertTrue(result.contains(".jpg"))
    }
}