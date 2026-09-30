protocol CommunityRepository {
    func observeGroups() -> AsyncThrowingStream<[CommunityGroup], Error>
}
