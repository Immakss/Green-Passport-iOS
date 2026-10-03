import Foundation

final class UpdateStreakReminderUseCase {
    private static let reminderHour = 20

    private let reminderScheduler: ReminderScheduler

    init(reminderScheduler: ReminderScheduler) {
        self.reminderScheduler = reminderScheduler
    }

    func execute(streak: Streak?, now: Date) async {
        guard let streak,
              streak.currentCount(at: now) > 0,
              !streak.isCounted(on: now),
              let fireDate = Calendar.minsk.date(bySettingHour: Self.reminderHour, minute: 0, second: 0, of: now),
              fireDate > now else {
            reminderScheduler.cancelStreakReminder()
            return
        }
        await reminderScheduler.scheduleStreakReminder(streakDays: streak.count, at: fireDate)
    }
}
