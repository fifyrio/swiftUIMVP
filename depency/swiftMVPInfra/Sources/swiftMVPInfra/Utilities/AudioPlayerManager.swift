import Foundation
import AVFoundation
import Combine

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var progress: Double = 0
    
    private var audioPlayer: AVAudioPlayer?
    private var avPlayer: AVPlayer?
    private var timeObserver: Any?
    private var timer: Timer?
    private var isRemoteURL = false
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func loadAudio(from url: URL) {
        // Clean up previous player
        cleanupPlayers()
        
        // Check if URL is HTTPS
        if url.absoluteString.hasPrefix("https") {
            loadRemoteAudio(from: url)
        } else {
            loadLocalAudio(from: url)
        }
    }
    
    private func loadLocalAudio(from url: URL) {
        do {
            isRemoteURL = false
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            duration = audioPlayer?.duration ?? 0
            currentTime = 0
            progress = 0
            
            print("Local audio loaded successfully. Duration: \(duration) seconds")
        } catch {
            print("Error loading local audio: \(error)")
        }
    }
    
    private func loadRemoteAudio(from url: URL) {
        isRemoteURL = true
        
        // Create player item with better configuration
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        // Configure player with automatic waiting behavior
        avPlayer = AVPlayer(playerItem: playerItem)
        avPlayer?.automaticallyWaitsToMinimizeStalling = true
        
        // Observe player item status
        playerItem.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        
        // Add time observer for progress updates
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.1, preferredTimescale: timeScale)
        
        timeObserver = avPlayer?.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            self?.updateTimeForAVPlayer(time)
        }
        
        // Observe playback events
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidStall),
            name: .AVPlayerItemPlaybackStalled,
            object: playerItem
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemFailed),
            name: .AVPlayerItemFailedToPlayToEndTime,
            object: playerItem
        )
        
        print("Remote audio loading started for URL: \(url)")
    }
    
    func play() {
        if isRemoteURL {
            avPlayer?.play()
        } else {
            audioPlayer?.play()
            startTimer()
        }
        isPlaying = true
        print("Audio playback started")
    }
    
    func pause() {
        if isRemoteURL {
            avPlayer?.pause()
        } else {
            audioPlayer?.pause()
            stopTimer()
        }
        isPlaying = false
        print("Audio playback paused")
    }
    
    func stop() {
        if isRemoteURL {
            avPlayer?.pause()
            avPlayer?.seek(to: CMTime.zero)
        } else {
            audioPlayer?.stop()
            audioPlayer?.currentTime = 0
            stopTimer()
        }
        isPlaying = false
        currentTime = 0
        progress = 0
        print("Audio playback stopped")
    }
    
    func seek(to time: TimeInterval) {
        if isRemoteURL {
            let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            avPlayer?.seek(to: cmTime)
        } else {
            audioPlayer?.currentTime = time
        }
        currentTime = time
        updateProgress()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTime() {
        guard let player = audioPlayer else { return }
        currentTime = player.currentTime
        updateProgress()
    }
    
    private func updateTimeForAVPlayer(_ time: CMTime) {
        let timeSeconds = CMTimeGetSeconds(time)
        if !timeSeconds.isNaN && timeSeconds.isFinite {
            currentTime = timeSeconds
            updateProgress()
        }
    }
    
    private func updateProgress() {
        if duration > 0 {
            progress = currentTime / duration
        }
    }
    
    private func cleanupPlayers() {
        // Clean up AVAudioPlayer
        audioPlayer?.stop()
        audioPlayer = nil
        
        // Clean up AVPlayer
        if let observer = timeObserver {
            avPlayer?.removeTimeObserver(observer)
            timeObserver = nil
        }
        avPlayer?.pause()
        avPlayer = nil
        
        // Clean up notifications
        NotificationCenter.default.removeObserver(self)
        
        // Stop timer
        stopTimer()
        
        // Reset state
        isPlaying = false
        currentTime = 0
        duration = 0
        progress = 0
        isRemoteURL = false
    }
    
    @objc private func playerDidFinishPlaying() {
        isPlaying = false
        currentTime = 0
        progress = 0
        print("Remote audio playback finished")
    }
    
    @objc private func playerDidStall() {
        print("Remote audio playback stalled - buffering...")
    }
    
    @objc private func playerItemFailed(_ notification: Notification) {
        if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
            print("Remote audio playback failed: \(error.localizedDescription)")
        }
        isPlaying = false
    }
    
    // MARK: - KVO for AVPlayer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let playerItem = object as? AVPlayerItem {
                switch keyPath {
                case "status":
                    switch playerItem.status {
                    case .readyToPlay:
                        let durationSeconds = CMTimeGetSeconds(playerItem.duration)
                        if !durationSeconds.isNaN && durationSeconds.isFinite {
                            self.duration = durationSeconds
                            print("✅ Remote audio loaded successfully. Duration: \(self.duration) seconds")
                        } else {
                            print("⚠️ Remote audio loaded but duration is invalid")
                        }
                    case .failed:
                        let errorMsg = playerItem.error?.localizedDescription ?? "Unknown error"
                        print("❌ Error loading remote audio: \(errorMsg)")
                        if let error = playerItem.error {
                            print("   Error details: \(error)")
                        }
                    case .unknown:
                        print("📡 Remote audio status unknown")
                    @unknown default:
                        print("📡 Remote audio status: unknown case")
                    }
                    
                case "loadedTimeRanges":
                    if let timeRange = playerItem.loadedTimeRanges.first?.timeRangeValue {
                        let loadedDuration = CMTimeGetSeconds(timeRange.duration)
                        print("📊 Buffered: \(loadedDuration) seconds")
                    }
                    
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentTime = 0
        progress = 0
        stopTimer()
        print("Audio playback finished")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio player decode error: \(error)")
        }
        isPlaying = false
        stopTimer()
    }
    
    deinit {
        cleanupPlayers()
    }
}