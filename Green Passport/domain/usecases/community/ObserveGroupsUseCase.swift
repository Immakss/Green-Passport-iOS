final class ObserveGroupsUseCase {
    private let communityRepository: CommunityRepository

    init(communityRepository: CommunityRepository) {
        self.communityRepository = communityRepository
    }

    func execute() -> AsyncThrowingStream<[CommunityGroup], Error> {
        return communityRepository.observeGroups()
    }
}
