protocol UserProfileRepository {
    func observeProfile(userId: String) -> AsyncThrowingStream<UserProfile?, Error>
    func saveProfile(_ profile: UserProfile) async throws
}
