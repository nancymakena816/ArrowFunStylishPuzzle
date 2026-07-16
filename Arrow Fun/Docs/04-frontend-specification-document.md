# Frontend Specification Document

## Experience Direction

The game should feel clean, tactile, and premium. The interface should focus on the puzzle board first, with controls that are easy to reach on mobile. The visual identity must be original and should not resemble any competitor icon, color treatment, screenshot layout, or ad creative.

Recommended tone:

- Bright but not childish.
- Minimal but not empty.
- Satisfying motion and sound.
- Clear states for every tile and action.
- Comfortable for short one-handed sessions.

## Visual Identity

Avoid copying the red-and-blue arrow icon style shown in the reference screenshot. Use a distinct identity.

Possible original directions:

- Glass arrows on soft dark board.
- Paper-fold arrows with colorful worlds.
- Neon circuit-board arrows.
- Compass/navigation theme.
- Toy-like plastic arrows with subtle shadows.

Final app icon should:

- Show one strong original symbol.
- Avoid looking like another app's icon.
- Work at small sizes.
- Avoid text inside the icon.
- Use a unique palette and shape language.

## Main Screens

### Splash Screen

- App logo.
- Short loading state only if needed.
- No fake progress bar.

### Home Screen

Primary actions:

- Continue
- Level Map
- Daily Puzzle
- Settings

### Level Map

- Worlds displayed as horizontal or vertical progression.
- Completed levels show stars.
- Locked worlds show requirement.
- Daily challenge entry remains visible but not intrusive.

### Gameplay Screen

Required elements:

- Top bar with level number, moves, and optional star target.
- Board centered and sized to fit screen.
- Remaining arrows indicator.
- Undo button.
- Hint button.
- Restart button.
- Pause or settings button.

The board should be the largest visual element.

### Pause Menu

- Resume
- Restart
- Level Map
- Settings

### Win Dialog

- Stars earned.
- Moves used.
- Reward summary.
- Replay
- Next Level

### Settings Screen

- Music toggle
- Sound toggle
- Haptics toggle
- Privacy Policy
- Terms
- Support
- App version

## Gameplay Board Specification

### Board Layout

- Grid sizes: 5x5, 6x6, 7x7, 8x8, and special boards.
- Board should remain fully visible on small iPhones.
- Maintain stable tile sizes during gameplay.
- No layout shift when counters change.
- Safe-area aware for iPhone notch and home indicator.

### Tile Types

- Empty tile
- Arrow tile
- Wall tile
- Exit tile
- Color exit tile
- Portal tile
- Gate tile
- Lock tile
- Ice tile
- Conveyor tile

### Arrow States

- Idle
- Selected
- Moving
- Blocked
- Exiting
- Locked
- Hint-highlighted

### Tile Feedback

- Valid action: subtle pulse or lift.
- Invalid action: short shake and soft error sound.
- Exit: smooth trail and fade.
- Collision: bounce and reset.
- Portal: quick warp animation.
- Gate: open or close animation.

## Controls

Touch interactions:

- Tap arrow to launch.
- Tap rotate control if level allows rotation.
- Drag only where drag mechanics are active.
- Tap undo to reverse last completed move.
- Tap hint to highlight suggested arrow.
- Long press optional for tile information.

Buttons:

- Minimum tap target: 44x44 points.
- Use icons with labels where clarity matters.
- Disabled controls should be visibly disabled.
- Controls should not overlap the board or home indicator.

## Onboarding

First-time flow:

- Level 1 teaches tap-to-launch.
- Level 2 teaches collisions.
- Level 3 teaches exits.
- Level 4 teaches undo.
- Level 5 teaches hints.

Guidance should be contextual and short. Avoid long tutorial paragraphs.

## Accessibility

Requirements:

- Support Dynamic Type where practical for menus.
- Provide sufficient color contrast.
- Do not rely on color alone for matching exits.
- Add symbols or patterns for color exits.
- Provide sound-off playability.
- Respect reduced motion where possible.
- Add VoiceOver labels for buttons and major game objects.

Color accessibility:

- Red exit should also include a shape marker.
- Blue exit should also include a different marker.
- Green exit should also include a different marker.
- Yellow exit should also include a different marker.

## Animation And Motion

Animation goals:

- Movement should feel quick and readable.
- Board actions should not feel sluggish.
- Win celebration should be satisfying but skippable.

Timing:

- Arrow movement per tile: 80-120 ms.
- Invalid action shake: 200-300 ms.
- Win dialog delay: 400-700 ms after final exit.
- Screen transition: 200-350 ms.

Reduced motion:

- Replace large movement effects with fades.
- Disable excessive particles.
- Keep gameplay state changes clear.

## Audio And Haptics

Audio:

- Tap sound.
- Move sound.
- Exit success sound.
- Collision sound.
- Win sound.
- Gentle background music.

Haptics:

- Light tap on valid action.
- Warning haptic on invalid move.
- Success haptic on level completion.

Settings must allow music, sound, and haptics to be turned off.

## Responsive Behavior

Small iPhone:

- Board remains fully visible.
- Controls compress into icon buttons if needed.
- Avoid tiny text on tile labels.

Large iPhone:

- Board scales up within max size.
- Controls stay near thumb reach.

iPad:

- Board and side panel can sit in a wider layout.
- Avoid stretching board too wide.
- Keep focus on gameplay, not empty margins.

## Empty, Error, And Offline States

- Daily puzzle offline: show cached puzzle or unavailable state.
- Level load error: return to level map with retry.
- Save error: retry automatically and warn if needed.

## Store Asset Requirements

- Screenshots must show actual gameplay.
- Do not use competitor-like icon or misleading store screenshots.
- Include at least one screenshot showing unique mechanics.
- App preview video should show real interaction, not misleading cinematic-only footage.
- Metadata must stay truthful and match the actual gameplay features.

## Frontend Acceptance Criteria

- Gameplay screen is usable on smallest supported iPhone.
- All primary controls have clear touch targets.
- Board does not overlap safe areas.
- Win, pause, settings, and offline states are implemented.
- Audio and haptics can be disabled.
- Visual design is original and does not resemble the reference app closely.
- Accessibility labels exist for major controls.
- Screenshots accurately represent the app.
