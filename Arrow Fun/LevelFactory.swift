import SwiftUI

@MainActor
enum LevelFactory {
    private struct LaneBlueprint {
        enum Axis {
            case horizontal
            case vertical
        }

        let axis: Axis
        let fixed: Int
        let direction: Direction
        let arrowPositions: [Int]
        let exitIndex: Int
        let color: ArrowColor
    }

    private struct Placement {
        let point: BoardPoint
        let tile: BoardTile
    }

    static var allLevels: [LevelDefinition] {
        (1...150).map { makeLevel(number: $0) }
    }

    static func makeLevel(number: Int) -> LevelDefinition {
        let world = 1
        let stage = number - 1
        let candidate = campaignLevel(number: number, stage: stage)
        return LevelValidator.isPlayable(candidate) ? candidate : safeFallbackLevel(number: number, world: world, stage: stage)
    }

    private static func campaignLevel(number: Int, stage: Int) -> LevelDefinition {
        let chapter = stage / 10
        let variant = stage % 10
        let sizeProfiles: [(Int, Int)] = [
            (5, 5),
            (5, 6),
            (6, 5),
            (6, 6),
            (6, 7),
            (7, 6),
            (7, 7),
            (7, 8),
            (8, 7),
            (8, 8)
        ]
        let baseSize = sizeProfiles[variant]
        let rows = min(8, baseSize.0 + min(chapter / 2, 2))
        let cols = min(8, baseSize.1 + min(chapter / 3, 2))

        let arrowCount = min(3 + stage / 6 + (variant >= 7 ? 1 : 0), 9)
        let moveLimit = arrowCount + 3 + min(chapter, 2)
        let palette = ArrowColor.allCases
        let primary = palette[(stage * 2 + chapter) % palette.count]
        let secondary = palette[(stage * 3 + 1) % palette.count]
        let accent = palette[(stage * 5 + 2) % palette.count]
        let trio = palette[(stage * 7 + 3) % palette.count]
        let extra = palette[(stage * 11 + 4) % palette.count]

        let portalTag = "p-\(number)"
        let gateTag = "g-\(number)"
        let lockTag = "l-\(number)"

        var placements: [Placement] = []
        var lanes: [LaneBlueprint] = []

        func addHorizontalLane(row: Int, direction: Direction, color: ArrowColor, exitIndex: Int, positions: [Int]) {
            lanes.append(
                LaneBlueprint(
                    axis: .horizontal,
                    fixed: row,
                    direction: direction,
                    arrowPositions: positions,
                    exitIndex: exitIndex,
                    color: color
                )
            )
        }

        func addVerticalLane(col: Int, direction: Direction, color: ArrowColor, exitIndex: Int, positions: [Int]) {
            lanes.append(
                LaneBlueprint(
                    axis: .vertical,
                    fixed: col,
                    direction: direction,
                    arrowPositions: positions,
                    exitIndex: exitIndex,
                    color: color
                )
            )
        }

        func clamp(_ value: Int, upper: Int) -> Int {
            min(max(value, 0), upper)
        }

        func uniqueIndices(_ values: [Int], upper: Int) -> [Int] {
            Array(Set(values.map { clamp($0, upper: upper) })).sorted()
        }

        let topRow = 1
        let bottomRow = max(1, rows - 2)
        let leftCol = 1
        let rightCol = max(1, cols - 2)
        let midRow = max(1, rows / 2)
        let midCol = max(1, cols / 2)
        let upperRow = max(1, rows - 3)
        let upperCol = max(1, cols - 3)

        switch variant {
        case 0:
            addHorizontalLane(
                row: topRow,
                direction: .right,
                color: primary,
                exitIndex: cols - 1,
                positions: uniqueIndices([0, 1, 2 + chapter, 3 + (stage % 2)], upper: cols - 2)
            )
            if chapter >= 1 {
                addVerticalLane(
                    col: rightCol,
                    direction: .down,
                    color: secondary,
                    exitIndex: rows - 1,
                    positions: uniqueIndices([0, 1 + chapter, 2 + (stage % 2)], upper: rows - 2)
                )
            }
        case 1:
            addHorizontalLane(
                row: topRow,
                direction: .right,
                color: primary,
                exitIndex: cols - 1,
                positions: uniqueIndices([0, 1, 2, 3 + chapter], upper: cols - 2)
            )
            addHorizontalLane(
                row: bottomRow,
                direction: .left,
                color: secondary,
                exitIndex: 0,
                positions: uniqueIndices([cols - 1, cols - 2, cols - 3 - (stage % 2)], upper: cols - 1)
            )
        case 2:
            addVerticalLane(
                col: leftCol,
                direction: .down,
                color: primary,
                exitIndex: rows - 1,
                positions: uniqueIndices([0, 1, 2 + chapter, 3 + (stage % 2)], upper: rows - 2)
            )
            addVerticalLane(
                col: rightCol,
                direction: .up,
                color: secondary,
                exitIndex: 0,
                positions: uniqueIndices([rows - 1, rows - 2, rows - 3 - (chapter % 2)], upper: rows - 1)
            )
            placements.append(.init(point: BoardPoint(row: midRow, col: midCol), tile: .portal(tag: portalTag, color: primary)))
            placements.append(.init(point: BoardPoint(row: min(rows - 2, midRow + 1), col: max(1, midCol - 1)), tile: .portal(tag: portalTag, color: primary)))
        case 3:
            addHorizontalLane(
                row: topRow,
                direction: .right,
                color: primary,
                exitIndex: cols - 1,
                positions: uniqueIndices([0, 1, 2 + (stage % 2), 3 + chapter], upper: cols - 2)
            )
            addVerticalLane(
                col: midCol,
                direction: .down,
                color: accent,
                exitIndex: rows - 1,
                positions: uniqueIndices([0, 1, 2 + chapter, 3], upper: rows - 2)
            )
            placements.append(.init(point: BoardPoint(row: midRow, col: midCol), tile: .gate(tag: gateTag, unlockAfterExits: 1, color: secondary)))
        case 4:
            addHorizontalLane(
                row: topRow,
                direction: .right,
                color: primary,
                exitIndex: cols - 1,
                positions: uniqueIndices([0, 1, 2, 3 + chapter], upper: cols - 2)
            )
            addHorizontalLane(
                row: bottomRow,
                direction: .left,
                color: secondary,
                exitIndex: 0,
                positions: uniqueIndices([cols - 1, cols - 2, cols - 3, cols - 4 + (stage % 2)], upper: cols - 1)
            )
            placements.append(.init(point: BoardPoint(row: midRow, col: midCol), tile: .lock(tag: lockTag, unlockAfterMoves: 2 + chapter, color: trio)))
        case 5:
            addVerticalLane(
                col: leftCol,
                direction: .down,
                color: primary,
                exitIndex: rows - 1,
                positions: uniqueIndices([0, 1, 2 + chapter, 3], upper: rows - 2)
            )
            addHorizontalLane(
                row: bottomRow,
                direction: .left,
                color: secondary,
                exitIndex: 0,
                positions: uniqueIndices([cols - 1, cols - 2, cols - 3 - (chapter % 2)], upper: cols - 1)
            )
            placements.append(.init(point: BoardPoint(row: midRow, col: midCol), tile: .portal(tag: portalTag, color: primary)))
            placements.append(.init(point: BoardPoint(row: max(1, midRow - 1), col: max(1, midCol - 1)), tile: .portal(tag: portalTag, color: primary)))
            placements.append(.init(point: BoardPoint(row: min(rows - 2, midRow + 1), col: min(cols - 2, midCol + 1)), tile: .gate(tag: gateTag, unlockAfterExits: 2, color: accent)))
        case 6:
            addHorizontalLane(
                row: topRow,
                direction: .right,
                color: primary,
                exitIndex: cols - 1,
                positions: uniqueIndices([0, 1, 2, 3, 4 + chapter], upper: cols - 2)
            )
            addHorizontalLane(
                row: bottomRow,
                direction: .left,
                color: secondary,
                exitIndex: 0,
                positions: uniqueIndices([cols - 1, cols - 2, cols - 3, cols - 4], upper: cols - 1)
            )
            addVerticalLane(
                col: rightCol,
                direction: .down,
                color: accent,
                exitIndex: rows - 1,
                positions: uniqueIndices([0, 1, 2 + (chapter % 2), 3], upper: rows - 2)
            )
            placements.append(.init(point: BoardPoint(row: midRow, col: midCol), tile: .lock(tag: lockTag, unlockAfterMoves: 3, color: trio)))
        case 7:
            addVerticalLane(
                col: leftCol,
                direction: .down,
                color: primary,
                exitIndex: rows - 1,
                positions: uniqueIndices([0, 1, 2, 3 + chapter], upper: rows - 2)
            )
            addVerticalLane(
                col: rightCol,
                direction: .up,
                color: secondary,
                exitIndex: 0,
                positions: uniqueIndices([rows - 1, rows - 2, rows - 3, rows - 4 + (stage % 2)], upper: rows - 1)
            )
            addHorizontalLane(
                row: bottomRow,
                direction: .left,
                color: accent,
                exitIndex: 0,
                positions: uniqueIndices([cols - 1, cols - 2, cols - 3], upper: cols - 1)
            )
            placements.append(.init(point: BoardPoint(row: midRow, col: midCol), tile: .portal(tag: portalTag, color: primary)))
            placements.append(.init(point: BoardPoint(row: max(1, midRow - 1), col: max(1, midCol - 1)), tile: .portal(tag: portalTag, color: primary)))
            placements.append(.init(point: BoardPoint(row: min(rows - 2, midRow + 1), col: min(cols - 2, midCol + 1)), tile: .lock(tag: lockTag, unlockAfterMoves: 4, color: trio)))
        case 8:
            addHorizontalLane(
                row: topRow,
                direction: .right,
                color: primary,
                exitIndex: cols - 1,
                positions: uniqueIndices([0, 1, 2, 4 + chapter], upper: cols - 2)
            )
            addVerticalLane(
                col: rightCol,
                direction: .down,
                color: secondary,
                exitIndex: rows - 1,
                positions: uniqueIndices([0, 1, 2 + chapter, 3], upper: rows - 2)
            )
            placements.append(.init(point: BoardPoint(row: midRow, col: midCol), tile: .portal(tag: portalTag, color: primary)))
            placements.append(.init(point: BoardPoint(row: max(1, midRow - 1), col: max(1, midCol - 1)), tile: .portal(tag: portalTag, color: primary)))
            placements.append(.init(point: BoardPoint(row: min(rows - 2, midRow + 1), col: min(cols - 2, midCol + 1)), tile: .gate(tag: gateTag, unlockAfterExits: 2, color: accent)))
        default:
            addHorizontalLane(
                row: topRow,
                direction: .right,
                color: primary,
                exitIndex: cols - 1,
                positions: uniqueIndices([0, 1, 2, 3, 4 + chapter], upper: cols - 2)
            )
            addHorizontalLane(
                row: bottomRow,
                direction: .left,
                color: secondary,
                exitIndex: 0,
                positions: uniqueIndices([cols - 1, cols - 2, cols - 3, cols - 4], upper: cols - 1)
            )
            addVerticalLane(
                col: midCol,
                direction: .down,
                color: accent,
                exitIndex: rows - 1,
                positions: uniqueIndices([0, 1, 2, 3 + chapter], upper: rows - 2)
            )
            placements.append(.init(point: BoardPoint(row: midRow, col: midCol), tile: .gate(tag: gateTag, unlockAfterExits: 2, color: primary)))
            placements.append(.init(point: BoardPoint(row: max(1, midRow - 1), col: max(1, midCol - 1)), tile: .portal(tag: portalTag, color: primary)))
            placements.append(.init(point: BoardPoint(row: min(rows - 2, midRow + 1), col: min(cols - 2, midCol + 1)), tile: .portal(tag: portalTag, color: primary)))
            placements.append(.init(point: BoardPoint(row: upperRow, col: upperCol), tile: .lock(tag: lockTag, unlockAfterMoves: 4, color: extra)))
        }

        if lanes.isEmpty {
            addHorizontalLane(row: topRow, direction: .right, color: primary, exitIndex: cols - 1, positions: uniqueIndices([0, 1, 2], upper: cols - 2))
        }

        let hintNotes: [String] = {
            switch variant {
            case 0: return ["Tap the front arrow first", "The pace changes by chapter"]
            case 1: return ["Two lanes start to overlap", "Mind the order"]
            case 2: return ["Portal levels begin", "Watch the lane direction"]
            case 3: return ["Gates open after progress", "Use the earlier exits"]
            case 4: return ["Locks punish rushing", "Plan the sequence"]
            case 5: return ["Portals and gates together", "The board is now a puzzle"]
            case 6: return ["More arrows, more timing", "Do not rush the second lane"]
            case 7: return ["A tighter route mix", "One wrong tap can waste a move"]
            case 8: return ["Portals reshape the board", "Hold your sequence"]
            default: return ["The pressure climbs fast", "Moves are precious"]
            }
        }()

        let sceneName = sceneNameForVariant(variant)

        return buildLevel(
            number: number,
            world: 1,
            title: "\(titleForStage(stage)) • \(sceneName)",
            subtitle: subtitleForStage(stage),
            rows: rows,
            cols: cols,
            moveLimit: moveLimit,
            lanes: lanes,
            placements: placements,
            mechanicNotes: hintNotes
        )
    }

