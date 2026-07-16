import SwiftUI

struct RootView: View {
    @StateObject private var store = GameStore()

    var body: some View {
        ZStack {
            AppBackdrop()

            switch store.route {
            case .splash:
                SplashView()
                    .transition(.opacity.combined(with: .scale(scale: 1.04)))
            case .home:
                HomeView(store: store)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            case .levelMap:
                LevelMapView(store: store)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            case .gameplay:
                if let session = store.session {
                    GameplayView(store: store, session: session)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    HomeView(store: store)
                }
            case .campaignScoreboard:
                if store.session != nil {
                    CampaignScoreboardView(store: store)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                } else {
                    HomeView(store: store)
                }
            case .arrowWeave:
                if let session = store.arrowWeaveSession {
                    ArrowWeaveView(store: store, session: session)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    HomeView(store: store)
                }
            case .arrowWeaveScoreboard:
                if store.arrowWeaveSession != nil {
                    ArrowWeaveScoreboardView(store: store)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                } else {
                    HomeView(store: store)
                }
            }
        }
        .sheet(isPresented: $store.showSettingsSheet) {
            SettingsSheet(settings: store.settings) { updated in
                store.update(settings: updated)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: store.route)
    }
}

struct AppBackdrop: View {
    @State private var animateGlow = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.07, blue: 0.13),
                    Color(red: 0.08, green: 0.12, blue: 0.19),
                    Color(red: 0.11, green: 0.09, blue: 0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.23, green: 0.48, blue: 0.95).opacity(0.25),
                            .clear
                        ],
                        center: .center,
                        startRadius: 12,
                        endRadius: 220
                    )
                )
                .frame(width: 280, height: 280)
                .blur(radius: 8)
                .offset(x: animateGlow ? 120 : -110, y: -210)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.92, green: 0.38, blue: 0.34).opacity(0.22),
                            .clear
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 200
                    )
                )
                .frame(width: 240, height: 240)
                .blur(radius: 10)
                .offset(x: animateGlow ? -130 : 140, y: 220)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                animateGlow.toggle()
            }
        }
    }
}

struct SplashView: View {
    @State private var floatUp = false
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 22) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 42, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 132, height: 132)
                    .overlay(
                        RoundedRectangle(cornerRadius: 42, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.22), Color.white.opacity(0.06)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 24, x: 0, y: 16)

                Circle()
                    .stroke(Color.white.opacity(0.18), lineWidth: 2)
                    .frame(width: 92, height: 92)
                    .scaleEffect(pulse ? 1.08 : 0.92)

                ArrowCompanionLogo()
                    .scaleEffect(floatUp ? 1.0 : 0.92)
                    .offset(y: floatUp ? -2 : 10)
            }
            .rotationEffect(.degrees(floatUp ? 2 : -2))

            VStack(spacing: 8) {
                Text("Arrow Fun")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Tap. Aim. Escape.")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
            }

            Text("A polished arrow puzzle with queues, color exits, portals, and gates.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.58))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)

            Spacer()

            ProgressView()
                .tint(.white)
                .scaleEffect(1.1)
        }
        .padding(.vertical, 48)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                floatUp.toggle()
                pulse.toggle()
            }
        }
    }
}

struct ArrowCompanionLogo: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.23, green: 0.57, blue: 0.98),
                            Color(red: 0.16, green: 0.79, blue: 0.62)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 64, height: 64)

            Image(systemName: "paperplane.fill")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(.white)
                .rotationEffect(.degrees(35))
                .offset(x: 2, y: -2)

            Circle()
                .stroke(.white.opacity(0.45), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                .frame(width: 94, height: 94)
        }
    }
}

