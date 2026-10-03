struct GroupsUiState {
    var groups: [CommunityGroup] = []
    var draftName = ""
    var isLoading = true
    var hasError = false
    var isCreating = false
    var isNameRejected = false
    var joiningGroupId: String?
    var currentUserId: String?
    var inviteCodeDraft = ""
    var isJoiningByCode = false
    var isInviteCodeNotFound = false
}
