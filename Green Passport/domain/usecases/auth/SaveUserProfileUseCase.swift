final class SaveUserProfileUseCase {
    private let userProfileRepository: UserProfileRepository
    private let textModerator: TextModerator

    init(userProfileRepository: UserProfileRepository, textModerator: TextModerator) {
        self.userProfileRepository = userProfileRepository
        self.textModerator = textModerator
    }

    func execute(profile: UserProfile) async throws {
        guard textModerator.isAllowed(profile.firstName), textModerator.isAllowed(profile.lastName) else {
            throw ContentRejectedError()
        }
        try await userProfileRepository.saveProfile(profile)
    }
}
