enum TasksListUserAction {
    case filtersChanged(TaskFilters)
    case favoriteToggled(EcoTask)
    case taskSelected(EcoTask)
    case retry
}
