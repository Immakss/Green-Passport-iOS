import FirebaseFirestore
import Foundation

final class FirestoreFeedbackRepository: FeedbackRepository {
    private static let surveyQueryLimit = 1
    private static let fieldQuestion = "question"
    private static let fieldOptions = "options"
    private static let fieldQuestions = "questions"
    private static let fieldOptionLists = "optionLists"
    private static let fieldIsActive = "isActive"

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func fetchActiveSurvey() async throws -> SurveyQuestion? {
        let snapshot = try await FirestoreCollections.surveys(firestore)
            .whereField(Self.fieldIsActive, isEqualTo: true)
            .limit(to: Self.surveyQueryLimit)
            .getDocuments()
        guard let document = snapshot.documents.first,
              let question = document.localizedString(Self.fieldQuestion, translations: Self.fieldQuestions) else {
            return nil
        }
        let options = document.localizedStrings(Self.fieldOptions, translations: Self.fieldOptionLists)
        guard !options.isEmpty else {
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
}
