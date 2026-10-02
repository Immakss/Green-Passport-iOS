import Foundation

extension Streak {
    private static let bonusPeriod = 7
    private static let daysInWeek = 7

    static func summary(of streak: Streak?, at now: Date) -> StreakSummary {
        let calendar = Calendar.minsk
        let days = streak?.currentCount(at: now) ?? 0
        let isTodayCounted = streak?.isCounted(on: now) ?? false
        let activeKeys = activeDayKeys(streak: streak, days: days, calendar: calendar)
        let todayKey = dayKey(of: now)
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let week = (0..<daysInWeek).compactMap { offset -> StreakWeekDay? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: weekStart) else {
                return nil
            }
            let key = dayKey(of: date)
            return StreakWeekDay(date: date, isActive: activeKeys.contains(key), isToday: key == todayKey)
        }
        return StreakSummary(
            days: days,
            isTodayCounted: isTodayCounted,
            daysUntilBonus: daysUntilBonus(days: days, isTodayCounted: isTodayCounted),
            week: week
        )
    }

    private static func activeDayKeys(streak: Streak?, days: Int, calendar: Calendar) -> Set<String> {
        guard let streak, days > 0, let lastDate = date(ofDayKey: streak.lastDay) else {
            return []
        }
        return Set((0..<days).compactMap { offset in
            return calendar.date(byAdding: .day, value: -offset, to: lastDate).map { return dayKey(of: $0) }
        })
    }

    private static func daysUntilBonus(days: Int, isTodayCounted: Bool) -> Int {
        let nextBonusDay = (days / bonusPeriod + 1) * bonusPeriod
        let todayNumber = isTodayCounted ? days : days + 1
        return nextBonusDay - todayNumber
    }
}
