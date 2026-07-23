import Foundation

enum LevelValidator {
    static func isPlayable(_ level: LevelDefinition) -> Bool {
        guard level.moveLimit >= level.arrows.count else { return false }
        var memo = Set<String>()
        return search(level: level, arrows: level.arrows, movesUsed: 0, exitsCleared: 0, memo: &memo)
    }

    private static func search(
        level: LevelDefinition,
        arrows: [ArrowToken],
        movesUsed: Int,
        exitsCleared: Int,
        memo: inout Set<String>
    ) -> Bool {
        if arrows.isEmpty {
            return true
        }

        let key = stateKey(arrows: arrows, movesUsed: movesUsed, exitsCleared: exitsCleared)
        guard memo.insert(key).inserted else { return false }

        for arrow in arrows {
            guard canLaunch(
                level: level,
                arrows: arrows,
                arrow: arrow,
                movesUsed: movesUsed,
                exitsCleared: exitsCleared
            ) else { continue }

            var remaining = arrows
            remaining.removeAll { $0.id == arrow.id }

            if search(
                level: level,
                arrows: remaining,
                movesUsed: movesUsed + 1,
                exitsCleared: exitsCleared + 1,
                memo: &memo
            ) {
                return true
            }
        }

        return false
    }

    private static func canLaunch(
        level: LevelDefinition,
        arrows: [ArrowToken],
        arrow: ArrowToken,
        movesUsed: Int,
        exitsCleared: Int
    ) -> Bool {
        evaluate(
            level: level,
            arrows: arrows,
            arrow: arrow,
            movesUsed: movesUsed,
            exitsCleared: exitsCleared
        )
    }

    private static func evaluate(
        level: LevelDefinition,
        arrows: [ArrowToken],
        arrow: ArrowToken,
        movesUsed: Int,
        exitsCleared: Int
    ) -> Bool {
        var position = arrow.position
        var portalHops = 0

        while true {
            let next = position.shifted(by: arrow.direction)
            guard inBounds(next, rows: level.rows, cols: level.cols) else { return false }

            if arrows.contains(where: { $0.id != arrow.id && $0.position == next }) {
                return false
            }

            let tile = level.board[next.row][next.col]
            switch tile.kind {
            case .empty, .ice, .conveyor:
                position = next
            case .wall:
                return false
            case .gate:
                guard let threshold = tile.unlockAfterExits, exitsCleared >= threshold else { return false }
                position = next
            case .lock:
                guard let threshold = tile.unlockAfterMoves, movesUsed >= threshold else { return false }
                position = next
            case .portal:
                guard let destination = matchingPortal(level: level, tag: tile.tag, excluding: next) else { return false }
                position = destination
                portalHops += 1
                if portalHops > 4 { return false }
            case .exit:
                if let expected = tile.color, expected != arrow.color {
                    return false
                }
                return true
            }
        }
    }

    private static func matchingPortal(level: LevelDefinition, tag: String?, excluding point: BoardPoint) -> BoardPoint? {
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

    private static func stateKey(arrows: [ArrowToken], movesUsed: Int, exitsCleared: Int) -> String {
        let parts = arrows
            .sorted { $0.id < $1.id }
            .map { "\($0.id):\($0.position.row),\($0.position.col),\($0.direction.rawValue),\($0.color.rawValue)" }
            .joined(separator: "|")
        return "\(parts)#m\(movesUsed)#e\(exitsCleared)"
    }

    private static func inBounds(_ point: BoardPoint, rows: Int, cols: Int) -> Bool {
        (0..<rows).contains(point.row) && (0..<cols).contains(point.col)
    }
}
