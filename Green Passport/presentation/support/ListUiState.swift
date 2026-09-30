enum ListUiState<Item> {
    case loading
    case success(data: [Item])
    case error
}
