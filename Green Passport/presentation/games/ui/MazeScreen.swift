import SwiftUI

struct MazeScreen: View {
    private static let cellSpacing: CGFloat = 4
    private static let symbolScale: CGFloat = 0.5
    private static let swipeThreshold: CGFloat = 24
    private static let padButtonSize: CGFloat = 56

    let uiState: MazeUiState
    let onMove: (MazeDirection) -> Void
    let onRestart: () -> Void

    var body: some View {
        VStack(spacing: Spacing.large) {
            if uiState.isFinished {
                Spacer()
                GameResultView(message: String(localized: .mazeFinishedFormat(uiState.score)), onPlayAgain: onRestart)
                Spacer()
            } else {
                Text(.mazeScoreFormat(uiState.score))
                    .font(.headline)
                    .contentTransition(.numericText(value: Double(uiState.score)))
                grid
                    .gesture(swipe)
                directionPad
            }
        }
        .padding(Spacing.screenHorizontal)
        .animation(.snappy, value: uiState.playerPosition)
        .animation(.snappy, value: uiState.isFinished)
        .background(Palette.screenBackground)
        .navigationTitle(Text(.gameEcoMazeTitle))
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.impact(weight: .light), trigger: uiState.playerPosition)
        .sensoryFeedback(.success, trigger: uiState.collectedItems.count)
    }

    private var grid: some View {
        Grid(horizontalSpacing: Self.cellSpacing, verticalSpacing: Self.cellSpacing) {
            ForEach(Array(MazeLayout.grid.enumerated()), id: \.offset) { rowIndex, row in
                GridRow {
                    ForEach(Array(row.enumerated()), id: \.offset) { columnIndex, cell in
                        cellView(cell, position: MazePosition(row: rowIndex, column: columnIndex))
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func cellView(_ cell: MazeCell, position: MazePosition) -> some View {
        return RoundedRectangle(cornerRadius: CornerRadius.small, style: .continuous)
            .fill(cell == .wall ? Palette.forest : Palette.mintSurface)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                GeometryReader { proxy in
                    if let symbol = symbol(for: cell, position: position) {
                        Image(systemName: symbol.name)
                            .font(.system(size: proxy.size.width * Self.symbolScale, weight: .bold))
                            .foregroundStyle(symbol.color)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
    }

    private func symbol(for cell: MazeCell, position: MazePosition) -> (name: String, color: Color)? {
        if position == uiState.playerPosition {
            return ("figure.walk.circle.fill", Palette.forest)
        }
        switch cell {
        case .item where !uiState.collectedItems.contains(position):
            return ("leaf.fill", SectionColor.tips)
        case .exit:
            return ("flag.checkered", SectionColor.feedback)
        default:
            return nil
        }
    }

    private var directionPad: some View {
        Grid(horizontalSpacing: Spacing.small, verticalSpacing: Spacing.small) {
            GridRow {
                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                padButton(.up)
                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
            }
            GridRow {
                padButton(.left)
                padButton(.down)
                padButton(.right)
            }
        }
    }

    private func padButton(_ direction: MazeDirection) -> some View {
        return Button {
            onMove(direction)
        } label: {
            Image(systemName: direction.systemImage)
                .font(.title2.weight(.semibold))
                .frame(width: Self.padButtonSize, height: Self.padButtonSize)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
    }

    private var swipe: some Gesture {
        DragGesture(minimumDistance: Self.swipeThreshold)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                if abs(horizontal) > abs(vertical) {
                    onMove(horizontal > 0 ? .right : .left)
                } else {
                    onMove(vertical > 0 ? .down : .up)
                }
            }
    }
}

#Preview {
    NavigationStack {
        MazeScreen(uiState: MazeUiState(), onMove: { _ in }, onRestart: {})
    }
}
