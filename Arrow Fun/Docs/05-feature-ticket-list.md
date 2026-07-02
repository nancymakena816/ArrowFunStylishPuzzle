# Feature Ticket List

## Epic 1: Product Foundation

### FT-001: Finalize Original Game Name

Define a final app name that does not conflict with existing arrow puzzle apps.

Acceptance criteria:

- Name search completed across App Store and Play Store.
- Name is not a close clone of competitor names.
- Name approved for metadata, icon, and marketing use.

### FT-002: Define Visual Identity

Create original art direction for board, arrows, icon, colors, and UI.

Acceptance criteria:

- Moodboard approved.
- Icon concept approved.
- Color palette and typography selected.
- Competitor similarity review completed.

### FT-003: Create Level Design Rules

Document level design constraints, difficulty tags, and mechanic progression.

Acceptance criteria:

- Difficulty definitions exist.
- Per-world mechanic rules exist.
- Level validation requirements documented.

## Epic 2: Core Gameplay

### FT-004: Implement Board Grid System

Create dynamic grid rendering for multiple board sizes.

Acceptance criteria:

- Supports 5x5 through 8x8 grids.
- Board fits supported iPhone screens.
- Tile positions are stable during gameplay.

### FT-005: Implement Arrow Movement Engine

Build deterministic arrow movement and collision resolution.

Acceptance criteria:

- Arrows move in correct direction.
- Walls block movement.
- Exits remove arrows.
- Collisions are detected.
- Engine can run without UI.

### FT-006: Implement Move History And Undo

Allow players to undo completed moves.

Acceptance criteria:

- Undo restores board state.
- Undo restores move count.
- Undo is disabled when no moves exist.
- Undo cannot trigger during animation.

### FT-007: Implement Restart Level

Allow full level reset.

Acceptance criteria:

- Restart restores initial state.
- Move count resets.
- Confirmation appears only if needed.

### FT-008: Implement Level Completion

Detect when a level is solved and show completion flow.

Acceptance criteria:

- Completion triggers after final objective.
- Win dialog shows stars and moves.
- Player can replay or continue.

## Epic 3: Special Mechanics

### FT-009: Add Color Exits

Require arrows to exit through matching destination tiles.

Acceptance criteria:

- Matching arrows exit successfully.
- Wrong-color arrows are blocked or fail clearly.
- Color markers are accessible beyond color alone.

### FT-010: Add Portals

Allow arrows to teleport between paired portal tiles.

Acceptance criteria:

- Portal pairs validate correctly.
- Arrow exits portal in expected direction.
- Animation clearly communicates teleport.

### FT-011: Add Gates And Locks

Create gates that open based on board events.

Acceptance criteria:

- Locked paths block arrows.
- Gates update after configured trigger.
- State is saved in move history.

### FT-012: Add Ice Lanes

Create tiles where arrows slide until stopped.

Acceptance criteria:

- Arrow continues sliding on ice.
- Collision and exit rules still apply.
- Animation remains readable.

### FT-013: Add Conveyor Tiles

Create tiles that redirect arrow movement.

Acceptance criteria:

- Conveyor changes direction reliably.
- Visual direction is clear.
- Solver supports conveyor rules.

## Epic 4: Levels And Content

### FT-014: Create Level Schema

Define JSON or asset format for all levels.

Acceptance criteria:

- Schema supports all launch mechanics.
- Invalid levels fail validation.
- Level IDs are stable.

### FT-015: Build Level Validator

Create tooling to check level correctness.

Acceptance criteria:

- Detects invalid tiles.
- Detects unpaired portals.
- Detects impossible levels.
- Runs before release.

### FT-016: Produce Launch Level Pack

Create at least 150 levels for launch.

Acceptance criteria:

- 150 levels complete.
- Levels grouped into worlds.
- All levels pass validation.
- Difficulty curve reviewed.

### FT-017: Implement Daily Puzzle

Add one daily challenge puzzle.

Acceptance criteria:

