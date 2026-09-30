import FirebaseFirestore
import Foundation

final class FirestoreFeedbackRepository: FeedbackRepository {
    private static let surveyQueryLimit = 1
    private static let fieldUserId = "userId"
    private static let fieldType = "type"
    private static let fieldMessage = "message"
    private static let fieldRating = "rating"
    private static let fieldCreatedAt = "createdAtEpochMillis"
    private static let fieldQuestion = "question"
    private static let fieldOptions = "options"
    private static let fieldIsActive = "isActive"
    private static let fieldSurveyId = "surveyId"
    private static let fieldOptionIndex = "optionIndex"

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func submitFeedback(_ entry: FeedbackEntry) async throws {
        let data: [String: Any] = [
            Self.fieldUserId: entry.userId,
            Self.fieldType: entry.type.rawValue,
            Self.fieldMessage: entry.message,
            Self.fieldRating: entry.rating ?? NSNull(),
            Self.fieldCreatedAt: EpochMillis.now,
        ]
        _ = try await FirestoreCollections.feedback(firestore).addDocument(data: data)
    }

    func fetchActiveSurvey() async throws -> SurveyQuestion? {
        let snapshot = try await FirestoreCollections.surveys(firestore)
            .whereField(Self.fieldIsActive, isEqualTo: true)
            .limit(to: Self.surveyQueryLimit)
            .getDocuments()
        guard let document = snapshot.documents.first,
              let question = document.string(Self.fieldQuestion),
              let options = document.get(Self.fieldOptions) as? [String] else {
            return nil
        }
        return SurveyQuestion(id: document.documentID, question: question, options: options)
    }

    func hasAnsweredSurvey(userId: String, surveyId: String) async throws -> Bool {
        return try await FirestoreCollections.surveyAnswers(firestore)
            .document("\(userId)_\(surveyId)")
            .getDocument()
            .exists
    }

    func submitSurveyAnswer(userId: String, surveyId: String, optionIndex: Int) async throws {
        let data: [String: Any] = [
            Self.fieldUserId: userId,
            Self.fieldSurveyId: surveyId,
            Self.fieldOptionIndex: optionIndex,
        ]
        try await FirestoreCollections.surveyAnswers(firestore).document("\(userId)_\(surveyId)").setData(data)
    }
}