struct HomeView: View {
    @ObservedObject var store: GameStore
    @State private var bob = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 18) {
                header
                heroCard
                actionGrid
                campaignProgress
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Arrow Fun")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Original levels. Clean motion. One-tap flow.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.68))
            }

            Spacer()

            Button {
                store.openSettings()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(.white.opacity(0.10), lineWidth: 1)
                    )
            }
            .foregroundStyle(.white)
        }
    }

    private var heroCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.14, green: 0.20, blue: 0.30).opacity(0.95),
                            Color(red: 0.09, green: 0.11, blue: 0.17).opacity(0.96)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.18),
                                    Color.white.opacity(0.04)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.34), radius: 24, x: 0, y: 16)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Level \(store.currentLevelIndexForContinue + 1)")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.72))
                        Text("Continue your path")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    Spacer()

                }

                Text("Queue arrows, clear lanes, and learn each chapter one move at a time.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    PrimaryButton(title: "Continue", systemImage: "play.fill") {
                        store.continueCampaign()
                    }

                    SecondaryButton(title: "Level Map", systemImage: "map.fill") {
                        store.openLevelMap()
                    }
                }
            }
            .padding(20)
            .padding(.top, -30)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 240)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                bob.toggle()
            }
        }
    }

    private var actionGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                MenuTile(
                    title: "Daily Challenge",
                    subtitle: "Fresh today",
                    systemImage: "calendar.badge.clock"
                ) {
                    store.startDailyChallenge()
                }

                MenuTile(
                    title: "Settings",
                    subtitle: "Sound and help",
                    systemImage: "slider.horizontal.3"
                ) {
                    store.openSettings()
                }
            }

                MenuTile(
                title: "Arrow Weave",
                subtitle: "Snake-style neon routes",
                systemImage: "waveform.path.ecg"
            ) {
                store.openArrowWeave()
            }
        }
    }

    private var campaignProgress: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Campaign Progress")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(store.progress.bestStarsByLevel.count) levels cleared")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }

            let start = min((store.currentLevelIndexForContinue / 15) * 15, max(0, store.levels.count - 1))
            let end = min(start + 14, store.levels.count - 1)
            let completed = (start...end).reduce(0) { partial, index in
                partial + (store.progress.bestStarsByLevel[index] == nil ? 0 : 1)
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Chapter \(start / 15 + 1)")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(store.levels[start].title)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.62))
                        Text(store.levels[start].subtitle)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.48))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Text("\(completed)/\(end - start + 1)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.82))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.08), in: Capsule())
                }

                ProgressView(value: Double(completed), total: Double(end - start + 1))
                    .tint(Color(red: 0.26, green: 0.60, blue: 0.98))

                HStack(spacing: 8) {
                    ForEach(start..<min(start + 5, end + 1), id: \.self) { index in
                        levelPill(index: index)
                    }
                }
            }
            .padding(16)
            .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white.opacity(0.09), lineWidth: 1)
            )
        }
    }

    private func levelPill(index: Int) -> some View {
        let stars = store.progress.bestStarsByLevel[index] ?? 0
        let totalScore = store.progress.totalScoresByLevel[index] ?? 0
        let unlocked = index <= store.progress.highestUnlockedLevel

        return Button {
            guard unlocked else { return }
            store.startLevel(at: index)
        } label: {
            VStack(spacing: 4) {
                Text("\(index + 1)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { star in
                        Image(systemName: star < stars ? "star.fill" : "star")
                            .font(.system(size: 7, weight: .bold))
                    }
                }
                Text(totalScore > 0 ? "S \(totalScore)" : "—")
                    .font(.system(size: 7, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: 54, height: 48)
            .foregroundStyle(unlocked ? .white : .white.opacity(0.32))
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(unlocked ? Color.white.opacity(0.09) : Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(unlocked ? Color.white.opacity(0.12) : Color.white.opacity(0.05), lineWidth: 1)
            )
        }
        .disabled(!unlocked)
        .accessibilityLabel("Level \(index + 1)")
        .accessibilityHint(unlocked ? "Tap to start" : "Locked")
    }
}

struct MenuTile: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red: 0.27, green: 0.72, blue: 0.96))
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
            .padding(14)
            .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

struct PrimaryButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.28, green: 0.62, blue: 0.98), Color(red: 0.18, green: 0.82, blue: 0.66)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .shadow(color: Color.cyan.opacity(0.24), radius: 12, x: 0, y: 8)
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )
        }
    }
}

struct LevelMapView: View {
    @ObservedObject var store: GameStore

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Button {
                        store.openHome()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .frame(width: 42, height: 42)
                            .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Level Map")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("One campaign, many distinct chapters.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.66))
                    }

                    Spacer()
                }

                ForEach(Array(stride(from: 0, to: store.levels.count, by: 15)), id: \.self) { start in
                    let end = min(start + 14, store.levels.count - 1)
                    CampaignSectionCard(
                        chapterIndex: start / 15,
                        levels: Array(store.levels[start...end]),
                        startIndex: start,
                        progress: store.progress
                    ) { index in
                        store.startLevel(at: index)
                    }
                }
            }
            .padding(18)
            .padding(.bottom, 28)
        }
    }
}

struct CampaignSectionCard: View {
    let chapterIndex: Int
    let levels: [LevelDefinition]
    let startIndex: Int
    let progress: GameProgress
    let onSelect: (Int) -> Void

    private let grid = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            levelGrid
        }
        .padding(16)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Chapter \(chapterIndex + 1)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(levels.first?.title ?? "Campaign")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                Text(levels.first?.subtitle ?? "")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Text("\(levels.count) levels")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.white.opacity(0.08), in: Capsule())
        }
    }

    private var levelGrid: some View {
        LazyVGrid(columns: grid, spacing: 8) {
            ForEach(levels.indices, id: \.self) { offset in
                let index = startIndex + offset
                LevelMapLevelButton(
                    levelNumber: index + 1,
                    unlocked: index <= progress.highestUnlockedLevel,
                    stars: progress.bestStarsByLevel[index] ?? 0
                ) {
                    onSelect(index)
                }
            }
        }
    }
}

