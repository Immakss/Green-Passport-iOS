final class LatestTask {
    private var task: Task<Void, Never>?

    func run(_ operation: @escaping () async -> Void) {
        task?.cancel()
        task = Task {
            await operation()
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }

    deinit {
        task?.cancel()
    }
}
