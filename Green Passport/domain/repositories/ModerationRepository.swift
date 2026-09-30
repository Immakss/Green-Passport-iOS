protocol ModerationRepository {
    func observeIsAdmin(userId: String) -> AsyncThrowingStream<Bool, Error>
}
