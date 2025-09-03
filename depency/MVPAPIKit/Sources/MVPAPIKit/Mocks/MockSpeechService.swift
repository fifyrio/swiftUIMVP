import Foundation

public final class MockSpeechService: SpeechServiceProtocol {
    private let mockAudioData: Data
    private let mockDelay: TimeInterval
    private let shouldSimulateError: Bool
    
    public init(
        mockAudioData: Data? = nil,
        mockDelay: TimeInterval = 0.5,
        shouldSimulateError: Bool = false
    ) {
        self.mockAudioData = mockAudioData ?? Self.generateMockAudioData()
        self.mockDelay = mockDelay
        self.shouldSimulateError = shouldSimulateError
    }
    
    public func textToSpeech(text: String, roleId: String) async throws -> URL? {
        try? await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
        
        if shouldSimulateError {
            throw MockError.simulatedError
        }
        
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let mockFilename = "mock_speech_\(UUID().uuidString).mp3"
        let fileURL = tempDirectoryURL.appendingPathComponent(mockFilename)
        
        try mockAudioData.write(to: fileURL)
        return fileURL
    }
    
    private static func generateMockAudioData() -> Data {
        let mockWaveform = Array(0..<1000).map { _ in UInt8.random(in: 0...255) }
        return Data(mockWaveform)
    }
}