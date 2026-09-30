enum TasksListUserAction {
    case filterSelected(TaskFilter)
    case favoriteToggled(EcoTask)
    case taskSelected(EcoTask)
    case retry
}
