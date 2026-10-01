import SwiftUI

struct GroupsScreen: View {
    let uiState: GroupsUiState
    @Binding var draftName: String
    @Binding var inviteCode: String
    let onCreate: () -> Void
    let onJoin: (CommunityGroup) -> Void
    let onOpen: (CommunityGroup) -> Void
    let onJoinByCode: () -> Void
    let onDismissNotFound: () -> Void
    let onRetry: () -> Void

    @State private var isCodePromptPresented = false

    var body: some View {
        List {
            Section {
                HStack(spacing: Spacing.xSmall) {
                    TextField(String(localized: .groupsDraftLabel), text: $draftName)
                        .submitLabel(.done)
                        .onSubmit(onCreate)
                    if uiState.isCreating {
                        ProgressView()
                    } else {
                        Button(action: onCreate) {
                            Text(.groupsCreateButton)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .disabled(draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            } footer: {
                if uiState.isNameRejected {
                    Text(.textContainsBannedWords)
                        .foregroundStyle(Palette.error)
                }
            }
            if !uiState.groups.isEmpty {
                Section {
                    ForEach(uiState.groups) { group in
                        groupRow(group)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .dismissesKeyboardOnScroll()
        .overlay {
            if uiState.isLoading {
                StateView(kind: .loading)
            } else if uiState.hasError {
                StateView(kind: .error(retry: onRetry))
            } else if uiState.groups.isEmpty {
                StateView(kind: .empty(message: .groupsEmpty))
            }
        }
        .navigationTitle(Text(.communityGroupsTitle))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if uiState.isJoiningByCode {
                    ProgressView()
                } else {
                    Button {
                        isCodePromptPresented = true
                    } label: {
                        Label(String(localized: .joinByCode), systemImage: "number")
                    }
                }
            }
        }
        .alert(Text(.joinByCode), isPresented: $isCodePromptPresented) {
            TextField(String(localized: .inviteCode), text: $inviteCode)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
            Button(role: .cancel) {
                inviteCode = ""
            } label: {
                Text(.cancel)
            }
            Button(action: onJoinByCode) {
                Text(.groupsJoinButton)
            }
        }
        .alert(
            Text(.groupNotFoundMsg),
            isPresented: Binding(get: { return uiState.isInviteCodeNotFound }, set: { _ in onDismissNotFound() })
        ) {
            Button(role: .cancel, action: onDismissNotFound) {
                Text(.close)
            }
        }
    }

    private func groupRow(_ group: CommunityGroup) -> some View {
        let isMember = uiState.currentUserId.map { return group.memberIds.contains($0) } ?? false
        return ListRow(title: group.name, subtitle: String(localized: .groupsMemberCountFormat(group.memberIds.count))) {
            SymbolTile(systemImage: "person.3.fill")
        } trailing: {
            if isMember {
                Text(.groupsJoinedLabel)
                    .font(.subheadline)
                    .foregroundStyle(Palette.forest)
            } else if uiState.joiningGroupId == group.id {
                ProgressView()
            } else {
                Button {
                    onJoin(group)
                } label: {
                    Text(.groupsJoinButton)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
            }
        }
        .onTapGesture {
            onOpen(group)
        }
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    NavigationStack {
        GroupsScreen(
            uiState: GroupsUiState(groups: [CommunityGroup(id: "1", name: "Эко-Минск", memberIds: ["1", "2"])], isLoading: false),
            draftName: .constant(""),
            inviteCode: .constant(""),
            onCreate: {},
            onJoin: { _ in },
            onOpen: { _ in },
            onJoinByCode: {},
            onDismissNotFound: {},
            onRetry: {}
        )
    }
}
