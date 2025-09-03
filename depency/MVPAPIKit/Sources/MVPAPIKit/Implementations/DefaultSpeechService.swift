import Foundation

public final class DefaultSpeechService: SpeechServiceProtocol {
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
    
    public func textToSpeech(text: String, roleId: String) async throws -> URL? {
        let request = urlBuilder.buildSpeechRequest(text: text, roleId: roleId)
        
        do {
            let data = try await networkService.performRequest(request)
            return try saveDataToTempFile(data: data)
        } catch {
            print("Speech API error: \(error)")
            return nil
        }
    }
    
    private func saveDataToTempFile(data: Data) throws -> URL {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let randomFilename = "\(UUID().uuidString).mp3"
        let fileURL = tempDirectoryURL.appendingPathComponent(randomFilename)
        try data.write(to: fileURL)
        return fileURL
    }
}