import Foundation

public protocol HomeServiceProtocol: Sendable {
    func fetchHomeData(locale: String) async throws -> Data
}