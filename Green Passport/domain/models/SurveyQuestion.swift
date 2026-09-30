nonisolated struct SurveyQuestion: Identifiable, Hashable, Sendable {
    let id: String
    let question: String
    let options: [String]
}