    private static func sceneNameForVariant(_ variant: Int) -> String {
        switch variant {
        case 0: return "Sprint"
        case 1: return "Split"
        case 2: return "Mirror"
        case 3: return "Cross"
        case 4: return "Lock"
        case 5: return "Warp"
        case 6: return "Thread"
        case 7: return "Cascade"
        case 8: return "Portal"
        default: return "Storm"
        }
    }

    private static func titleForStage(_ stage: Int) -> String {
        switch stage {
        case 0..<12: return "Warm Tap"
        case 12..<30: return "Queue Shift"
        case 30..<45: return "Portal Start"
        case 45..<60: return "Gate Flow"
        case 60..<75: return "Lock Line"
        case 75..<90: return "Warp Lock"
        case 90..<110: return "Mind Maze"
        case 110..<130: return "Deep Sequence"
        case 130..<145: return "Arrow Pressure"
        default: return "Final Escape"
        }
    }

    private static func subtitleForStage(_ stage: Int) -> String {
        switch stage {
        case 0..<12: return "A gentle warm-up."
        case 12..<30: return "The order starts to matter."
        case 30..<45: return "Portals change the route."
        case 45..<60: return "Gates open after progress."
        case 60..<75: return "Locks punish guesswork."
        case 75..<90: return "More mechanics, less room for error."
        case 90..<110: return "A true sequence puzzle."
        case 110..<130: return "Bigger board, tighter logic."
        case 130..<145: return "The pressure climbs fast."
        default: return "Last stop. Make every tap count."
        }
    }

