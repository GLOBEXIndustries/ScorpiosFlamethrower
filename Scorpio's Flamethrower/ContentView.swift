//
//  ContentView.swift
//  Scorpio's Flamethrower
//
//  Created by Ian McHale on 2/20/26.
//





import SwiftUI

struct ContentView: View {
    // This connects to your "Electrician's Wiring" (The Manager)
    @StateObject var manager = FlamethrowerManager.shared
    
    // These hold what the user types before hitting "IGNITE"
    @State private var urlInput: String = "https://fsn1-speed.hetzner.com/10GB.bin"
    @State private var selectedDuration: Int = 15
    
    let durations = [43200, 2, 15, 30, 60, 120, 240, 480, 720, 1440]

    var body: some View {
        NavigationView {
            Form {
                // SECTION 1: THE INPUTS (The "Light Switches")
                Section(header: Text("Configuration")) {
                    HStack {
                        Image(systemName: "globe")
                        TextField("Target URL", text: $urlInput)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    Picker("Burn Duration", selection: $selectedDuration) {
                        ForEach(durations, id: \.self) { mins in
                            if mins < 60 {
                                Text("\(mins) Minutes").tag(mins)
                            } else if mins == 60 {
                                Text("1 Hour").tag(mins)
                            } else {
                                Text("\(mins / 60) Hours").tag(mins)
                            }
                        }
                    }
                    
                    .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .principal) {
                                        VStack(spacing: 2) {
                                            // 2. Controlled title size to prevent cutoff
                                            Text("Scorpio's Flamethrower")
                                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                                .foregroundColor(.primary)
                                            
                                            // 3. Your new sub-header
                                            Text("NETWORK STRESS TEST UTILITY")
                                                .font(.system(size: 10, weight: .semibold))
                                                .foregroundColor(.orange)
                                                .tracking(2)
                                            
                                            // sub sub header
                                            Text("By GLOBEX Industries")
                                                .font(.system(size: 8, weight: .semibold))
                                                .foregroundColor(.orange)
                                                .tracking(2)
                                        }
                                    }
                                }
                    
                }

                // SECTION 2: THE DASHBOARD (The "Gauges")
                Section(header: Text("Telemetry")) {
                    HStack {
                        Text("Throughput")
                        Spacer()
                        Text("\(String(format: "%.2f", manager.currentThroughputMbps)) Mbps")
                            .foregroundColor(.orange).bold().monospacedDigit()
                    }
                    HStack {
                        Text("Total Data Burned")
                        Spacer()
                        Text("\(String(format: "%.4f", manager.totalDataBurnedGB)) GB")
                            .foregroundColor(.red).bold().monospacedDigit()
                    }
                    HStack {
                        Text("Time Remaining")
                        Spacer()
                        Text(manager.timeRemaining)
                            .monospacedDigit().bold()
                    }
                }

                // SECTION 3: THE BIG RED BUTTON
                Section {
                    Button(action: {
                        if manager.isRunning {
                            manager.extinguish()
                        } else if let url = URL(string: urlInput) {
                            manager.ignite(url: url, durationMinutes: selectedDuration)
                        }
                    }) {
                        Text(manager.isRunning ? "EXTINGUISH" : "IGNITE")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(manager.isRunning ? Color.red : Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .listRowBackground(Color.clear) // Makes the button stand out
                }
                
                
                // NEW LOGO SECTION
                                Section {
                                    HStack {
                                        Spacer()
                                        Image("globex") // Ensure your PNG is named "globex" in Assets.xcassets
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 100) // Adjust height as needed
                                            .opacity(0.8) // Subtle sysadmin vibe
                                        Spacer()
                                    }
                                }
                                .listRowBackground(Color.clear) // Keeps the background clean
            }
            .navigationTitle("Scorpio's Flamethrower")
        }
    }
}

// THIS MAKES THE UI SHOW UP IN XCODE PREVIEW
#Preview {
    ContentView()
}
