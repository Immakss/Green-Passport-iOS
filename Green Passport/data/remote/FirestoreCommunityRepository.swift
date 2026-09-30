import FirebaseFirestore

final class FirestoreCommunityRepository: CommunityRepository {
    private static let fieldAuthorId = "authorId"
    private static let fieldAuthorName = "authorName"
    private static let fieldAuthorAvatar = "authorAvatar"
    private static let fieldText = "text"
    private static let fieldCreatedAt = "createdAtEpochMillis"
    private static let fieldHidden = "hidden"
    private static let fieldReportCount = "reportCount"
    private static let fieldName = "name"
    private static let fieldMemberIds = "memberIds"

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func observeForumPosts() -> AsyncThrowingStream<[ForumPost], Error> {
        let query = FirestoreCollections.posts(firestore).order(by: Self.fieldCreatedAt, descending: true)
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: query)) { snapshot in
            return snapshot.documents.compactMap(Self.post(from:)).filter { return !$0.isHidden }
        }
    }

    func postToForum(authorId: String, authorName: String?, authorAvatar: AvatarStyle?, text: String) async throws {
        let data: [String: Any] = [
            Self.fieldAuthorId: authorId,
            Self.fieldAuthorName: authorName ?? NSNull(),
            Self.fieldAuthorAvatar: authorAvatar?.rawValue ?? NSNull(),
            Self.fieldText: text,
            Self.fieldCreatedAt: EpochMillis.now,
        ]
        _ = try await FirestoreCollections.posts(firestore).addDocument(data: data)
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

    func createGroup(name: String, creatorId: String) async throws {
        let data: [String: Any] = [Self.fieldName: name, Self.fieldMemberIds: [creatorId]]
        _ = try await FirestoreCollections.groups(firestore).addDocument(data: data)
    }

    func joinGroup(groupId: String, userId: String) async throws {
        try await FirestoreCollections.groups(firestore)
            .document(groupId)
            .updateData([Self.fieldMemberIds: FieldValue.arrayUnion([userId])])
    }

    static func post(from document: DocumentSnapshot) -> ForumPost? {
        guard let authorId = document.string(fieldAuthorId),
              let text = document.string(fieldText),
              let createdAt = document.date(fieldCreatedAt) else {
            return nil
        }
        return ForumPost(
            id: document.documentID,
            authorId: authorId,
            authorName: document.string(fieldAuthorName),
            authorAvatar: document.string(fieldAuthorAvatar).flatMap(AvatarStyle.init(rawValue:)),
            text: text,
            createdAt: createdAt,
            isHidden: document.bool(fieldHidden) ?? false,
            reportCount: document.int(fieldReportCount) ?? 0
        )
    }
}
