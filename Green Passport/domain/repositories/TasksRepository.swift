protocol TasksRepository {
    func fetchTasks() async throws -> [EcoTask]
    func fetchCompletedTaskIds(userId: String) async throws -> Set<String>
}
