import SwiftUI

struct CommunityHubScreen: View {
    @Environment(TabRouter.self) private var router

    var body: some View {
        List {
            hubRow(title: .communityForumTitle, systemImage: "bubble.left.and.bubble.right.fill") {
                router.push(.forum)
            }
            hubRow(title: .communityGroupsTitle, systemImage: "person.3.fill") {
                router.push(.groups)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Text(.community))
    }

    private func hubRow(
        title: LocalizedStringResource,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        return Button(action: action) {
            ListRow(title: String(localized: title)) {
                SymbolTile(systemImage: systemImage)
            } trailing: {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
        }
        .buttonStyle(.plain)
    }
}
