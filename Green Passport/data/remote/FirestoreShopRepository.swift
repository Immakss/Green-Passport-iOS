import FirebaseFirestore
import Foundation

final class FirestoreShopRepository: ShopRepository {
    private static let fieldTitle = "title"
    private static let fieldPartnerName = "partnerName"
    private static let fieldTitles = "titles"
    private static let fieldPartnerNames = "partnerNames"
    private static let fieldPointsCost = "pointsCost"
    private static let fieldImageUrl = "imageUrl"
    private static let fieldIsActive = "isActive"
    private static let fieldUserId = "userId"
    private static let fieldRewardId = "rewardId"
    private static let fieldRedeemedAt = "redeemedAtEpochMillis"
    private static let fieldExpiresAt = "expiresAtEpochMillis"
    private static let fieldCode = "code"
    private static let fieldUsedAt = "usedAtEpochMillis"
    private static let scanUrlInfoKey = "CouponScanURL"
    private static let couponIdParameter = "id"
    private static let codeParameter = "code"

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func observeRewards() -> AsyncThrowingStream<[Reward], Error> {
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: FirestoreCollections.shopItems(firestore))) { snapshot in
            return snapshot.documents.compactMap { document in
                guard let title = document.localizedString(Self.fieldTitle, translations: Self.fieldTitles),
                      let partnerName = document.localizedString(Self.fieldPartnerName, translations: Self.fieldPartnerNames),
                      let pointsCost = document.int(Self.fieldPointsCost) else {
                    return nil
                }
                return Reward(
                    id: document.documentID,
                    title: title,
                    partnerName: partnerName,
                    pointsCost: pointsCost,
                    imageUrl: document.string(Self.fieldImageUrl),
                    isActive: document.bool(Self.fieldIsActive) ?? true
                )
            }
        }
    }

    func observePurchases(userId: String) -> AsyncThrowingStream<[Coupon], Error> {
        let query = FirestoreCollections.purchases(firestore).whereField(Self.fieldUserId, isEqualTo: userId)
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: query)) { snapshot in
            return snapshot.documents.compactMap { return Self.coupon(from: $0) }
        }
    }

    func observePurchase(id: String) -> AsyncThrowingStream<Coupon?, Error> {
        let document = FirestoreCollections.purchases(firestore).document(id)
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: document)) { snapshot in
            return Self.coupon(from: snapshot)
        }
    }

    func scanUrl(for coupon: Coupon) -> URL? {
        guard let code = coupon.code,
              let base = Bundle.main.object(forInfoDictionaryKey: Self.scanUrlInfoKey) as? String,
              var components = URLComponents(string: base) else {
            return nil
        }
        components.queryItems = [
            URLQueryItem(name: Self.couponIdParameter, value: coupon.id),
            URLQueryItem(name: Self.codeParameter, value: code),
        ]
        return components.url
    }

    private static func coupon(from document: DocumentSnapshot) -> Coupon? {
        guard let rewardId = document.string(fieldRewardId),
              let redeemedAt = document.date(fieldRedeemedAt) else {
            return nil
        }
        return Coupon(
            id: document.documentID,
            rewardId: rewardId,
            code: document.string(fieldCode),
            redeemedAt: redeemedAt,
            expiresAt: document.date(fieldExpiresAt),
            usedAt: document.date(fieldUsedAt)
        )
    }
}
