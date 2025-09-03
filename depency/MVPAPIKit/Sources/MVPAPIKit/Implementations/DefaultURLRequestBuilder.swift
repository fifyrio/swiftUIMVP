import Foundation

public final class DefaultURLRequestBuilder: URLRequestBuilderProtocol {
    private let configuration: ConfigurationProtocol
    
    public init(configuration: ConfigurationProtocol) {
        self.configuration = configuration
    }
    
    public func buildChatRequest(
        messages: [Message],
        model: String,
        temperature: Double,
        stream: Bool,
        roleId: String
    ) -> URLRequest {
        let url = URL(string: configuration.baseURL + "/role/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        configuration.headers.forEach { 
            request.setValue($1, forHTTPHeaderField: $0) 
        }
        
        let requestBody = Request(
            roleId: roleId,
            model: model,
            temperature: temperature,
            messages: messages,
            stream: stream
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            print("Failed to encode request: \(error)")
        }
        
        return request
    }
    
    public func buildSpeechRequest(text: String, roleId: String) -> URLRequest {
        let url = URL(string: configuration.baseURL + "/role/textToSpeech")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        configuration.headers.forEach { 
            request.setValue($1, forHTTPHeaderField: $0) 
        }
        
        let body: [String: String] = ["text": text, "roleId": roleId]
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            print("Failed to encode request: \(error)")
        }
        
        return request
    }
    
    public func buildHomeRequest(locale: String) -> URLRequest {
        let url = URL(string: configuration.baseURL + "/home/rec")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        configuration.headers.forEach { 
            request.setValue($1, forHTTPHeaderField: $0) 
        }
        
        let body: [String: String] = ["local": locale]
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            print("Failed to encode request: \(error)")
        }
        
        return request
    }
    
    public func buildImageRequest(prompt: String, locale: String) -> URLRequest {
        let url = URL(string: configuration.baseURL + "/role/genImage")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        configuration.headers.forEach { 
            request.setValue($1, forHTTPHeaderField: $0) 
        }
        
        let requestBody = GenImageRequest(locale: locale, prompt: prompt)
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            print("Failed to encode request: \(error)")
        }
        
        return request
    }
}