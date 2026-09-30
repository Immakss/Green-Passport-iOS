final class ObserveForumPostsUseCase {
    private let communityRepository: CommunityRepository

    init(communityRepository: CommunityRepository) {
        self.communityRepository = communityRepository
    }

    func execute() -> AsyncThrowingStream<[ForumPost], Error> {
        return communityRepository.observeForumPosts()
    }
}
