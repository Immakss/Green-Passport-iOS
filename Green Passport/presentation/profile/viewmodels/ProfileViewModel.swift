import Observation

@Observable
final class ProfileViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let observeUserProfile: ObserveUserProfileUseCase
    @ObservationIgnored private let observeIsModerator: ObserveIsModeratorUseCase
    @ObservationIgnored private let observeWallet: ObserveWalletUseCase
    @ObservationIgnored private let signOut: SignOutUseCase
    @ObservationIgnored private let isNotificationsEnabled: IsNotificationsEnabledUseCase
    @ObservationIgnored private let setNotificationsEnabled: SetNotificationsEnabledUseCase
    @ObservationIgnored private let notificationPermission: NotificationPermission
    @ObservationIgnored private let appTheme: AppThemeUseCase
    @ObservationIgnored private let sessionTask = LatestTask()
    @ObservationIgnored private var session: AuthSession?

    private(set) var uiState = ProfileUiState()

    init(
        observeSession: ObserveSessionUseCase,
        observeUserProfile: ObserveUserProfileUseCase,
        observeIsModerator: ObserveIsModeratorUseCase,
        observeWallet: ObserveWalletUseCase,
        signOut: SignOutUseCase,
        isNotificationsEnabled: IsNotificationsEnabledUseCase,
        setNotificationsEnabled: SetNotificationsEnabledUseCase,
        notificationPermission: NotificationPermission,
        appTheme: AppThemeUseCase
    ) {
        self.observeSession = observeSession
        self.observeUserProfile = observeUserProfile
        self.observeIsModerator = observeIsModerator
        self.observeWallet = observeWallet
        self.signOut = signOut
        self.isNotificationsEnabled = isNotificationsEnabled
        self.setNotificationsEnabled = setNotificationsEnabled
        self.notificationPermission = notificationPermission
        self.appTheme = appTheme
        uiState.theme = appTheme.current()
    }

    func observe() async {
        uiState.notificationsEnabled = await notificationPermission.isAuthorized() && isNotificationsEnabled.execute()
        for await session in observeSession.execute() {
            guard let session else {
                continue
            }
            self.session = session
            uiState.email = session.email
            uiState.isAnonymous = session.isAnonymous
            start(userId: session.userId)
        }
        sessionTask.cancel()
    }

    func retry() {
        guard let session else {
            return
        }
        uiState.isLoading = true
        uiState.hasError = false
        start(userId: session.userId)
    }

    func toggleNotifications(_ isEnabled: Bool) {
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

    private func start(userId: String) {
        sessionTask.run { [weak self] in
            await self?.observeUserData(userId: userId)
        }
    }

    private func observeUserData(userId: String) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.observeWalletData(userId: userId) }
            group.addTask { await self.observeProfile(userId: userId) }
            group.addTask { await self.observeModerator(userId: userId) }
        }
    }

    private func observeWalletData(userId: String) async {
        do {
            for try await wallet in observeWallet.execute(userId: userId) {
                uiState.points = wallet.availablePoints
                uiState.level = wallet.level
                uiState.isLoading = false
                uiState.hasError = false
            }
        } catch {
            guard !Task.isCancelled else {
                return
            }
            uiState.isLoading = false
            uiState.hasError = true
        }
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
