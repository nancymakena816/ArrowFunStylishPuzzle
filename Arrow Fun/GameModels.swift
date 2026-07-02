import SwiftUI

enum Direction: String, CaseIterable, Codable, Hashable {
    case up
    case right
    case down
    case left

    var vector: BoardPoint {
        switch self {
        case .up: return BoardPoint(row: -1, col: 0)
        case .right: return BoardPoint(row: 0, col: 1)
        case .down: return BoardPoint(row: 1, col: 0)
        case .left: return BoardPoint(row: 0, col: -1)
        }
    }

    var symbolName: String {
        switch self {
        case .up: return "arrow.up"
        case .right: return "arrow.right"
        case .down: return "arrow.down"
        case .left: return "arrow.left"
        }
    }
}

struct BoardPoint: Hashable, Codable {
    var row: Int
    var col: Int

    func shifted(by direction: Direction) -> BoardPoint {
        let delta = direction.vector
        return BoardPoint(row: row + delta.row, col: col + delta.col)
    }
}

enum ArrowColor: String, CaseIterable, Codable, Hashable {
    case ember
    case ocean
    case jade
    case solar
    case coral
    case mint
    case indigo
    case amber

    var title: String {
        switch self {
        case .ember: return "Ember"
        case .ocean: return "Ocean"
        case .jade: return "Jade"
        case .solar: return "Solar"
        case .coral: return "Coral"
        case .mint: return "Mint"
        case .indigo: return "Indigo"
        case .amber: return "Amber"
        }
    }

    var color: Color {
        switch self {
        case .ember: return Color(red: 0.95, green: 0.39, blue: 0.28)
        case .ocean: return Color(red: 0.20, green: 0.57, blue: 0.95)
        case .jade: return Color(red: 0.19, green: 0.76, blue: 0.56)
        case .solar: return Color(red: 0.95, green: 0.78, blue: 0.26)
        case .coral: return Color(red: 0.98, green: 0.54, blue: 0.42)
        case .mint: return Color(red: 0.36, green: 0.84, blue: 0.69)
        case .indigo: return Color(red: 0.44, green: 0.57, blue: 0.96)
        case .amber: return Color(red: 0.98, green: 0.68, blue: 0.24)
        }
    }

    var accent: Color {
        switch self {
        case .ember: return Color(red: 1.00, green: 0.67, blue: 0.54)
        case .ocean: return Color(red: 0.53, green: 0.82, blue: 1.00)
        case .jade: return Color(red: 0.55, green: 0.95, blue: 0.74)
        case .solar: return Color(red: 1.00, green: 0.92, blue: 0.58)
        case .coral: return Color(red: 1.00, green: 0.78, blue: 0.66)
        case .mint: return Color(red: 0.70, green: 0.98, blue: 0.86)
        case .indigo: return Color(red: 0.72, green: 0.82, blue: 1.00)
        case .amber: return Color(red: 1.00, green: 0.88, blue: 0.62)
        }
    }

    var markerSymbol: String {
        switch self {
        case .ember: return "flame.fill"
        case .ocean: return "drop.fill"
        case .jade: return "leaf.fill"
        case .solar: return "sun.max.fill"
        case .coral: return "heart.fill"
        case .mint: return "sparkles"
        case .indigo: return "moon.stars.fill"
        case .amber: return "bolt.fill"
        }
    }
}

enum BoardTileKind: String, Codable, Hashable {
    case empty
    case wall
    case exit
    case portal
    case gate
    case lock
    case ice
    case conveyor
}

struct BoardTile: Hashable {
    var kind: BoardTileKind = .empty
    var direction: Direction?
    var color: ArrowColor?
    var tag: String?
    var unlockAfterExits: Int?
    var unlockAfterMoves: Int?

    static var empty: BoardTile { BoardTile() }

    static func wall() -> BoardTile {
        // Launch build keeps the core lane mechanic clean and solvable.
        // Walls are reserved for future route-manipulation mechanics.
        BoardTile.empty
    }

    static func exit(direction: Direction, color: ArrowColor? = nil) -> BoardTile {
        BoardTile(kind: .exit, direction: direction, color: color)
    }

    static func portal(tag: String, color: ArrowColor? = nil) -> BoardTile {
        BoardTile(kind: .portal, color: color, tag: tag)
    }

    static func gate(tag: String, unlockAfterExits: Int, color: ArrowColor? = nil) -> BoardTile {
        BoardTile(kind: .gate, color: color, tag: tag, unlockAfterExits: unlockAfterExits)
    }

    static func lock(tag: String, unlockAfterMoves: Int, color: ArrowColor? = nil) -> BoardTile {
        BoardTile(kind: .lock, color: color, tag: tag, unlockAfterMoves: unlockAfterMoves)
    }

    var label: String {
        switch kind {
        case .empty: return "Empty"
        case .wall: return "Wall"
        case .exit: return "Exit"
        case .portal: return "Portal"
        case .gate: return "Gate"
        case .lock: return "Lock"
        case .ice: return "Ice"
        case .conveyor: return "Conveyor"
        }
    }
}

struct ArrowToken: Identifiable, Hashable {
    let id: String
    var position: BoardPoint
    var direction: Direction
    var color: ArrowColor
}

struct LevelDefinition: Identifiable, Hashable {
    let id: String
    let world: Int
    let number: Int
    let title: String
    let subtitle: String
    let rows: Int
    let cols: Int
    let moveLimit: Int
    let board: [[BoardTile]]
    let arrows: [ArrowToken]
    let recommendedOrder: [String]
    let mechanicNotes: [String]

    var totalArrows: Int { arrows.count }
}

struct GameProgress: Codable {
    var highestUnlockedLevel: Int = 0
    var lastPlayedLevel: Int = 0
    var bestStarsByLevel: [Int: Int] = [:]
}

struct GameSettings: Codable {
    var musicEnabled: Bool = true
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
}

struct TravelPlan {
    enum Outcome {
        case success(path: [BoardPoint])
        case blocked(message: String)
    }

    let outcome: Outcome
}

struct GameSnapshot {
    let arrows: [ArrowToken]
    let movesUsed: Int
    let exitsCleared: Int
}
