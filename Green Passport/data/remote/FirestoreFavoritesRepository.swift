import FirebaseFirestore

final class FirestoreFavoritesRepository: FavoritesRepository {
    private static let fieldUserId = "userId"
    private static let fieldTaskId = "taskId"
    private static let fieldTipId = "tipId"

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func observeFavoriteTaskIds(userId: String) -> AsyncThrowingStream<Set<String>, Error> {
        let query = FirestoreCollections.favoriteTasks(firestore).whereField(Self.fieldUserId, isEqualTo: userId)
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: query)) { snapshot in
            return Set(snapshot.documents.compactMap { return $0.string(Self.fieldTaskId) })
        }
    }

    func setTaskFavorite(userId: String, taskId: String, isFavorite: Bool) async throws {
        let document = FirestoreCollections.favoriteTasks(firestore).document("\(userId)_\(taskId)")
        if isFavorite {
            try await document.setData([Self.fieldUserId: userId, Self.fieldTaskId: taskId])
        } else {
            try await document.delete()
        }
    }

    func observeBookmarkedTipIds(userId: String) -> AsyncThrowingStream<Set<String>, Error> {
        let query = FirestoreCollections.bookmarkedTips(firestore).whereField(Self.fieldUserId, isEqualTo: userId)
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: query)) { snapshot in
            return Set(snapshot.documents.compactMap { return $0.string(Self.fieldTipId) })
        }
    }

    func setTipBookmarked(userId: String, tipId: String, isBookmarked: Bool) async throws {
        let document = FirestoreCollections.bookmarkedTips(firestore).document("\(userId)_\(tipId)")
        if isBookmarked {
            try await document.setData([Self.fieldUserId: userId, Self.fieldTipId: tipId])
        } else {
            try await document.delete()
        }
    }
}
