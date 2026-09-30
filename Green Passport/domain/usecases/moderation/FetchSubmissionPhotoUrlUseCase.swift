import Foundation

final class FetchSubmissionPhotoUrlUseCase {
    private let taskSubmissionsRepository: TaskSubmissionsRepository

    init(taskSubmissionsRepository: TaskSubmissionsRepository) {
        self.taskSubmissionsRepository = taskSubmissionsRepository
    }

    func execute(photoPath: String) async -> URL? {
        return try? await taskSubmissionsRepository.photoUrl(photoPath: photoPath)
    }
}
