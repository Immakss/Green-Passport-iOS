import Foundation

nonisolated struct GroupMessage: Identifiable, Hashable, Sendable {
    let id: String
    let senderId: String
    let senderName: String?
    let senderAvatar: AvatarStyle?
    let text: String
    let sentAt: Date
}
