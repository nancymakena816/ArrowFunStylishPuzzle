# Product Requirements Document

## Product Summary

Working title: Arrow Fun

Arrow Fun is a mobile puzzle game where players clear a board by sending directional arrows through safe paths, exits, portals, gates, and obstacles. The game is inspired by the broad arrow-puzzle genre, but must use original branding, visual design, level layouts, mechanics, sounds, and progression to avoid App Store clone or intellectual-property rejection risk.

It also includes a second original mode, Arrow Weave, which focuses on flowing lane reading, sequence timing, and snake-like path clearing through a separate visual identity and level structure.

The first release should feel like a complete casual puzzle game, not a prototype. It should include enough levels, difficulty progression, polish, accessibility, and release readiness to pass Apple App Review and support future live updates.

## Goals

- Launch a polished iOS-ready casual puzzle game with original identity and mechanics.
- Provide a simple first-session experience that teaches the game without long text.
- Include enough content for real replay value: at least 150 levels at launch.
- Keep the first release fully free and offline-first.
- Avoid App Store rejection risks related to copycat design, spam, low functionality, privacy, and misleading metadata.

## Non-Goals

- Do not copy another game's name, icon, screenshots, level layouts, UI, ad creatives, or store metadata.
- Do not include gambling, cash rewards, crypto, or real-money prize mechanics.
- Do not include unmoderated user-generated content in version 1.
- Do not require account creation for basic gameplay.
- Do not make the app dependent on internet access for core gameplay.

## Target Users

- Casual puzzle players aged 9+.
- Users who enjoy short sessions, daily challenges, and satisfying logic puzzles.
- Players who want offline gameplay with optional progression rewards.

## Core Gameplay Loop

1. Player opens a level.
2. Board displays arrows, exits, obstacles, and special tiles.
3. Player taps, rotates, swaps, or launches arrows depending on level rules.
4. Arrows move in their facing direction.
5. Player clears all arrows or completes the level objective.
6. Game awards stars, coins, or streak progress.
7. Player advances to the next level, replays, or uses hints if stuck.

## Primary Mechanics

- Tap to launch an arrow in its current direction.
- Rotate arrows on specific levels where rotation is allowed.
- Move arrows through exits, gates, portals, and color-matched lanes.
- Prevent collisions between arrows.
- Solve within optional move limits for star ratings.
- Use hints to reveal the next safe action.
- Undo the previous move.

## Unique Mechanics For Differentiation

- Color exits: arrows must leave through matching colored exits.
- Portal pairs: arrows teleport between linked cells.
- Ice lanes: arrows slide until blocked.
- Lock tiles: arrows unlock after another arrow exits.
- Split arrows: one action creates two directional movements.
- Timed gates: gates open or close after each move.
- Conveyor tiles: arrows change direction when crossing moving tracks.
- Chapter modifiers: every world introduces one new mechanic.

## Game Modes

- Campaign: 150+ levels grouped into worlds.
- Daily Puzzle: one handcrafted or generated puzzle per day.
- Challenge Mode: limited-move or timed variants for advanced users.
- Practice Mode: replay unlocked mechanics without penalties.
- Arrow Weave: a separate flow-based mode with layered routes, smooth path animation, and distinct level patterns.

## Level Structure

- World 1: Basics, simple exits, no penalties.
- World 2: Obstacles and collisions.
- World 3: Color exits.
- World 4: Portals and gates.
- World 5: Ice lanes and conveyors.
- Expert Pack: mixed mechanics and tight move limits.

## Progression

- Stars: up to 3 stars per level based on move efficiency.
- Coins: earned through completion and daily streaks.
- Hints: limited free hints, then earned through gameplay.
- Unlocks: themes, board skins, arrow skins, and special effects.

## Monetization

- Free-to-play.
- No monetization features in the first release.
- Rewards should come from gameplay only.

## App Store Compliance Requirements

- Use an original app name and icon. Avoid names too close to existing arrow puzzle apps.
- Do not copy competitor screenshots, descriptions, icons, sound effects, level designs, or UI layout.
- Submit a complete app, not a beta or prototype.
- Include accurate screenshots showing real gameplay.
- Include privacy policy and accurate App Privacy details.
- Include review notes explaining offline gameplay and any non-obvious features.
- Ensure app works without crashes on supported iPhone and iPad devices.
- Provide complete functionality to App Review without requiring login.
- Keep metadata truthful: the app is fully free and offline-first.

## Functional Requirements

- Player can start, pause, restart, undo, and complete levels.
- Player can view level number, moves used, remaining arrows, stars, and hints.
- Player can toggle sound, music, and haptics.
- Player can access privacy policy, terms, and support email.
- Game saves progress locally.
- Game supports offline campaign play.
- Game gracefully handles no internet for offline play and any future optional online features.
- Game includes accessibility labels for major UI controls.

## Quality Requirements

- Launch time under 3 seconds on supported devices.
- Level interactions should respond within 100 ms.
- Animations should run smoothly at 60 FPS where possible.
- No blocked progression due to failed ad loading.
- No crash loops, broken buttons, placeholder text, or test metadata.

## Success Metrics

- Day 1 retention: 35%+
- Day 7 retention: 12%+
- Average session length: 5-8 minutes
- Level completion rate for first 10 levels: 85%+
- Crash-free sessions: 99.5%+
- App Review approval on first or second submission

## Launch Checklist

- 150+ tested levels.
- Original icon and screenshots.
- App Store metadata complete and accurate.
- Privacy policy URL live.
- Support URL live.
- Offline campaign and save flow tested on device.
- Review notes prepared.
- Real-device testing completed.
