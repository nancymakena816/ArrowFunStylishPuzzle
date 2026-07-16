import SwiftUI
import UIKit
import Combine

@MainActor
enum ArrowWeaveLevelFactory {
    private enum RouteStyle: Int, CaseIterable {
        case sweep
        case drop
        case reverseSweep
        case rise
        case weave
        case funnel
    }

    static var allLevels: [ArrowWeaveLevelDefinition] {
        (1...24).map { makeLevel(number: $0) }
    }

    static func makeLevel(number: Int) -> ArrowWeaveLevelDefinition {
        let stage = number - 1
        let rows = min(9, 6 + stage / 5)
        let cols = min(9, 7 + stage / 6)
        let routeCount = min(3 + stage / 4, 6)
        let moveLimit = max(routeCount + 2 + min(stage / 6, 3), routeCount)
        let palette = ArrowColor.allCases
        let scenePalette = [
            palette[(stage * 2) % palette.count],
            palette[(stage * 3 + 1) % palette.count],
            palette[(stage * 5 + 2) % palette.count],
            palette[(stage * 7 + 3) % palette.count],
            palette[(stage * 11 + 4) % palette.count],
            palette[(stage * 13 + 5) % palette.count]
        ]

        var routes: [ArrowWeaveRoute] = []
        for index in 0..<routeCount {
            let style = RouteStyle.allCases[(stage + index) % RouteStyle.allCases.count]
            let route = makeRoute(
                number: number,
                index: index,
                stage: stage,
                rows: rows,
                cols: cols,
                style: style,
                color: scenePalette[index % scenePalette.count]
            )
            routes.append(route)
        }

        return ArrowWeaveLevelDefinition(
            id: "escape-level-\(number)",
            number: number,
            title: titleForStage(stage),
            subtitle: subtitleForStage(stage),
            rows: rows,
            cols: cols,
            moveLimit: moveLimit,
            routes: routes,
            mechanicNotes: notesForStage(stage)
        )
    }

    private static func makeRoute(
        number: Int,
        index: Int,
        stage: Int,
        rows: Int,
        cols: Int,
        style: RouteStyle,
        color: ArrowColor
    ) -> ArrowWeaveRoute {
        let insetRow = clamp(1 + ((stage + index) % max(1, rows - 2)), upper: rows - 2)
        let mirroredInsetRow = clamp(rows - 2 - ((stage + index) % max(1, rows - 2)), upper: rows - 2)
        let centerRow = clamp(rows / 2 + ((index % 3) - 1), upper: rows - 2)
        let centerCol = clamp(cols / 2 + (((stage + index) % 3) - 1), upper: cols - 2)
        let farCol = clamp(cols - 2 - ((stage + index) % 2), upper: cols - 2)
        let innerCol = clamp(1 + ((stage * 2 + index) % max(1, cols - 2)), upper: cols - 2)
        let routeTitle: String
        let waypoints: [BoardPoint]

        switch style {
        case .sweep:
            routeTitle = "Sweep"
            waypoints = [
                BoardPoint(row: insetRow, col: 0),
                BoardPoint(row: insetRow, col: centerCol),
                BoardPoint(row: mirroredInsetRow, col: centerCol),
                BoardPoint(row: mirroredInsetRow, col: cols - 1)
            ]
        case .drop:
            routeTitle = "Drop"
            waypoints = [
                BoardPoint(row: 0, col: innerCol),
                BoardPoint(row: centerRow, col: innerCol),
                BoardPoint(row: centerRow, col: farCol),
                BoardPoint(row: rows - 1, col: farCol)
            ]
        case .reverseSweep:
            routeTitle = "Reverse"
            waypoints = [
                BoardPoint(row: insetRow, col: cols - 1),
                BoardPoint(row: insetRow, col: centerCol),
                BoardPoint(row: mirroredInsetRow, col: centerCol),
                BoardPoint(row: mirroredInsetRow, col: 0)
            ]
        case .rise:
            routeTitle = "Rise"
            waypoints = [
                BoardPoint(row: rows - 1, col: innerCol),
                BoardPoint(row: centerRow, col: innerCol),
                BoardPoint(row: centerRow, col: farCol),
                BoardPoint(row: 0, col: farCol)
            ]
        case .weave:
            routeTitle = "Weave"
            waypoints = [
                BoardPoint(row: insetRow, col: 0),
                BoardPoint(row: insetRow, col: centerCol),
                BoardPoint(row: centerRow, col: centerCol),
                BoardPoint(row: centerRow, col: cols - 2),
                BoardPoint(row: rows - 1, col: cols - 2)
            ]
        case .funnel:
            routeTitle = "Funnel"
            waypoints = [
                BoardPoint(row: 0, col: innerCol),
                BoardPoint(row: centerRow, col: innerCol),
                BoardPoint(row: centerRow, col: clamp(innerCol - 2, upper: cols - 2)),
                BoardPoint(row: rows - 1, col: clamp(innerCol - 2, upper: cols - 2))
            ]
        }

        let unlockAfterEscapes = min(index, 3)

        return ArrowWeaveRoute(
            id: "escape-\(number)-route-\(index)",
            path: orthogonalPath(waypoints),
            color: color,
            unlockAfterEscapes: unlockAfterEscapes,
            title: routeTitle
        )
    }

