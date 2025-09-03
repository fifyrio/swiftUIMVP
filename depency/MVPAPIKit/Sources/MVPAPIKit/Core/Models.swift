//
//  Models.swift
//  MVPAPIKit
//
//  Created by Alfian Losari on 02/03/23.
//

import Foundation

// MARK: - API Response Models

public struct WWChatGPTAPIResponse: Codable {
    public let code: Int
    public let msg: String
    public let data: ResponseData
    
    public struct ResponseData: Codable {
        public let role: String
        public let content: String
        public let type: Int
    }
}

// MARK: - Core Message Model

public struct Message: Codable {
    public let role: String
    public let content: String
    public let type: Int
    
    public init(role: String, content: String, type: Int = 0) {
        self.role = role
        self.content = content
        self.type = type
    }
}

public extension Array where Element == Message {
    var contentCount: Int { map { $0.content }.count }
    var content: String { reduce("") { $0 + $1.content } }
}

// MARK: - Request Models

public struct Request: Codable {
    public let roleId: String
    public let model: String
    public let temperature: Double
    public let messages: [Message]
    public let stream: Bool
    
    public init(roleId: String, model: String, temperature: Double, messages: [Message], stream: Bool) {
        self.roleId = roleId
        self.model = model
        self.temperature = temperature
        self.messages = messages
        self.stream = stream
    }
}

public struct GenImageRequest: Codable {
    public let locale: String
    public let prompt: String
    
    public init(locale: String, prompt: String) {
        self.locale = locale
        self.prompt = prompt
    }
}

// MARK: - Stream Response Models

public struct StreamCompletionResponse: Decodable {
    public let choices: [StreamChoice]
}

public struct StreamChoice: Decodable {
    public let finishReason: String?
    public let delta: StreamMessage
}

public struct StreamMessage: Decodable {
    public let content: String?
    public let role: String?
    public let imageUrl: String?
}

// MARK: - Image Generation Response Models

public struct GenImageStreamResponse: Decodable {
    public let data: GenImageStreamData
}

public struct GenImageStreamData: Decodable {
    public let stage: String?
    public let image: String?
}