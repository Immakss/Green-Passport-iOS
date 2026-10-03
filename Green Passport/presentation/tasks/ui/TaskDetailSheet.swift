import SwiftUI

extension View {
    func taskDetailSheet(
        item: Binding<TaskSheetItem?>,
        container: AppDIContainer,
        onDismiss: @escaping () -> Void = {}
    ) -> some View {
        return sheet(item: item, onDismiss: onDismiss) { selected in
            TaskDetailRoute(taskId: selected.id, container: container)
        }
    }
}
