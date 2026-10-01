final class FetchGroupMembersUseCase {
    private let communityRepository: CommunityRepository

    init(communityRepository: CommunityRepository) {
        self.communityRepository = communityRepository
    }

    func execute(memberIds: [String]) async throws -> [GroupMember] {
        return try await communityRepository.fetchMembers(ids: memberIds)
    }
}
