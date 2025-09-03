import Foundation

public final class MockNetworkService: NetworkServiceProtocol {
    private let mockData: Data
    private let mockDelay: TimeInterval
    private let shouldSimulateError: Bool
    private let mockStatusCode: Int
    
    public init(
        mockData: Data? = nil,
        mockDelay: TimeInterval = 0.2,
        shouldSimulateError: Bool = false,
        mockStatusCode: Int = 200
    ) {
        self.mockData = mockData ?? "Mock response data".data(using: .utf8)!
        self.mockDelay = mockDelay
        self.shouldSimulateError = shouldSimulateError
        self.mockStatusCode = mockStatusCode
    }
    
    public func performRequest(_ request: URLRequest) async throws -> Data {
        try? await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
        
        if shouldSimulateError {
            throw NetworkError.httpError(500)
        }
        
        if !(200...299 ~= mockStatusCode) {
            throw NetworkError.httpError(mockStatusCode)
        }
        
        return mockData
    }
    
    public func performStreamRequest(
        _ request: URLRequest,
        onData: @escaping @Sendable (Data) -> Void,
        onComplete: @escaping @Sendable (Result<Void, Error>) -> Void
    ) async {
        if shouldSimulateError {
            onComplete(.failure(NetworkError.httpError(500)))
            return
        }
        
        let mockStreamChunks = [
            "data: {\"choices\":[{\"delta\":{\"content\":\"Hello\"}}]}\n",
            "data: {\"choices\":[{\"delta\":{\"content\":\" there!\"}}]}\n",
            "data: {\"choices\":[{\"delta\":{\"content\":\" This\"}}]}\n",
            "data: {\"choices\":[{\"delta\":{\"content\":\" is\"}}]}\n",
            "data: {\"choices\":[{\"delta\":{\"content\":\" mock\"}}]}\n",
            "data: {\"choices\":[{\"delta\":{\"content\":\" streaming.\"}}]}\n",
            "data: [DONE]\n"
        ]
        
        for chunk in mockStreamChunks {
            try? await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
            if let data = chunk.data(using: .utf8) {
                onData(data)
            }
        }
        
        onComplete(.success(()))
    }
}