protocol CommunityRepository {
    func observeForumPosts() -> AsyncThrowingStream<[ForumPost], Error>
    func postToForum(authorId: String, authorName: String?, authorAvatar: AvatarStyle?, text: String) async throws
    func observeGroups() -> AsyncThrowingStream<[CommunityGroup], Error>
    func observeGroup(id: String) -> AsyncThrowingStream<CommunityGroup?, Error>
    func createGroup(name: String, creatorId: String) async throws
    func joinGroup(groupId: String, userId: String) async throws
    func leaveGroup(groupId: String, userId: String) async throws
    func findGroup(inviteCode: String) async throws -> CommunityGroup?
    func observeMessages(groupId: String) -> AsyncThrowingStream<[GroupMessage], Error>
    func sendMessage(groupId: String, senderId: String, senderName: String?, senderAvatar: AvatarStyle?, text: String) async throws
    func fetchMembers(ids: [String]) async throws -> [GroupMember]
}
