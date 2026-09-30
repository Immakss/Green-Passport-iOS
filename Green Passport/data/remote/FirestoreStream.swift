import FirebaseFirestore

enum FirestoreStream {
    static func snapshots(of query: Query) -> AsyncThrowingStream<QuerySnapshot, Error> {
        return AsyncThrowingStream { continuation in
            let registration = query.addSnapshotListener { snapshot, error in
                if let error {
                    continuation.finish(throwing: error)
                } else if let snapshot {
                    continuation.yield(snapshot)
                }
            }
            continuation.onTermination = { _ in
                registration.remove()
            }
        }
    }

    static func snapshots(of document: DocumentReference) -> AsyncThrowingStream<DocumentSnapshot, Error> {
        return AsyncThrowingStream { continuation in
            let registration = document.addSnapshotListener { snapshot, error in
                if let error {
                    continuation.finish(throwing: error)
                } else if let snapshot {
                    continuation.yield(snapshot)
                }
            }
            continuation.onTermination = { _ in
                registration.remove()
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
