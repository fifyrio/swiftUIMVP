import Foundation

public final class DefaultNetworkService: NetworkServiceProtocol {
    
    public init() {}
    
    public func performRequest(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        
        return data
    }
    
    public func performStreamRequest(
        _ request: URLRequest,
        onData: @escaping @Sendable (Data) -> Void,
        onComplete: @escaping @Sendable (Result<Void, Error>) -> Void
    ) async {
        do {
            let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                onComplete(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                onComplete(.failure(NetworkError.httpError(httpResponse.statusCode)))
                return
            }
            
            for try await line in asyncBytes.lines {
                if let data = line.data(using: .utf8) {
                    onData(data)
                }
            }
            
            onComplete(.success(()))
        } catch {
            onComplete(.failure(error))
        }
    }
}

public enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case httpError(Int)
    case noData
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response received"
        case .httpError(let code):
            return "HTTP error with status code: \(code)"
        case .noData:
            return "No data received"
        }
    }
}