import FirebaseFirestore

final class FirestorePointsRepository: PointsRepository {
    private static let fieldAvailablePoints = "availablePoints"
    private static let fieldLifetimeXp = "lifetimeXp"

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func fetchAvailablePoints(userId: String) async throws -> Int {
        let snapshot = try await FirestoreCollections.users(firestore).document(userId).getDocument()
        return snapshot.int(Self.fieldAvailablePoints) ?? 0
    }

    func fetchLifetimeXp(userId: String) async throws -> Int {
        let snapshot = try await FirestoreCollections.users(firestore).document(userId).getDocument()
        return snapshot.int(Self.fieldLifetimeXp) ?? 0
    }
}
