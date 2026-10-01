extension AsyncThrowingStream where Failure == Error {
    func firstValue() async throws -> Element? {
        for try await value in self {
            return value
        }
        return nil
    }
}
