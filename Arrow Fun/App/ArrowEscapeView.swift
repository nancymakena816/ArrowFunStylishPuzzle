import SwiftUI

struct ArrowWeaveView: View {
    @ObservedObject var store: GameStore
    @ObservedObject var session: ArrowWeaveSession

    var body: some View {
        GeometryReader { proxy in
            let availableWidth = proxy.size.width
            let availableHeight = proxy.size.height
            let boardWidth = min(availableWidth - 24, availableHeight * 0.56)
            let boardSize = min(max(280, boardWidth), 460)

            ZStack {
                ArrowWeaveBackdrop()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        header
                        levelStrip
                        statRow
                        EscapeBoardView(session: session, boardSize: boardSize)
                            .frame(maxWidth: .infinity)
                        mechanicNotes
                        controlRow
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 70)
                    .padding(.bottom, 22)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
            .overlay(alignment: .center) {
                if session.failed {
                    ArrowWeaveFailurePanel(
                        session: session,
                        onRetry: {
                            session.restart()
                        },
                        onHome: {
                            store.goBackFromArrowWeave()
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                } else if session.completed {
                    ArrowWeaveCompletionPanel(
                        session: session,
                        bestScore: max(store.arrowWeaveProgress.bestScoresByLevel[session.level.number - 1] ?? 0, session.score),
                        totalScore: store.arrowWeaveProgress.totalScoresByLevel[session.level.number - 1] ?? 0,
                        onReplay: {
                            session.restart()
                        },
                        onNext: {
                            let nextIndex = min(session.level.number, store.arrowWeaveLevels.count - 1)
                            store.startArrowWeaveLevel(at: nextIndex)
                        },
                        onHome: {
                            store.goBackFromArrowWeave()
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.25), value: session.completed)
        .animation(.easeInOut(duration: 0.25), value: session.failed)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                store.goBackFromArrowWeave()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(.white.opacity(0.12), lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Arrow Weave")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("Tap the leading arrow. Let the snake unwind.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.70))
            }

            Spacer()

            HStack(alignment: .top, spacing: 10) {
                Button {
                    store.openArrowWeaveScoreboard()
                } label: {
                    Image(systemName: "chart.bar.doc.horizontal.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(.white.opacity(0.12), lineWidth: 1)
                        )
                }

                VStack(alignment: .trailing, spacing: 5) {
                    Text("Level \(session.level.number)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.78))
                    Text(session.level.title)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.58))
                }
            }
        }
    }

    private var levelStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(store.arrowWeaveLevels.enumerated()), id: \.offset) { index, _ in
                    let unlocked = index <= store.arrowWeaveProgress.highestUnlockedLevel
                    let selected = index == session.level.number - 1
                    let totalScore = store.arrowWeaveProgress.totalScoresByLevel[index] ?? 0
                    Button {
                        guard unlocked else { return }
                        store.startArrowWeaveLevel(at: index)
                    } label: {
                        VStack(spacing: 4) {
                            Text("\(index + 1)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                            Text(unlocked ? "Ready" : "Lock")
                                .font(.system(size: 8, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white.opacity(0.72))
                            Text(totalScore > 0 ? "S \(totalScore)" : "—")
                                .font(.system(size: 7, weight: .bold, design: .rounded))
                        }
                        .frame(width: 52, height: 48)
                        .foregroundStyle(unlocked ? .white : .white.opacity(0.30))
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    selected
                                    ? AnyShapeStyle(
                                        LinearGradient(
                                            colors: [Color(red: 0.93, green: 0.35, blue: 0.76), Color(red: 0.31, green: 0.74, blue: 0.99)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    : AnyShapeStyle(Color.white.opacity(unlocked ? 0.10 : 0.05))
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    selected ? Color.white.opacity(0.35) : Color.white.opacity(unlocked ? 0.14 : 0.06),
                                    lineWidth: 1
                                )
                        )
                    }
                    .disabled(!unlocked)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private var statRow: some View {
        HStack(spacing: 10) {
            EscapeStatChip(title: "Moves", value: "\(session.remainingMoves)", systemImage: "arrow.triangle.2.circlepath", tint: Color(red: 0.99, green: 0.64, blue: 0.26))
            EscapeStatChip(title: "Escaped", value: "\(session.escapedRoutes)", systemImage: "arrow.turn.up.right", tint: Color(red: 0.40, green: 0.89, blue: 0.73))
            EscapeStatChip(title: "Routes Left", value: "\(session.remainingRoutes)", systemImage: "scope", tint: Color(red: 0.54, green: 0.72, blue: 1.00))
        }
    }

    private var mechanicNotes: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(session.level.subtitle)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.80))
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(session.level.mechanicNotes, id: \.self) { note in
                    Text(note)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white.opacity(0.08), in: Capsule())
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.09), lineWidth: 1)
        )
    }

    private var controlRow: some View {
        HStack(spacing: 10) {
            EscapeActionButton(title: "Restart", systemImage: "arrow.clockwise", tint: Color(red: 0.93, green: 0.35, blue: 0.76)) {
                session.restart()
            }
            EscapeActionButton(title: "Hint", systemImage: "lightbulb.fill", tint: Color(red: 0.40, green: 0.89, blue: 0.73)) {
                session.requestHint()
            }
            EscapeActionButton(
                title: "Next",
                systemImage: "forward.fill",
                tint: Color(red: 0.54, green: 0.72, blue: 1.00),
                enabled: session.completed
            ) {
                let nextIndex = min(session.level.number, store.arrowWeaveLevels.count - 1)
                store.startArrowWeaveLevel(at: nextIndex)
            }
        }
    }
}

