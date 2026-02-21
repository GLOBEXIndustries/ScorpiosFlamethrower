//
//  IgniteFlamethrowerIntent.swift
//  Scorpio's Flamethrower
//
//  Created by Ian McHale on 2/20/26.
//


import AppIntents
import Foundation

struct IgniteFlamethrowerIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Net Test"
    
    @Parameter(title: "Test URL")
    var url: URL

    @Parameter(title: "Duration", default: 15)
    var duration: Int // Users can pass 15, 30, 60, etc.

    static var parameterSummary: some ParameterSummary {
        Summary("Run \(\.$url) for \(\.$duration) minutes")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        FlamethrowerManager.shared.ignite(url: url, durationMinutes: duration)
        return .result(dialog: "Test Started")
    }
}
