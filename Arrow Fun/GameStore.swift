import SwiftUI
import UIKit
import Combine

@MainActor
final class GameStore: ObservableObject {
    enum Route: Equatable {
        case splash
        case home
        case levelMap
        case gameplay
        case arrowWeave
    }

    @Published var route: Route = .splash
    @Published var progress: GameProgress
    @Published var arrowWeaveProgress: GameProgress
    @Published var settings: GameSettings
    @Published var activeLevelIndex: Int = 0
    @Published var session: GameSession?
    @Published var arrowWeaveSession: ArrowWeaveSession?
    @Published var showSettingsSheet = false

    let levels = LevelFactory.allLevels
    let arrowWeaveLevels = ArrowWeaveLevelFactory.allLevels

    private let progressKey = "ArrowFun.GameProgress.v1"
    private let arrowWeaveProgressKey = "ArrowFun.ArrowWeaveProgress.v1"
    private let legacyArrowWeaveProgressKey = "ArrowFun.Arrow" + "EscapeProgress.v1"
    private let settingsKey = "ArrowFun.GameSettings.v1"

    init() {
        progress = Self.loadValue(forKey: progressKey) ?? GameProgress()
        arrowWeaveProgress = Self.loadValue(forKey: arrowWeaveProgressKey) ?? Self.loadValue(forKey: legacyArrowWeaveProgressKey) ?? GameProgress()
        settings = Self.loadValue(forKey: settingsKey) ?? GameSettings()
        progress.highestUnlockedLevel = min(progress.highestUnlockedLevel, max(0, levels.count - 1))
        progress.lastPlayedLevel = min(progress.lastPlayedLevel, max(0, levels.count - 1))
        arrowWeaveProgress.highestUnlockedLevel = min(arrowWeaveProgress.highestUnlockedLevel, max(0, arrowWeaveLevels.count - 1))
        arrowWeaveProgress.lastPlayedLevel = min(arrowWeaveProgress.lastPlayedLevel, max(0, arrowWeaveLevels.count - 1))
        startSplashTimer()
    }

    var currentLevelIndexForContinue: Int {
        max(progress.lastPlayedLevel, progress.highestUnlockedLevel)
    }

    var currentArrowWeaveLevelIndexForContinue: Int {
        max(arrowWeaveProgress.lastPlayedLevel, arrowWeaveProgress.highestUnlockedLevel)
    }

    var dailyChallengeIndex: Int {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return max(0, (day - 1) % levels.count)
    }

    func finishSplash() {
        withAnimation(.easeOut(duration: 0.35)) {
            route = .home
        }
    }

    func openLevelMap() {
        withAnimation(.easeInOut(duration: 0.25)) {
            route = .levelMap
        }
    }

    func openHome() {
        withAnimation(.easeInOut(duration: 0.25)) {
            route = .home
        }
    }

    func openArrowWeave() {
        startArrowWeaveLevel(at: currentArrowWeaveLevelIndexForContinue)
    }

    func openSettings() {
        showSettingsSheet = true
    }

    func continueCampaign() {
        startLevel(at: currentLevelIndexForContinue)
    }

    func startDailyChallenge() {
        startLevel(at: dailyChallengeIndex)
    }

    func startLevel(at index: Int) {
        guard levels.indices.contains(index) else { return }
        activeLevelIndex = index
        progress.lastPlayedLevel = index
        saveProgress()
        arrowWeaveSession = nil

        session = GameSession(
            level: levels[index],
            settings: settings,
            onComplete: { [weak self] stars in
                self?.handleCompletion(levelIndex: index, stars: stars)
            },
        )
        withAnimation(.easeInOut(duration: 0.25)) {
            route = .gameplay
        }
    }

    func startArrowWeaveLevel(at index: Int) {
        guard arrowWeaveLevels.indices.contains(index) else { return }
        arrowWeaveProgress.lastPlayedLevel = index
        saveArrowWeaveProgress()
        session = nil

        arrowWeaveSession = ArrowWeaveSession(
            level: arrowWeaveLevels[index],
            settings: settings,
            onComplete: { [weak self] stars in
                self?.handleArrowWeaveCompletion(levelIndex: index, stars: stars)
            }
        )

        withAnimation(.easeInOut(duration: 0.25)) {
            route = .arrowWeave
        }
    }

    func restartCurrentLevel() {
        guard let session else { return }
        session.restart()
    }

    func goBackFromGameplay() {
        session = nil
        openHome()
    }

    func goBackFromArrowWeave() {
        arrowWeaveSession = nil
        openHome()
    }

    func update(settings newSettings: GameSettings) {
        settings = newSettings
        session?.settings = newSettings
        arrowWeaveSession?.settings = newSettings
        saveSettings()
    }

    func unlockNextLevel(after completedIndex: Int) {
        let next = min(completedIndex + 1, levels.count - 1)
        if next > progress.highestUnlockedLevel {
            progress.highestUnlockedLevel = next
        }
    }

