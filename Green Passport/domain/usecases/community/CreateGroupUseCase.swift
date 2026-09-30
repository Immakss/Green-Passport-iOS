final class CreateGroupUseCase {
    private let communityRepository: CommunityRepository
    private let textModerator: TextModerator

    init(communityRepository: CommunityRepository, textModerator: TextModerator) {
        self.communityRepository = communityRepository
        self.textModerator = textModerator
    }

    func execute(name: String, creatorId: String) async throws {
        guard textModerator.isAllowed(name) else {
            throw ContentRejectedError()
        }
        try await communityRepository.createGroup(name: name, creatorId: creatorId)
    }
}
