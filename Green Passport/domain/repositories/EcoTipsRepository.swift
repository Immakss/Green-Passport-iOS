protocol EcoTipsRepository {
    func observeTips() -> AsyncThrowingStream<[EcoTip], Error>
    func observeReadTipIds(userId: String) -> AsyncThrowingStream<Set<String>, Error>
}