    func unlockArrowWeaveNextLevel(after completedIndex: Int) {
        let next = min(completedIndex + 1, arrowWeaveLevels.count - 1)
        if next > arrowWeaveProgress.highestUnlockedLevel {
            arrowWeaveProgress.highestUnlockedLevel = next
        }
    }

    private func handleCompletion(levelIndex: Int, stars: Int) {
        let previousStars = progress.bestStarsByLevel[levelIndex] ?? 0
        progress.bestStarsByLevel[levelIndex] = max(previousStars, stars)
        unlockNextLevel(after: levelIndex)
        saveProgress()
    }

    private func handleArrowWeaveCompletion(levelIndex: Int, stars: Int) {
        let previousStars = arrowWeaveProgress.bestStarsByLevel[levelIndex] ?? 0
        arrowWeaveProgress.bestStarsByLevel[levelIndex] = max(previousStars, stars)
        unlockArrowWeaveNextLevel(after: levelIndex)
        saveArrowWeaveProgress()
    }

    private func startSplashTimer() {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.15))
            guard route == .splash else { return }
            finishSplash()
        }
    }

    private func saveProgress() {
        Self.saveValue(progress, forKey: progressKey)
    }

    private func saveSettings() {
        Self.saveValue(settings, forKey: settingsKey)
    }

    private func saveArrowWeaveProgress() {
        Self.saveValue(arrowWeaveProgress, forKey: arrowWeaveProgressKey)
    }

    private static func saveValue<T: Codable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private static func loadValue<T: Codable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

@MainActor
final class GameSession: ObservableObject {
    @Published var level: LevelDefinition
    @Published var arrows: [ArrowToken]
    @Published var movesUsed: Int = 0
    @Published var exitsCleared: Int = 0
    @Published var completed = false
    @Published var failed = false
    @Published var isAnimating = false
    @Published var toastMessage: String = "Tap an arrow to launch."
    @Published var failureMessage: String = "Out of moves."
    @Published var highlightedArrowID: String?
    @Published var travelTrail: [BoardPoint] = []

    var settings: GameSettings
    let onComplete: (Int) -> Void

    private var history: [GameSnapshot] = []
    private var completionNotified = false

    init(
        level: LevelDefinition,
        settings: GameSettings,
        onComplete: @escaping (Int) -> Void
    ) {
        self.level = level
        self.arrows = level.arrows
        self.settings = settings
        self.onComplete = onComplete
    }

    var remainingArrows: Int {
        arrows.count
    }

    var remainingMoves: Int {
        max(0, level.moveLimit - movesUsed)
    }

    var score: Int {
        let moveBonus = remainingMoves * 90
        let escapeBonus = exitsCleared * 150
        let efficiencyBonus = max(0, level.totalArrows - movesUsed) * 20
        let completionBonus = completed ? 350 : 0
        let failurePenalty = failed ? 0 : 0
        return max(0, moveBonus + escapeBonus + efficiencyBonus + completionBonus - failurePenalty)
    }

    var starsEarned: Int {
        if failed {
            return 0
        }
        let moveLimit = max(1, level.moveLimit)
        if movesUsed <= moveLimit { return 3 }
        if movesUsed <= moveLimit + 2 { return 2 }
        return 1
    }

    var completionSubtitle: String {
        switch starsEarned {
        case 3: return "Perfect route"
        case 2: return "Clean finish"
        default: return "Solved"
        }
    }

    func restart() {
        guard !isAnimating else { return }
        arrows = level.arrows
        movesUsed = 0
        exitsCleared = 0
        completed = false
        failed = false
        isAnimating = false
        toastMessage = "Fresh board. Tap an arrow to launch."
        failureMessage = "Out of moves."
        highlightedArrowID = nil
        travelTrail = []
        history.removeAll()
        completionNotified = false
    }

    func undo() {
        guard !isAnimating, let snapshot = history.popLast() else { return }
        arrows = snapshot.arrows
        movesUsed = snapshot.movesUsed
        exitsCleared = snapshot.exitsCleared
        failed = false
        highlightedArrowID = nil
        travelTrail = []
        toastMessage = "Move undone."
    }

