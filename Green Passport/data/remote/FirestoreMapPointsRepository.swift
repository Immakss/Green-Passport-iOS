import FirebaseFirestore
import Foundation

final class FirestoreMapPointsRepository: MapPointsRepository {
    private static let fieldName = "name"
    private static let fieldType = "type"
    private static let fieldAddress = "address"
    private static let fieldCity = "city"
    private static let fieldLatitude = "latitude"
    private static let fieldLongitude = "longitude"

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func observePoints() -> AsyncThrowingStream<[MapPoint], Error> {
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: FirestoreCollections.mapPoints(firestore))) { snapshot in
            return snapshot.documents.compactMap { document in
                guard let name = document.string(Self.fieldName),
                      let type = document.string(Self.fieldType).flatMap(MapPointType.init(rawValue:)),
                      let address = document.string(Self.fieldAddress),
                      let city = document.string(Self.fieldCity),
                      let latitude = (document.get(Self.fieldLatitude) as? NSNumber)?.doubleValue,
                      let longitude = (document.get(Self.fieldLongitude) as? NSNumber)?.doubleValue else {
                    return nil
                }
                return MapPoint(
                    id: document.documentID,
                    name: name,
                    type: type,
                    address: address,
                    city: city,
                    latitude: latitude,
                    longitude: longitude
                )
            }
        }
    }
}
