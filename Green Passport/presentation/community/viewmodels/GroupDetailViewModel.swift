import Foundation
import Observation

@Observable
final class GroupDetailViewModel {
    @ObservationIgnored private let groupId: String
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let observeGroup: ObserveGroupUseCase
    @ObservationIgnored private let observeMessages: ObserveGroupMessagesUseCase
    @ObservationIgnored private let sendMessage: SendGroupMessageUseCase
    @ObservationIgnored private let joinGroup: JoinGroupUseCase
    @ObservationIgnored private let leaveGroup: LeaveGroupUseCase
    @ObservationIgnored private let fetchMembers: FetchGroupMembersUseCase
    @ObservationIgnored private var messagesTask: Task<Void, Never>?

    private(set) var uiState = GroupDetailUiState()

    init(
        groupId: String,
        observeSession: ObserveSessionUseCase,
        observeGroup: ObserveGroupUseCase,
        observeMessages: ObserveGroupMessagesUseCase,
        sendMessage: SendGroupMessageUseCase,
        joinGroup: JoinGroupUseCase,
        leaveGroup: LeaveGroupUseCase,
        fetchMembers: FetchGroupMembersUseCase
    ) {
        self.groupId = groupId
        self.observeSession = observeSession
        self.observeGroup = observeGroup
        self.observeMessages = observeMessages
        self.sendMessage = sendMessage
        self.joinGroup = joinGroup
        self.leaveGroup = leaveGroup
        self.fetchMembers = fetchMembers
    }

    func observe() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.observeUser() }
            group.addTask { await self.observeGroupDocument() }
        }
        stopMessages()
    }

    func updateDraft(_ text: String) {
        uiState.draft = text
        uiState.isTextRejected = false
        uiState.isSendFailed = false
    }

    func send() {
        let text = uiState.draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let userId = uiState.currentUserId, uiState.isMember, !text.isEmpty, !uiState.isSending else {
            return
        }
        uiState.isSending = true
        uiState.isSendFailed = false
        Task {
            do {
                try await sendMessage.execute(groupId: groupId, senderId: userId, text: text)
                uiState.draft = ""
            } catch is ContentRejectedError {
                uiState.isTextRejected = true
            } catch {
                uiState.isSendFailed = true
            }
            uiState.isSending = false
        }
    }

    func join() {
        guard let userId = uiState.currentUserId, !uiState.isJoining else {
            return
        }
        uiState.isJoining = true
        Task {
            try? await joinGroup.execute(groupId: groupId, userId: userId)
            uiState.isJoining = false
            updateMessagesObservation()
        }
    }

    func leave() {
        guard let userId = uiState.currentUserId, !uiState.isLeaving else {
            return
        }
        uiState.isLeaving = true
        stopMessages()
        Task {
            try? await leaveGroup.execute(groupId: groupId, userId: userId)
            uiState.isLeaving = false
            updateMessagesObservation()
        }
    }

    func loadMembers() async {
        guard let memberIds = uiState.group?.memberIds else {
            return
        }
        uiState.isLoadingMembers = true
        uiState.members = (try? await fetchMembers.execute(memberIds: memberIds)) ?? []
        uiState.isLoadingMembers = false
    }

    func retryMessages() {
        stopMessages()
        updateMessagesObservation()
    }

    private func observeUser() async {
        for await session in observeSession.execute() {
            uiState.currentUserId = session?.userId
            updateMessagesObservation()
        }
    }

    private func observeGroupDocument() async {
        do {
            for try await group in observeGroup.execute(groupId: groupId) {
                uiState.group = group
                uiState.isLoading = false
                uiState.hasError = group == nil
                updateMessagesObservation()
            }
        } catch {
            uiState.isLoading = false
            uiState.hasError = true
        }
    }

    private func updateMessagesObservation() {
        guard uiState.isMember, !uiState.isJoining, !uiState.isLeaving else {
            if !uiState.isJoining {
                stopMessages()
            }
            return
        }
        guard messagesTask == nil else {
            return
        }
        messagesTask = Task { [weak self] in
            await self?.observeMessageList()
        }
    }

    private func stopMessages() {
        messagesTask?.cancel()
        messagesTask = nil
        uiState.messages = []
        uiState.isLoadingMessages = true
        uiState.hasMessagesError = false
    }

    private func observeMessageList() async {
        do {
            for try await messages in observeMessages.execute(groupId: groupId) {
                uiState.messages = messages
                uiState.isLoadingMessages = false
                uiState.hasMessagesError = false
            }
        } catch {
            if !Task.isCancelled {
                uiState.isLoadingMessages = false
                uiState.hasMessagesError = true
            }
        }
    }
}
