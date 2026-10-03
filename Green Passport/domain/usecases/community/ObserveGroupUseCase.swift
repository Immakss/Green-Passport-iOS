final class ObserveGroupUseCase {
    private let communityRepository: CommunityRepository

    init(communityRepository: CommunityRepository) {
        self.communityRepository = communityRepository
    }

    func execute(groupId: String) -> AsyncThrowingStream<CommunityGroup?, Error> {
        return communityRepository.observeGroup(id: groupId)
    }
}