    private static func buildLevel(
        number: Int,
        world: Int,
        title: String,
        subtitle: String,
        rows: Int,
        cols: Int,
        moveLimit: Int,
        lanes: [LaneBlueprint],
        placements: [Placement],
        mechanicNotes: [String]
    ) -> LevelDefinition {
        var board = Array(repeating: Array(repeating: BoardTile.empty, count: cols), count: rows)
        var arrows: [ArrowToken] = []
        var laneOrder: [[String]] = []

        func point(for lane: LaneBlueprint, index: Int) -> BoardPoint {
            switch lane.axis {
            case .horizontal:
                return BoardPoint(row: lane.fixed, col: index)
            case .vertical:
                return BoardPoint(row: index, col: lane.fixed)
            }
        }

        for (laneIndex, lane) in lanes.enumerated() {
            let exitPoint = point(for: lane, index: lane.exitIndex)
            if inBounds(exitPoint, rows: rows, cols: cols) {
                board[exitPoint.row][exitPoint.col] = .exit(direction: lane.direction, color: lane.color)
            }

            var idsForLane: [(index: Int, id: String)] = []
            for (slotIndex, arrowPosition) in lane.arrowPositions.enumerated() {
                let arrowPoint = point(for: lane, index: arrowPosition)
                guard inBounds(arrowPoint, rows: rows, cols: cols) else { continue }
                let arrowID = "\(number)-\(laneIndex)-\(slotIndex)"
                arrows.append(
                    ArrowToken(
                        id: arrowID,
                        position: arrowPoint,
                        direction: lane.direction,
                        color: lane.color
                    )
                )
                idsForLane.append((index: arrowPosition, id: arrowID))
            }
            let orderedIDs: [String]
            switch lane.direction {
            case .right, .down:
                orderedIDs = idsForLane.sorted { $0.index > $1.index }.map(\.id)
            case .left, .up:
                orderedIDs = idsForLane.sorted { $0.index < $1.index }.map(\.id)
            }
            laneOrder.append(orderedIDs)
        }

        for placement in placements {
            guard inBounds(placement.point, rows: rows, cols: cols) else { continue }
            board[placement.point.row][placement.point.col] = placement.tile
        }

        let recommendedOrder = laneOrder.flatMap { $0 }

        return LevelDefinition(
            id: "world\(world)-level\(number)",
            world: world,
            number: number,
            title: title,
            subtitle: subtitle,
            rows: rows,
            cols: cols,
            moveLimit: moveLimit,
            board: board,
            arrows: arrows,
            recommendedOrder: recommendedOrder,
            mechanicNotes: mechanicNotes
        )
    }

