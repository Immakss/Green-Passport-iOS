import Foundation

nonisolated struct TaskSubmission: Identifiable, Hashable, Sendable {
    let id: String
    let taskId: String
    let userId: String
    let userName: String?
    let photoPath: String
    let status: SubmissionStatus
    let rejectionReason: String?
    let createdAt: Date
}