struct ArrowWeaveBackdrop: View {
    @State private var drift = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.04, blue: 0.10),
                    Color(red: 0.09, green: 0.05, blue: 0.16),
                    Color(red: 0.04, green: 0.11, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color(red: 0.92, green: 0.34, blue: 0.74).opacity(0.24), .clear],
                center: .topLeading,
                startRadius: 4,
                endRadius: 260
            )
            .blur(radius: 8)
            .offset(x: drift ? -120 : -160, y: -220)

            RadialGradient(
                colors: [Color(red: 0.31, green: 0.74, blue: 0.99).opacity(0.22), .clear],
                center: .bottomTrailing,
                startRadius: 10,
                endRadius: 280
            )
            .blur(radius: 10)
            .offset(x: drift ? 170 : 110, y: 240)

            Capsule()
                .fill(Color.white.opacity(0.08))
                .frame(width: 340, height: 8)
                .rotationEffect(.degrees(-22))
                .offset(x: drift ? -150 : -110, y: -80)

            Capsule()
                .fill(Color.white.opacity(0.05))
                .frame(width: 260, height: 6)
                .rotationEffect(.degrees(18))
                .offset(x: drift ? 150 : 190, y: 190)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                drift.toggle()
            }
        }
    }
}

struct EscapeStatChip: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 1) {
                Text(title.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.58))
                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        )
    }
}

struct EscapeActionButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .bold))
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                LinearGradient(
                    colors: [tint.opacity(0.92), tint.opacity(0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .shadow(color: tint.opacity(0.20), radius: 12, x: 0, y: 8)
        }
        .opacity(enabled ? 1 : 0.45)
        .disabled(!enabled)
    }
}

