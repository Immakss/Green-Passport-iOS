import FirebaseFirestore

final class FirebaseModerationRepository: ModerationRepository {
    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func observeIsAdmin(userId: String) -> AsyncThrowingStream<Bool, Error> {
        let document = FirestoreCollections.admins(firestore).document(userId)
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: document)) { snapshot in
            return snapshot.exists
        }
    }
}
