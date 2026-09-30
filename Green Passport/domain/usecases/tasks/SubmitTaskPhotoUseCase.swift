import Foundation

final class SubmitTaskPhotoUseCase {
    private let photoCompressor: PhotoCompressor
    private let userProfileRepository: UserProfileRepository
    private let taskSubmissionsRepository: TaskSubmissionsRepository

    init(
        photoCompressor: PhotoCompressor,
        userProfileRepository: UserProfileRepository,
        taskSubmissionsRepository: TaskSubmissionsRepository
    ) {
        self.photoCompressor = photoCompressor
        self.userProfileRepository = userProfileRepository
        self.taskSubmissionsRepository = taskSubmissionsRepository
    }

    func execute(userId: String, taskId: String, imageData: Data) async throws -> TaskSubmission {
        let jpegData = try photoCompressor.compress(imageData)
        let profile = await firstProfile(userId: userId)
        let userName = profile.map { return "\($0.firstName) \($0.lastName)".trimmingCharacters(in: .whitespaces) }
        return try await taskSubmissionsRepository.submitPhoto(
            userId: userId,
            userName: userName,
            taskId: taskId,
            jpegData: jpegData
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
