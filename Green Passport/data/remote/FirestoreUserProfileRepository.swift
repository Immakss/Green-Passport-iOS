import FirebaseFirestore
import Foundation

final class FirestoreUserProfileRepository: UserProfileRepository {
    private static let fieldFirstName = "firstName"
    private static let fieldLastName = "lastName"
    private static let fieldCity = "city"
    private static let fieldInterests = "interests"
    private static let fieldAvatar = "avatar"
    private static let fieldProfileCompletedAt = "profileCompletedAt"

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func observeProfile(userId: String) -> AsyncThrowingStream<UserProfile?, Error> {
        let document = FirestoreCollections.users(firestore).document(userId)
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await snapshot in FirestoreStream.snapshots(of: document) {
                        if snapshot.metadata.isFromCache && !snapshot.exists {
                            continue
                        }
                        continuation.yield(Self.profile(from: snapshot))
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

    func saveProfile(_ profile: UserProfile) async throws {
        let data: [String: Any] = [
            Self.fieldFirstName: profile.firstName,
            Self.fieldLastName: profile.lastName,
            Self.fieldCity: profile.city,
            Self.fieldInterests: profile.interests.map(\.rawValue).sorted(),
            Self.fieldAvatar: profile.avatar.rawValue,
            Self.fieldProfileCompletedAt: EpochMillis.now,
        ]
        try await FirestoreCollections.users(firestore).document(profile.userId).setData(data, merge: true)
    }

    private static func profile(from snapshot: DocumentSnapshot) -> UserProfile? {
        guard snapshot.exists,
              snapshot.get(fieldProfileCompletedAt) != nil,
              let firstName = snapshot.get(fieldFirstName) as? String else {
            return nil
        }
        let interestNames = snapshot.get(fieldInterests) as? [String] ?? []
        let avatarName = snapshot.get(fieldAvatar) as? String ?? ""
        return UserProfile(
            userId: snapshot.documentID,
            firstName: firstName,
            lastName: snapshot.get(fieldLastName) as? String ?? "",
            city: snapshot.get(fieldCity) as? String ?? "",
            interests: Set(interestNames.compactMap(TaskCategory.init(rawValue:))),
            avatar: AvatarStyle(rawValue: avatarName) ?? .lime
        )
    }
}
