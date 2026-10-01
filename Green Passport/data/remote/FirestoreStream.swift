import FirebaseFirestore

enum FirestoreStream {
    private static let emptyCacheGracePeriod = Duration.seconds(5)

    static func snapshots(of query: Query) -> AsyncThrowingStream<QuerySnapshot, Error> {
        return AsyncThrowingStream { continuation in
            let emptyCacheFallback = CacheFallbackTask()
            let registration = query.addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
                if let error {
                    continuation.finish(throwing: error)
                    return
                }
                guard let snapshot else {
                    return
                }
                if snapshot.metadata.isFromCache && snapshot.isEmpty {
                    emptyCacheFallback.run {
                        try? await Task.sleep(for: emptyCacheGracePeriod)
                        if !Task.isCancelled {
                            continuation.yield(snapshot)
                        }
                    }
                    return
                }
                emptyCacheFallback.cancel()
                continuation.yield(snapshot)
            }
            continuation.onTermination = { _ in
                registration.remove()
                Task { @MainActor in
                    emptyCacheFallback.cancel()
                }
            }
        }
    }

    static func snapshots(of document: DocumentReference) -> AsyncThrowingStream<DocumentSnapshot, Error> {
        return AsyncThrowingStream { continuation in
            let missingCacheFallback = CacheFallbackTask()
            let registration = document.addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
                if let error {
                    continuation.finish(throwing: error)
                    return
                }
                guard let snapshot else {
                    return
                }
                if snapshot.metadata.isFromCache && !snapshot.exists {
                    missingCacheFallback.run {
                        try? await Task.sleep(for: emptyCacheGracePeriod)
                        if !Task.isCancelled {
                            continuation.yield(snapshot)
                        }
                    }
                    return
                }
                missingCacheFallback.cancel()
                continuation.yield(snapshot)
            }
            continuation.onTermination = { _ in
                registration.remove()
                Task { @MainActor in
                    missingCacheFallback.cancel()
                }
            }
        }
    }

    static func mapped<Input, Output>(
        _ stream: AsyncThrowingStream<Input, Error>,
        transform: @escaping (Input) -> Output
    ) -> AsyncThrowingStream<Output, Error> {
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await value in stream {
                        continuation.yield(transform(value))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

private final class CacheFallbackTask {
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
}
