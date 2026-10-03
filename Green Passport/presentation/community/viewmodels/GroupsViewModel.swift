import Foundation
import Observation

@Observable
final class GroupsViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let observeGroups: ObserveGroupsUseCase
    @ObservationIgnored private let createGroup: CreateGroupUseCase
    @ObservationIgnored private let joinGroup: JoinGroupUseCase
    @ObservationIgnored private let joinGroupByCode: JoinGroupByCodeUseCase

    private(set) var uiState = GroupsUiState()

    init(
        observeSession: ObserveSessionUseCase,
        observeGroups: ObserveGroupsUseCase,
        createGroup: CreateGroupUseCase,
        joinGroup: JoinGroupUseCase,
        joinGroupByCode: JoinGroupByCodeUseCase
    ) {
        self.observeSession = observeSession
        self.observeGroups = observeGroups
        self.createGroup = createGroup
        self.joinGroup = joinGroup
        self.joinGroupByCode = joinGroupByCode
    }

    func observe() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.observeUser() }
            group.addTask { await self.observeGroupList() }
        }
    }

    func updateDraftName(_ name: String) {
        uiState.draftName = name
        uiState.isNameRejected = false
    }

    func create() {
        let name = uiState.draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let userId = uiState.currentUserId, !name.isEmpty, !uiState.isCreating else {
            return
        }
        uiState.isCreating = true
        Task {
            do {
                try await createGroup.execute(name: name, creatorId: userId)
                uiState.draftName = ""
            } catch is ContentRejectedError {
                uiState.isNameRejected = true
            } catch {
                uiState.isNameRejected = false
            }
            uiState.isCreating = false
        }
    }

    func join(_ group: CommunityGroup) {
        guard let userId = uiState.currentUserId, uiState.joiningGroupId == nil else {
            return
        }
        uiState.joiningGroupId = group.id
        Task {
            try? await joinGroup.execute(groupId: group.id, userId: userId)
            uiState.joiningGroupId = nil
        }
    }

    func updateInviteCodeDraft(_ code: String) {
        uiState.inviteCodeDraft = code
    }

    func dismissInviteCodeNotFound() {
        uiState.isInviteCodeNotFound = false
    }

    func joinByCode() async -> String? {
        guard let userId = uiState.currentUserId, !uiState.isJoiningByCode else {
            return nil
        }
        uiState.isJoiningByCode = true
        defer {
            uiState.isJoiningByCode = false
            uiState.inviteCodeDraft = ""
        }
        do {
            let group = try await joinGroupByCode.execute(code: uiState.inviteCodeDraft, userId: userId)
            return group.id
        } catch {
            uiState.isInviteCodeNotFound = true
            return nil
        }
    }

    private func observeUser() async {
        for await session in observeSession.execute() {
            uiState.currentUserId = session?.userId
        }
    }

    private func observeGroupList() async {
        do {
            for try await groups in observeGroups.execute() {
                uiState.groups = groups
                uiState.isLoading = false
                uiState.hasError = false
            }
        } catch {
            uiState.isLoading = false
            uiState.hasError = true
        }
    }
}
