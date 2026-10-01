import SwiftUI

struct GroupDetailScreen: View {
    private static let avatarSize: CGFloat = 28
    private static let bubbleInset: CGFloat = 48
    private static let headerTileSize: CGFloat = 64

    let uiState: GroupDetailUiState
    @Binding var draft: String
    let onSend: () -> Void
    let onJoin: () -> Void
    let onLeave: () -> Void
    let onLoadMembers: () async -> Void
    let onRetryMessages: () -> Void
    let onRetry: () -> Void

    @State private var isMembersPresented = false
    @State private var isLeaveConfirmationPresented = false

    var body: some View {
        content
            .background(Palette.screenBackground)
            .navigationTitle(Text(verbatim: uiState.group?.name ?? ""))
            .toolbar {
                if let group = uiState.group, uiState.isMember {
                    ToolbarItem(placement: .topBarTrailing) {
                        menu(group)
                    }
                }
            }
            .sheet(isPresented: $isMembersPresented) {
                GroupMembersSheet(members: uiState.members, isLoading: uiState.isLoadingMembers, onLoad: onLoadMembers)
            }
            .confirmationDialog(Text(.leaveGroup), isPresented: $isLeaveConfirmationPresented, titleVisibility: .visible) {
                Button(role: .destructive, action: onLeave) {
                    Text(.leaveGroup)
                }
            } message: {
                Text(.leaveGroupConfirmMsg)
            }
    }

    @ViewBuilder
    private var content: some View {
        if let group = uiState.group {
            if uiState.isMember {
                chat
            } else {
                joinPrompt(group)
            }
        } else if uiState.hasError {
            StateView(kind: .error(retry: onRetry))
        } else {
            StateView(kind: .loading)
        }
    }

    private var chat: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.xSmall) {
                ForEach(uiState.messages) { message in
                    messageRow(message)
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.vertical, Spacing.small)
        }
        .defaultScrollAnchor(.bottom)
        .defaultScrollAnchor(.bottom, for: .sizeChanges)
        .scrollDismissesKeyboard(.interactively)
        .dismissesKeyboardOnBackgroundTap()
        .overlay {
            if uiState.hasMessagesError {
                StateView(kind: .error(retry: onRetryMessages))
            } else if uiState.isLoadingMessages {
                StateView(kind: .loading)
            } else if uiState.messages.isEmpty {
                StateView(kind: .empty(message: .groupChatEmptyMsg))
            }
        }
        .safeAreaInset(edge: .bottom) {
            MessageComposer(
                draft: $draft,
                placeholder: .forumDraftLabel,
                isSending: uiState.isSending,
                errorMessage: composerError,
                onSend: onSend
            )
        }
    }

    private var composerError: LocalizedStringResource? {
        if uiState.isTextRejected {
            return .textContainsBannedWords
        }
        if uiState.isSendFailed {
            return .messageNotSentMsg
        }
        return nil
    }

    private func joinPrompt(_ group: CommunityGroup) -> some View {
        return VStack(spacing: Spacing.medium) {
            SymbolTile(systemImage: "person.3.fill", size: Self.headerTileSize)
            VStack(spacing: Spacing.xxSmall) {
                Text(group.name)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                Text(.groupsMemberCountFormat(group.memberIds.count))
                    .font(.subheadline)
                    .foregroundStyle(Palette.secondaryText)
            }
            Text(.joinGroupToChatMsg)
                .font(.body)
                .foregroundStyle(Palette.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            AppButton(title: .groupsJoinButton, isLoading: uiState.isJoining, action: onJoin)
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.bottom, Spacing.medium)
        }
    }

    private func menu(_ group: CommunityGroup) -> some View {
        return Menu {
            Button {
                isMembersPresented = true
            } label: {
                Label(String(localized: .groupMembers), systemImage: "person.2")
            }
            if let inviteCode = group.inviteCode {
                ShareLink(item: String(localized: .groupInviteShareMsg(group.name, inviteCode))) {
                    Label(String(localized: .invite), systemImage: "person.badge.plus")
                }
            }
            Button(role: .destructive) {
                isLeaveConfirmationPresented = true
            } label: {
                Label(String(localized: .leaveGroup), systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            Label(String(localized: .more), systemImage: "ellipsis")
        }
        .disabled(uiState.isLeaving)
    }

    @ViewBuilder
    private func messageRow(_ message: GroupMessage) -> some View {
        if message.senderId == uiState.currentUserId {
            HStack {
                Spacer(minLength: Self.bubbleInset)
                bubble(message, showsSender: false)
                    .background(Palette.mintSurfaceHigh, in: .rect(cornerRadius: CornerRadius.large, style: .continuous))
            }
        } else {
            HStack(alignment: .bottom, spacing: Spacing.xSmall) {
                ProfileAvatar(style: message.senderAvatar ?? .lime, size: Self.avatarSize)
                bubble(message, showsSender: true)
                    .background(Palette.cardBackground, in: .rect(cornerRadius: CornerRadius.large, style: .continuous))
                Spacer(minLength: Self.bubbleInset)
            }
        }
    }

    private func bubble(_ message: GroupMessage, showsSender: Bool) -> some View {
        return VStack(alignment: .leading, spacing: Spacing.hairline) {
            if showsSender {
                Text(message.senderName ?? String(localized: .guest))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Palette.forest)
            }
            Text(message.text)
                .font(.body)
            Text(message.sentAt.formatted(date: .omitted, time: .shortened))
                .font(.caption2)
                .foregroundStyle(Palette.secondaryText)
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Spacing.xSmall)
    }
}

#Preview {
    NavigationStack {
        GroupDetailScreen(
            uiState: GroupDetailUiState(
                group: CommunityGroup(id: "1", name: "Эко-Минск", memberIds: ["1", "2"], ownerId: "1", inviteCode: "ABC234"),
                messages: [
                    GroupMessage(id: "1", senderId: "2", senderName: "Аня", senderAvatar: .berry, text: "Кто идёт на субботник?", sentAt: .now),
                    GroupMessage(id: "2", senderId: "1", senderName: "Я", senderAvatar: .lime, text: "Я иду!", sentAt: .now),
                ],
                currentUserId: "1",
                isLoading: false,
                isLoadingMessages: false
            ),
            draft: .constant(""),
            onSend: {},
            onJoin: {},
            onLeave: {},
            onLoadMembers: {},
            onRetryMessages: {},
            onRetry: {}
        )
    }
}
