import FirebaseFirestore
import Foundation

final class FirestorePointsRepository: PointsRepository {
    private static let fieldAvailablePoints = "availablePoints"
    private static let fieldLifetimeXp = "lifetimeXp"
    private static let fieldStreak = "streak"
    private static let fieldStreakCount = "count"
    private static let fieldStreakLastDay = "lastDay"

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func fetchAvailablePoints(userId: String) async throws -> Int {
        let snapshot = try await FirestoreCollections.users(firestore).document(userId).getDocument()
        return snapshot.int(Self.fieldAvailablePoints) ?? 0
    }

    func fetchStreak(userId: String) async throws -> Streak? {
        let snapshot = try await FirestoreCollections.users(firestore).document(userId).getDocument()
        guard let streak = snapshot.get(Self.fieldStreak) as? [String: Any],
              let count = (streak[Self.fieldStreakCount] as? NSNumber)?.intValue,
              let lastDay = streak[Self.fieldStreakLastDay] as? String else {
            return nil
        }
        return Streak(count: count, lastDay: lastDay)
    }

    func fetchLifetimeXp(userId: String) async throws -> Int {
        let snapshot = try await FirestoreCollections.users(firestore).document(userId).getDocument()
        return snapshot.int(Self.fieldLifetimeXp) ?? 0
    }
}
