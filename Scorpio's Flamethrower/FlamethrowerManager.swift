//import Foundation
import AVFoundation
import Combine

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
        
        // Use a background configuration to resist Jetsam
        let config = URLSessionConfiguration.background(withIdentifier: "com.scorpio.flamethrower.bg")
        
        // Correct Background Settings
        config.isDiscretionary = false // Run immediately, don't wait for Wi-Fi/Power
        config.sessionSendsLaunchEvents = true
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.waitsForConnectivity = true
        
        // Initialize session with self as delegate
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }

    func ignite(url: URL, durationMinutes: Int) {
        self.targetURL = url
        self.endTime = Date().addingTimeInterval(TimeInterval(durationMinutes * 60))
        self.isRunning = true
        
        startAudioNuke()
        startTelemetryTimer()
        
        // Fire 4 parallel tasks to ensure high network usage
        for _ in 0..<4 {
            burn()
        }
    }

    func extinguish() {
        isRunning = false
        timer?.invalidate()
        audioPlayer?.stop()
        currentThroughputMbps = 0
        
        // Cancel all pending tasks
        session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
    }

    private func burn() {
        // Use the local 'endTime' we defined in the class properties
        guard isRunning, let url = targetURL, let end = endTime, Date() < end else {
            if isRunning { extinguish() }
            return
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        // Add a unique ID to each request to prevent ISP/System caching
        request.addValue(UUID().uuidString, forHTTPHeaderField: "X-Scorpio-Burst")
        
        let task = session.dataTask(with: request)
        task.resume()
    }

    // Delegate methods for byte counting
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        bytesReceivedThisSecond += Int64(data.count)
        totalDataBurnedGB += Double(data.count) / 1_073_741_824.0
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // Immediate re-queue to keep the "Flamethrower" firing
        if isRunning {
            burn()
        }
    }

    // MARK: - Helper Methods
    
    private func startTelemetryTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
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
    
    private func startAudioNuke() {
        // This keeps the app 'Active' in the eyes of iOS to prevent suspension
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? audioSession.setActive(true)
        
        // Even a silent loop prevents the system from putting the app to sleep
        // (Assuming you have a silent.mp3 in your project bundle)
        if let bundlePath = Bundle.main.path(forResource: "silent", ofType: "mp3") {
            let url = URL(fileURLWithPath: bundlePath)
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        }
    }
}

/*

import Foundation
import AVFoundation
import Combine

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

*/
