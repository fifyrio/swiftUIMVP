import Foundation

public protocol NetworkServiceProtocol: Sendable {
    func performRequest(_ request: URLRequest) async throws -> Data
    func performStreamRequest(
        _ request: URLRequest,
        onData: @escaping @Sendable (Data) -> Void,
        onComplete: @escaping @Sendable (Result<Void, Error>) -> Void
    ) async
}