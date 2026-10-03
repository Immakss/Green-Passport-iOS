import Foundation

extension Streak {
    nonisolated private static let dayFormat = "yyyy-MM-dd"
    nonisolated private static let posixLocale = "en_US_POSIX"

    nonisolated static func dayKey(of date: Date) -> String {
        return dayFormatter().string(from: date)
    }

    nonisolated static func date(ofDayKey key: String) -> Date? {
        return dayFormatter().date(from: key)
    }

    nonisolated func currentCount(at date: Date) -> Int {
        let yesterday = Calendar.minsk.date(byAdding: .day, value: -1, to: date) ?? date
        return lastDay == Self.dayKey(of: date) || lastDay == Self.dayKey(of: yesterday) ? count : 0
    }

    nonisolated func isCounted(on date: Date) -> Bool {
        return lastDay == Self.dayKey(of: date)
    }

    private nonisolated static func dayFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: posixLocale)
        formatter.timeZone = Calendar.minsk.timeZone
        formatter.dateFormat = dayFormat
        return formatter
    }
}