    func requestHint() {
        guard !isAnimating else { return }
        if let next = nextRecommendedArrowID() {
            highlightedArrowID = next
            toastMessage = "Hint highlighted."
            triggerHaptic(style: .soft)
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.5))
                if highlightedArrowID == next {
                    highlightedArrowID = nil
                }
            }
        } else {
            toastMessage = "No hint available."
        }
    }

    func launchArrow(id: String) {
        guard !isAnimating, !completed, !failed, let index = arrows.firstIndex(where: { $0.id == id }) else { return }
        let arrow = arrows[index]

        let evaluation = evaluateMovement(for: arrow)
        switch evaluation.outcome {
        case .blocked(let message):
            consumeMove()
            toastMessage = message
            failureMessage = message
            triggerHaptic(style: .rigid)
            if remainingMoves == 0 {
                failRun(message: message)
            }
            return
        case .success(let path):
            history.append(GameSnapshot(arrows: arrows, movesUsed: movesUsed, exitsCleared: exitsCleared))
            consumeMove()
            isAnimating = true
            highlightedArrowID = nil
            toastMessage = "Launching..."
            triggerHaptic(style: .light)
            Task { @MainActor in
                await animate(path: path, arrowIndex: index)
            }
        }
    }

    private func animate(path: [BoardPoint], arrowIndex: Int) async {
        guard arrows.indices.contains(arrowIndex) else {
            isAnimating = false
            return
        }

        travelTrail = Array(path.dropFirst())
        let arrowID = arrows[arrowIndex].id

        for point in path.dropFirst() {
            guard let currentIndex = arrows.firstIndex(where: { $0.id == arrowID }) else { break }
            arrows[currentIndex].position = point
            try? await Task.sleep(for: .milliseconds(92))
        }

        guard let finalArrowIndex = arrows.firstIndex(where: { $0.id == arrowID }) else {
            travelTrail = []
            isAnimating = false
            return
        }

        arrows.remove(at: finalArrowIndex)
        exitsCleared += 1
        travelTrail = []
        isAnimating = false
        toastMessage = "Arrow escaped."

        if arrows.isEmpty {
            completed = true
            if !completionNotified {
                completionNotified = true
                onComplete(starsEarned)
            }
        } else if remainingMoves == 0 {
            failRun(message: "Out of moves.")
        }
    }

    private func nextRecommendedArrowID() -> String? {
        for candidate in level.recommendedOrder {
            if arrows.contains(where: { $0.id == candidate }) {
                return candidate
            }
        }
        return arrows.first?.id
    }

    private func evaluateMovement(for arrow: ArrowToken) -> TravelPlan {
        var position = arrow.position
        var path: [BoardPoint] = [position]
        var portalHops = 0

        while true {
            let next = position.shifted(by: arrow.direction)
            guard inBounds(next) else {
                return TravelPlan(outcome: .blocked(message: "The path ends before the exit."))
            }

            if let blocker = arrows.first(where: { $0.id != arrow.id && $0.position == next }) {
                return TravelPlan(outcome: .blocked(message: "\(blocker.color.title) is in the way."))
            }

            let tile = level.board[next.row][next.col]

            switch tile.kind {
            case .empty:
                position = next
                path.append(next)
            case .wall:
                return TravelPlan(outcome: .blocked(message: "A wall blocks the lane."))
            case .gate:
                if !isGateOpen(tile) {
                    return TravelPlan(outcome: .blocked(message: "The gate is still closed."))
                }
                position = next
                path.append(next)
            case .lock:
                if !isLockOpen(tile) {
                    return TravelPlan(outcome: .blocked(message: "The lock needs more momentum."))
                }
                position = next
                path.append(next)
            case .portal:
                guard let destination = matchingPortal(for: tile.tag, excluding: next) else {
                    return TravelPlan(outcome: .blocked(message: "Portal link missing."))
                }
                position = destination
                path.append(next)
                path.append(destination)
                portalHops += 1
                if portalHops > 4 {
                    return TravelPlan(outcome: .blocked(message: "Portal loop detected."))
                }
            case .exit:
                if let expected = tile.color, expected != arrow.color {
                    return TravelPlan(outcome: .blocked(message: "Wrong color exit."))
                }
                path.append(next)
                return TravelPlan(outcome: .success(path: path))
            case .ice, .conveyor:
                position = next
                path.append(next)
            }
        }
    }

    private func matchingPortal(for tag: String?, excluding point: BoardPoint) -> BoardPoint? {
        guard let tag else { return nil }
        for row in 0..<level.rows {
            for col in 0..<level.cols {
                let tile = level.board[row][col]
                if tile.kind == .portal, tile.tag == tag {
                    let candidate = BoardPoint(row: row, col: col)
                    if candidate != point {
                        return candidate
                    }
                }
            }
        }
        return nil
    }

    private func isGateOpen(_ tile: BoardTile) -> Bool {
        guard let threshold = tile.unlockAfterExits else { return false }
        return exitsCleared >= threshold
    }

    private func isLockOpen(_ tile: BoardTile) -> Bool {
        guard let threshold = tile.unlockAfterMoves else { return false }
        return movesUsed >= threshold
    }

    private func consumeMove() {
        guard movesUsed < level.moveLimit else { return }
        movesUsed += 1
    }

    private func failRun(message: String) {
        guard !completed else { return }
        failed = true
        isAnimating = false
        highlightedArrowID = nil
        travelTrail = []
        failureMessage = message
        toastMessage = "Game over."
    }

    private func inBounds(_ point: BoardPoint) -> Bool {
        (0..<level.rows).contains(point.row) && (0..<level.cols).contains(point.col)
    }

    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard settings.hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
