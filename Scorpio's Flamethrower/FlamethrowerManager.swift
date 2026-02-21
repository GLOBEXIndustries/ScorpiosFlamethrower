import Foundation
import AVFoundation

class FlamethrowerManager: NSObject, URLSessionDataDelegate, ObservableObject {
    static let shared = FlamethrowerManager()
    
    @Published var isRunning = false
    @Published var currentThroughputMbps: Double = 0.0
    @Published var totalDataBurnedGB: Double = 0.0
    @Published var timeRemaining: String = "00:00"
    
    private var session: URLSession!
    private var targetURL: URL?
    private var endTime: Date?
    private var audioPlayer: AVAudioPlayer?
    private var bytesReceivedThisSecond: Int64 = 0
    private var timer: Timer?

    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        // Important: background compatibility
        config.allowsCellularAccess = true
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }

    func ignite(url: URL, durationMinutes: Int) {
        self.targetURL = url
        self.endTime = Date().addingTimeInterval(TimeInterval(durationMinutes * 60))
        self.isRunning = true
        
        startAudioNuke()
        startTelemetryTimer()
        burn()
    }

    func extinguish() {
        isRunning = false
        timer?.invalidate()
        audioPlayer?.stop()
        currentThroughputMbps = 0
    }

    private func burn() {
        guard isRunning, let url = targetURL, let end = endTime, Date() < end else {
            extinguish()
            return
        }
        session.dataTask(with: url).resume()
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        bytesReceivedThisSecond += Int64(data.count)
        totalDataBurnedGB += Double(data.count) / 1_073_741_824.0
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if isRunning { burn() }
    }

    private func startTelemetryTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Calculate Mbps
            self.currentThroughputMbps = Double(self.bytesReceivedThisSecond * 8) / 1_000_000.0
            self.bytesReceivedThisSecond = 0
            
            // Update Countdown
            if let end = self.endTime {
                let remaining = end.timeIntervalSinceNow
                if remaining > 0 {
                    let mins = Int(remaining) / 60
                    let secs = Int(remaining) % 60
                    self.timeRemaining = String(format: "%02d:%02d", mins, secs)
                } else {
                    self.extinguish()
                }
            }
        }
    }
    
    private func startAudioNuke() { /* Your existing audio code is fine */ }
}