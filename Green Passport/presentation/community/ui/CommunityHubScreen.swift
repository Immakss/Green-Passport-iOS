import SwiftUI

struct CommunityHubScreen: View {
    @Environment(TabRouter.self) private var router

    var body: some View {
        List {
            hubRow(title: .communityForumTitle, systemImage: "bubble.left.and.bubble.right.fill", color: SectionColor.community) {
                router.push(.forum)
            }
            hubRow(title: .communityGroupsTitle, systemImage: "person.3.fill", color: SectionColor.calendar) {
                router.push(.groups)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Text(.community))
    }

    private func hubRow(
        title: LocalizedStringResource,
        systemImage: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        return Button(action: action) {
            ListRow(title: String(localized: title)) {
                SymbolTile(systemImage: systemImage, color: color)
            } trailing: {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
        }
        .buttonStyle(.plain)
    }
}
