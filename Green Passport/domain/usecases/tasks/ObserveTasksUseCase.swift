final class ObserveTasksUseCase {
    private let tasksRepository: TasksRepository
    private let includesArchived: Bool

    init(tasksRepository: TasksRepository, includesArchived: Bool = false) {
        self.tasksRepository = tasksRepository
        self.includesArchived = includesArchived
    }

    func execute() -> AsyncThrowingStream<[EcoTask], Error> {
        let includesArchived = includesArchived
        return StreamCombiner.mapped(tasksRepository.observeTasks()) { tasks in
            return includesArchived ? tasks : tasks.filter { return $0.isActive }
        }
    }
}
