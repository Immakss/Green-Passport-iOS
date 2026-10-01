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

    func observeWallet(userId: String) -> AsyncThrowingStream<Wallet, Error> {
        let document = FirestoreCollections.users(firestore).document(userId)
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: document)) { snapshot in
            return Wallet(
                availablePoints: snapshot.int(Self.fieldAvailablePoints) ?? 0,
                lifetimeXp: snapshot.int(Self.fieldLifetimeXp) ?? 0,
                streak: Self.streak(from: snapshot)
            )
        }
    }

    private static func streak(from snapshot: DocumentSnapshot) -> Streak? {
        guard let streak = snapshot.get(fieldStreak) as? [String: Any],
              let count = (streak[fieldStreakCount] as? NSNumber)?.intValue,
              let lastDay = streak[fieldStreakLastDay] as? String else {
            return nil
        }
        return Streak(count: count, lastDay: lastDay)
    }
}
