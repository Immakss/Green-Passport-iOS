import Foundation

extension Calendar {
    nonisolated private static let minskTimeZone = "Europe/Minsk"

    nonisolated static var minsk: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: minskTimeZone) ?? .current
        return calendar
    }
}
