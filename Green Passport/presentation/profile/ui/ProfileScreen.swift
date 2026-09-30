import SwiftUI

struct ProfileScreen: View {
    private static let avatarSize: CGFloat = 64
    private static let tileSize: CGFloat = 30

    let uiState: ProfileUiState
    let languageName: String
    let onAction: (ProfileUserAction) -> Void

    var body: some View {
        List {
            Section {
                header
                ProgressHeroCard(points: uiState.points, level: uiState.level)
                    .redacted(reason: uiState.isLoading ? .placeholder : [])
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            .listRowSeparator(.hidden)
            Section {
                if uiState.isModerator {
                    menuButton(title: .moderation, systemImage: "checkmark.shield.fill", color: Palette.error) {
                        onAction(.moderation)
                    }
                }
                if !uiState.isAnonymous {
                    menuButton(title: .editProfile, systemImage: "pencil", color: Palette.forest) {
                        onAction(.editProfile)
                    }
                }
                Toggle(isOn: Binding(get: { return uiState.notificationsEnabled }, set: { onAction(.notificationsToggled($0)) })) {
                    HStack(spacing: Spacing.small) {
                        SymbolTile(systemImage: "bell.badge.fill", color: Palette.forest, size: Self.tileSize)
                        Text(.profileNotificationsLabel)
                    }
                }
                Button {
                    onAction(.language)
                } label: {
                    HStack(spacing: Spacing.small) {
                        SymbolTile(systemImage: "character.bubble.fill", color: SectionColor.calendar, size: Self.tileSize)
                        Text(.language)
                            .foregroundStyle(Color.primary)
                        Spacer()
                        Text(languageName)
                            .foregroundStyle(Palette.secondaryText)
                        Image(systemName: "arrow.up.forward.app")
                            .font(.footnote)
                            .foregroundStyle(Color(.tertiaryLabel))
                    }
                }
            }
            Section {
                ForEach(ProfileMenuEntry.allCases, id: \.self) { entry in
                    menuButton(title: entry.title, systemImage: entry.systemImage, color: entry.color) {
                        onAction(.open(entry.destination))
                    }
                }
            }
            Section {
                Button(role: .destructive) {
                    onAction(.signOut)
                } label: {
                    Label {
                        Text(.profileSignOut)
                    } icon: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Text(.profile))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: Spacing.medium) {
            ProfileAvatar(style: uiState.profile?.avatar ?? .lime, size: Self.avatarSize)
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                Text(displayName)
                    .font(.title2.bold())
                    .lineLimit(1)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Palette.secondaryText)
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: Spacing.xSmall, trailing: 0))
    }

    private var displayName: String {
        if let profile = uiState.profile {
            return "\(profile.firstName) \(profile.lastName)".trimmingCharacters(in: .whitespaces)
        }
        if uiState.isAnonymous {
            return String(localized: .profileAnonymousLabel)
        }
        return uiState.email ?? String(localized: .profileAnonymousLabel)
    }

    private var subtitle: String {
        guard let city = uiState.profile?.city, !city.isEmpty else {
            return String(localized: .pointsBalance(uiState.points))
        }
        return String(localized: .cityAndPoints(city, uiState.points))
    }

    private func menuButton(
        title: LocalizedStringResource,
        systemImage: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        return Button(action: action) {
            HStack(spacing: Spacing.small) {
                SymbolTile(systemImage: systemImage, color: color, size: Self.tileSize)
                Text(title)
                    .foregroundStyle(Color.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileScreen(
            uiState: ProfileUiState(
                profile: UserProfile(userId: "1", firstName: "Роман", lastName: "Г.", city: "Минск", interests: [], avatar: .sky),
                isModerator: true,
                level: Level(lifetimeXp: 1500),
                points: 300,
                isLoading: false
            ),
            languageName: "Русский",
            onAction: { _ in }
        )
    }
}
