protocol TasksRepository {
    func observeTasks() -> AsyncThrowingStream<[EcoTask], Error>
    func observeTask(id: String) -> AsyncThrowingStream<EcoTask?, Error>
    func observeCompletedTaskIds(userId: String) -> AsyncThrowingStream<Set<String>, Error>
}
