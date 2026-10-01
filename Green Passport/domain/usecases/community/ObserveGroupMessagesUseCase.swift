final class ObserveGroupMessagesUseCase {
    private let communityRepository: CommunityRepository

    init(communityRepository: CommunityRepository) {
        self.communityRepository = communityRepository
    }

    func execute(groupId: String) -> AsyncThrowingStream<[GroupMessage], Error> {
        return communityRepository.observeMessages(groupId: groupId)
    }
}
