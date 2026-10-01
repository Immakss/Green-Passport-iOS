enum StreamCombiner {
    static func mapped<Input, Output>(
        _ stream: AsyncThrowingStream<Input, Error>,
        transform: @escaping (Input) -> Output
    ) -> AsyncThrowingStream<Output, Error> {
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await value in stream {
                        continuation.yield(transform(value))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    static func latest<First, Second, Output>(
        _ first: AsyncThrowingStream<First, Error>,
        _ second: AsyncThrowingStream<Second, Error>,
        transform: @escaping (First, Second) -> Output
    ) -> AsyncThrowingStream<Output, Error> {
        return AsyncThrowingStream { continuation in
            let (merged, mergedContinuation) = AsyncThrowingStream<LatestValue<First, Second>, Error>.makeStream()
            let firstTask = Task {
                do {
                    for try await value in first {
                        mergedContinuation.yield(.first(value))
                    }
                } catch {
                    mergedContinuation.finish(throwing: error)
                }
            }
            let secondTask = Task {
                do {
                    for try await value in second {
                        mergedContinuation.yield(.second(value))
                    }
                } catch {
                    mergedContinuation.finish(throwing: error)
                }
            }
            let task = Task {
                var latestFirst: First?
                var latestSecond: Second?
                do {
                    for try await value in merged {
                        switch value {
                        case .first(let value):
                            latestFirst = value
                        case .second(let value):
                            latestSecond = value
                        }
                        if let latestFirst, let latestSecond {
                            continuation.yield(transform(latestFirst, latestSecond))
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
                firstTask.cancel()
                secondTask.cancel()
                mergedContinuation.finish()
            }
        }
    }
}

private enum LatestValue<First, Second> {
    case first(First)
    case second(Second)
}
