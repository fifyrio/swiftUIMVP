import Foundation
import Moya

public enum MVPAPITarget {
    case chat(request: Request)
    case chatStream(request: Request)
    case textToSpeech(text: String, roleId: String)
    case homeRecommendations(locale: String)
    case generateImage(prompt: String, locale: String)
}

extension MVPAPITarget: TargetType {
    public var baseURL: URL {
        guard let config = ServiceContainer.shared.resolve(ConfigurationProtocol.self) else {
            fatalError("Configuration not registered")
        }
        return URL(string: config.baseURL)!
    }
    
    public var path: String {
        switch self {
        case .chat, .chatStream:
            return "/role/chat"
        case .textToSpeech:
            return "/role/textToSpeech"
        case .homeRecommendations:
            return "/home/rec"
        case .generateImage:
            return "/role/genImage"
        }
    }
    
    public var method: Moya.Method {
        return .post
    }
    
    public var task: Moya.Task {
        switch self {
        case .chat(let request):
            return .requestJSONEncodable(request)
        case .chatStream(let request):
            return .requestJSONEncodable(request)
        case .textToSpeech(let text, let roleId):
            let parameters = ["text": text, "roleId": roleId]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .homeRecommendations(let locale):
            let parameters = ["local": locale]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .generateImage(let prompt, let locale):
            let request = GenImageRequest(locale: locale, prompt: prompt)
            return .requestJSONEncodable(request)
        }
    }
    
    public var headers: [String: String]? {
        guard let config = ServiceContainer.shared.resolve(ConfigurationProtocol.self) else {
            return ["Content-Type": "application/json"]
        }
        return config.headers
    }
}