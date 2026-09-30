protocol EcoTipsRepository {
    func fetchTips() async throws -> [EcoTip]
    func fetchReadTipIds(userId: String) async throws -> Set<String>
}
