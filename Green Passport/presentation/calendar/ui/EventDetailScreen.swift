import SwiftUI

struct EventDetailScreen: View {
    private static let imageAspectRatio: CGFloat = 1.5

    let uiState: EventDetailUiState
    let onSignUp: () -> Void
    let onRetry: () -> Void

    var body: some View {
        Group {
            if uiState.hasError {
                StateView(kind: .error(retry: onRetry))
            } else if let event = uiState.event, !uiState.isLoading {
                content(event: event)
            } else {
                StateView(kind: .loading)
            }
        }
        .background(Palette.screenBackground)
        .sensoryFeedback(.success, trigger: uiState.isRegistered) { _, isRegistered in
            return isRegistered
        }
    }

    private func content(event: EcoEvent) -> some View {
        return ScrollView {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Color.clear
                    .aspectRatio(Self.imageAspectRatio, contentMode: .fit)
                    .overlay {
                        RemoteImage(url: event.imageUrl.flatMap(URL.init(string:)))
                    }
                    .clipShape(.rect(cornerRadius: CornerRadius.large, style: .continuous))
                Text(event.title)
                    .font(.title2.bold())
                VStack(alignment: .leading, spacing: Spacing.xSmall) {
                    Label {
                        Text(.dateTime(event.dateText, event.timeText))
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundStyle(Palette.forest)
                    }
                    Label {
                        Text(event.location)
                    } icon: {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(Palette.forest)
                    }
                }
                .font(.subheadline)
                Text(event.description)
                    .font(.body)
                    .foregroundStyle(Palette.secondaryText)
            }
            .padding(Spacing.screenHorizontal)
        }
        .safeAreaInset(edge: .bottom) {
            Group {
                if uiState.isRegistered {
                    Label {
                        Text(.calendarRegisteredLabel)
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .font(.headline)
                    .foregroundStyle(Palette.forest)
                } else {
                    AppButton(
                        title: event.rewardPoints > 0 ? .signUpPoints(event.rewardPoints) : .signUp,
                        isLoading: uiState.isRegistering,
                        action: onSignUp
                    )
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.bottom, Spacing.medium)
        }
    }
}