struct LevelMapLevelButton: View {
    let levelNumber: Int
    let unlocked: Bool
    let stars: Int
    let action: () -> Void

    var body: some View {
        Button {
            guard unlocked else { return }
            action()
        } label: {
            VStack(spacing: 4) {
                Text("\(levelNumber)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { star in
                        Image(systemName: star < stars ? "star.fill" : "star")
                            .font(.system(size: 7, weight: .bold))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .foregroundStyle(unlocked ? .white : .white.opacity(0.28))
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(unlocked ? Color.white.opacity(0.09) : Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(unlocked ? Color.white.opacity(0.12) : Color.white.opacity(0.05), lineWidth: 1)
            )
        }
        .disabled(!unlocked)
    }
}

struct GameplayView: View {
    @ObservedObject var store: GameStore
    @ObservedObject var session: GameSession
    @State private var showPauseMenu = false
    @State private var showCompletion = false

    var body: some View {
        GeometryReader { proxy in
            let availableWidth = proxy.size.width
            let availableHeight = proxy.size.height
            let boardWidth = min(availableWidth - 24, availableHeight * 0.54)
            let boardSize = min(max(240, boardWidth), 420)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {
                    gameplayHeader
                    BoardView(session: session, boardSize: boardSize)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 2)
                    gameplayControls
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 18)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .overlay(alignment: .center) {
                if session.failed {
                    FailurePanel(
                        session: session,
                        onRetry: {
                            session.restart()
                        },
                        onMap: {
                            store.goBackFromGameplay()
                            store.openLevelMap()
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                } else if session.completed || showCompletion {
                    CompletionPanel(
                        session: session,
                        bestScore: max(store.progress.bestScoresByLevel[store.activeLevelIndex] ?? 0, session.score),
                        totalScore: store.progress.totalScoresByLevel[store.activeLevelIndex] ?? 0,
                        onReplay: {
                            session.restart()
                            showCompletion = false
                        },
                        onNext: {
                            showCompletion = false
                            let nextIndex = min(store.activeLevelIndex + 1, store.levels.count - 1)
                            store.startLevel(at: nextIndex)
                        },
                        onMap: {
                            showCompletion = false
                            store.goBackFromGameplay()
                            store.openLevelMap()
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .overlay(alignment: .top) {
                if showPauseMenu {
                    PauseOverlay(
                        onResume: { showPauseMenu = false },
                        onRestart: {
                            session.restart()
                            showPauseMenu = false
                        },
                        onMap: {
                            showPauseMenu = false
                            store.goBackFromGameplay()
                            store.openLevelMap()
                        },
                        onSettings: {
                            showPauseMenu = false
                            store.openSettings()
                        }
                    )
                    .padding(.top, 86)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .onChange(of: session.completed) { _, newValue in
                if newValue {
                    showCompletion = true
                }
            }
        }
    }

    private var gameplayHeader: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                buttonChip(systemName: "chevron.left") {
                    store.goBackFromGameplay()
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Campaign • Level \(session.level.number)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                    Text(session.level.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()

                buttonChip(systemName: "chart.bar.doc.horizontal.fill") {
                    store.openCampaignScoreboard()
                }

                buttonChip(systemName: "pause.fill") {
                    showPauseMenu = true
                }
            }

            HStack(spacing: 10) {
                statPill(title: "Moves", value: "\(session.remainingMoves)", icon: "arrow.triangle.2.circlepath")
                statPill(title: "Arrows", value: "\(session.remainingArrows)", icon: "scope")
                statPill(title: "Score", value: "\(session.score)", icon: "sparkles")
            }
        }
    }

    private var gameplayControls: some View {
        VStack(spacing: 10) {
            Text(session.toastMessage)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.76))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            HStack(spacing: 10) {
                controlButton(title: "Undo", systemImage: "arrow.uturn.backward") {
                    session.undo()
                }
                controlButton(title: "Hint", systemImage: "lightbulb.fill") {
                    session.requestHint()
                }
                controlButton(title: "Restart", systemImage: "arrow.clockwise") {
                    session.restart()
                }
            }
        }
    }

    private func buttonChip(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.white.opacity(0.10), lineWidth: 1)
                )
        }
    }

    private func statPill(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
            VStack(alignment: .leading, spacing: 1) {
                Text(title.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.55))
                Text(value)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func controlButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .bold))
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 62)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.10), lineWidth: 1)
            )
        }
    }
}

struct BoardView: View {
    @ObservedObject var session: GameSession
    let boardSize: CGFloat

