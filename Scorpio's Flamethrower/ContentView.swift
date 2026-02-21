import SwiftUI

struct ContentView: View {
    // 1. Link to the shared manager
    @StateObject var manager = FlamethrowerManager.shared
    
    // 2. These local states handle the UI inputs before "Ignite" is pressed
    @State private var urlInput: String = "https://cia.gov"
    @State private var selectedDuration: Int = 60
    
    let durations = [15, 30, 60, 120, 240, 600, 720, 1440]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Configuration")) {
                    TextField("Target URL", text: $urlInput) // Using local @State
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Picker("Duration", selection: $selectedDuration) {
                        ForEach(durations, id: \.self) { min in
                            Text(min >= 60 ? "\(min/60) Hours" : "\(min) Minutes").tag(min)
                        }
                    }
                }

                Section(header: Text("Telemetry")) {
                    TelemetryRow(label: "Throughput", value: "\(String(format: "%.2f", manager.currentThroughputMbps)) Mbps", color: .orange)
                    TelemetryRow(label: "Total Burned", value: "\(String(format: "%.4f", manager.totalDataBurnedGB)) GB", color: .red)
                    TelemetryRow(label: "Remaining", value: manager.timeRemaining, color: .primary)
                }

                Button(action: {
                    if manager.isRunning {
                        manager.extinguish()
                    } else if let url = URL(string: urlInput) {
                        manager.ignite(url: url, durationMinutes: selectedDuration)
                    }
                }) {
                    Text(manager.isRunning ? "EXTINGUISH" : "IGNITE")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(manager.isRunning ? Color.red : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Scorpio's Flamethrower")
        }
    }
}

// Helper view to keep code clean
struct TelemetryRow: View {
    let label: String
    let value: String
    let color: Color
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundColor(color).bold().monospacedDigit()
        }
    }
}