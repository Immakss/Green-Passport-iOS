import Observation

@Observable
final class RootViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let observeUserProfile: ObserveUserProfileUseCase
    @ObservationIgnored private let markOnboardingSeen: MarkOnboardingSeenUseCase
    @ObservationIgnored private var profileTask: Task<Void, Never>?

    private var isOnboardingSeen: Bool
    private var profileStatus: ProfileStatus?

    init(
        observeSession: ObserveSessionUseCase,
        observeUserProfile: ObserveUserProfileUseCase,
        isOnboardingSeen: IsOnboardingSeenUseCase,
        markOnboardingSeen: MarkOnboardingSeenUseCase
    ) {
        self.observeSession = observeSession
        self.observeUserProfile = observeUserProfile
        self.markOnboardingSeen = markOnboardingSeen
        self.isOnboardingSeen = isOnboardingSeen.execute()
    }

    var state: AppStartState {
        guard let profileStatus else {
            return .loading
        }
        guard isOnboardingSeen else {
            return .needsOnboarding
        }
        switch profileStatus {
        case .signedOut:
            return .needsAuth
        case .incomplete:
            return .needsProfile
        case .complete:
            return .ready
        }
    }

    func observe() async {
        for await session in observeSession.execute() {
            profileTask?.cancel()
            guard let session else {
                profileStatus = .signedOut
                continue
            }
            guard !session.isAnonymous else {
                profileStatus = .complete
                continue
            }
            profileTask = Task { [weak self] in
                await self?.observeProfileStatus(userId: session.userId)
            }
        }
        profileTask?.cancel()
    }

    func completeOnboarding() {
        markOnboardingSeen.execute()
        isOnboardingSeen = true
    }

    private func observeProfileStatus(userId: String) async {
        do {
            for try await profile in observeUserProfile.execute(userId: userId) {
                profileStatus = profile == nil ? .incomplete : .complete
            }
        } catch {
            profileStatus = .complete
        }
    }
}
