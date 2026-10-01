final class LeaveGroupUseCase {
    private let communityRepository: CommunityRepository

    init(communityRepository: CommunityRepository) {
        self.communityRepository = communityRepository
    }

    func execute(groupId: String, userId: String) async throws {
        try await communityRepository.leaveGroup(groupId: groupId, userId: userId)
    }
}
