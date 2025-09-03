import Foundation
import Moya

public final class MoyaNetworkService: NetworkServiceProtocol {
    private let provider: MoyaProvider<MVPAPITarget>
    
    public init(provider: MoyaProvider<MVPAPITarget>? = nil) {
        self.provider = provider ?? MoyaProvider<MVPAPITarget>()
    }
    
    public func performRequest(_ request: URLRequest) async throws -> Data {
        // Legacy support for URLRequest - convert to Moya target if needed
        // For now, fallback to URLSession
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

public extension MoyaNetworkService {
    func performMoyaRequest<T: Decodable>(_ target: MVPAPITarget, responseType: T.Type) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try response.map(T.self)
                        continuation.resume(returning: decodedResponse)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}