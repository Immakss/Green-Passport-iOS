import FirebaseFirestore

final class FirestoreShopRepository: ShopRepository {
    private static let fieldTitle = "title"
    private static let fieldPartnerName = "partnerName"
    private static let fieldPointsCost = "pointsCost"
    private static let fieldUserId = "userId"
    private static let fieldRewardId = "rewardId"
    private static let fieldRedeemedAt = "redeemedAtEpochMillis"
    private static let fieldExpiresAt = "expiresAtEpochMillis"
    private static let fieldCode = "code"
    private static let fieldUsedAt = "usedAtEpochMillis"

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func fetchRewards() async throws -> [Reward] {
        let snapshot = try await FirestoreCollections.shopItems(firestore).getDocuments()
        return snapshot.documents.compactMap { document in
            guard let title = document.string(Self.fieldTitle),
                  let partnerName = document.string(Self.fieldPartnerName),
                  let pointsCost = document.int(Self.fieldPointsCost) else {
                return nil
            }
            return Reward(id: document.documentID, title: title, partnerName: partnerName, pointsCost: pointsCost)
        }
    }

    func fetchPurchases(userId: String) async throws -> [Coupon] {
        let snapshot = try await FirestoreCollections.purchases(firestore)
            .whereField(Self.fieldUserId, isEqualTo: userId)
            .getDocuments()
        return snapshot.documents.compactMap { document in
            guard let rewardId = document.string(Self.fieldRewardId),
                  let redeemedAt = document.date(Self.fieldRedeemedAt) else {
                return nil
            }
            return Coupon(
                id: document.documentID,
                rewardId: rewardId,
                code: document.string(Self.fieldCode),
                redeemedAt: redeemedAt,
                expiresAt: document.date(Self.fieldExpiresAt),
                usedAt: document.date(Self.fieldUsedAt)
            )
        }
    }
}
