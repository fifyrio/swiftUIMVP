import Foundation
import GPTEncoder

public final class DefaultChatService: ChatServiceProtocol {
    private let configuration: ConfigurationProtocol
    private let networkService: NetworkServiceProtocol
    private let urlBuilder: URLRequestBuilderProtocol
    private let gptEncoder = GPTEncoder()
    private let jsonDecoder: JSONDecoder
    
    public private(set) var historyList: [Message] = []
    private let lock = NSLock()
    
    public init(
        configuration: ConfigurationProtocol,
        networkService: NetworkServiceProtocol,
        urlBuilder: URLRequestBuilderProtocol
    ) {
        self.configuration = configuration
        self.networkService = networkService
        self.urlBuilder = urlBuilder
        
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    public func sendMessage(
        _ message: Message,
        model: String = "gpt-3.5-turbo",
        temperature: Double = 0.5,
        completion: @escaping @Sendable (Result<WWChatGPTAPIResponse, Error>) -> Void
    ) {
        Task {
            do {
                addToHistory(message)
                
                let request = urlBuilder.buildChatRequest(
                    messages: historyList,
                    model: model,
                    temperature: temperature,
                    stream: false,
                    roleId: "default"
                )
                
                let data = try await networkService.performRequest(request)
                let response = try jsonDecoder.decode(WWChatGPTAPIResponse.self, from: data)
                
                let assistantMessage = Message(
                    role: response.data.role,
                    content: response.data.content,
                    type: response.data.type
                )
                addToHistory(assistantMessage)
                
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func sendStreamMessage(
        _ message: Message,
        model: String = "gpt-3.5-turbo",
        temperature: Double = 0.5,
        completion: @escaping @Sendable (Result<Message, Error>) -> Void
    ) async throws {
        addToHistory(message)
        
        let request = urlBuilder.buildChatRequest(
            messages: historyList,
            model: model,
            temperature: temperature,
            stream: true,
            roleId: "default"
        )
        
        var streamContent = ""
        
        await networkService.performStreamRequest(request) { [weak self] data in
            guard let self else { return }
            self.processStreamData(data, content: &streamContent, completion: completion)
        } onComplete: { result in
            switch result {
            case .success:
                if !streamContent.isEmpty {
                    let assistantMessage = Message(role: "assistant", content: streamContent)
                    completion(.success(assistantMessage))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func generateImage(
        prompt: String,
        locale: String,
        completion: @escaping @Sendable (Result<String, Error>) -> Void
    ) async throws {
        let request = urlBuilder.buildImageRequest(prompt: prompt, locale: locale)
        
        await networkService.performStreamRequest(request) { data in
            self.processImageStreamData(data, completion: completion)
        } onComplete: { result in
            if case .failure(let error) = result {
                completion(.failure(error))
            }
        }
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
    
    private func processStreamData(
        _ data: Data,
        content: inout String,
        completion: @escaping @Sendable (Result<Message, Error>) -> Void
    ) {
        guard let jsonString = String(data: data, encoding: .utf8) else { return }
        
        let lines = jsonString.components(separatedBy: "\n")
        for line in lines {
            if line.hasPrefix("data: ") {
                let jsonData = String(line.dropFirst(6))
                if jsonData == "[DONE]" {
                    let assistantMessage = Message(role: "assistant", content: content)
                    addToHistory(assistantMessage)
                    return
                }
                
                if let data = jsonData.data(using: .utf8) {
                    do {
                        let streamResponse = try jsonDecoder.decode(StreamCompletionResponse.self, from: data)
                        if let deltaContent = streamResponse.choices.first?.delta.content {
                            content += deltaContent
                            let partialMessage = Message(role: "assistant", content: deltaContent)
                            completion(.success(partialMessage))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    private func processImageStreamData(
        _ data: Data,
        completion: @escaping @Sendable (Result<String, Error>) -> Void
    ) {
        guard let jsonString = String(data: data, encoding: .utf8) else { return }
        
        let lines = jsonString.components(separatedBy: "\n")
        for line in lines {
            if line.hasPrefix("data: ") {
                let jsonData = String(line.dropFirst(6))
                if jsonData == "[DONE]" { return }
                
                if let data = jsonData.data(using: .utf8) {
                    do {
                        let imageResponse = try jsonDecoder.decode(GenImageStreamResponse.self, from: data)
                        if let imageUrl = imageResponse.data.image {
                            completion(.success(imageUrl))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}