    var body: some View {
        let cellSpacing: CGFloat = 8
        let rows = session.level.rows
        let cols = session.level.cols
        let cellSize = floor((boardSize - CGFloat(cols - 1) * cellSpacing) / CGFloat(cols))

        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.level.subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.66))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Move limit \(session.level.moveLimit)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.52))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)

                VStack(alignment: .trailing, spacing: 6) {
                    Text("Remaining \(session.remainingArrows)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.08), in: Capsule())

                    Text("Moves \(session.remainingMoves)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.06), in: Capsule())
                }
            }

            VStack(spacing: cellSpacing) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: cellSpacing) {
                        ForEach(0..<cols, id: \.self) { col in
                            let point = BoardPoint(row: row, col: col)
                            let tile = session.level.board[row][col]
                            let arrow = session.arrows.first(where: { $0.position == point })
                            let highlighted = session.highlightedArrowID == arrow?.id
                            let inTrail = session.travelTrail.contains(point)

                            BoardCellView(
                                tile: tile,
                                arrow: arrow,
                                highlighted: highlighted,
                                inTrail: inTrail,
                                size: cellSize
                            ) {
                                if let arrow {
                                    session.launchArrow(id: arrow.id)
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: boardSize, height: boardSize)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.30), radius: 24, x: 0, y: 18)
        }
        .frame(width: boardSize)
    }
}

struct BoardCellView: View {
    let tile: BoardTile
    let arrow: ArrowToken?
    let highlighted: Bool
    let inTrail: Bool
    let size: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(baseFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(borderColor, lineWidth: 1)
                    )
                    .shadow(color: shadowColor, radius: 10, x: 0, y: 6)

                if tile.kind != .empty {
                    tileIcon
                }

                if inTrail {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 2)
                        .scaleEffect(1.02)
                }

                if let arrow {
                    ArrowTokenView(token: arrow, highlighted: highlighted)
                        .padding(3)
                }
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private var baseFill: some ShapeStyle {
        switch tile.kind {
        case .wall:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color(red: 0.18, green: 0.21, blue: 0.27), Color(red: 0.09, green: 0.11, blue: 0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .exit:
            return AnyShapeStyle(Color.white.opacity(0.06))
        case .portal:
            return AnyShapeStyle(Color(red: 0.15, green: 0.17, blue: 0.25).opacity(0.95))
        case .gate, .lock:
            return AnyShapeStyle(Color(red: 0.13, green: 0.15, blue: 0.21).opacity(0.95))
        case .ice:
            return AnyShapeStyle(Color(red: 0.19, green: 0.30, blue: 0.42).opacity(0.85))
        case .conveyor:
            return AnyShapeStyle(Color(red: 0.18, green: 0.18, blue: 0.26).opacity(0.90))
        case .empty:
            return AnyShapeStyle(Color.white.opacity(0.05))
        }
    }

    private var borderColor: Color {
        switch tile.kind {
        case .wall:
            return Color.white.opacity(0.05)
        case .portal:
            return Color(red: 0.45, green: 0.73, blue: 1.0).opacity(0.45)
        case .gate:
            return Color(red: 0.31, green: 0.79, blue: 0.98).opacity(0.45)
        case .lock:
            return Color(red: 0.95, green: 0.78, blue: 0.26).opacity(0.45)
        case .exit:
            return (tile.color?.accent ?? .white).opacity(0.55)
        case .ice, .conveyor, .empty:
            return Color.white.opacity(0.09)
        }
    }

    private var shadowColor: Color {
        if arrow != nil || tile.kind == .portal {
            return Color.black.opacity(0.20)
        }
        return Color.black.opacity(0.12)
    }

    @ViewBuilder
    private var tileIcon: some View {
        switch tile.kind {
        case .wall:
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .padding(10)
        case .exit:
            VStack(spacing: 5) {
                Image(systemName: tile.direction?.symbolName ?? "arrow.up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(tile.color?.accent ?? .white)
                HStack(spacing: 3) {
                    Image(systemName: tile.color?.markerSymbol ?? "circle.fill")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(tile.color?.accent ?? .white)
                    Text(tile.color?.title.uppercased().prefix(3) ?? "OUT")
                        .font(.system(size: 8, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        case .portal:
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.30, green: 0.70, blue: 0.98),
                                Color(red: 0.56, green: 0.92, blue: 0.72)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .padding(10)
                Circle()
                    .fill(Color.white.opacity(0.10))
                    .padding(18)
            }
        case .gate:
            VStack(spacing: 4) {
                Image(systemName: "rectangle.portrait.on.rectangle.portrait")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(red: 0.36, green: 0.81, blue: 0.98))
                Text(tile.unlockAfterExits.map { "\($0)" } ?? "G")
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
        case .lock:
            VStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(red: 0.96, green: 0.79, blue: 0.26))
                Text(tile.unlockAfterMoves.map { "\($0)" } ?? "L")
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
        case .ice:
            Image(systemName: "snowflake")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(red: 0.52, green: 0.78, blue: 1.0))
        case .conveyor:
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(red: 0.72, green: 0.74, blue: 0.95))
        case .empty:
            EmptyView()
        }
    }

    private var accessibilityLabel: String {
        if let arrow {
            return "Arrow \(arrow.color.title)"
        }
        return tile.label
    }
}

