import SwiftUI
import UIKit

struct EventCalendarView: UIViewRepresentable {
    let eventDays: Set<DateComponents>
    let selectedDay: DateComponents
    let onSelectDay: (DateComponents) -> Void

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = .current
        calendarView.locale = .current
        calendarView.tintColor = UIColor(Palette.forest)
        calendarView.delegate = context.coordinator
        calendarView.visibleDateComponents = selectedDay
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        selection.selectedDate = selectedDay
        calendarView.selectionBehavior = selection
        calendarView.setContentHuggingPriority(.required, for: .vertical)
        calendarView.setContentCompressionResistancePriority(.required, for: .vertical)
        return calendarView
    }

    func updateUIView(_ calendarView: UICalendarView, context: Context) {
        let previousDays = context.coordinator.eventDays
        context.coordinator.parent = self
        context.coordinator.eventDays = eventDays
        let changedDays = previousDays.symmetricDifference(eventDays)
        if !changedDays.isEmpty {
            calendarView.reloadDecorations(forDateComponents: Array(changedDays), animated: true)
        }
        if let selection = calendarView.selectionBehavior as? UICalendarSelectionSingleDate,
           selection.selectedDate?.dayOnly != selectedDay {
            selection.setSelected(selectedDay, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: EventCalendarView
        var eventDays: Set<DateComponents>

        init(parent: EventCalendarView) {
            self.parent = parent
            self.eventDays = parent.eventDays
        }

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard eventDays.contains(dateComponents.dayOnly) else {
                return nil
            }
            return .default(color: UIColor(Palette.forest), size: .medium)
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let dateComponents else {
                return
            }
            parent.onSelectDay(dateComponents.dayOnly)
        }
    }
}