struct EscapeBoardView: View {
    @ObservedObject var session: ArrowWeaveSession
    let boardSize: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let boardFrame = CGRect(origin: .zero, size: proxy.size)
            let padding: CGFloat = 22

            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.08, green: 0.09, blue: 0.18),
                                Color(red: 0.12, green: 0.07, blue: 0.23),
                                Color(red: 0.06, green: 0.12, blue: 0.19)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.18), Color.white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 18)

                gridDots(in: boardFrame, padding: padding)
                routeStrokes(in: boardFrame, padding: padding)
                trailStroke(in: boardFrame, padding: padding)
                routeNodes(in: boardFrame, padding: padding)
            }
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(session.level.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Move limit \(session.level.moveLimit)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.62))
                }
                .padding(.leading, 18)
                .padding(.top, 16)
            }
        }
        .frame(width: boardSize, height: boardSize * 0.98)
        .frame(maxWidth: .infinity)
    }

    private func gridDots(in frame: CGRect, padding: CGFloat) -> some View {
        let rows = session.level.rows
        let cols = session.level.cols
        return ZStack {
            ForEach(0..<rows, id: \.self) { row in
                ForEach(0..<cols, id: \.self) { col in
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 4, height: 4)
                        .position(point(for: BoardPoint(row: row, col: col), in: frame, padding: padding))
                }
            }
        }
    }

    private func routeStrokes(in frame: CGRect, padding: CGFloat) -> some View {
        ZStack {
            ForEach(session.level.routes, id: \.id) { route in
                let state = routeState(for: route.id)
                routePath(route.path, in: frame, padding: padding)
                    .stroke(
                        LinearGradient(
                            colors: [
                                route.color.color.opacity(state?.escaped == true ? 0.30 : 0.50),
                                route.color.accent.opacity(state?.escaped == true ? 0.24 : 0.72)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(
                            lineWidth: state?.isFlying == true ? 20 : 16,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .shadow(color: route.color.accent.opacity(state?.isFlying == true ? 0.45 : 0.18), radius: 10, x: 0, y: 0)
                    .opacity(state?.escaped == true ? 0.70 : 1.0)

                if session.highlightedRouteID == route.id {
                    routePath(route.path, in: frame, padding: padding)
                        .stroke(route.color.accent.opacity(0.78), style: StrokeStyle(lineWidth: 24, lineCap: .round, lineJoin: .round))
                        .blur(radius: 8)
                }
            }
        }
    }

    private func trailStroke(in frame: CGRect, padding: CGFloat) -> some View {
        Group {
            if session.travelTrail.count >= 2, let activeRoute = session.routes.first(where: { $0.isFlying }) {
                routePath(session.travelTrail, in: frame, padding: padding)
                    .stroke(
                        LinearGradient(
                            colors: [activeRoute.color.accent, activeRoute.color.color],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 24, lineCap: .round, lineJoin: .round)
                    )
                    .shadow(color: activeRoute.color.accent.opacity(0.50), radius: 14, x: 0, y: 0)
            }
        }
    }

    private func routeNodes(in frame: CGRect, padding: CGFloat) -> some View {
        ZStack {
            ForEach(session.level.routes, id: \.id) { route in
                if let state = routeState(for: route.id) {
                    let headPoint = point(for: state.headPoint, in: frame, padding: padding)
                    let startPoint = point(for: route.path.first ?? state.headPoint, in: frame, padding: padding)
                    let endPoint = point(for: route.path.last ?? state.headPoint, in: frame, padding: padding)

                    Circle()
                        .fill(state.escaped ? route.color.accent.opacity(0.50) : route.color.color.opacity(0.92))
                        .frame(width: 18, height: 18)
                        .position(startPoint)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.20), lineWidth: 1)
                                .frame(width: 18, height: 18)
                                .position(startPoint)
                        )

                    Circle()
                        .fill(state.escaped ? route.color.accent.opacity(0.42) : Color.white.opacity(0.10))
                        .frame(width: 16, height: 16)
                        .position(endPoint)
                        .overlay(
                            Image(systemName: "flag.checkered")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white.opacity(0.78))
                                .position(endPoint)
                        )

                    if !state.escaped {
                        Button {
                            session.launchRoute(id: route.id)
                        } label: {
                            EscapeArrowBadge(route: state, highlighted: session.highlightedRouteID == route.id)
                        }
                        .buttonStyle(.plain)
                        .position(headPoint)
                        .disabled(session.isAnimating)
                    } else {
                        EscapeArrowBadge(route: state, highlighted: false)
                            .opacity(0.55)
                            .position(endPoint)
                    }
                }
            }
        }
    }

    private func routeState(for id: String) -> ArrowWeaveRouteState? {
        session.routes.first(where: { $0.id == id })
    }

    private func routePath(_ points: [BoardPoint], in frame: CGRect, padding: CGFloat) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: point(for: first, in: frame, padding: padding))
        for nextPoint in points.dropFirst() {
            path.addLine(to: point(for: nextPoint, in: frame, padding: padding))
        }
        return path
    }

    private func point(for point: BoardPoint, in frame: CGRect, padding: CGFloat) -> CGPoint {
        let rows = max(1, session.level.rows - 1)
        let cols = max(1, session.level.cols - 1)
        let usableWidth = frame.width - padding * 2
        let usableHeight = frame.height - padding * 2
        let x = padding + CGFloat(point.col) * usableWidth / CGFloat(cols)
        let y = padding + CGFloat(point.row) * usableHeight / CGFloat(rows)
        return CGPoint(x: x, y: y)
    }
}

struct EscapeArrowBadge: View {
    let route: ArrowWeaveRouteState
    let highlighted: Bool
    @State private var pulse = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [route.color.color, route.color.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .stroke(.white.opacity(0.22), lineWidth: 1)
                )

            Image(systemName: route.facingDirection.symbolName)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(.white)
        }
        .frame(width: 34, height: 34)
        .scaleEffect(highlighted ? 1.12 : (route.isFlying ? 1.08 : 1.0))
        .shadow(color: route.color.accent.opacity(highlighted ? 0.55 : 0.30), radius: 12, x: 0, y: 6)
        .overlay {
            if highlighted {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(route.color.accent.opacity(0.72), lineWidth: 2)
                    .scaleEffect(pulse ? 1.20 : 1.04)
                    .opacity(0.9)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.82).repeatForever(autoreverses: true)) {
                pulse.toggle()
            }
        }
    }
}