struct ArrowTokenView: View {
    let token: ArrowToken
    let highlighted: Bool
    @State private var bounce = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [token.color.color, token.color.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: token.color.accent.opacity(0.32), radius: 10, x: 0, y: 6)

            Circle()
                .stroke(Color.white.opacity(0.22), lineWidth: 1.2)

            Image(systemName: token.direction.symbolName)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(.white)
        }
        .scaleEffect(highlighted ? 1.10 : (bounce ? 1.05 : 1.0))
        .overlay {
            if highlighted {
                Circle()
                    .stroke(token.color.accent.opacity(0.55), lineWidth: 2.5)
                    .scaleEffect(bounce ? 1.20 : 1.08)
                    .opacity(0.8)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                bounce.toggle()
            }
        }
    }
}

struct PauseOverlay: View {
    let onResume: () -> Void
    let onRestart: () -> Void
    let onMap: () -> Void
    let onSettings: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            VStack(spacing: 12) {
                Text("Paused")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                ButtonRow(title: "Resume", systemImage: "play.fill", action: onResume)
                ButtonRow(title: "Restart", systemImage: "arrow.clockwise", action: onRestart)
                ButtonRow(title: "Level Map", systemImage: "map.fill", action: onMap)
                ButtonRow(title: "Settings", systemImage: "gearshape.fill", action: onSettings)
            }
            .padding(18)
            .frame(maxWidth: 360)
            .background(.black.opacity(0.40), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(.white.opacity(0.10), lineWidth: 1)
            )
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.38))
    }
}

struct ButtonRow: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .bold))
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

struct CompletionPanel: View {
    let session: GameSession
    let bestScore: Int
    let totalScore: Int
    let onReplay: () -> Void
    let onNext: () -> Void
    let onMap: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 10) {
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < session.starsEarned ? "star.fill" : "star")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(index < session.starsEarned ? Color(red: 0.98, green: 0.82, blue: 0.28) : .white.opacity(0.25))
                    }
                }
                Text("Level Complete")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(session.completionSubtitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
            }

            VStack(spacing: 8) {
                infoRow(label: "Score", value: "\(session.score)")
                infoRow(label: "Best score", value: "\(bestScore)")
                infoRow(label: "Total score", value: "\(totalScore)")
                infoRow(label: "Time", value: CompetitiveScoring.timeLabel(for: session.elapsedSeconds))
                infoRow(label: "Moves left", value: "\(session.remainingMoves)")
                infoRow(label: "Moves used", value: "\(session.movesUsed)")
                infoRow(label: "Arrow count", value: "\(session.level.totalArrows)")
            }
            .padding(.vertical, 4)

            HStack(spacing: 10) {
                SecondaryButton(title: "Map", systemImage: "map.fill", action: onMap)
                PrimaryButton(title: "Replay", systemImage: "arrow.clockwise", action: onReplay)
            }
            Button {
                onNext()
            } label: {
                Text("Next Level")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.28, green: 0.62, blue: 0.98), Color(red: 0.18, green: 0.82, blue: 0.66)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )
            }
        }
        .padding(18)
        .frame(maxWidth: 360)
        .background(.black.opacity(0.50), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.45), radius: 24, x: 0, y: 16)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

struct CampaignScoreboardView: View {
    @ObservedObject var store: GameStore

    private var summaries: [LevelScoreSummary] {
        campaignScoreSummaries(progress: store.progress, levels: store.levels)
    }

    private var totalScore: Int {
        summaries.reduce(0) { $0 + $1.totalScore }
    }

    var body: some View {
        ScoreboardScreen(
            title: "Campaign Scoreboard",
            subtitle: "Every cleared chapter keeps its own score trail.",
            icon: "map.fill",
            accentColors: [
                Color(red: 0.27, green: 0.64, blue: 0.98),
                Color(red: 0.18, green: 0.84, blue: 0.66)
            ],
            summaries: summaries,
            totalScore: totalScore,
            emptyTitle: "No campaign scores yet",
            emptyMessage: "Finish a level to see its score, timing, moves, and total progress here.",
            onDeleteLevel: { summary in
                store.deleteCampaignScore(for: summary.levelIndex)
            },
            onClearAll: {
                store.clearAllCampaignScores()
            },
            onBack: {
                store.closeScoreboard()
            }
        )
    }
}

