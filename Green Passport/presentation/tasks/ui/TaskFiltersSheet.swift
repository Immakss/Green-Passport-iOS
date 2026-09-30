import SwiftUI

struct TaskFiltersSheet: View {
    let initialFilters: TaskFilters
    let profileCity: String?
    let resultCount: (TaskFilters) -> Int
    let onApply: (TaskFilters) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: TaskFilters

    init(
        initialFilters: TaskFilters,
        profileCity: String?,
        resultCount: @escaping (TaskFilters) -> Int,
        onApply: @escaping (TaskFilters) -> Void
    ) {
        self.initialFilters = initialFilters
        self.profileCity = profileCity
        self.resultCount = resultCount
        self.onApply = onApply
        _draft = State(initialValue: initialFilters)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.large) {
                    section(.status) {
                        FlowLayout {
                            ForEach(TaskStatusFilter.allCases, id: \.self) { status in
                                ChoiceCapsule(title: String(localized: status.title), isSelected: draft.status == status) {
                                    draft.status = status
                                }
                            }
                        }
                    }
                    section(.confirmation) {
                        FlowLayout {
                            ForEach(TaskVerification.filterOrder, id: \.self) { verification in
                                ChoiceCapsule(
                                    title: String(localized: verification.title),
                                    isSelected: draft.verifications.contains(verification)
                                ) {
                                    toggle(verification, in: \.verifications)
                                }
                            }
                        }
                    }
                    section(.city) {
                        FlowLayout {
                            cityCapsule(.profileCity)
                            cityCapsule(.all)
                            ForEach(SupportedCities.all.filter { return $0 != profileCity }, id: \.self) { city in
                                cityCapsule(.city(city))
                            }
                        }
                    }
                    section(.category) {
                        FlowLayout {
                            ForEach(TaskCategory.allCases, id: \.self) { category in
                                ChoiceCapsule(
                                    title: String(localized: category.title),
                                    isSelected: draft.categories.contains(category)
                                ) {
                                    toggle(category, in: \.categories)
                                }
                            }
                        }
                    }
                }
                .padding(Spacing.screenHorizontal)
            }
            .background(Palette.screenBackground)
            .safeAreaInset(edge: .bottom) {
                AppButton(title: .showTasksCount(resultCount(draft))) {
                    onApply(draft)
                    dismiss()
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.bottom, Spacing.medium)
            }
            .navigationTitle(Text(.filters))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        draft = TaskFilters()
                    } label: {
                        Text(.reset)
                    }
                    .disabled(draft == TaskFilters())
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
            .animation(.snappy, value: draft)
            .sensoryFeedback(.selection, trigger: draft)
        }
    }

    private func section<Content: View>(
        _ title: LocalizedStringResource,
        @ViewBuilder content: () -> Content
    ) -> some View {
        return VStack(alignment: .leading, spacing: Spacing.small) {
            Text(title)
                .font(.headline)
            content()
        }
    }

    private func cityCapsule(_ filter: TaskCityFilter) -> some View {
        return ChoiceCapsule(title: filter.title(profileCity: profileCity), isSelected: draft.city == filter) {
            draft.city = filter
        }
    }

    private func toggle<Value: Hashable>(_ value: Value, in keyPath: WritableKeyPath<TaskFilters, Set<Value>>) {
        if draft[keyPath: keyPath].contains(value) {
            draft[keyPath: keyPath].remove(value)
        } else {
            draft[keyPath: keyPath].insert(value)
        }
    }
}

#Preview {
    TaskFiltersSheet(initialFilters: TaskFilters(), profileCity: "Минск", resultCount: { _ in return 4 }, onApply: { _ in })
}
