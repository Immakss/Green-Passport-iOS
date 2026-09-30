import Foundation

protocol TaskSubmissionsRepository {
    func observeUserSubmissions(userId: String) -> AsyncThrowingStream<[TaskSubmission], Error>
    func submitPhoto(userId: String, userName: String?, taskId: String, jpegData: Data) async throws -> TaskSubmission
    func photoUrl(photoPath: String) async throws -> URL
}
