import Foundation

nonisolated enum EpochMillis {
    private static let millisPerSecond: Double = 1000

    static var now: Int64 {
        return from(Date())
    }

    static func from(_ date: Date) -> Int64 {
        return Int64(date.timeIntervalSince1970 * millisPerSecond)
    }

    static func date(from millis: Int64) -> Date {
        return Date(timeIntervalSince1970: Double(millis) / millisPerSecond)
    }
}
