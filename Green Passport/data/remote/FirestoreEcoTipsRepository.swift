import FirebaseFirestore

final class FirestoreEcoTipsRepository: EcoTipsRepository {
    private static let fieldCategory = "category"
    private static let fieldTitle = "title"
    private static let fieldBody = "body"
    private static let fieldTitles = "titles"
    private static let fieldBodies = "bodies"
    private static let fieldImageUrl = "imageUrl"
    private static let fieldMediaUrl = "mediaUrl"
    private static let fieldIsDailyTip = "isDailyTip"
    private static let fieldRewardPoints = "rewardPoints"
    private static let fieldRewardXp = "rewardXp"
    private static let fieldIsActive = "isActive"
    private static let fieldUserId = "userId"
    private static let fieldTipId = "tipId"

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func observeTips() -> AsyncThrowingStream<[EcoTip], Error> {
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: FirestoreCollections.ecoTips(firestore))) { snapshot in
            return snapshot.documents.compactMap { document in
                guard let category = document.string(Self.fieldCategory).flatMap(EcoTipCategory.init(rawValue:)),
                      let title = document.localizedString(Self.fieldTitle, translations: Self.fieldTitles),
                      let body = document.localizedString(Self.fieldBody, translations: Self.fieldBodies) else {
                    return nil
                }
                return EcoTip(
                    id: document.documentID,
                    category: category,
                    title: title,
                    body: body,
                    imageUrl: document.string(Self.fieldImageUrl),
                    mediaUrl: document.string(Self.fieldMediaUrl),
                    isDailyTip: document.bool(Self.fieldIsDailyTip) ?? false,
                    rewardPoints: document.int(Self.fieldRewardPoints) ?? 0,
                    rewardXp: document.int(Self.fieldRewardXp) ?? 0,
                    isActive: document.bool(Self.fieldIsActive) ?? true
                )
            }
        }
    }

    func observeReadTipIds(userId: String) -> AsyncThrowingStream<Set<String>, Error> {
        let query = FirestoreCollections.ecoTipReads(firestore).whereField(Self.fieldUserId, isEqualTo: userId)
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: query)) { snapshot in
            return Set(snapshot.documents.compactMap { return $0.string(Self.fieldTipId) })
        }
    }
}
