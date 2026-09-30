import Foundation

extension EcoEvent {
    private static let checkInOpensBefore: TimeInterval = 2 * 60 * 60
    private static let checkInClosesAfter: TimeInterval = 6 * 60 * 60

    func isCheckInOpen(at date: Date) -> Bool {
        return date >= startAt.addingTimeInterval(-Self.checkInOpensBefore)
            && date <= startAt.addingTimeInterval(Self.checkInClosesAfter)
    }
}
