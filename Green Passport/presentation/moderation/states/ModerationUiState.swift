struct ModerationUiState {
    var isLoading = true
    var isModerator = false
    var submissions: [SubmissionItem] = []
    var flaggedPosts: [ForumPost] = []
    var processingIds: Set<String> = []
    var hasActionError = false
}
