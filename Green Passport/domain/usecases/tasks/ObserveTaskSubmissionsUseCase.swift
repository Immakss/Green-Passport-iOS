final class ObserveTaskSubmissionsUseCase {
    private let taskSubmissionsRepository: TaskSubmissionsRepository

    init(taskSubmissionsRepository: TaskSubmissionsRepository) {
        self.taskSubmissionsRepository = taskSubmissionsRepository
    }

    func execute(userId: String) -> AsyncThrowingStream<[TaskSubmission], Error> {
        return taskSubmissionsRepository.observeUserSubmissions(userId: userId)
    }
}
