import Foundation

public final class DefaultHomeService: HomeServiceProtocol {
    private let configuration: ConfigurationProtocol
    private let networkService: NetworkServiceProtocol
    private let urlBuilder: URLRequestBuilderProtocol
    
    public init(
        configuration: ConfigurationProtocol,
        networkService: NetworkServiceProtocol,
        urlBuilder: URLRequestBuilderProtocol
    ) {
        self.configuration = configuration
        self.networkService = networkService
        self.urlBuilder = urlBuilder
    }
    
    public func fetchHomeData(locale: String) async throws -> Data {
        let request = urlBuilder.buildHomeRequest(locale: locale)
        return try await networkService.performRequest(request)
    }
}