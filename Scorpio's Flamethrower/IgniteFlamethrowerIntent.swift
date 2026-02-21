import AppIntents
import Foundation

struct IgniteFlamethrowerIntent: AppIntent {
    static var title: LocalizedStringResource = "Ignite Scorpio's Flamethrower"
    
    @Parameter(title: "Test URL")
    var url: URL

    @Parameter(title: "Duration", default: 15)
    var duration: Int // Users can pass 15, 30, 60, etc.

    static var parameterSummary: some ParameterSummary {
        Summary("Burn \(\.$url) for \(\.$duration) minutes")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        FlamethrowerManager.shared.ignite(url: url, durationMinutes: duration)
        return .result(dialog: "Flamethrower Ignited. Stay frosty.")
    }
}