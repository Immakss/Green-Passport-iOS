final class FetchCompletedTaskIdsUseCase {
    private let tasksRepository: TasksRepository

    init(tasksRepository: TasksRepository) {
        self.tasksRepository = tasksRepository
    }

    func execute(userId: String) async throws -> Set<String> {
        return try await tasksRepository.fetchCompletedTaskIds(userId: userId)
    }
}
