import SwiftUI
import UIKit

struct EventCalendarView: UIViewRepresentable {
    let eventCounts: [DateComponents: Int]
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
        return calendarView
    }

    func updateUIView(_ calendarView: UICalendarView, context: Context) {
        let previousCounts = context.coordinator.eventCounts
        context.coordinator.parent = self
        context.coordinator.eventCounts = eventCounts
        let changedDays = Set(previousCounts.keys).union(eventCounts.keys).filter { day in
            return previousCounts[day] != eventCounts[day]
        }
        if !changedDays.isEmpty {
            calendarView.reloadDecorations(forDateComponents: Array(changedDays), animated: true)
        }
        if let selection = calendarView.selectionBehavior as? UICalendarSelectionSingleDate,
           selection.selectedDate?.dayOnly != selectedDay {
            selection.setSelected(selectedDay, animated: true)
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UICalendarView, context: Context) -> CGSize? {
        guard let width = proposal.width else {
            return nil
        }
        let height = uiView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        return CGSize(width: width, height: height)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: EventCalendarView
        var eventCounts: [DateComponents: Int]

        init(parent: EventCalendarView) {
            self.parent = parent
            self.eventCounts = parent.eventCounts
        }

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let count = eventCounts[dateComponents.dayOnly] else {
                return nil
            }
            return .customView {
                return EventCountBadge.make(count: count)
            }
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let dateComponents else {
                return
            }
            parent.onSelectDay(dateComponents.dayOnly)
        }
    }
}
