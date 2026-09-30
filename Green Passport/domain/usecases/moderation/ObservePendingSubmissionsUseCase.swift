import Foundation

final class ObservePendingSubmissionsUseCase {
    private let moderationRepository: ModerationRepository

    init(moderationRepository: ModerationRepository) {
        self.moderationRepository = moderationRepository
    }

    func execute() -> AsyncThrowingStream<[TaskSubmission], Error> {
        return moderationRepository.observePendingSubmissions()
    }
}
