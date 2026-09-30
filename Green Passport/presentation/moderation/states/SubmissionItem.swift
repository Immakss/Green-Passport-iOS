import Foundation

struct SubmissionItem: Identifiable, Hashable {
    let submission: TaskSubmission
    let taskTitle: String
    let photoUrl: URL?

    var id: String {
        return submission.id
    }
}
