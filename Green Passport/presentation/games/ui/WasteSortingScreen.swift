import SwiftUI

struct WasteSortingScreen: View {
    private static let binColumnCount = 2
    private static let binHeight: CGFloat = 110
    private static let binSymbolSize: CGFloat = 32
    private static let warningSeconds = 5

    let uiState: WasteSortingUiState
    let onSelect: (WasteCategory) -> Void
    let onRestart: () -> Void

    var body: some View {
        VStack(spacing: Spacing.large) {
            if uiState.isFinished {
                Spacer()
                GameResultView(message: String(localized: .sortingFinishedFormat(uiState.score)), onPlayAgain: onRestart)
                Spacer()
            } else {
                HStack {
                    Label {
                        Text(.sortingScoreFormat(uiState.score))
                            .contentTransition(.numericText(value: Double(uiState.score)))
                    } icon: {
                        Image(systemName: "star.fill")
                            .foregroundStyle(SectionColor.tips)
                    }
                    Spacer()
                    Label {
                        Text(.sortingTimeFormat(uiState.secondsRemaining))
                            .contentTransition(.numericText(countsDown: true))
                    } icon: {
                        Image(systemName: "timer")
                    }
                    .foregroundStyle(uiState.secondsRemaining <= Self.warningSeconds ? Palette.error : Color.primary)
                }
                .font(.headline.monospacedDigit())
                Text(.sortingInstructions)
                    .font(.subheadline)
                    .foregroundStyle(Palette.secondaryText)
                Spacer()
                if let item = uiState.currentItem {
                    Text(item.name)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .id(uiState.answerCount)
                        .transition(.push(from: .trailing))
                }
                Spacer()
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.small), count: Self.binColumnCount),
                    spacing: Spacing.small
                ) {
                    ForEach(WasteCategory.allCases, id: \.self) { category in
                        binButton(category)
                    }
                }
            }
        }
        .padding(Spacing.screenHorizontal)
        .animation(.snappy, value: uiState.answerCount)
        .animation(.snappy, value: uiState.isFinished)
        .background(Palette.screenBackground)
        .navigationTitle(Text(.gameWasteSortingTitle))
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(trigger: uiState.answerCount) {
            return uiState.lastAnswerCorrect == true ? .success : .error
        }
    }

    private func binButton(_ category: WasteCategory) -> some View {
        return Button {
            onSelect(category)
        } label: {
            VStack(spacing: Spacing.xSmall) {
                Image(systemName: category.systemImage)
                    .font(.system(size: Self.binSymbolSize, weight: .semibold))
                Text(category.title)
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: Self.binHeight)
            .background(category.color.gradient, in: .rect(cornerRadius: CornerRadius.large, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        WasteSortingScreen(
            uiState: WasteSortingUiState(currentItem: WasteItem.pool.first, secondsRemaining: 20),
            onSelect: { _ in },
            onRestart: {}
        )
    }
}