struct ScoreboardScreen: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColors: [Color]
    let summaries: [LevelScoreSummary]
    let totalScore: Int
    let emptyTitle: String
    let emptyMessage: String
    let onDeleteLevel: (LevelScoreSummary) -> Void
    let onClearAll: () -> Void
    let onBack: () -> Void
    @State private var pendingDeleteLevel: LevelScoreSummary?
    @State private var showClearAllAlert = false

    private var totalRuns: Int {
        summaries.reduce(0) { $0 + $1.playCount }
    }

    private var bestScore: Int {
        summaries.map(\.bestScore).max() ?? 0
    }

    private var lastCompletedAt: Date? {
        summaries
            .map(\.lastCompletedAt)
            .filter { $0 > .distantPast }
            .max()
    }

    private var starClearCount: Int {
        summaries.filter { $0.bestStars == 3 }.count
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                scoreboardHeader
                scoreboardHero

                if summaries.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(summaries) { summary in
                            ScoreboardLevelCard(
                                summary: summary,
                                accentColors: accentColors,
                                onDeleteTapped: {
                                    pendingDeleteLevel = summary
                                }
                            )
                        }
                    }
                }
            }
            .padding(18)
            .padding(.top, 10)
            .padding(.bottom, 28)
        }
        .alert(item: $pendingDeleteLevel) { summary in
            Alert(
                title: Text("Delete level score?"),
                message: Text("This will remove all stored score details for Level \(summary.levelNumber)."),
                primaryButton: .destructive(Text("Delete")) {
                    onDeleteLevel(summary)
                },
                secondaryButton: .cancel()
            )
        }
        .alert("Clear all scores?", isPresented: $showClearAllAlert) {
            Button("Clear All", role: .destructive) {
                onClearAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will clear every stored scoreboard entry in this mode. Your unlocked progress stays intact.")
        }
    }

    private var scoreboardHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(.white.opacity(0.10), lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.66))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: accentColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(.white.opacity(0.16), lineWidth: 1)
                    )

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.white)
            }
        }
    }

    private var scoreboardHero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Total Score")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.62))
                        .textCase(.uppercase)
                    Text("\(totalScore)")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()

                if let lastCompletedAt {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Last clear")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.55))
                            .textCase(.uppercase)
                        Text(lastCompletedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.82))
                    }
                }
            }

            HStack(spacing: 10) {
                ScoreboardMetricCard(title: "Played", value: "\(summaries.count)", icon: "checkmark.seal.fill", tint: accentColors.first ?? .white)
                ScoreboardMetricCard(title: "Runs", value: "\(totalRuns)", icon: "repeat", tint: accentColors.last ?? .white)
            }

            HStack(spacing: 10) {
                ScoreboardMetricCard(title: "Best", value: "\(bestScore)", icon: "sparkles", tint: Color(red: 0.99, green: 0.78, blue: 0.30))
                ScoreboardMetricCard(title: "3-Star", value: "\(starClearCount)", icon: "star.fill", tint: Color(red: 0.98, green: 0.83, blue: 0.36))
            }

            if !summaries.isEmpty {
                HStack {
                    Spacer()
                    Button {
                        showClearAllAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.fill")
                            Text("Clear All Scores")
                        }
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.98, green: 0.55, blue: 0.52))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.12), in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.red.opacity(0.24), lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.10),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            accentColors.first?.opacity(0.28) ?? .clear,
                            accentColors.last?.opacity(0.14) ?? .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.28), radius: 20, x: 0, y: 12)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(accentColors.first ?? .white)
            Text(emptyTitle)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(emptyMessage)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.68))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct ScoreboardMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 1) {
                Text(title.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.58))
                Text(value)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct ScoreboardLevelCard: View {
    let summary: LevelScoreSummary
    let accentColors: [Color]
    let onDeleteTapped: () -> Void

    private var dateText: String {
        guard summary.lastCompletedAt > .distantPast else { return "—" }
        return summary.lastCompletedAt.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: accentColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    VStack(spacing: 2) {
                        Text("\(summary.levelNumber)")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("\(summary.bestStars)★")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(summary.levelTitle)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(summary.levelSubtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.66))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
                    Button {
                        onDeleteTapped()
                    } label: {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(red: 0.98, green: 0.60, blue: 0.56))
                            .frame(width: 26, height: 26)
                            .background(Color.red.opacity(0.10), in: Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.red.opacity(0.18), lineWidth: 1)
                            )
                    }
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { index in
                            Image(systemName: index < summary.bestStars ? "star.fill" : "star")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(index < summary.bestStars ? Color(red: 0.99, green: 0.82, blue: 0.30) : .white.opacity(0.26))
                        }
                    }
                    Text("x\(summary.playCount)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                }
            }

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    ScoreboardMiniMetric(title: "Last Score", value: "\(summary.lastScore)")
                    ScoreboardMiniMetric(title: "Best Score", value: "\(summary.bestScore)")
                }
                HStack(spacing: 8) {
                    ScoreboardMiniMetric(title: "Total Score", value: "\(summary.totalScore)")
                    ScoreboardMiniMetric(title: "Moves", value: "\(summary.lastMovesUsed)/\(summary.lastMoveLimit)")
                }
                HStack(spacing: 8) {
                    ScoreboardMiniMetric(title: "Time", value: CompetitiveScoring.timeLabel(for: summary.lastElapsedSeconds))
                    ScoreboardMiniMetric(title: "Completed", value: dateText)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            accentColors.first?.opacity(0.22) ?? .clear,
                            accentColors.last?.opacity(0.10) ?? .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct ScoreboardMiniMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.54))
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

