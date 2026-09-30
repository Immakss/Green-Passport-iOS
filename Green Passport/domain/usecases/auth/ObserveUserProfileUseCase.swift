final class ObserveUserProfileUseCase {
    private let userProfileRepository: UserProfileRepository

    init(userProfileRepository: UserProfileRepository) {
        self.userProfileRepository = userProfileRepository
    }

    func execute(userId: String) -> AsyncThrowingStream<UserProfile?, Error> {
        return userProfileRepository.observeProfile(userId: userId)
    }
}
