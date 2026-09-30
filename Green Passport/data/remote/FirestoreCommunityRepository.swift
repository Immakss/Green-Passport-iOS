import FirebaseFirestore

final class FirestoreCommunityRepository: CommunityRepository {
    private static let fieldName = "name"
    private static let fieldMemberIds = "memberIds"

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func observeGroups() -> AsyncThrowingStream<[CommunityGroup], Error> {
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: FirestoreCollections.groups(firestore))) { snapshot in
            return snapshot.documents.compactMap { document in
                guard let name = document.string(Self.fieldName) else {
                    return nil
                }
                return CommunityGroup(id: document.documentID, name: name, memberIds: document.strings(Self.fieldMemberIds))
            }
        }
    }
}
