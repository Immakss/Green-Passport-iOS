import FirebaseFirestore

final class FirestoreEventsRepository: EventsRepository {
    private static let fieldTitle = "title"
    private static let fieldDescription = "description"
    private static let fieldLocation = "location"
    private static let fieldTitles = "titles"
    private static let fieldDescriptions = "descriptions"
    private static let fieldLocations = "locations"
    private static let fieldCity = "city"
    private static let fieldStartAt = "startAtEpochMillis"
    private static let fieldImageUrl = "imageUrl"
    private static let fieldRewardPoints = "rewardPoints"
    private static let fieldUserId = "userId"
    private static let fieldEventId = "eventId"
    private static let fieldRegisteredAt = "registeredAtEpochMillis"

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func observeEvents() -> AsyncThrowingStream<[EcoEvent], Error> {
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: FirestoreCollections.events(firestore))) { snapshot in
            return snapshot.documents.compactMap { return Self.event(from: $0) }
        }
    }

    func observeRegisteredEventIds(userId: String) -> AsyncThrowingStream<Set<String>, Error> {
        return observeEventIds(in: FirestoreCollections.eventRegistrations(firestore), userId: userId)
    }

    func observeAttendedEventIds(userId: String) -> AsyncThrowingStream<Set<String>, Error> {
        return observeEventIds(in: FirestoreCollections.eventAttendance(firestore), userId: userId)
    }

    func registerForEvent(userId: String, eventId: String) async throws {
        let data: [String: Any] = [
            Self.fieldUserId: userId,
            Self.fieldEventId: eventId,
            Self.fieldRegisteredAt: EpochMillis.now,
        ]
        try await FirestoreCollections.eventRegistrations(firestore)
            .document("\(userId)_\(eventId)")
            .setData(data)
    }

    private func observeEventIds(in collection: CollectionReference, userId: String) -> AsyncThrowingStream<Set<String>, Error> {
        let query = collection.whereField(Self.fieldUserId, isEqualTo: userId)
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: query)) { snapshot in
            return Set(snapshot.documents.compactMap { return $0.string(Self.fieldEventId) })
        }
    }

    private static func event(from document: DocumentSnapshot) -> EcoEvent? {
        guard let title = document.localizedString(fieldTitle, translations: fieldTitles),
              let description = document.localizedString(fieldDescription, translations: fieldDescriptions),
              let location = document.localizedString(fieldLocation, translations: fieldLocations),
              let city = document.string(fieldCity),
              let startAt = document.date(fieldStartAt) else {
            return nil
        }
        return EcoEvent(
            id: document.documentID,
            title: title,
            description: description,
            location: location,
            city: city,
            startAt: startAt,
            imageUrl: document.string(fieldImageUrl),
            rewardPoints: document.int(fieldRewardPoints) ?? 0
        )
    }
}
