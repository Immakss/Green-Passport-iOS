final class ObserveCompletedTaskIdsUseCase {
    private let tasksRepository: TasksRepository

    init(tasksRepository: TasksRepository) {
        self.tasksRepository = tasksRepository
    }

    func execute(userId: String) -> AsyncThrowingStream<Set<String>, Error> {
        return tasksRepository.observeCompletedTaskIds(userId: userId)
    }
}
