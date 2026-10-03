import Foundation

final class PostToForumUseCase {
    private let communityRepository: CommunityRepository
    private let userProfileRepository: UserProfileRepository
    private let textModerator: TextModerator

    init(
        communityRepository: CommunityRepository,
        userProfileRepository: UserProfileRepository,
        textModerator: TextModerator
    ) {
        self.communityRepository = communityRepository
        self.userProfileRepository = userProfileRepository
        self.textModerator = textModerator
    }

    func execute(authorId: String, text: String) async throws {
        guard textModerator.isAllowed(text) else {
            throw ContentRejectedError()
        }
        let profile = await firstProfile(userId: authorId)
        try await communityRepository.postToForum(
            authorId: authorId,
            authorName: profile?.displayName,
            authorAvatar: profile?.avatar,
            text: text
        )
    }

    private func firstProfile(userId: String) async -> UserProfile? {
        do {
            for try await profile in userProfileRepository.observeProfile(userId: userId) {
                return profile
            }
        } catch {
            return nil
        }
        return nil
    }
}