    private static func orthogonalPath(_ points: [BoardPoint]) -> [BoardPoint] {
        guard let first = points.first else { return [] }
        var path: [BoardPoint] = [first]

        for target in points.dropFirst() {
            var current = path[path.count - 1]

            while current.row != target.row {
                current.row += target.row > current.row ? 1 : -1
                path.append(current)
            }

            while current.col != target.col {
                current.col += target.col > current.col ? 1 : -1
                path.append(current)
            }
        }

        return path
    }

    private static func titleForStage(_ stage: Int) -> String {
        switch stage {
        case 0..<5: return "Warm Escape"
        case 5..<10: return "Neon Drift"
        case 10..<15: return "Snake Flow"
        case 15..<20: return "Pulse Run"
        default: return "Final Slip"
        }
    }

    private static func subtitleForStage(_ stage: Int) -> String {
        switch stage {
        case 0..<5: return "Tap the front arrow and learn the rhythm."
        case 5..<10: return "Longer routes begin to curl and split."
        case 10..<15: return "Sequence matters. Escape one by one."
        case 15..<20: return "The board tightens and the timing matters."
        default: return "Last stretch. Keep the flow clean."
        }
    }

    private static func notesForStage(_ stage: Int) -> [String] {
        switch stage {
        case 0..<5:
            return ["Tap the leading arrow", "Each escape counts as one move"]
        case 5..<10:
            return ["Routes now bend more sharply", "Watch the order of taps"]
        case 10..<15:
            return ["Some arrows stay locked until others escape", "Snake-like motion is the win condition"]
        case 15..<20:
            return ["Move budget is tighter here", "Use hints if a route is still blocked"]
        default:
            return ["Final levels demand clean sequencing", "Every tap must feel deliberate"]
        }
    }

    private static func clamp(_ value: Int, upper: Int) -> Int {
        min(max(value, 1), upper)
    }
}

struct ArrowWeaveRouteState: Identifiable, Hashable {
    let id: String
    let title: String
    let path: [BoardPoint]
    let color: ArrowColor
    let unlockAfterEscapes: Int
    var escaped: Bool = false
    var isFlying: Bool = false
    var progressIndex: Int = 0

    var startPoint: BoardPoint {
        path.first ?? BoardPoint(row: 0, col: 0)
    }

    var headPoint: BoardPoint {
        guard !path.isEmpty else { return BoardPoint(row: 0, col: 0) }
        return path[min(progressIndex, path.count - 1)]
    }

    var facingDirection: Direction {
        guard path.count >= 2 else { return .right }
        let currentIndex = min(max(progressIndex, 0), path.count - 1)
        let previousIndex = max(0, min(currentIndex, path.count - 2))
        let previous = path[previousIndex]
        let next = path[previousIndex + 1]
        let delta = BoardPoint(row: next.row - previous.row, col: next.col - previous.col)
        switch delta {
        case BoardPoint(row: -1, col: 0): return .up
        case BoardPoint(row: 1, col: 0): return .down
        case BoardPoint(row: 0, col: -1): return .left
        default: return .right
        }
    }

    var renderedTrail: [BoardPoint] {
        guard !path.isEmpty else { return [] }
        return Array(path.prefix(min(progressIndex + 1, path.count)))
    }
}

@MainActor
final class ArrowWeaveSession: ObservableObject {
    @Published var level: ArrowWeaveLevelDefinition
    @Published var routes: [ArrowWeaveRouteState]
    @Published var movesUsed: Int = 0
    @Published var escapedRoutes: Int = 0
    @Published var hintsUsed: Int = 0
    @Published var undosUsed: Int = 0
    @Published var elapsedSeconds: TimeInterval = 0
    @Published var scoreEarned: Int = 0
    @Published var completed = false
    @Published var failed = false
    @Published var isAnimating = false
    @Published var toastMessage: String = "Tap the front arrow to slither out."
    @Published var failureMessage: String = "Out of moves."
    @Published var highlightedRouteID: String?
    @Published var travelTrail: [BoardPoint] = []

    var settings: GameSettings
    let onComplete: (Int, Int) -> Void

    private var completionNotified = false
    private var attemptStartedAt: Date = .init()
    private var scoreTimerTask: Task<Void, Never>?
    private var scoringStarted = false

    init(
        level: ArrowWeaveLevelDefinition,
        settings: GameSettings,
        onComplete: @escaping (Int, Int) -> Void
    ) {
        self.level = level
        self.routes = level.routes.map {
            ArrowWeaveRouteState(
                id: $0.id,
                title: $0.title,
                path: $0.path,
                color: $0.color,
                unlockAfterEscapes: $0.unlockAfterEscapes
            )
        }
        self.settings = settings
        self.onComplete = onComplete
        startNewAttempt()
    }

