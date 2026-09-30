protocol CommunityRepository {
    func observeForumPosts() -> AsyncThrowingStream<[ForumPost], Error>
    func postToForum(authorId: String, authorName: String?, authorAvatar: AvatarStyle?, text: String) async throws
    func observeGroups() -> AsyncThrowingStream<[CommunityGroup], Error>
    func createGroup(name: String, creatorId: String) async throws
    func joinGroup(groupId: String, userId: String) async throws
}
