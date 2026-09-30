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
}