func campaignScoreSummaries(progress: GameProgress, levels: [LevelDefinition]) -> [LevelScoreSummary] {
    if !progress.levelSummaries.isEmpty {
        return progress.levelSummaries
    }

    let indices = Set(progress.bestStarsByLevel.keys)
        .union(progress.bestScoresByLevel.keys)
        .union(progress.totalScoresByLevel.keys)

    return indices.sorted().compactMap { index in
        guard levels.indices.contains(index) else { return nil }
        let level = levels[index]
        let bestStars = progress.bestStarsByLevel[index] ?? 0
        let bestScore = progress.bestScoresByLevel[index] ?? 0
        let totalScore = progress.totalScoresByLevel[index] ?? bestScore
        guard bestStars > 0 || bestScore > 0 || totalScore > 0 else { return nil }

        return LevelScoreSummary(
            id: index,
            levelIndex: index,
            levelNumber: level.number,
            levelTitle: level.title,
            levelSubtitle: level.subtitle,
            bestStars: bestStars,
            bestScore: bestScore,
            totalScore: totalScore,
            lastScore: bestScore,
            lastStars: bestStars,
            lastMovesUsed: 0,
            lastMoveLimit: level.moveLimit,
            lastElapsedSeconds: 0,
            playCount: 1,
            lastCompletedAt: .distantPast
        )
    }
}

func arrowWeaveScoreSummaries(progress: GameProgress, levels: [ArrowWeaveLevelDefinition]) -> [LevelScoreSummary] {
    if !progress.levelSummaries.isEmpty {
        return progress.levelSummaries
    }

    let indices = Set(progress.bestStarsByLevel.keys)
        .union(progress.bestScoresByLevel.keys)
        .union(progress.totalScoresByLevel.keys)

    return indices.sorted().compactMap { index in
        guard levels.indices.contains(index) else { return nil }
        let level = levels[index]
        let bestStars = progress.bestStarsByLevel[index] ?? 0
        let bestScore = progress.bestScoresByLevel[index] ?? 0
        let totalScore = progress.totalScoresByLevel[index] ?? bestScore
        guard bestStars > 0 || bestScore > 0 || totalScore > 0 else { return nil }

        return LevelScoreSummary(
            id: index,
            levelIndex: index,
            levelNumber: level.number,
            levelTitle: level.title,
            levelSubtitle: level.subtitle,
            bestStars: bestStars,
            bestScore: bestScore,
            totalScore: totalScore,
            lastScore: bestScore,
            lastStars: bestStars,
            lastMovesUsed: 0,
            lastMoveLimit: level.moveLimit,
            lastElapsedSeconds: 0,
            playCount: 1,
            lastCompletedAt: .distantPast
        )
    }
}