    var remainingMoves: Int {
        max(0, level.moveLimit - movesUsed)
    }

    var remainingRoutes: Int {
        routes.filter { !$0.escaped }.count
    }

    var score: Int {
        guard scoringStarted else { return 0 }
        return scoreEarned
    }

    var starsEarned: Int {
        if failed {
            return 0
        }
        let limit = max(1, level.moveLimit)
        if movesUsed <= limit { return 3 }
        if movesUsed <= limit + 2 { return 2 }
        return 1
    }

    var completionSubtitle: String {
        switch starsEarned {
        case 3: return "Perfect slither"
        case 2: return "Clean escape"
        default: return "Escaped"
        }
    }

    func restart() {
        guard !isAnimating else { return }
        startNewAttempt()
    }

    func requestHint() {
        guard !isAnimating else { return }
        if let routeID = nextRecommendedRouteID() {
            hintsUsed += 1
            highlightedRouteID = routeID
            toastMessage = "Route highlighted."
            triggerHaptic(style: .soft)
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.35))
                if highlightedRouteID == routeID {
                    highlightedRouteID = nil
                }
            }
        } else {
            toastMessage = "No route available."
        }
    }

    func launchRoute(id: String) {
        guard !isAnimating, !completed, !failed, let index = routes.firstIndex(where: { $0.id == id }) else { return }
        beginScoringIfNeeded()
        let route = routes[index]
        guard !route.escaped else { return }

        if !canLaunch(route: route) {
            consumeMove()
            toastMessage = route.unlockAfterEscapes == 0
                ? "That route is jammed."
                : "Need \(route.unlockAfterEscapes) escapes first."
            failureMessage = toastMessage
            triggerHaptic(style: .rigid)
            if remainingMoves == 0 {
                failRun(message: toastMessage)
            }
            return
        }

        consumeMove()
        isAnimating = true
        highlightedRouteID = nil
        toastMessage = "Slithering..."
        triggerHaptic(style: .light)
        Task { @MainActor in
            await animate(routeIndex: index)
        }
    }

    private func animate(routeIndex: Int) async {
        guard routes.indices.contains(routeIndex) else {
            isAnimating = false
            return
        }

        let path = routes[routeIndex].path
        guard path.count >= 2 else {
            isAnimating = false
            return
        }

        routes[routeIndex].isFlying = true
        routes[routeIndex].progressIndex = 0
        travelTrail = [path[0]]

        for stepIndex in 1..<path.count {
            guard routes.indices.contains(routeIndex) else { break }
            routes[routeIndex].progressIndex = stepIndex
            travelTrail = Array(path.prefix(stepIndex + 1))
            try? await Task.sleep(for: .milliseconds(84))
        }

        guard routes.indices.contains(routeIndex) else {
            travelTrail = []
            isAnimating = false
            return
        }

        routes[routeIndex].isFlying = false
        routes[routeIndex].escaped = true
        routes[routeIndex].progressIndex = max(0, path.count - 1)
        escapedRoutes += 1
        scoreEarned += CompetitiveScoring.arrowWeaveEscapePoints(
            level: level,
            escapeIndex: escapedRoutes,
            elapsedSeconds: currentElapsedSeconds(),
            hintsUsed: hintsUsed,
            undosUsed: undosUsed
        )
        travelTrail = []
        isAnimating = false
        toastMessage = "Arrow escaped."

        if escapedRoutes == routes.count {
            scoreEarned += CompetitiveScoring.arrowWeaveCompletionBonus(
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

    private func nextRecommendedRouteID() -> String? {
        for candidate in routes.sorted(by: { $0.unlockAfterEscapes < $1.unlockAfterEscapes }) {
            if !candidate.escaped, canLaunch(route: candidate) {
                return candidate.id
            }
        }
        return routes.first(where: { !$0.escaped })?.id
    }

    private func canLaunch(route: ArrowWeaveRouteState) -> Bool {
        escapedRoutes >= route.unlockAfterEscapes
    }

    private func consumeMove() {
        guard movesUsed < level.moveLimit else { return }
        movesUsed += 1
    }

    private func failRun(message: String) {
        guard !completed else { return }
        failed = true
        isAnimating = false
        highlightedRouteID = nil
        travelTrail = []
        failureMessage = message
        toastMessage = "Game over."
        finishAttempt()
    }

    private func startNewAttempt() {
        scoreTimerTask?.cancel()
        routes = level.routes.map {
            ArrowWeaveRouteState(
                id: $0.id,
                title: $0.title,
                path: $0.path,
                color: $0.color,
                unlockAfterEscapes: $0.unlockAfterEscapes
            )
        }
        movesUsed = 0
        escapedRoutes = 0
        hintsUsed = 0
        undosUsed = 0
        elapsedSeconds = 0
        scoreEarned = 0
        completed = false
        failed = false
        isAnimating = false
        toastMessage = "Fresh board. Tap the front arrow to slither out."
        failureMessage = "Out of moves."
        highlightedRouteID = nil
        travelTrail = []
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
