import Foundation
import UIKit


enum SkillzMatchMode: String, Codable, Sendable {
    case campaign
    case arrowWeave
    case unknown
}

struct SkillzMatchConfiguration: Codable, Sendable {
    var mode: SkillzMatchMode
    var levelIndex: Int?
    var rawParameters: [String: String]
}

struct SkillzDebugStep: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let detail: String
    let isComplete: Bool
}

enum SkillzFlowState: Equatable, Sendable {
    case idle
    case launching
    case ready
    case progressionRoom
    case tournamentReceived(mode: SkillzMatchMode, levelIndex: Int?)
    case scoreSynced(score: Int)
    case submittingFinalScore(score: Int)
    case returningToSkillz
    case showingResults(score: Int)
    case exited

    var title: String {
        switch self {
        case .idle:
            return "Skillz idle"
        case .launching:
            return "Launching Skillz"
        case .ready:
            return "Skillz UI ready"
        case .progressionRoom:
            return "Progression room"
        case .tournamentReceived:
            return "Tournament received"
        case .scoreSynced:
            return "Score synced"
        case .submittingFinalScore:
            return "Submitting final score"
        case .returningToSkillz:
            return "Returning to Skillz"
        case .showingResults:
            return "Showing results"
        case .exited:
            return "Exited Skillz"
        }
    }

    var detail: String {
        switch self {
        case .idle:
            return "Tap Skillz to launch a match."
        case .launching:
            return "Opening the Skillz experience."
        case .ready:
            return "The Skillz home or lobby UI is visible."
        case .progressionRoom:
            return "Progression room callback received."
        case let .tournamentReceived(mode, levelIndex):
            let modeLabel: String = {
                switch mode {
                case .campaign: return "Campaign"
                case .arrowWeave: return "Arrow Weave"
                case .unknown: return "Unknown mode"
                }
            }()
            if let levelIndex {
                return "\(modeLabel) match parameters received for level \(levelIndex + 1)."
            }
            return "\(modeLabel) match parameters received."
        case let .scoreSynced(score):
            return "Current score synced: \(score)."
        case let .submittingFinalScore(score):
            return "Submitting final score \(score)."
        case .returningToSkillz:
            return "Returning to Skillz after submission."
        case let .showingResults(score):
            return "Showing fallback results for \(score)."
        case .exited:
            return "Skillz closed and app returned home."
        }
    }
}

extension Notification.Name {
    static let skillzTournamentWillBegin = Notification.Name("SkillzTournamentWillBeginNotification")
    static let skillzWillExit = Notification.Name("SkillzWillExitNotification")
    static let skillzOnProgressionRoomEnter = Notification.Name("SkillzProgressionRoomEnterNotification")
    static let skillzHasFinishedLaunching = Notification.Name("SkillzHasFinishedLaunchingNotification")
    static let skillzWillLaunch = Notification.Name("SkillzWillLaunchNotification")
}

final class SkillzBridge {
    static let shared = SkillzBridge()
    private var didInitializeSkillz = false

    var isAvailable: Bool {
        #if !arch(x86_64)
        return true
        #else
        return false
        #endif
    }

    private(set) var currentMatchConfiguration: SkillzMatchConfiguration?

    func launchSkillz() {
        initializeSkillzIfNeeded()
        Skillz.skillzInstance().launch()
    }

    func handleTournamentWillBegin(_ gameParameters: [AnyHashable: Any], matchInfo: Any? = nil) {
        let configuration = parseConfiguration(from: gameParameters)
        currentMatchConfiguration = configuration
        NotificationCenter.default.post(
            name: .skillzTournamentWillBegin,
            object: configuration
        )
    }

    func handleSkillzWillExit() {
        currentMatchConfiguration = nil
        NotificationCenter.default.post(name: .skillzWillExit, object: nil)
    }

    func handleProgressionRoomEnter() {
        NotificationCenter.default.post(name: .skillzOnProgressionRoomEnter, object: nil)
    }

    func handleSkillzHasFinishedLaunching() {
        NotificationCenter.default.post(name: .skillzHasFinishedLaunching, object: nil)
    }

    func handleSkillzWillLaunch() {
        NotificationCenter.default.post(name: .skillzWillLaunch, object: nil)
    }

    func updateCurrentScore(_ score: Int) {
        guard currentMatchConfiguration != nil else { return }
        Skillz.skillzInstance().updatePlayersCurrentScore(NSNumber(value: score))
    }

    func submitFinalScore(_ score: Int, completion: @escaping (Bool) -> Void) {
        Skillz.skillzInstance().submitScore(
            NSNumber(value: score),
            withSuccess: {
                DispatchQueue.main.async { completion(true) }
            },
            withFailure: { _ in
                DispatchQueue.main.async { completion(false) }
            }
        )
    }

    func returnToSkillz(completion: @escaping () -> Void) {
        Skillz.skillzInstance().returnToSkillz(completion: {
            DispatchQueue.main.async { completion() }
        })
    }

    func displayFallbackResults(score: Int, completion: @escaping () -> Void) {
        Skillz.skillzInstance().displayTournamentResults(
            withScore: NSNumber(value: score),
            withCompletion: {
                DispatchQueue.main.async { completion() }
            }
        )
    }

    func clearMatchState() {
        currentMatchConfiguration = nil
    }

    private func initializeSkillzIfNeeded() {
        guard !didInitializeSkillz else { return }
        guard let delegate = UIApplication.shared.delegate as? SkillzDelegate else { return }

        let environment: SkillzEnvironment = .production

        Skillz.skillzInstance().initWithGameId(
            "103057",
            for: delegate,
            with: environment,
            allowExit: true
        )
        didInitializeSkillz = true
    }

    private func parseConfiguration(from gameParameters: [AnyHashable: Any]) -> SkillzMatchConfiguration {
        var raw: [String: String] = [:]
        for (key, value) in gameParameters {
            guard let key = key as? String else { continue }
            raw[key.lowercased()] = String(describing: value)
        }

        let modeToken = rawValue(
            from: raw,
            keys: ["mode", "gamemode", "game_mode", "matchmode", "playmode", "play_mode", "type"]
        )?.lowercased()

        let mode: SkillzMatchMode
        switch modeToken {
        case "arrowweave", "weave", "snake", "escape":
            mode = .arrowWeave
        case "campaign", "level", "classic", "puzzle":
            mode = .campaign
        default:
            mode = .unknown
        }

        let levelIndex = rawInt(
            from: raw,
            keys: ["levelindex", "level_index", "level", "stage", "round", "campaignlevel", "campaign_level"]
        )

        return SkillzMatchConfiguration(mode: mode, levelIndex: levelIndex, rawParameters: raw)
    }

    private func rawValue(from values: [String: String], keys: [String]) -> String? {
        for key in keys {
            if let value = values[key] {
                return value
            }
        }
        return nil
    }

    private func rawInt(from values: [String: String], keys: [String]) -> Int? {
        for key in keys {
            guard let value = values[key] else { continue }
            if let intValue = Int(value) {
                return intValue
            }
            if let doubleValue = Double(value) {
                return Int(doubleValue.rounded())
            }
        }
        return nil
    }
}
