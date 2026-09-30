struct EventDetailUiState {
    var event: EcoEvent?
    var isRegistered = false
    var isRegistering = false
    var isCheckedIn = false
    var isCheckingIn = false
    var checkInPoints: Int?
    var streakBonus = 0
    var checkInFailure: RewardFailure?
    var isLoading = true
    var hasError = false
}
