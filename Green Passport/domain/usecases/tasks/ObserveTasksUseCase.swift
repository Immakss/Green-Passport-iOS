final class ObserveTasksUseCase {
    private let tasksRepository: TasksRepository

    init(tasksRepository: TasksRepository) {
        self.tasksRepository = tasksRepository
    }

    func execute() -> AsyncThrowingStream<[EcoTask], Error> {
        return tasksRepository.observeTasks()
    }
}
