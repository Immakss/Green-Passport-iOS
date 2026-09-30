struct PuzzleCard: Identifiable, Hashable {
    let id: Int
    let symbolIndex: Int
    var isFaceUp = false
    var isMatched = false
}
