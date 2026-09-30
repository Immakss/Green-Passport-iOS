import Foundation

extension Streak {
    private static let serverTimeZone = "Europe/Minsk"
    private static let dayFormat = "yyyy-MM-dd"
    private static let dayLength: TimeInterval = 24 * 60 * 60

    func currentCount(at date: Date) -> Int {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: Self.serverTimeZone)
        formatter.dateFormat = Self.dayFormat
        let today = formatter.string(from: date)
        let yesterday = formatter.string(from: date.addingTimeInterval(-Self.dayLength))
        return lastDay == today || lastDay == yesterday ? count : 0
    }
}
