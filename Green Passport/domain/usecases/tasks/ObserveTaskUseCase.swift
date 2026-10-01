final class ObserveTaskUseCase {
    private let tasksRepository: TasksRepository

    init(tasksRepository: TasksRepository) {
        self.tasksRepository = tasksRepository
    }

    func execute(taskId: String) -> AsyncThrowingStream<EcoTask?, Error> {
        return tasksRepository.observeTask(id: taskId)
    }
}
