import Foundation

public final class MockHomeService: HomeServiceProtocol {
    private let mockData: Data
    private let mockDelay: TimeInterval
    private let shouldSimulateError: Bool
    
    public init(
        mockData: Data? = nil,
        mockDelay: TimeInterval = 0.3,
        shouldSimulateError: Bool = false
    ) {
        self.mockData = mockData ?? Self.generateMockHomeData()
        self.mockDelay = mockDelay
        self.shouldSimulateError = shouldSimulateError
    }
    
    public func fetchHomeData(locale: String) async throws -> Data {
        try? await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
        
        if shouldSimulateError {
            throw MockError.simulatedError
        }
        
        return mockData
    }
    
    private static func generateMockHomeData() -> Data {
        let mockResponse = [
            "recommendations": [
                ["id": "1", "title": "Mock Recommendation 1", "category": "tech"],
                ["id": "2", "title": "Mock Recommendation 2", "category": "news"]
            ],
            "featured": [
                ["id": "f1", "title": "Featured Content", "priority": "high"]
            ]
        ]
        
        return try! JSONSerialization.data(withJSONObject: mockResponse)
    }
}