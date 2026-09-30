import SwiftUI

struct TaskRowsCard: View {
    private static let mascotSize: CGFloat = 34

    let tasks: [EcoTask]
    let onTask: (EcoTask) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(tasks) { task in
                Button {
                    onTask(task)
                } label: {
                    ListRow(title: task.title, subtitle: task.city.isEmpty ? nil : task.city) {
                        MascotImage(size: Self.mascotSize)
                    } trailing: {
                        PointsBadge(points: task.rewardPoints)
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color(.tertiaryLabel))
                    }
                    .padding(.horizontal, Spacing.medium)
                }
                .buttonStyle(.plain)
                if task.id != tasks.last?.id {
                    Divider()
                        .padding(.leading, Spacing.medium + Self.mascotSize + Spacing.small)
                }
            }
        }
        .padding(.vertical, Spacing.xxSmall)
        .background(Palette.cardBackground, in: .rect(cornerRadius: CornerRadius.large, style: .continuous))
    }
}

#Preview {
    TaskRowsCard(tasks: EcoTask.placeholders(count: 3), onTask: { _ in })
        .padding()
        .background(Palette.screenBackground)
}
