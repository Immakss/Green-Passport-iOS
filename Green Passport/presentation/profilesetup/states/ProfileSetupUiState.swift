struct ProfileSetupUiState {
    var isPrefilled = false
    var userId: String?
    var step: ProfileSetupStep = .name
    var firstName = ""
    var lastName = ""
    var firstNameError: NameError?
    var lastNameError: NameError?
    var city: String?
    var isCityMissing = false
    var interests: Set<TaskCategory> = []
    var isInterestsMissing = false
    var avatar: AvatarStyle = .lime
    var isSaving = false
    var hasSaveError = false
    var isSaved = false
}
