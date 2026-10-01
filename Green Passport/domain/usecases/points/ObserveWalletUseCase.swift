final class ObserveWalletUseCase {
    private let pointsRepository: PointsRepository

    init(pointsRepository: PointsRepository) {
        self.pointsRepository = pointsRepository
    }

    func execute(userId: String) -> AsyncThrowingStream<Wallet, Error> {
        return pointsRepository.observeWallet(userId: userId)
    }
}
