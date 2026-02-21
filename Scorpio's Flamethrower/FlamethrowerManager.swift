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
    private var bytesReceivedThisSecond: Int64 = 0
    private var timer: Timer?

    override init() {
        super.init()
        
        // Switch to .default for the App Store / "Polite" version
        let config = URLSessionConfiguration.default
        
        config.timeoutIntervalForRequest = 30 // Give it some breathing room
        config.timeoutIntervalForResource = 60
        config.httpMaximumConnectionsPerHost = 10 // Beef up the concurrent pipes
        
        // Keep these for the burn efficiency
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }
    
    
    /*
    override init() {
        super.init()
        

        let config = URLSessionConfiguration.background(withIdentifier: "com.scorpio.nettest.bg")
        
        // Correct Background Settings
        config.isDiscretionary = false // Run immediately, don't wait for Wi-Fi/Power
        config.sessionSendsLaunchEvents = true
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.waitsForConnectivity = true
        
        // Initialize session with self as delegate
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }
 
 */

    func ignite(url: URL, durationMinutes: Int) {
        
        
        DispatchQueue.main.async {
                    self.totalDataBurnedGB = 0.0
                    self.currentThroughputMbps = 0.0
                    self.isRunning = true
            self.timeRemaining = String(format: "%02d:00", durationMinutes)
                }
        
        
        
        self.targetURL = url
        self.endTime = Date().addingTimeInterval(TimeInterval(durationMinutes * 60))
        self.isRunning = true
        
        startTelemetryTimer()
        
        // Fire 4 parallel tasks to ensure high network usage
        for _ in 0..<4 {
            burn()
        }
    }

    func extinguish() {
        isRunning = false
        timer?.invalidate()
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
    
    
    /*
    
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
     */
    
    
    private func startTelemetryTimer() {
        // 1. Change interval to 2.5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // 2. Calculate Mbps based on a 2.5-second window
            // Formula: (Bytes * 8 bits) / (1,000,000 bits per Mb) / 2.5 seconds
            self.currentThroughputMbps = (Double(self.bytesReceivedThisSecond * 8) / 1_000_000.0) / 2.5
            self.bytesReceivedThisSecond = 0
            
            // 3. Update the Countdown
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
    
}

