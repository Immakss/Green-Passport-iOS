final class FetchTasksUseCase {
    private let tasksRepository: TasksRepository

    init(tasksRepository: TasksRepository) {
        self.tasksRepository = tasksRepository
    }

    func execute() async throws -> [EcoTask] {
        return try await tasksRepository.fetchTasks()
    }
}
