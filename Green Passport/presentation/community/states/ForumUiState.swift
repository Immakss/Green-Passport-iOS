struct ForumUiState {
    var posts: [ForumPost] = []
    var draft = ""
    var isLoading = true
    var hasError = false
    var isPosting = false
    var isTextRejected = false
    var currentUserId: String?
    var reportedPostIds: Set<String> = []
}
