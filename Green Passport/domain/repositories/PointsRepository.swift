protocol PointsRepository {
    func observeWallet(userId: String) -> AsyncThrowingStream<Wallet, Error>
}
