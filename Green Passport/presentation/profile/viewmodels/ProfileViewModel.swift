import Observation

@Observable
final class ProfileViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let observeUserProfile: ObserveUserProfileUseCase
    @ObservationIgnored private let observeIsModerator: ObserveIsModeratorUseCase
    @ObservationIgnored private let fetchPointsBalance: FetchPointsBalanceUseCase
    @ObservationIgnored private let fetchLevel: FetchLevelUseCase
    @ObservationIgnored private let signOut: SignOutUseCase
    @ObservationIgnored private let isNotificationsEnabled: IsNotificationsEnabledUseCase
    @ObservationIgnored private let setNotificationsEnabled: SetNotificationsEnabledUseCase
    @ObservationIgnored private let appTheme: AppThemeUseCase
    @ObservationIgnored private let sessionTask = LatestTask()
    @ObservationIgnored private var session: AuthSession?

    private(set) var uiState = ProfileUiState()

    init(
        observeSession: ObserveSessionUseCase,
        observeUserProfile: ObserveUserProfileUseCase,
        observeIsModerator: ObserveIsModeratorUseCase,
        fetchPointsBalance: FetchPointsBalanceUseCase,
        fetchLevel: FetchLevelUseCase,
        signOut: SignOutUseCase,
        isNotificationsEnabled: IsNotificationsEnabledUseCase,
        setNotificationsEnabled: SetNotificationsEnabledUseCase,
        appTheme: AppThemeUseCase
    ) {
        self.observeSession = observeSession
        self.observeUserProfile = observeUserProfile
        self.observeIsModerator = observeIsModerator
        self.fetchPointsBalance = fetchPointsBalance
        self.fetchLevel = fetchLevel
        self.signOut = signOut
        self.isNotificationsEnabled = isNotificationsEnabled
        self.setNotificationsEnabled = setNotificationsEnabled
        self.appTheme = appTheme
        uiState.notificationsEnabled = isNotificationsEnabled.execute()
        uiState.theme = appTheme.current()
    }

    func observe() async {
        for await session in observeSession.execute() {
            guard let session else {
                continue
            }
            self.session = session
            uiState.email = session.email
            uiState.isAnonymous = session.isAnonymous
            sessionTask.run { [weak self] in
                await self?.observeUserData(userId: session.userId)
            }
        }
        sessionTask.cancel()
    }

    func refresh() async {
        guard let session else {
            return
        }
        await loadPoints(userId: session.userId)
    }

    func toggleNotifications(_ isEnabled: Bool) {
        uiState.notificationsEnabled = isEnabled
        Task {
            uiState.notificationsEnabled = await setNotificationsEnabled.execute(isEnabled: isEnabled)
        }
    }

    func selectTheme(_ theme: AppTheme) {
        appTheme.update(theme)
        uiState.theme = theme
    }

    func performSignOut() {
        try? signOut.execute()
    }

    private func observeUserData(userId: String) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadPoints(userId: userId) }
            group.addTask { await self.observeProfile(userId: userId) }
            group.addTask { await self.observeModerator(userId: userId) }
        }
    }

    private func loadPoints(userId: String) async {
        do {
            async let points = fetchPointsBalance.execute(userId: userId)
            async let level = fetchLevel.execute(userId: userId)
            uiState.points = try await points
            uiState.level = try await level
            uiState.hasError = false
        } catch {
            uiState.hasError = true
        }
        uiState.isLoading = false
    }

    private func observeProfile(userId: String) async {
        do {
            for try await profile in observeUserProfile.execute(userId: userId) {
                uiState.profile = profile
            }
        } catch {
            uiState.profile = nil
        }
    }

    private func observeModerator(userId: String) async {
        do {
            for try await isModerator in observeIsModerator.execute(userId: userId) {
                uiState.isModerator = isModerator
            }
        } catch {
            uiState.isModerator = false
        }
    }
}