struct ArrowWeaveCompletionPanel: View {
    let session: ArrowWeaveSession
    let bestScore: Int
    let totalScore: Int
    let onReplay: () -> Void
    let onNext: () -> Void
    let onHome: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 10) {
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < session.starsEarned ? "star.fill" : "star")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(index < session.starsEarned ? Color(red: 0.99, green: 0.80, blue: 0.30) : .white.opacity(0.24))
                    }
                }
                Text("Escape Complete")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(session.completionSubtitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.74))
            }

            VStack(spacing: 8) {
                escapeInfoRow(label: "Score", value: "\(session.score)")
                escapeInfoRow(label: "Best score", value: "\(bestScore)")
                escapeInfoRow(label: "Total score", value: "\(totalScore)")
                escapeInfoRow(label: "Time", value: CompetitiveScoring.timeLabel(for: session.elapsedSeconds))
                escapeInfoRow(label: "Moves left", value: "\(session.remainingMoves)")
                escapeInfoRow(label: "Routes cleared", value: "\(session.escapedRoutes)")
                escapeInfoRow(label: "Total routes", value: "\(session.level.totalRoutes)")
            }
            .padding(.vertical, 4)

            HStack(spacing: 10) {
                EscapeActionButton(title: "Home", systemImage: "house.fill", tint: Color(red: 0.54, green: 0.72, blue: 1.00), action: onHome)
                EscapeActionButton(title: "Replay", systemImage: "arrow.clockwise", tint: Color(red: 0.40, green: 0.89, blue: 0.73), action: onReplay)
            }

            Button {
                onNext()
            } label: {
                Text("Next Level")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.93, green: 0.35, blue: 0.76), Color(red: 0.31, green: 0.74, blue: 0.99)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )
            }
        }
        .padding(18)
        .frame(maxWidth: 360)
        .background(.black.opacity(0.56), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.45), radius: 24, x: 0, y: 16)
    }

    private func escapeInfoRow(label: String, value: String) -> some View {
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

struct ArrowWeaveScoreboardView: View {
    @ObservedObject var store: GameStore

    private var summaries: [LevelScoreSummary] {
        arrowWeaveScoreSummaries(progress: store.arrowWeaveProgress, levels: store.arrowWeaveLevels)
    }

    private var totalScore: Int {
        summaries.reduce(0) { $0 + $1.totalScore }
    }

    var body: some View {
        ScoreboardScreen(
            title: "Arrow Weave Scoreboard",
            subtitle: "Route flow, timing, and total clears are tracked per level.",
            icon: "waveform.path.ecg",
            accentColors: [
                Color(red: 0.92, green: 0.35, blue: 0.76),
                Color(red: 0.31, green: 0.74, blue: 0.99)
            ],
            summaries: summaries,
            totalScore: totalScore,
            emptyTitle: "No Arrow Weave scores yet",
            emptyMessage: "Play an Arrow Weave level to see its route score, moves, and timing here.",
            onDeleteLevel: { summary in
                store.deleteArrowWeaveScore(for: summary.levelIndex)
            },
            onClearAll: {
                store.clearAllArrowWeaveScores()
            },
            onBack: {
                store.closeScoreboard()
            }
        )
    }
}

struct ArrowWeaveFailurePanel: View {
    let session: ArrowWeaveSession
    let onRetry: () -> Void
    let onHome: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color(red: 0.99, green: 0.64, blue: 0.26))
                Text("Escape Failed")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(session.failureMessage)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.74))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 8) {
                escapeInfoRow(label: "Score", value: "\(session.score)")
                escapeInfoRow(label: "Moves left", value: "\(session.remainingMoves)")
                escapeInfoRow(label: "Routes cleared", value: "\(session.escapedRoutes)")
            }
            .padding(.vertical, 4)

            HStack(spacing: 10) {
                EscapeActionButton(title: "Home", systemImage: "house.fill", tint: Color(red: 0.54, green: 0.72, blue: 1.00), action: onHome)
                EscapeActionButton(title: "Retry", systemImage: "arrow.clockwise", tint: Color(red: 0.99, green: 0.64, blue: 0.26), action: onRetry)
            }
        }
        .padding(18)
        .frame(maxWidth: 360)
        .background(.black.opacity(0.58), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.45), radius: 24, x: 0, y: 16)
    }

    private func escapeInfoRow(label: String, value: String) -> some View {
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
