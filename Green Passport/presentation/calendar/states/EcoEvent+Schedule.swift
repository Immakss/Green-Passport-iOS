import Foundation

extension EcoEvent {
    var dateText: String {
        return startAt.formatted(.dateTime.day().month(.wide))
    }

    var timeText: String {
        return startAt.formatted(date: .omitted, time: .shortened)
    }

    var scheduleSummary: String {
        return String(localized: .dateTimePlace(dateText, timeText, location))
    }
}
