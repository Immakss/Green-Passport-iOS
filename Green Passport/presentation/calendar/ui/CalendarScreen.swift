import SwiftUI

struct CalendarScreen: View {
    private static let cardHeight: CGFloat = 160

    let uiState: ListUiState<EcoEvent>
    let onEvent: (EcoEvent) -> Void
    let onRetry: () -> Void

    var body: some View {
        Group {
            switch uiState {
            case .loading:
                StateView(kind: .loading)
            case .error:
                StateView(kind: .error(retry: onRetry))
            case .success(let events) where events.isEmpty:
                StateView(kind: .empty(message: .calendarEmpty))
            case .success(let events):
                ScrollView {
                    LazyVStack(spacing: Spacing.small) {
                        ForEach(events) { event in
                            Button {
                                onEvent(event)
                            } label: {
                                HeroImageCard(
                                    imageUrl: event.imageUrl,
                                    title: event.title,
                                    subtitle: String(localized: .dateTime(event.dateText, event.timeText)),
                                    height: Self.cardHeight
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.bottom, Spacing.large)
                }
            }
        }
        .background(Palette.screenBackground)
        .navigationTitle(Text(.calendar))
    }
}

#Preview {
    NavigationStack {
        CalendarScreen(uiState: .success(data: []), onEvent: { _ in }, onRetry: {})
    }
}
