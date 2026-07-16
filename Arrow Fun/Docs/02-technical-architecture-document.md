# Technical Architecture Document

## Architecture Summary

The game should be built as a mobile-first puzzle engine with a clear separation between game logic, presentation, persistence, and platform services. The core puzzle engine should be deterministic and testable without UI, so levels can be validated automatically before release.

Recommended implementation path:

- SwiftUI for a focused iOS release.
- Local-first gameplay with optional backend support for daily puzzles and analytics.
- Keep the core engine independent from any future third-party services.

If the project expands beyond iOS later, the architecture can be revisited. For this build, SwiftUI remains the target.

## High-Level Components

- Game Client
  - Board renderer
  - Input controller
  - Puzzle engine
  - Animation system
  - Sound and haptics
  - UI screens
  - Local save system
  - Analytics adapter

- Content Pipeline
  - Level schema
  - Level editor or spreadsheet import
  - Level validator
  - Difficulty tags
  - Localization files

- Optional Backend
  - Daily puzzle configuration
  - Event collection endpoint or third-party analytics
  - No account system required for version 1

## Client Layers

### Presentation Layer

Responsible for visual output only.

- Board grid rendering
- Arrow sprites and states
- Tile effects
- Movement animations
- Win and fail dialogs
- Menus, settings, and level map

### Input Layer

Responsible for translating touch gestures into game commands.

- Tap arrow
- Drag or swap arrow if enabled
- Rotate arrow if enabled
- Tap undo, hint, restart
- Block input during movement animation

### Puzzle Engine

Responsible for authoritative game rules.

- Load level definitions.
- Validate available moves.
- Apply move commands.
- Resolve arrow movement.
- Detect collisions, exits, blockers, portals, and gates.
- Track move count and completion state.
- Provide hint candidates.

The engine should expose pure functions where possible:

```text
GameState + PlayerAction -> GameResult
```

### Persistence Layer

Stores local player state.

- Completed levels
- Stars
- Coins
- Hint inventory
- Settings
- Daily streak cache

Use encrypted storage only if a future feature truly requires sensitive data. Normal progress can use platform storage with basic integrity checks.

### Platform Services Layer

Abstracts external SDKs behind interfaces.

- AnalyticsProvider
- HapticsProvider
- RemoteConfigProvider

This prevents core gameplay from depending directly on vendor SDKs.

## Data Model

### Level Definition

```json
{
  "id": "world1_level001",
  "world": 1,
  "difficulty": "easy",
  "grid": { "rows": 5, "cols": 5 },
  "moveLimit": 12,
  "tiles": [
    { "x": 0, "y": 0, "type": "empty" },
    { "x": 1, "y": 0, "type": "arrow", "direction": "right", "color": "red" },
    { "x": 4, "y": 0, "type": "exit", "direction": "right", "color": "red" }
  ],
  "mechanics": ["basic", "color_exit"]
}
```

### Runtime Game State

- Level ID
- Board cells
- Arrow entities
- Tile states
- Move history stack
- Move count
- Remaining arrows
- Completion status

### Player Profile

- Current world
- Current level
- Completed levels
- Star counts
- Hint count
- Coin balance
- Settings

## Level Validation

Every level should pass automated validation before shipping.

Validation rules:

- Level has at least one valid solution.
- Required exits exist.
- Arrows do not start outside board bounds.
- Tile references are valid.
- Portals are paired.
- Move limit is achievable.
- Difficulty tag matches solver estimate.
- No softlock unless restart is available.

## Hint System

Preferred approach:

- Store known solution paths for handcrafted levels.
- Use current move history to suggest the next action from the canonical solution.
- For dynamic states, run a bounded solver to find a valid next move.

The hint system should never block gameplay or require payment.

## Offline Behavior

Required offline support:

- Campaign levels playable offline.
- Progress saved offline.
- Settings available offline.
- Daily puzzle can use last cached puzzle or show unavailable state.

## Analytics Events

Collect only necessary gameplay events.

- app_open
- level_start
- level_complete
- level_fail
- hint_used
- settings_changed

Avoid collecting personal data unless necessary. Keep analytics anonymous by default.

## Release Scope

The first release is a complete offline build.

If future versions add online or storefront features, they should be treated as separate scope items with updated review materials.

## Build And Release

Environments:

- Development
- QA
- TestFlight
- Production

Release checks:

- Level validation passes.
- No debug UI visible.
- No placeholder metadata.
- Privacy manifest and tracking prompts match actual SDK behavior.

## Testing Strategy

- Unit tests for puzzle engine.
- Solver tests for every level.
- Snapshot tests for key board states.
- Device tests on small and large iPhones.
- iPad layout test.
- Offline mode test.
- Crash and memory profiling.

## Technical Risks

- Poorly separated engine and UI may make bugs hard to fix.
- Unvalidated levels can create impossible puzzles.
- Extra third-party SDKs can create privacy or review risk.
- Animation timing bugs can desync visual and logical board state.

## Recommended Milestones

- M1: Core puzzle engine and 20 prototype levels.
- M2: Final visual direction and board animation.
- M3: 150 levels plus validation tooling.
- M4: Settings, privacy, analytics.
- M5: TestFlight QA and App Review submission.
