import FirebaseFirestore

final class FirestoreEcoTipsRepository: EcoTipsRepository {
    private static let fieldCategory = "category"
    private static let fieldTitle = "title"
    private static let fieldBody = "body"
    private static let fieldMediaUrl = "mediaUrl"
    private static let fieldIsDailyTip = "isDailyTip"
    private static let fieldRewardPoints = "rewardPoints"
    private static let fieldRewardXp = "rewardXp"
    private static let fieldUserId = "userId"
    private static let fieldTipId = "tipId"

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func fetchTips() async throws -> [EcoTip] {
        let snapshot = try await FirestoreCollections.ecoTips(firestore).getDocuments()
        return snapshot.documents.compactMap { document in
            guard let category = document.string(Self.fieldCategory).flatMap(EcoTipCategory.init(rawValue:)),
                  let title = document.string(Self.fieldTitle),
                  let body = document.string(Self.fieldBody) else {
                return nil
            }
            return EcoTip(
                id: document.documentID,
                category: category,
                title: title,
                body: body,
                mediaUrl: document.string(Self.fieldMediaUrl),
                isDailyTip: document.bool(Self.fieldIsDailyTip) ?? false,
                rewardPoints: document.int(Self.fieldRewardPoints) ?? 0,
                rewardXp: document.int(Self.fieldRewardXp) ?? 0
            )
        }
    }

    func fetchReadTipIds(userId: String) async throws -> Set<String> {
        let snapshot = try await FirestoreCollections.ecoTipReads(firestore)
            .whereField(Self.fieldUserId, isEqualTo: userId)
            .getDocuments()
        return Set(snapshot.documents.compactMap { return $0.string(Self.fieldTipId) })
    }
}