- Daily puzzle can load from local or remote config.
- Offline fallback exists.
- Streak progress is saved.

## Epic 5: User Interface

### FT-018: Build Home Screen

Create main entry screen.

Acceptance criteria:

- Continue button works.
- Level map accessible.
- Daily puzzle accessible.
- Settings accessible.

### FT-019: Build Gameplay HUD

Create level HUD with moves, remaining arrows, hints, and controls.

Acceptance criteria:

- HUD fits small iPhone screens.
- Controls have 44x44 point tap targets.
- Counters update correctly.

### FT-020: Build Level Map

Create world and level selection UI.

Acceptance criteria:

- Completed levels show stars.
- Locked levels show status.
- Player can replay unlocked levels.

### FT-021: Build Settings Screen

Create settings and support UI.

Acceptance criteria:

- Music toggle works.
- Sound toggle works.
- Haptics toggle works.
- Privacy policy opens.
- Support contact visible.
- App version visible.

### FT-022: Improve Progression Presentation

Create a polished free-to-play progression flow with no monetization UI.

Acceptance criteria:

- Home screen shows a clear continue action.
- Level map displays completed level feedback.
- Settings screen contains support and legal links only.
- No monetization controls are visible in the shipped build.

## Epic 6: Progression

### FT-023: Implement Stars

Award stars based on move efficiency.

Acceptance criteria:

- Star thresholds are defined per level.
- Stars persist.
- Level map displays stars.

### FT-024: Implement Coins And Hints

Add player economy for hints and rewards.

Acceptance criteria:

- Coins persist.
- Hints persist.
- Balances do not expire.

### FT-025: Implement Daily Streaks

Reward daily puzzle completion.

Acceptance criteria:

- Streak increments once per day.
- Missed day resets or pauses according to product rule.
- Offline behavior is defined.

## Epic 7: Progression And Retention

## Epic 8: Accessibility And Polish

### FT-029: Add Accessibility Labels

Add labels for buttons and key game elements.

Acceptance criteria:

- VoiceOver identifies primary controls.
- Buttons have meaningful labels.
- Color exits have non-color indicators.

### FT-030: Add Sound And Haptics

Add feedback for key actions.

Acceptance criteria:

- Valid move feedback exists.
- Invalid move feedback exists.
- Win feedback exists.
- Settings toggles disable feedback.

### FT-031: Add Reduced Motion Support

Respect reduced motion where practical.

Acceptance criteria:

- Large effects are reduced.
- Gameplay remains understandable.
- Setting is tested on device.

## Epic 9: Compliance And Release

### FT-032: Create Privacy Policy

Publish accurate privacy policy.

Acceptance criteria:

- Policy covers analytics and data retention.
- URL is live before submission.
- App Store privacy labels match policy.

### FT-033: Prepare App Store Metadata

Create App Store listing content.

Acceptance criteria:

- Screenshots show real gameplay.
- Description does not make false claims.
- No monetization features are advertised because none exist in this build.
- Support URL is live.

### FT-034: Prepare App Review Notes

Write notes for Apple App Review.

Acceptance criteria:

- No login required or demo mode documented.
- Daily puzzle and remote config explained if used.

### FT-035: Run Release QA

Complete pre-submission test plan.

Acceptance criteria:

- Real-device smoke test passed.
- Offline test passed.
- No placeholder content remains.
- Crash-free testing completed.

## Epic 10: Analytics And Operations

### FT-036: Integrate Crash Reporting

Capture crashes for production monitoring.

Acceptance criteria:

- Crash reports include app version.
- No personal data is logged.
- Crash dashboard access is restricted.

### FT-037: Integrate Anonymous Analytics

Track core gameplay funnel events.

Acceptance criteria:

- level_start tracked.
- level_complete tracked.
- hint_used tracked.
- Privacy labels account for analytics SDK.

### FT-038: Add Remote Config

Allow safe tuning of non-critical values.

Acceptance criteria:

- Daily puzzle config can be updated.
- Defaults work offline.
- Access is restricted to release owners.