struct FailurePanel: View {
    let session: GameSession
    let onRetry: () -> Void
    let onMap: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 10) {
                Image(systemName: "xmark.octagon.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color(red: 0.96, green: 0.45, blue: 0.42))
                Text("Game Over")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(session.failureMessage)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 8) {
                infoRow(label: "Score", value: "\(session.score)")
                infoRow(label: "Moves left", value: "\(session.remainingMoves)")
                infoRow(label: "Arrows escaped", value: "\(session.exitsCleared)")
            }
            .padding(.vertical, 4)

            HStack(spacing: 10) {
                SecondaryButton(title: "Level Map", systemImage: "map.fill", action: onMap)
                PrimaryButton(title: "Retry", systemImage: "arrow.clockwise", action: onRetry)
            }
        }
        .padding(18)
        .frame(maxWidth: 360)
        .background(.black.opacity(0.52), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.45), radius: 24, x: 0, y: 16)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State var settings: GameSettings
    @State private var showRestoreAlert = false
    let onSave: (GameSettings) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Audio & Feedback") {
                    Toggle("Music", isOn: $settings.musicEnabled)
                    Toggle("Sound", isOn: $settings.soundEnabled)
                    Toggle("Haptics", isOn: $settings.hapticsEnabled)
                }

                Section("Support") {
                    NavigationLink("How to Play") {
                        HowToPlayView()
                    }

                    NavigationLink("Privacy Policy") {
                        LegalDocumentView(
                            title: "Privacy Policy",
                            subtitle: "Local-first, minimal-data gameplay.",
                            content: privacyPolicyText
                        )
                    }

                    NavigationLink("Terms of Use") {
                        LegalDocumentView(
                            title: "Terms of Use",
                            subtitle: "How Arrow Fun should be used.",
                            content: termsOfUseText
                        )
                    }

                }

            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        onSave(settings)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(settings)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        
        }
        .presentationDetents([.medium, .large])
    }

    private var privacyPolicyText: String {
        """
        Arrow Fun is designed to be local-first. We store your game progress and settings on device using standard app storage.

        Data we may use:
        - Level progress
        - Stars and move counts
        - Settings such as sound and haptics
        - Anonymous crash or performance data if enabled in a future release

        Data we do not require:
        - No account creation
        - No contact list access
        - No camera or microphone access
        - No precise location tracking

        This build is local-first and stores game progress and settings on your device.
        If future releases add online features, this privacy policy will be updated before submission.
        """
    }

    private var termsOfUseText: String {
        """
        By using Arrow Fun, you agree to play fairly and respect the original game design.

        - The app is provided for entertainment.
        - Levels, UI, and assets in this build are original to this project.
        - You may not redistribute the app as your own product.
        - We may update or change levels, balance, and features over time.

        This game is a complete offline campaign experience with future content updates.
        """
    }
}

struct HowToPlayView: View {
    private let guideCards: [(title: String, body: String, icon: String, tint: Color)] = [
        (
            title: "Objective",
            body: "Study the board pattern, choose the correct arrow, and clear every level step by step. Each board is designed as a fresh puzzle layout with its own flow.",
            icon: "target",
            tint: Color(red: 0.27, green: 0.64, blue: 0.98)
        ),
        (
            title: "Core Action",
            body: "Tap the leading arrow to launch the route. When the arrow escapes successfully, the board updates and the next move becomes available.",
            icon: "hand.tap.fill",
            tint: Color(red: 0.18, green: 0.84, blue: 0.66)
        ),
        (
            title: "Scoring",
            body: "Score is earned from successful escapes and level completion. Faster finishes increase the reward, while clean runs can produce stronger results.",
            icon: "sparkles",
            tint: Color(red: 0.99, green: 0.78, blue: 0.30)
        ),
        (
            title: "Moves",
            body: "Every tap counts. The move limit is part of the challenge, so planning ahead helps you finish with a better score and a stronger star rating.",
            icon: "arrow.triangle.2.circlepath",
            tint: Color(red: 0.92, green: 0.35, blue: 0.76)
        ),
        (
            title: "Hints",
            body: "Hints highlight the recommended next move when you need guidance. They are useful for tricky boards and can reduce your final score slightly.",
            icon: "lightbulb.fill",
            tint: Color(red: 0.98, green: 0.60, blue: 0.24)
        ),
        (
            title: "Timing",
            body: "Faster completion improves the time bonus. The scoreboard and result panel show your run time, best score, total score, and level history.",
            icon: "clock.fill",
            tint: Color(red: 0.54, green: 0.72, blue: 1.00)
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                VStack(spacing: 12) {
                    ForEach(Array(guideCards.enumerated()), id: \.offset) { _, card in
                        guideCard(title: card.title, body: card.body, icon: card.icon, tint: card.tint)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Progress Flow")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)

                    Text("Complete levels to unlock the next stage, build your score history, and compare your performance on the scoreboard for each mode.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.black.opacity(0.70))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.black.opacity(0.08), lineWidth: 1)
                )
            }
            .padding(18)
            .padding(.bottom, 24)
        }
        .background(Color.clear)
        .navigationTitle("How to Play")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.27, green: 0.64, blue: 0.98),
                                    Color(red: 0.18, green: 0.84, blue: 0.66)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: "book.fill")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("How to Play")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                    Text("Learn the rules, scoring, and level flow in a few quick steps.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.black.opacity(0.62))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text("Arrow Fun rewards careful planning, fast decision-making, and clean completion. The better your timing and move efficiency, the stronger your score can be.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.black.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.96),
                            Color(red: 0.95, green: 0.97, blue: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(.black.opacity(0.08), lineWidth: 1)
        )
    }

    private func guideCard(title: String, body: String, icon: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)
                Text(body)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.black.opacity(0.70))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.black.opacity(0.08), lineWidth: 1)
        )
    }
}

struct LegalDocumentView: View {
    let title: String
    let subtitle: String
    let content: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                Text(content)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineSpacing(4)
            }
            .padding(20)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}


private extension Bundle {
    var shortVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
}