    private static func inBounds(_ point: BoardPoint, rows: Int, cols: Int) -> Bool {
        (0..<rows).contains(point.row) && (0..<cols).contains(point.col)
    }

    private static func safeFallbackLevel(number: Int, world: Int, stage: Int) -> LevelDefinition {
        let dimensions: [(Int, Int)] = [
            (5, 5),
            (6, 6),
            (6, 6),
            (7, 7),
            (8, 8)
        ]
        let (rows, cols) = dimensions[min(max(world - 1, 0), dimensions.count - 1)]
        let arrowCount = min(2 + (stage / 10), 4)
        let primaryColor: ArrowColor = ArrowColor.allCases[(world + stage) % ArrowColor.allCases.count]
        let secondaryColor: ArrowColor = ArrowColor.allCases[(world + stage + 1) % ArrowColor.allCases.count]

        var board = Array(repeating: Array(repeating: BoardTile.empty, count: cols), count: rows)
        let firstRow = min(1 + (stage % max(1, rows - 2)), rows - 2)
        let secondRow = min(rows - 2, firstRow + 2)

        board[firstRow][cols - 1] = .exit(direction: .right, color: primaryColor)
        board[secondRow][0] = .exit(direction: .left, color: secondaryColor)

        let firstArrows = Array(0..<arrowCount).map { index -> ArrowToken in
            ArrowToken(
                id: "\(number)-a\(index)",
                position: BoardPoint(row: firstRow, col: index),
                direction: .right,
                color: primaryColor
            )
        }

        let secondArrows = Array(0..<max(1, arrowCount - 1)).map { index -> ArrowToken in
            ArrowToken(
                id: "\(number)-b\(index)",
                position: BoardPoint(row: secondRow, col: cols - 1 - index),
                direction: .left,
                color: secondaryColor
            )
        }

        if stage % 5 == 3 {
            let portalTag = "fallback-\(number)"
            board[firstRow][min(cols - 2, 3)] = .portal(tag: portalTag, color: primaryColor)
            board[secondRow][max(1, cols - 2)] = .portal(tag: portalTag, color: primaryColor)
        }

        let arrows = firstArrows + secondArrows
        let order = arrows.sorted {
            if $0.position.row == $1.position.row {
                return $0.position.col > $1.position.col
            }
            return $0.position.row < $1.position.row
        }.map(\.id)

        return LevelDefinition(
            id: "world\(world)-level\(number)",
            world: world,
            number: number,
            title: "Flow \(number)",
            subtitle: "A safe campaign route.",
            rows: rows,
            cols: cols,
            moveLimit: 6 + arrowCount + (stage / 10),
            board: board,
            arrows: arrows,
            recommendedOrder: order,
            mechanicNotes: [
                "Reliable fallback layout",
                "More arrows appear as the campaign advances"
            ]
        )
    }
}
