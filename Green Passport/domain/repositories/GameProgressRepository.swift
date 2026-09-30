protocol GameProgressRepository {
    func bestScores() -> [String: Int]
    func recordScore(gameId: String, score: Int)
}
