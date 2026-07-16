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
        case campaignScoreboard
        case arrowWeave
        case arrowWeaveScoreboard
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

    func openCampaignScoreboard() {
        withAnimation(.easeInOut(duration: 0.25)) {
            route = .campaignScoreboard
        }
    }

    func openArrowWeave() {
        startArrowWeaveLevel(at: currentArrowWeaveLevelIndexForContinue)
    }

    func openArrowWeaveScoreboard() {
        withAnimation(.easeInOut(duration: 0.25)) {
            route = .arrowWeaveScoreboard
        }
    }

    func closeScoreboard() {
        withAnimation(.easeInOut(duration: 0.25)) {
            if session != nil {
                route = .gameplay
            } else if arrowWeaveSession != nil {
                route = .arrowWeave
            } else {
                route = .home
            }
        }
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
            onComplete: { [weak self] stars, score in
                self?.handleCompletion(levelIndex: index, stars: stars, score: score)
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
            onComplete: { [weak self] stars, score in
                self?.handleArrowWeaveCompletion(levelIndex: index, stars: stars, score: score)
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

    func deleteCampaignScore(for levelIndex: Int) {
        guard levels.indices.contains(levelIndex) else { return }
        removeScoreData(for: levelIndex, from: &progress)
        saveProgress()
    }

    func clearAllCampaignScores() {
        clearScoreData(&progress)
        saveProgress()
    }

    func deleteArrowWeaveScore(for levelIndex: Int) {
        guard arrowWeaveLevels.indices.contains(levelIndex) else { return }
        removeScoreData(for: levelIndex, from: &arrowWeaveProgress)
        saveArrowWeaveProgress()
    }

    func clearAllArrowWeaveScores() {
        clearScoreData(&arrowWeaveProgress)
        saveArrowWeaveProgress()
    }

    private func handleCompletion(levelIndex: Int, stars: Int, score: Int) {
        let run = session
        let previousStars = progress.bestStarsByLevel[levelIndex] ?? 0
        progress.bestStarsByLevel[levelIndex] = max(previousStars, stars)
        let previousScore = progress.bestScoresByLevel[levelIndex] ?? 0
        progress.bestScoresByLevel[levelIndex] = max(previousScore, score)
        let previousTotal = progress.totalScoresByLevel[levelIndex] ?? 0
        progress.totalScoresByLevel[levelIndex] = previousTotal + score
        upsertLevelSummary(
            into: &progress.levelSummaries,
            levelIndex: levelIndex,
            levelNumber: levelIndex + 1,
            levelTitle: run?.level.title ?? levels[levelIndex].title,
            levelSubtitle: run?.level.subtitle ?? levels[levelIndex].subtitle,
            stars: stars,
            score: score,
            movesUsed: run?.movesUsed ?? 0,
            moveLimit: run?.level.moveLimit ?? levels[levelIndex].moveLimit,
            elapsedSeconds: run?.elapsedSeconds ?? 0,
            completedAt: Date(),
            totalScore: progress.totalScoresByLevel[levelIndex] ?? score
        )
        unlockNextLevel(after: levelIndex)
        saveProgress()
    }

    private func handleArrowWeaveCompletion(levelIndex: Int, stars: Int, score: Int) {
        let run = arrowWeaveSession
        let previousStars = arrowWeaveProgress.bestStarsByLevel[levelIndex] ?? 0
        arrowWeaveProgress.bestStarsByLevel[levelIndex] = max(previousStars, stars)
        let previousScore = arrowWeaveProgress.bestScoresByLevel[levelIndex] ?? 0
        arrowWeaveProgress.bestScoresByLevel[levelIndex] = max(previousScore, score)
        let previousTotal = arrowWeaveProgress.totalScoresByLevel[levelIndex] ?? 0
        arrowWeaveProgress.totalScoresByLevel[levelIndex] = previousTotal + score
        upsertLevelSummary(
            into: &arrowWeaveProgress.levelSummaries,
            levelIndex: levelIndex,
            levelNumber: levelIndex + 1,
            levelTitle: run?.level.title ?? arrowWeaveLevels[levelIndex].title,
            levelSubtitle: run?.level.subtitle ?? arrowWeaveLevels[levelIndex].subtitle,
            stars: stars,
            score: score,
            movesUsed: run?.movesUsed ?? 0,
            moveLimit: run?.level.moveLimit ?? arrowWeaveLevels[levelIndex].moveLimit,
            elapsedSeconds: run?.elapsedSeconds ?? 0,
            completedAt: Date(),
            totalScore: arrowWeaveProgress.totalScoresByLevel[levelIndex] ?? score
        )
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

    private func upsertLevelSummary(
        into summaries: inout [LevelScoreSummary],
        levelIndex: Int,
        levelNumber: Int,
        levelTitle: String,
        levelSubtitle: String,
        stars: Int,
        score: Int,
        movesUsed: Int,
        moveLimit: Int,
        elapsedSeconds: TimeInterval,
        completedAt: Date,
        totalScore: Int
    ) {
        let updated = LevelScoreSummary(
            id: levelIndex,
            levelIndex: levelIndex,
            levelNumber: levelNumber,
            levelTitle: levelTitle,
            levelSubtitle: levelSubtitle,
            bestStars: stars,
            bestScore: score,
            totalScore: totalScore,
            lastScore: score,
            lastStars: stars,
            lastMovesUsed: movesUsed,
            lastMoveLimit: moveLimit,
            lastElapsedSeconds: elapsedSeconds,
            playCount: 1,
            lastCompletedAt: completedAt
        )

        if let existingIndex = summaries.firstIndex(where: { $0.levelIndex == levelIndex }) {
            let existing = summaries[existingIndex]
            summaries[existingIndex] = LevelScoreSummary(
                id: levelIndex,
                levelIndex: levelIndex,
                levelNumber: levelNumber,
                levelTitle: levelTitle,
                levelSubtitle: levelSubtitle,
                bestStars: max(existing.bestStars, stars),
                bestScore: max(existing.bestScore, score),
                totalScore: totalScore,
                lastScore: score,
                lastStars: stars,
                lastMovesUsed: movesUsed,
                lastMoveLimit: moveLimit,
                lastElapsedSeconds: elapsedSeconds,
                playCount: existing.playCount + 1,
                lastCompletedAt: completedAt
            )
        } else {
            summaries.append(updated)
        }
        summaries.sort { $0.levelIndex < $1.levelIndex }
    }

    private func removeScoreData(for levelIndex: Int, from progress: inout GameProgress) {
        progress.bestStarsByLevel.removeValue(forKey: levelIndex)
        progress.bestScoresByLevel.removeValue(forKey: levelIndex)
        progress.totalScoresByLevel.removeValue(forKey: levelIndex)
        progress.levelSummaries.removeAll { $0.levelIndex == levelIndex }
    }

    private func clearScoreData(_ progress: inout GameProgress) {
        progress.bestStarsByLevel.removeAll()
        progress.bestScoresByLevel.removeAll()
        progress.totalScoresByLevel.removeAll()
        progress.levelSummaries.removeAll()
    }
}

@MainActor
final class GameSession: ObservableObject {
    @Published var level: LevelDefinition
    @Published var arrows: [ArrowToken]
    @Published var movesUsed: Int = 0
    @Published var exitsCleared: Int = 0
    @Published var hintsUsed: Int = 0
    @Published var undosUsed: Int = 0
    @Published var elapsedSeconds: TimeInterval = 0
    @Published var scoreEarned: Int = 0
    @Published var completed = false
    @Published var failed = false
    @Published var isAnimating = false
    @Published var toastMessage: String = "Tap an arrow to launch."
    @Published var failureMessage: String = "Out of moves."
    @Published var highlightedArrowID: String?
    @Published var travelTrail: [BoardPoint] = []

    var settings: GameSettings
    let onComplete: (Int, Int) -> Void

    private var history: [GameSnapshot] = []
    private var completionNotified = false
    private var attemptStartedAt: Date = .init()
    private var scoreTimerTask: Task<Void, Never>?
    private var scoringStarted = false

    init(
        level: LevelDefinition,
        settings: GameSettings,
        onComplete: @escaping (Int, Int) -> Void
    ) {
        self.level = level
        self.arrows = level.arrows
        self.settings = settings
        self.onComplete = onComplete
        startNewAttempt()
    }

    var remainingArrows: Int {
        arrows.count
    }

    var remainingMoves: Int {
        max(0, level.moveLimit - movesUsed)
    }

    var score: Int {
        guard scoringStarted else { return 0 }
        return scoreEarned
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
        startNewAttempt()
    }

    func undo() {
        guard !isAnimating, let snapshot = history.popLast() else { return }
        arrows = snapshot.arrows
        movesUsed = snapshot.movesUsed
        exitsCleared = snapshot.exitsCleared
        scoreEarned = snapshot.scoreEarned
        undosUsed += 1
        failed = false
        highlightedArrowID = nil
        travelTrail = []
        toastMessage = "Move undone."
    }

    func requestHint() {
        guard !isAnimating else { return }
        if let next = nextRecommendedArrowID() {
            hintsUsed += 1
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
        beginScoringIfNeeded()
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
            history.append(GameSnapshot(arrows: arrows, movesUsed: movesUsed, exitsCleared: exitsCleared, scoreEarned: scoreEarned))
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
        scoreEarned += CompetitiveScoring.campaignEscapePoints(
            level: level,
            escapeIndex: exitsCleared,
            elapsedSeconds: currentElapsedSeconds(),
            hintsUsed: hintsUsed,
            undosUsed: undosUsed
        )
        travelTrail = []
        isAnimating = false
        toastMessage = "Arrow escaped."

        if arrows.isEmpty {
            scoreEarned += CompetitiveScoring.campaignCompletionBonus(
                level: level,
                elapsedSeconds: currentElapsedSeconds(),
                hintsUsed: hintsUsed,
                undosUsed: undosUsed
            )
            completed = true
            finishAttempt()
            if !completionNotified {
                completionNotified = true
                onComplete(starsEarned, score)
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
        finishAttempt()
    }

    private func inBounds(_ point: BoardPoint) -> Bool {
        (0..<level.rows).contains(point.row) && (0..<level.cols).contains(point.col)
    }

    private func startNewAttempt() {
        scoreTimerTask?.cancel()
        arrows = level.arrows
        movesUsed = 0
        exitsCleared = 0
        hintsUsed = 0
        undosUsed = 0
        elapsedSeconds = 0
        scoreEarned = 0
        completed = false
        failed = false
        isAnimating = false
        toastMessage = "Fresh board. Tap an arrow to launch."
        failureMessage = "Out of moves."
        highlightedArrowID = nil
        travelTrail = []
        history.removeAll()
        completionNotified = false
        attemptStartedAt = Date()
        scoringStarted = false
    }

    private func beginScoringIfNeeded() {
        guard !scoringStarted else { return }
        scoringStarted = true
        attemptStartedAt = Date()
        startScoreTimer()
    }

    private func startScoreTimer() {
        scoreTimerTask?.cancel()
        scoreTimerTask = Task { @MainActor [weak self] in
            guard let self else { return }
            while !Task.isCancelled && !self.completed && !self.failed {
                self.elapsedSeconds = Date().timeIntervalSince(self.attemptStartedAt)
                try? await Task.sleep(for: .milliseconds(200))
            }
        }
    }

    private func finishAttempt() {
        guard scoringStarted else {
            elapsedSeconds = 0
            scoreTimerTask?.cancel()
            scoreTimerTask = nil
            return
        }
        elapsedSeconds = Date().timeIntervalSince(attemptStartedAt)
        scoreTimerTask?.cancel()
        scoreTimerTask = nil
    }

    private func currentElapsedSeconds() -> TimeInterval {
        max(elapsedSeconds, Date().timeIntervalSince(attemptStartedAt))
    }

    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard settings.hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    deinit {
        scoreTimerTask?.cancel()
    }
}
