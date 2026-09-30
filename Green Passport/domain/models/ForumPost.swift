import Foundation

nonisolated struct ForumPost: Identifiable, Hashable, Sendable {
    let id: String
    let authorId: String
    let authorName: String?
    let authorAvatar: AvatarStyle?
    let text: String
    let createdAt: Date
    let isHidden: Bool
    let reportCount: Int
}
