import Foundation

enum CompetitiveScoring {
    static func campaignEscapePoints(
        level: LevelDefinition,
        escapeIndex: Int,
        elapsedSeconds: TimeInterval,
        hintsUsed: Int,
        undosUsed: Int
    ) -> Int {
        let targetSeconds = campaignTargetSeconds(for: level)
        let speedBonus = max(0, Int((targetSeconds - elapsedSeconds) * 24))
        let base = 120 + (level.totalArrows * 10)
        let sequenceBonus = escapeIndex * 28
        let penalty = (hintsUsed * 6) + (undosUsed * 4)
        return max(25, base + speedBonus + sequenceBonus - penalty)
    }

    static func campaignCompletionBonus(
        level: LevelDefinition,
        elapsedSeconds: TimeInterval,
        hintsUsed: Int,
        undosUsed: Int
    ) -> Int {
        let targetSeconds = campaignTargetSeconds(for: level)
        let speedBonus = max(0, Int((targetSeconds - elapsedSeconds) * 18))
        let base = 160
        let cleanPlayBonus = (hintsUsed == 0 && undosUsed == 0) ? 120 : 0
        return max(80, base + speedBonus + cleanPlayBonus)
    }

    static func arrowWeaveEscapePoints(
        level: ArrowWeaveLevelDefinition,
        escapeIndex: Int,
        elapsedSeconds: TimeInterval,
        hintsUsed: Int,
        undosUsed: Int
    ) -> Int {
        let targetSeconds = arrowWeaveTargetSeconds(for: level)
        let speedBonus = max(0, Int((targetSeconds - elapsedSeconds) * 26))
        let base = 110 + (level.totalRoutes * 12)
        let sequenceBonus = escapeIndex * 24
        let penalty = (hintsUsed * 7) + (undosUsed * 4)
        return max(25, base + speedBonus + sequenceBonus - penalty)
    }

    static func arrowWeaveCompletionBonus(
        level: ArrowWeaveLevelDefinition,
        elapsedSeconds: TimeInterval,
        hintsUsed: Int,
        undosUsed: Int
    ) -> Int {
        let targetSeconds = arrowWeaveTargetSeconds(for: level)
        let speedBonus = max(0, Int((targetSeconds - elapsedSeconds) * 20))
        let base = 150
        let cleanPlayBonus = (hintsUsed == 0 && undosUsed == 0) ? 100 : 0
        return max(80, base + speedBonus + cleanPlayBonus)
    }

    static func campaignScore(
        level: LevelDefinition,
        movesUsed: Int,
        exitsCleared: Int,
        elapsedSeconds: TimeInterval,
        hintsUsed: Int,
        undosUsed: Int,
        completed: Bool,
        failed: Bool
    ) -> Int {
        guard !failed else { return 0 }
        let targetSeconds = campaignTargetSeconds(for: level)
        let speedBonus = max(0, Int((targetSeconds - elapsedSeconds) * 14))
        let clearBonus = exitsCleared * 95
        let cleanPlayBonus = (hintsUsed == 0 && undosUsed == 0) ? 80 : 0
        let completionBonus = completed ? 120 : 0
        let hintPenalty = hintsUsed * 20
        let undoPenalty = undosUsed * 10

        return max(0, clearBonus + speedBonus + cleanPlayBonus + completionBonus - hintPenalty - undoPenalty)
    }

    static func arrowWeaveScore(
        level: ArrowWeaveLevelDefinition,
        movesUsed: Int,
        escapedRoutes: Int,
        elapsedSeconds: TimeInterval,
        hintsUsed: Int,
        undosUsed: Int,
        completed: Bool,
        failed: Bool
    ) -> Int {
        guard !failed else { return 0 }
        let targetSeconds = arrowWeaveTargetSeconds(for: level)
        let speedBonus = max(0, Int((targetSeconds - elapsedSeconds) * 16))
        let routeBonus = escapedRoutes * 110
        let cleanPlayBonus = (hintsUsed == 0 && undosUsed == 0) ? 70 : 0
        let completionBonus = completed ? 120 : 0
        let hintPenalty = hintsUsed * 22
        let undoPenalty = undosUsed * 12

        return max(0, routeBonus + speedBonus + cleanPlayBonus + completionBonus - hintPenalty - undoPenalty)
    }

    static func campaignTargetSeconds(for level: LevelDefinition) -> TimeInterval {
        18
        + (Double(level.totalArrows) * 2.2)
        + (Double(level.moveLimit) * 0.8)
        + (Double(level.rows * level.cols) / 12.0)
    }

    static func arrowWeaveTargetSeconds(for level: ArrowWeaveLevelDefinition) -> TimeInterval {
        16
        + (Double(level.totalRoutes) * 2.0)
        + (Double(level.moveLimit) * 0.9)
        + (Double(level.rows * level.cols) / 14.0)
    }

    static func timeLabel(for seconds: TimeInterval) -> String {
        let clamped = max(0, Int(seconds.rounded()))
        let minutes = clamped / 60
        let remainder = clamped % 60
        return String(format: "%d:%02d", minutes, remainder)
    }
}
